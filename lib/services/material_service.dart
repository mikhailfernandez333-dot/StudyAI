
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final String _bucket = 'materiales-studyai';
  String get uidUsuario => _uid;

  // Obtener el UID del usuario autenticado
  String get _uid {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('Debes iniciar sesión para continuar.');
    }

    return usuario.uid;
  }

  // Subir un PDF o una imagen
  Future<String> subirMaterial({
    required String materiaId,
    required String nombreArchivo,
    required Uint8List archivo,
    required String tipoContenido,
  }) async {
    try {
      final nombreSeguro = nombreArchivo.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );

      final ruta =
          '$_uid/$materiaId/${DateTime.now().millisecondsSinceEpoch}_$nombreSeguro';

      await _supabase.storage.from(_bucket).uploadBinary(
        ruta,
        archivo,
        fileOptions: FileOptions(
          contentType: tipoContenido,
          upsert: false,
        ),
      );

      return ruta;
    } catch (e) {
      throw Exception('No se pudo subir el archivo: $e');
    }
  }

  // Consultar los materiales de una materia
  Future<List<FileObject>> listarMateriales({
    required String materiaId,
  }) async {
    try {
      final ruta = '$_uid/$materiaId';

      return await _supabase.storage.from(_bucket).list(
        path: ruta,
      );
    } catch (e) {
      throw Exception('No se pudieron consultar los archivos: $e');
    }
  }

  // Obtener un enlace temporal para abrir un archivo privado
  Future<String> obtenerUrl({
    required String ruta,
  }) async {
    try {
      return await _supabase.storage.from(_bucket).createSignedUrl(
        ruta,
        3600,
      );
    } catch (e) {
      throw Exception('No se pudo abrir el archivo: $e');
    }
  }

  // Eliminar un archivo
  Future<void> eliminarMaterial({
    required String ruta,
  }) async {
    try {
      await _supabase.storage.from(_bucket).remove([ruta]);
    } catch (e) {
      throw Exception('No se pudo eliminar el archivo: $e');
    }
  }
}
