
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConversationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _conversaciones({
    String? materiaId,
  }) {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    final usuarioRef = _db
        .collection('usuarios')
        .doc(usuario.uid);

    if (materiaId == null) {
      return usuarioRef.collection('conversaciones');
    }

    return usuarioRef
        .collection('materias')
        .doc(materiaId)
        .collection('conversaciones');
  }

  Future<String> crearConversacion(
    String titulo, {
    String? materiaId,
  }) async {
    final documento = await _conversaciones(
      materiaId: materiaId,
    ).add({
      'titulo': titulo,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
      'mensajes': [],
    });

    return documento.id;
  }

  Future<void> guardarMensaje({
    required String conversacionId,
    required String texto,
    required bool esUsuario,
    String? materiaId,
  }) async {
    await _conversaciones(
      materiaId: materiaId,
    ).doc(conversacionId).update({
      'mensajes': FieldValue.arrayUnion([
        {
          'texto': texto,
          'esUsuario': esUsuario,
          'fecha': Timestamp.now(),
        }
      ]),
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      obtenerConversaciones({
    String? materiaId,
  }) {
    return _conversaciones(
      materiaId: materiaId,
    )
        .orderBy('fechaActualizacion', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> obtenerMensajes(
    String conversacionId, {
    String? materiaId,
  }) async {
    final documento = await _conversaciones(
      materiaId: materiaId,
    ).doc(conversacionId).get();

    if (!documento.exists) return [];

    final datos = documento.data();

    if (datos == null) return [];

    return List<Map<String, dynamic>>.from(
      (datos['mensajes'] ?? []).map(
        (mensaje) => Map<String, dynamic>.from(mensaje),
      ),
    );
  }

  Future<void> eliminarConversacion(
    String conversacionId, {
    String? materiaId,
  }) async {
    await _conversaciones(
      materiaId: materiaId,
    ).doc(conversacionId).delete();
  }
}
