
import 'package:flutter/material.dart';

import '../services/conversation_service.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatelessWidget {
  final String? materiaId;
  final String? materiaNombre;
  final String? materiaDescripcion;

  HistoryScreen({
    super.key,
    this.materiaId,
    this.materiaNombre,
    this.materiaDescripcion,
  });

  final ConversationService conversationService =
      ConversationService();

  @override
  Widget build(BuildContext context) {
    final esHistorialMateria = materiaId != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: Text(
          esHistorialMateria
              ? 'Conversaciones de $materiaNombre'
              : 'Mis conversaciones',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: conversationService.obtenerConversaciones(
          materiaId: materiaId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar el historial.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9B8CFF),
              ),
            );
          }

          final conversaciones = snapshot.data?.docs ?? [];

          if (conversaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history,
                    size: 65,
                    color: Color(0xFF9B8CFF),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    esHistorialMateria
                        ? 'Todavía no tienes chats de $materiaNombre'
                        : 'Todavía no tienes conversaciones',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus conversaciones aparecerán aquí.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: conversaciones.length,
            itemBuilder: (context, index) {
              final documento = conversaciones[index];
              final datos = documento.data();

              final titulo =
                  datos['titulo'] ?? 'Conversación sin título';

              final fecha = datos['fechaActualizacion'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF191F38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF30265F),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xFFB7A9FF),
                    ),
                  ),
                  title: Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    fecha == null
                        ? 'Fecha no disponible'
                        : fecha.toDate().toString().substring(0, 16),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: const Color(0xFF191F38),
                          title: const Text(
                            'Eliminar conversación',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            '¿Seguro que deseas eliminar esta conversación?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true) {
                        await conversationService.eliminarConversacion(
                          documento.id,
                          materiaId: materiaId,
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          conversacionId: documento.id,
                          materiaId: materiaId,
                          materiaNombre: materiaNombre,
                          materiaDescripcion: materiaDescripcion,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
