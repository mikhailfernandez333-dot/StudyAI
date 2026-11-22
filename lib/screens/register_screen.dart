
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool ocultarPassword = true;
  bool cargando = false;

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> crearCuenta() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text;

    if (nombre.isEmpty || correo.isEmpty || password.isEmpty) {
      mostrarMensaje('Completa todos los campos.');
      return;
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      mostrarMensaje('Ingresa un correo electrónico válido.');
      return;
    }

    if (password.length < 6) {
      mostrarMensaje('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await authService.registrar(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF191F38),
            icon: const Icon(
              Icons.check_circle,
              color: Color(0xFF8B78FF),
              size: 55,
            ),
            title: const Text(
              '¡Cuenta creada!',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Tu cuenta de StudyAI se creó correctamente. '
              'Ya puedes iniciar sesión.',
              style: TextStyle(color: Color(0xFFB7B9D0)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Continuar',
                  style: TextStyle(color: Color(0xFF9B8CFF)),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case 'email-already-in-use':
          mensaje = 'Este correo ya tiene una cuenta registrada.';
          break;
        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido.';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es demasiado débil.';
          break;
        case 'network-request-failed':
          mensaje = 'Comprueba tu conexión a Internet.';
          break;
        default:
          mensaje = e.message ?? 'No se pudo crear la cuenta.';
      }

      mostrarMensaje(mensaje);

    } catch (e) {
      mostrarMensaje('Ocurrió un error al crear la cuenta.');
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF39304F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Color(0xFF8B78FF),
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Únete a StudyAI y comienza a aprender',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFB7B9D0)),
                ),
              ),

              const SizedBox(height: 35),

              const Text('Nombre completo'),
              const SizedBox(height: 10),

              campo(
                controller: nombreController,
                hint: 'Tu nombre',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              const Text('Correo electrónico'),
              const SizedBox(height: 10),

              campo(
                controller: correoController,
                hint: 'ejemplo@correo.com',
                icon: Icons.email_outlined,
                tipo: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              const Text('Contraseña'),
              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Crea una contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarPassword = !ocultarPassword;
                      });
                    },
                    icon: Icon(
                      ocultarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF191F38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: cargando ? null : crearCuenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7865FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF51458F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: cargando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Crear mi cuenta',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Ya tengo una cuenta',
                    style: TextStyle(color: Color(0xFF9B8CFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFF191F38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
