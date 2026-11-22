
class AuthValidators {
  static String? validarRegistro({
    required String nombre,
    required String correo,
    required String password,
  }) {
    if (nombre.trim().isEmpty ||
        correo.trim().isEmpty ||
        password.isEmpty) {
      return 'Completa todos los campos.';
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      return 'Ingresa un correo electrónico válido.';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    return null;
  }
}
