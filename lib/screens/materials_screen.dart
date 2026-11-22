
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/material_service.dart';

class MaterialsScreen extends StatefulWidget {
  final String materiaId;
  final String materiaNombre;

  const MaterialsScreen({
    super.key,
    required this.materiaId,
    required this.materiaNombre,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final MaterialService _service = MaterialService();

  List<dynamic> _archivos = [];
  bool _cargando = true;
  bool _subiendo = false;

  @override
  void initState() {
    super.initState();
    _cargarArchivos();
  }

  Future<void> _cargarArchivos() async {
    setState(() => _cargando = true);

    try {
      final archivos = await _service.listarMateriales(
        materiaId: widget.materiaId,
      );

      if (!mounted) return;

      setState(() {
        _archivos = archivos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mensaje(e.toString());
    }
  }

  
Future<void> _seleccionarArchivo() async {
  try {
    final archivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );

    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();

    if (bytes.length > 50 * 1024 * 1024) {
      _mensaje('El archivo supera el límite de 50 MB.');
      return;
    }

    final extension = archivo.extension?.toLowerCase();

    final tipos = {
      'pdf': 'application/pdf',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
    };

    final tipoContenido = tipos[extension];

    if (tipoContenido == null) {
      _mensaje('Formato de archivo no permitido.');
      return;
    }

    setState(() => _subiendo = true);

    await _service.subirMaterial(
      materiaId: widget.materiaId,
      nombreArchivo: archivo.name,
      archivo: bytes,
      tipoContenido: tipoContenido,
    );

    if (!mounted) return;

    setState(() => _subiendo = false);

    _mensaje('Archivo subido correctamente.');

    await _cargarArchivos();
  } catch (e) {
    if (!mounted) return;

    setState(() => _subiendo = false);
    _mensaje(e.toString());
  }
}


  Future<void> _abrirArchivo(dynamic archivo) async {
    try {
      final ruta = '${widget.materiaId}/${archivo.name}';

      final url = await _service.obtenerUrl(
        ruta: '$_uid/$ruta',
      );

      final uri = Uri.parse(url);

      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        _mensaje('No se pudo abrir el archivo.');
      }
    } catch (e) {
      _mensaje(e.toString());
    }
  }

  String get _uid {
    return _service.uidUsuario;
  }

  Future<void> _eliminarArchivo(dynamic archivo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF191F38),
        title: const Text(
          'Eliminar archivo',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de eliminar este material?',
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

    if (confirmar != true) return;

    try {
      await _service.eliminarMaterial(
        ruta: '$_uid/${widget.materiaId}/${archivo.name}',
      );

      _mensaje('Archivo eliminado correctamente.');

      await _cargarArchivos();
    } catch (e) {
      _mensaje(e.toString());
    }
  }

  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text('Mis materiales'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _subiendo ? null : _seleccionarArchivo,
        backgroundColor: const Color(0xFF7865FF),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Subir archivo'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarArchivos,
        child: ListView(
          padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.folder_open_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Material de estudio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.materiaNombre,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PDF, JPG, PNG y WEBP · Máximo 50 MB por archivo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Mis archivos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            if (_subiendo)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF8B78FF),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Subiendo archivo...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            if (_cargando)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B78FF),
                ),
              )
            else if (_archivos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_off_rounded,
                      size: 55,
                      color: Colors.white38,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Todavía no tienes materiales.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Pulsa Subir archivo para comenzar.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              )
            else
              ..._archivos.map((archivo) {
                final esPdf = archivo.name.toLowerCase().endsWith('.pdf');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191F38),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: esPdf
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.blue.withValues(alpha: 0.15),
                      child: Icon(
                        esPdf
                            ? Icons.picture_as_pdf_rounded
                            : Icons.image_rounded,
                        color: esPdf ? Colors.redAccent : Colors.blueAccent,
                      ),
                    ),
                    title: Text(
                      archivo.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      esPdf ? 'Documento PDF' : 'Imagen',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: PopupMenuButton<String>(
                      iconColor: Colors.white70,
                      color: const Color(0xFF252D4A),
                      onSelected: (opcion) {
                        if (opcion == 'abrir') {
                          _abrirArchivo(archivo);
                        } else if (opcion == 'eliminar') {
                          _eliminarArchivo(archivo);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'abrir',
                          child: Text(
                            'Abrir archivo',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
