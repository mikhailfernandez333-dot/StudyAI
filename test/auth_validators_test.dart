
import 'package:flutter_test/flutter_test.dart';
import 'package:studyai/utils/auth_validators.dart';

void main() {
  group('Pruebas de validación del registro', () {

    test('1. Debe rechazar campos vacíos', () {
      // Arrange
      const nombre = '';
      const correo = '';
      const password = '';

      // Act
      final resultado = AuthValidators.validarRegistro(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, 'Completa todos los campos.');
    });

    test('2. Debe rechazar un correo inválido', () {
      // Arrange
      const nombre = 'Michael';
      const correo = 'michaelcorreo';
      const password = '123456';

      // Act
      final resultado = AuthValidators.validarRegistro(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      // Assert
      expect(
        resultado,
        'Ingresa un correo electrónico válido.',
      );
    });

    test('3. Debe rechazar una contraseña corta', () {
      // Arrange
      const nombre = 'Michael';
      const correo = 'michael@gmail.com';
      const password = '123';

      // Act
      final resultado = AuthValidators.validarRegistro(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      // Assert
      expect(
        resultado,
        'La contraseña debe tener al menos 6 caracteres.',
      );
    });

    test('4. Debe aceptar un registro válido', () {
      // Arrange
      const nombre = 'Michael';
      const correo = 'michael@gmail.com';
      const password = '123456';

      // Act
      final resultado = AuthValidators.validarRegistro(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, isNull);
    });

    test('5. Debe rechazar un nombre vacío', () {
      // Arrange
      const nombre = '   ';
      const correo = 'michael@gmail.com';
      const password = '123456';

      // Act
      final resultado = AuthValidators.validarRegistro(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, 'Completa todos los campos.');
    });

  });
}
