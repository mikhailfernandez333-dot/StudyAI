
import 'package:flutter/material.dart';
import '../services/subject_service.dart';
import 'subject_detail_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectService subjectService = SubjectService();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();

  bool guardando = false;

  
Future<void> mostrarFormulario({
  String? materiaId,
  String? nombre,
  String? descripcion,
}) async {
  nombreController.text = nombre ?? '';
  descripcionController.text = descripcion ?? '';

  final messenger = ScaffoldMessenger.of(context);

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (_, actualizarDialogo) {
          return AlertDialog(
            backgroundColor: const Color(0xFF191F38),
            title: Text(
              materiaId == null ? 'Nueva materia' : 'Editar materia',
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    style: const TextStyle(color: Colors.white),
                    decoration: campoDecoracion('Nombre de la materia'),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: descripcionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: campoDecoracion('Descripción'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: guardando
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: guardando
                    ? null
                    : () async {
                        final nombreNuevo =
                            nombreController.text.trim();

                        if (nombreNuevo.isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Escribe el nombre de la materia.',
                              ),
                            ),
                          );
                          return;
                        }

                        actualizarDialogo(() {
                          guardando = true;
                        });

                        try {
                          if (materiaId == null) {
                            await subjectService.crearMateria(
                              nombre: nombreNuevo,
                              descripcion:
                                  descripcionController.text,
                            );
                          } else {
                            await subjectService.actualizarMateria(
                              materiaId: materiaId,
                              nombre: nombreNuevo,
                              descripcion:
                                  descripcionController.text,
                            );
                          }

                          if (!dialogContext.mounted) return;

                          Navigator.pop(dialogContext);

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                materiaId == null
                                    ? 'Materia registrada correctamente.'
                                    : 'Materia actualizada correctamente.',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!dialogContext.mounted) return;

                          actualizarDialogo(() {
                            guardando = false;
                          });

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                            ),
                          );
                        }
                      },
                child: guardando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}


  InputDecoration campoDecoracion(String texto) {
    return InputDecoration(
      labelText: texto,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF252D48),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> confirmarEliminar(String materiaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF191F38),
        title: const Text(
          'Eliminar materia',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta materia?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await subjectService.eliminarMateria(materiaId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materia eliminada.'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text('Mis materias'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7865FF),
        foregroundColor: Colors.white,
        onPressed: () => mostrarFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva materia'),
      ),
      body: StreamBuilder(
        stream: subjectService.obtenerMaterias(),
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
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 65,
                      color: Color(0xFF9B8CFF),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Todavía no tienes materias',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pulsa Nueva materia para comenzar '
                      'a organizar tus estudios.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB7B9D0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final documento = materias[index];
              final datos = documento.data();

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF191F38),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF30265F),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF9B8CFF),
                    ),
                  ),
                  title: Text(
                    datos['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(
                      datos['descripcion'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFFB7B9D0),
                      ),
                    ),
                  ),
                  
trailing: PopupMenuButton<String>(
  iconColor: Colors.white70,
  color: const Color(0xFF252D48),
  onSelected: (opcion) {
    if (opcion == 'editar') {
      mostrarFormulario(
        materiaId: documento.id,
        nombre: datos['nombre'],
        descripcion: datos['descripcion'],
      );
    } else if (opcion == 'eliminar') {
      confirmarEliminar(documento.id);
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'editar',
      child: Text(
        'Editar',
        style: TextStyle(color: Colors.white),
      ),
    ),
    const PopupMenuItem(
      value: 'eliminar',
      child: Text(
        'Eliminar',
        style: TextStyle(color: Colors.redAccent),
      ),
    ),
  ],
),

// Abrir los detalles al pulsar la materia
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SubjectDetailScreen(
        materiaId: documento.id,
        nombre: datos['nombre'] ?? 'Sin nombre',
        descripcion: datos['descripcion'] ?? '',
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
