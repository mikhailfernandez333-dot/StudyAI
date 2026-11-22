
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool ocultarPassword = true;
  bool cargando = false;

  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final password = passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos.'),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      await authService.iniciarSesion(
  correo: correo,
  password: password,
);

      if (!mounted) return;

      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const HomeScreen(),
  ),
);
    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe una cuenta con ese correo.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          mensaje = 'El correo o la contraseña son incorrectos.';
          break;
        case 'invalid-email':
          mensaje = 'El correo electrónico no es válido.';
          break;
        case 'user-disabled':
          mensaje = 'Esta cuenta ha sido deshabilitada.';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos. Inténtalo más tarde.';
          break;
        default:
          mensaje = 'Error al iniciar sesión: ${e.message ?? e.code}';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
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

              const SizedBox(height: 35),

              const Center(
                child: Icon(
                  Icons.psychology_alt_rounded,
                  size: 75,
                  color: Color(0xFF8B78FF),
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Inicia sesión para continuar aprendiendo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFB7B9D0)),
                ),
              ),

              const SizedBox(height: 40),

              const Text('Correo electrónico'),

              const SizedBox(height: 10),

              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: const Color(0xFF191F38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text('Contraseña'),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
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

              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Próximamente: recuperar contraseña',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Color(0xFF9B8CFF)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: cargando ? null : iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7865FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: cargando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'O continúa con',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Próximamente conectaremos Google',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text('Continuar con Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Color(0xFF9B8CFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
