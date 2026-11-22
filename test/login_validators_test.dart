
import 'package:flutter_test/flutter_test.dart';
import 'package:studyai/utils/auth_validators.dart';

void main() {
  group('Pruebas de validación del inicio de sesión', () {

    test('6. Debe rechazar el correo vacío', () {
      // Arrange
      const correo = '';
      const password = '123456';

      // Act
      final resultado = AuthValidators.validarLogin(
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, 'Completa todos los campos.');
    });

    test('7. Debe rechazar la contraseña vacía', () {
      // Arrange
      const correo = 'usuario@gmail.com';
      const password = '';

      // Act
      final resultado = AuthValidators.validarLogin(
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, 'Completa todos los campos.');
    });

    test('8. Debe rechazar ambos campos vacíos', () {
      // Arrange
      const correo = '';
      const password = '';

      // Act
      final resultado = AuthValidators.validarLogin(
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, 'Completa todos los campos.');
    });

    test('9. Debe aceptar correo y contraseña ingresados', () {
      // Arrange
      const correo = 'usuario@gmail.com';
      const password = '123456';

      // Act
      final resultado = AuthValidators.validarLogin(
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, isNull);
    });

    test('10. Debe aceptar espacios al inicio y final del correo', () {
      // Arrange
      const correo = ' usuario@gmail.com ';
      const password = '123456';

      // Act
      final resultado = AuthValidators.validarLogin(
        correo: correo,
        password: password,
      );

      // Assert
      expect(resultado, isNull);
    });

  });
}
