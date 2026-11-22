
import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF171D3B),
              Color(0xFF0B1020),
              Color(0xFF17102D),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7865FF),
                        Color(0xFF3949AB),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'StudyAI',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu asistente inteligente de estudio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB7B9D0),
                  ),
                ),
                const SizedBox(height: 55),
                const Icon(
                  Icons.auto_awesome,
                  size: 45,
                  color: Color(0xFF9B8CFF),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aprende de una manera diferente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Pregunta, descubre y resuelve tus dudas '
                  'con ayuda de la inteligencia artificial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFFB7B9D0),
                  ),
                ),
                const SizedBox(height: 45),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7865FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Comenzar ahora',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tu aprendizaje comienza aquí',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777D9B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
