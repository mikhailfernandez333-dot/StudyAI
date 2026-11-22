
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _materias {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return _db
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('materias');
  }

  // Registrar una materia
  Future<void> crearMateria({
    required String nombre,
    required String descripcion,
  }) async {
    await _materias.add({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  // Obtener las materias del estudiante
  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerMaterias() {
    return _materias
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }

  // Editar una materia
  Future<void> actualizarMateria({
    required String materiaId,
    required String nombre,
    required String descripcion,
  }) async {
    await _materias.doc(materiaId).update({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
    });
  }

  // Eliminar una materia
  Future<void> eliminarMateria(String materiaId) async {
    await _materias.doc(materiaId).delete();
  }
}
