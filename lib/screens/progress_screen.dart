
import 'package:flutter/material.dart';
import '../services/quiz_result_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const Color fondo = Color(0xFF0B1020);
  static const Color tarjeta = Color(0xFF191F38);
  static const Color morado = Color(0xFF9B8CFF);

  @override
  Widget build(BuildContext context) {
    final servicio = QuizResultService();

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        title: const Text('Mi progreso'),
      ),
      body: StreamBuilder(
        stream: servicio.obtenerResultados(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el progreso: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: morado),
            );
          }

          final resultados = snapshot.data?.docs ?? [];

          if (resultados.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: morado,
                      size: 65,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Todavía no tienes resultados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Completa tus cuestionarios para comenzar '
                      'a registrar tu progreso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          }

          final notas = resultados.map((doc) {
            return (doc.data()['porcentaje'] as num).toDouble();
          }).toList();

          final total = notas.length;
          final promedio =
              notas.reduce((a, b) => a + b) / total;
          final mejor = notas.reduce((a, b) => a > b ? a : b);

          int correctas = 0;
          int incorrectas = 0;

          for (final doc in resultados) {
            final datos = doc.data();
            correctas +=
                (datos['respuestasCorrectas'] as num).toInt();
            incorrectas +=
                (datos['respuestasIncorrectas'] as num).toInt();
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7865FF),
                      Color(0xFF4936B8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tu rendimiento general',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${promedio.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Promedio de calificaciones',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _estadistica(
                    Icons.quiz_rounded,
                    'Cuestionarios',
                    '$total',
                    const Color(0xFFFFB74D),
                  ),
                  _estadistica(
                    Icons.emoji_events_rounded,
                    'Mejor nota',
                    '${mejor.round()}%',
                    Colors.amber,
                  ),
                  _estadistica(
                    Icons.check_circle_rounded,
                    'Correctas',
                    '$correctas',
                    Colors.greenAccent,
                  ),
                  _estadistica(
                    Icons.cancel_rounded,
                    'Incorrectas',
                    '$incorrectas',
                    Colors.redAccent,
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Text(
                'Historial de cuestionarios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              ...resultados.map((doc) {
                final datos = doc.data();
                final nota =
                    (datos['porcentaje'] as num).toInt();

                final fecha = datos['fecha'] as Timestamp?;

                final fechaTexto = fecha == null
                    ? 'Fecha pendiente'
                    : '${fecha.toDate().day.toString().padLeft(2, '0')}/'
                      '${fecha.toDate().month.toString().padLeft(2, '0')}/'
                      '${fecha.toDate().year}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tarjeta,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            morado.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: morado,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              datos['tema'] ?? 'Cuestionario',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${datos['dificultad']} • $fechaTexto',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${datos['respuestasCorrectas']} '
                              'de ${datos['totalPreguntas']} correctas',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$nota%',
                        style: TextStyle(
                          color: nota >= 70
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _estadistica(
    IconData icono,
    String titulo,
    String valor,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
