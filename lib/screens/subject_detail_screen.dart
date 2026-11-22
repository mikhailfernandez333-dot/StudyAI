
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'history_screen.dart';
import 'quiz_screen.dart';
import 'materials_screen.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String materiaId;
  final String nombre;
  final String descripcion;

  const SubjectDetailScreen({
    super.key,
    required this.materiaId,
    required this.nombre,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: Text(nombre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7865FF),
                    Color(0xFF4936B8),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion.isEmpty
                        ? 'Organiza y mejora tus conocimientos en esta materia.'
                        : descripcion,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Herramientas de estudio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            herramienta(
              context,
              icono: Icons.psychology_alt_rounded,
              titulo: 'Consultar con Gemini',
              descripcion: 'Resuelve tus dudas sobre $nombre.',
              color: const Color(0xFF7865FF),
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      materiaId: materiaId,
                      materiaNombre: nombre,
                      materiaDescripcion: descripcion,
                    ),
                  ),
                );
              },
            ),

            herramienta(
              context,
              icono: Icons.history_rounded,
              titulo: 'Mis conversaciones',
              descripcion: 'Continúa tus conversaciones anteriores.',
              color: const Color(0xFF9B8CFF),
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(
                      materiaId: materiaId,
                      materiaNombre: nombre,
                      materiaDescripcion: descripcion,
                    ),
                  ),
                );
              },
            ),

            herramienta(
              context,
              icono: Icons.note_alt_rounded,
              titulo: 'Mis apuntes',
              descripcion: 'Guarda y consulta tus notas.',
              color: const Color(0xFF2196F3),
              accion: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MaterialsScreen(
        materiaId: materiaId,
        materiaNombre: nombre,
      ),
    ),
  );
},
            ),

            herramienta(
              context,
              icono: Icons.quiz_rounded,
              titulo: 'Cuestionarios',
              descripcion: 'Practica lo que has aprendido con Gemini.',
              color: const Color(0xFFFF9800),
              accion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      materiaNombre: nombre,
                      materiaDescripcion: descripcion,
                    ),
                  ),
                );
              },
            ),

            herramienta(
              context,
              icono: Icons.bar_chart_rounded,
              titulo: 'Mi progreso',
              descripcion: 'Consulta tu avance en esta materia.',
              color: const Color(0xFF4CAF50),
              accion: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: seguimiento.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget herramienta(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback accion,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF191F38),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(icono, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            descripcion,
            style: const TextStyle(
              color: Color(0xFFB7B9D0),
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white54,
          size: 17,
        ),
        onTap: accion,
      ),
    );
  }
}
