
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_screen.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'subjects_screen.dart';
import 'apuntes_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> cerrarSesion(BuildContext context) async {
    try {
      await AuthService().cerrarSesion();

      if (!context.mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    final nombre = usuario?.displayName?.isNotEmpty == true
        ? usuario!.displayName!
        : 'Estudiante';

    final inicial = nombre.isNotEmpty
        ? nombre[0].toUpperCase()
        : 'E';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.psychology_alt_rounded,
              color: Color(0xFF9B8CFF),
              size: 29,
            ),
            const SizedBox(width: 9),
            const Text(
              'StudyAI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => cerrarSesion(context),
            tooltip: 'Cerrar sesión',
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO DEL ESTUDIANTE
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, $nombre!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        '¿Qué vamos a aprender hoy?',
                        style: TextStyle(
                          color: Color(0xFFB7B9D0),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9B8CFF),
                        Color(0xFF4936B8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // TARJETA PRINCIPAL DE STUDYAI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF806CFF),
                    Color(0xFF4936B8),
                    Color(0xFF302477),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7865FF).withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white70,
                        size: 25,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Tu aprendizaje,\nimpulsado por IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Resuelve dudas, comprende nuevos temas '
                    'y aprende a tu propio ritmo con Gemini.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_rounded, size: 19),
                      label: const Text(
                        'Comenzar a estudiar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4936B8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SECCIÓN DE HERRAMIENTAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Herramientas de estudio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubjectsScreen(),
                        ),
                      );
                    },
                    child: herramienta(
                      icono: Icons.menu_book_rounded,
                      titulo: 'Materias',
                      descripcion: 'Organiza tus estudios',
                      color: const Color(0xFF9B8CFF),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizScreen(),
        ),
      );
    },
    child: herramienta(
      icono: Icons.quiz_rounded,
      titulo: 'Cuestionarios',
      descripcion: 'Pon a prueba lo aprendido',
      color: const Color(0xFFFFB74D),
    ),
  ),
),
              ],
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ApuntesScreen(),
        ),
      );
    },
    child: herramienta(
      icono: Icons.note_alt_rounded,
      titulo: 'Apuntes',
      descripcion: 'Consulta tus documentos',
      color: const Color(0xFF64B5F6),
    ),
  ),
),
                const SizedBox(width: 13),
                
Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProgressScreen(),
        ),
      );
    },
    child: herramienta(
      icono: Icons.bar_chart_rounded,
      titulo: 'Progreso',
      descripcion: 'Revisa tu aprendizaje',
      color: const Color(0xFF66BB6A),
    ),
  ),
),

              ],
            ),

            const SizedBox(height: 28),

            // HISTORIAL DE CONVERSACIONES
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF191F38),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 9,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7865FF).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Color(0xFFB8A9FF),
                    size: 25,
                  ),
                ),
                title: const Text(
                  'Mis conversaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'Continúa donde te quedaste',
                  style: TextStyle(
                    color: Color(0xFFB7B9D0),
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white54,
                  size: 17,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            const Center(
              child: Text(
                'STUDYAI • APRENDE A TU PROPIO RITMO',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETAS DE HERRAMIENTAS
  Widget herramienta({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    return Container(
      height: 153,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191F38),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icono,
              color: color,
              size: 25,
            ),
          ),

          const Spacer(),

          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB7B9D0),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
