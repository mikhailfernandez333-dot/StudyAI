
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizResultService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> guardarResultado({
    required String tema,
    String? materiaNombre,
    required String dificultad,
    required int totalPreguntas,
    required int respuestasCorrectas,
    required int porcentaje,
    required String tipo,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    await _db
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('resultados_cuestionarios')
        .add({
      'tema': tema,
      'materiaNombre': materiaNombre,
      'dificultad': dificultad,
      'totalPreguntas': totalPreguntas,
      'respuestasCorrectas': respuestasCorrectas,
      'respuestasIncorrectas':
          totalPreguntas - respuestasCorrectas,
      'porcentaje': porcentaje,
      'tipo': tipo,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerResultados() {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    return _db
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('resultados_cuestionarios')
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}
