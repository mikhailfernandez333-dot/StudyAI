
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get usuarioActual => _auth.currentUser;

  // Registrar usuario
  Future<UserCredential> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: correo.trim(),
      password: password,
    );

    final usuario = credencial.user!;

    await usuario.updateDisplayName(nombre.trim());

    await _db.collection('usuarios').doc(usuario.uid).set({
      'nombre': nombre.trim(),
      'correo': correo.trim(),
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return credencial;
  }

  // Iniciar sesión
  Future<UserCredential> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: correo.trim(),
      password: password,
    );
  }

  // Recuperar contraseña
  Future<void> recuperarPassword(String correo) async {
    await _auth.sendPasswordResetEmail(
      email: correo.trim(),
    );
  }

  // Iniciar sesión con Google
  Future<UserCredential> iniciarConGoogle() async {
    await _googleSignIn.initialize();

    final cuenta = await _googleSignIn.authenticate();

    final idToken = cuenta.authentication.idToken;

    if (idToken == null) {
      throw Exception('No se pudo obtener el token de Google.');
    }

    final credencialGoogle = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final resultado = await _auth.signInWithCredential(
      credencialGoogle,
    );

    final usuario = resultado.user!;

    await _db.collection('usuarios').doc(usuario.uid).set({
      'nombre': usuario.displayName ?? '',
      'correo': usuario.email ?? '',
      'fechaRegistro': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return resultado;
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
