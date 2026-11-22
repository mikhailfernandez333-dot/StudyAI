
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/subject_service.dart';
import '../services/material_service.dart';

class ApuntesScreen extends StatefulWidget {
  const ApuntesScreen({super.key});

  @override
  State<ApuntesScreen> createState() => _ApuntesScreenState();
}

class _ApuntesScreenState extends State<ApuntesScreen> {
  final SubjectService _subjectService = SubjectService();
  final MaterialService _materialService = MaterialService();

  Future<void> abrirArchivo(String ruta) async {
    try {
      final url = await _materialService.obtenerUrl(ruta: ruta);

      final abierto = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el archivo.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir archivo: $e')),
      );
    }
  }

  IconData iconoArchivo(String nombre) {
    final extension = nombre.split('.').last.toLowerCase();

    if (extension == 'pdf') {
      return Icons.picture_as_pdf_rounded;
    }

    if (['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      return Icons.image_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text('Mis apuntes'),
      ),
      body: StreamBuilder(
        stream: _subjectService.obtenerMaterias(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar materias: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
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

          final materias = snapshot.data?.docs ?? [];

          if (materias.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no tienes materias registradas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final materia = materias[index];
              final datos = materia.data();

              final nombreMateria =
                  datos['nombre'] ?? 'Sin nombre';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF191F38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF9B8CFF),
                          size: 25,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nombreMateria,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    FutureBuilder(
                      future: _materialService.listarMateriales(
                        materiaId: materia.id,
                      ),
                      builder: (context, archivosSnapshot) {
                        if (archivosSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF9B8CFF),
                              ),
                            ),
                          );
                        }

                        if (archivosSnapshot.hasError) {
                          return const Text(
                            'No se pudieron cargar los apuntes.',
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          );
                        }

                        final archivos =
                            archivosSnapshot.data ?? [];

                        if (archivos.isEmpty) {
                          return const Text(
                            'No hay archivos en esta materia.',
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          );
                        }

                        return Column(
                          children: archivos.map((archivo) {
                            final ruta =
                                '${_materialService.uidUsuario}/'
                                '${materia.id}/${archivo.name}';

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                iconoArchivo(archivo.name),
                                color: const Color(0xFF9B8CFF),
                                size: 30,
                              ),
                              title: Text(
                                archivo.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: const Text(
                                'Toca para abrir',
                                style: TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.open_in_new_rounded,
                                color: Colors.white70,
                              ),
                              onTap: () => abrirArchivo(ruta),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
