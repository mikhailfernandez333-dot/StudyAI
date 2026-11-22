
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/ai_service.dart';
import '../services/quiz_result_service.dart';

class QuizScreen extends StatefulWidget {
  final String? materiaNombre;
  final String? materiaDescripcion;

  const QuizScreen({
    super.key,
    this.materiaNombre,
    this.materiaDescripcion,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final temaController = TextEditingController();

    bool usarPDF = false;
  String? nombreArchivoPDF;
  Uint8List? archivoPDF;

  late final AIService aiService;
  final QuizResultService resultadoService = QuizResultService();

  int cantidad = 5;
  String dificultad = 'Intermedia';

  bool generando = false;
  bool finalizado = false;

  List<Map<String, dynamic>> preguntas = [];

  final Map<int, int> respuestas = {};
  Future<void> seleccionarPDF() async {
    try {
      final archivo = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (archivo == null) return;

      final bytes = await archivo.readAsBytes();

      // Limitar el PDF a 15 MB.
      if (bytes.length > 15 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El PDF no debe superar los 15 MB.'),
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        archivoPDF = bytes;
        nombreArchivoPDF = archivo.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar el PDF: $e'),
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();

    aiService = AIService(
      materiaNombre: widget.materiaNombre,
      materiaDescripcion: widget.materiaDescripcion,
    );
  }

    Future<void> generarCuestionario() async {
    final tema = temaController.text.trim();

    if (!usarPDF && tema.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe el tema que deseas estudiar.'),
        ),
      );
      return;
    }

    if (usarPDF && archivoPDF == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona un documento PDF.'),
        ),
      );
      return;
    }

    setState(() {
      generando = true;
      preguntas = [];
      respuestas.clear();
      finalizado = false;
    });

    try {
      final resultado = usarPDF
          ? await aiService.generarCuestionarioDesdePDF(
              archivoPDF: archivoPDF!,
              cantidad: cantidad,
              dificultad: dificultad,
            )
          : await aiService.generarCuestionario(
              tema: tema,
              cantidad: cantidad,
              dificultad: dificultad,
            );

      if (!mounted) return;

      setState(() {
        preguntas = resultado;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo generar el cuestionario: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          generando = false;
        });
      }
    }
  }

  
Future<void> finalizarCuestionario() async {
  if (finalizado) return;

  if (respuestas.length != preguntas.length) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Responde todas las preguntas antes de finalizar.'),
      ),
    );
    return;
  }

  final correctas = calcularPuntaje();
  final porcentaje =
      (correctas / preguntas.length * 100).round();

  final tema = usarPDF
      ? nombreArchivoPDF ?? 'Cuestionario desde PDF'
      : temaController.text.trim();

  setState(() {
    finalizado = true;
  });

  try {
    await resultadoService.guardarResultado(
      tema: tema,
      materiaNombre: widget.materiaNombre,
      dificultad: dificultad,
      totalPreguntas: preguntas.length,
      respuestasCorrectas: correctas,
      porcentaje: porcentaje,
      tipo: usarPDF ? 'PDF' : 'Tema',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Tu resultado se guardó correctamente!'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No se pudo guardar tu resultado: $e'),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}


  int calcularPuntaje() {
    int correctas = 0;

    for (int i = 0; i < preguntas.length; i++) {
      if (respuestas[i] ==
          preguntas[i]['respuestaCorrecta']) {
        correctas++;
      }
    }

    return correctas;
  }

  void reiniciarCuestionario() {
    setState(() {
      preguntas = [];
      respuestas.clear();
      finalizado = false;
    });
  }

  Widget construirOpcion(
    int preguntaIndex,
    int opcionIndex,
    String opcion,
  ) {
    final seleccionada =
        respuestas[preguntaIndex] == opcionIndex;

    final correcta =
        preguntas[preguntaIndex]['respuestaCorrecta'] ==
            opcionIndex;

    Color color = const Color(0xFF252D48);

    if (finalizado && correcta) {
      color = const Color(0xFF1B6545);
    } else if (finalizado && seleccionada && !correcta) {
      color = const Color(0xFF762D3B);
    } else if (seleccionada) {
      color = const Color(0xFF4936B8);
    }

    return GestureDetector(
      onTap: finalizado
          ? null
          : () {
              setState(() {
                respuestas[preguntaIndex] = opcionIndex;
              });
            },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: seleccionada || (finalizado && correcta)
                ? const Color(0xFF9B8CFF)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              seleccionada
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                opcion,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            if (finalizado && correcta)
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
              ),
            if (finalizado && seleccionada && !correcta)
              const Icon(
                Icons.cancel,
                color: Colors.redAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget construirPregunta(int index) {
    final pregunta = preguntas[index];

    final opciones =
        List<String>.from(pregunta['opciones']);

    final correcta =
        pregunta['respuestaCorrecta'] as int;

    final acerto = respuestas[index] == correcta;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF191F38),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREGUNTA ${index + 1}',
            style: const TextStyle(
              color: Color(0xFFB8A9FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            pregunta['pregunta'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(
            opciones.length,
            (opcionIndex) => construirOpcion(
              index,
              opcionIndex,
              opciones[opcionIndex],
            ),
          ),
          if (finalizado) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.white.withValues(alpha: 0.15)),
            Row(
              children: [
                Icon(
                  acerto ? Icons.check_circle : Icons.info_outline,
                  color: acerto
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  acerto ? '¡Respuesta correcta!' : 'Respuesta incorrecta',
                  style: TextStyle(
                    color: acerto
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Respuesta correcta: ${opciones[correcta]}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pregunta['explicacion'],
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget construirConfiguracion() {
    return Column(
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pon a prueba tus conocimientos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.materiaNombre == null
                    ? 'Crea un cuestionario personalizado con Gemini.'
                    : 'Practica tus conocimientos de ${widget.materiaNombre}.',
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Text(
          '¿Cómo quieres crear tu cuestionario?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                avatar: const Icon(
                  Icons.edit_note,
                  color: Colors.white,
                ),
                label: const Text('Por tema'),
                selected: !usarPDF,
                onSelected: (valor) {
                  setState(() {
                    usarPDF = false;
                  });
                },
                selectedColor: const Color(0xFF7865FF),
                backgroundColor: const Color(0xFF191F38),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                avatar: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                ),
                label: const Text('Desde PDF'),
                selected: usarPDF,
                onSelected: (valor) {
                  setState(() {
                    usarPDF = true;
                  });
                },
                selectedColor: const Color(0xFF7865FF),
                backgroundColor: const Color(0xFF191F38),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
        const Text(
          'Tema de estudio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
               const SizedBox(height: 25),

        if (!usarPDF) ...[
          const Text(
            'Tema de estudio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: temaController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ej. Ecuaciones de primer grado',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF191F38),
              prefixIcon: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF9B8CFF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],

        if (usarPDF) ...[
          const Text(
            'Documento de estudio',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF191F38),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF9B8CFF),
                  size: 42,
                ),
                const SizedBox(height: 10),
                Text(
                  nombreArchivoPDF ?? 'Todavía no has seleccionado un PDF',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: seleccionarPDF,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Seleccionar PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF7865FF)),
                  ),
                ),
                if (archivoPDF != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        archivoPDF = null;
                        nombreArchivoPDF = null;
                      });
                    },
                    child: const Text(
                      'Quitar documento',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        const Text(
          'Cantidad de preguntas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: [5, 10, 15].map((numero) {
            final seleccionado = cantidad == numero;

            return ChoiceChip(
              label: Text('$numero preguntas'),
              selected: seleccionado,
              onSelected: (valor) {
                setState(() {
                  cantidad = numero;
                });
              },
              selectedColor: const Color(0xFF7865FF),
              backgroundColor: const Color(0xFF191F38),
              labelStyle: TextStyle(
                color: seleccionado ? Colors.white : Colors.white70,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        const Text(
          'Nivel de dificultad',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: dificultad,
          dropdownColor: const Color(0xFF191F38),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF191F38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          items: ['Fácil', 'Intermedia', 'Difícil']
              .map(
                (nivel) => DropdownMenuItem(
                  value: nivel,
                  child: Text(nivel),
                ),
              )
              .toList(),
          onChanged: (valor) {
            if (valor != null) {
              setState(() {
                dificultad = valor;
              });
            }
          },
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: generando ? null : generarCuestionario,
            icon: generando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              generando
                  ? 'Generando preguntas...'
                  : 'Generar con Gemini',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7865FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget construirResultado() {
    final correctas = calcularPuntaje();
    final porcentaje =
        (correctas / preguntas.length * 100).round();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4936B8),
            Color(0xFF7865FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.amber,
            size: 50,
          ),
          const SizedBox(height: 12),
          const Text(
            '¡Cuestionario terminado!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$porcentaje%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$correctas de ${preguntas.length} respuestas correctas',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: reiniciarCuestionario,
              icon: const Icon(Icons.refresh),
              label: const Text('Crear otro cuestionario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4936B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    temaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text(
          'Cuestionarios StudyAI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: generando
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF9B8CFF),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Gemini está preparando tu cuestionario...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : preguntas.isEmpty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: construirConfiguracion(),
                )
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (finalizado) construirResultado(),
                    if (!finalizado)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          'Respondidas: ${respuestas.length} de ${preguntas.length}',
                          style: const TextStyle(
                            color: Color(0xFFB8A9FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ...List.generate(
                      preguntas.length,
                      (index) => construirPregunta(index),
                    ),
                    if (!finalizado)
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: finalizarCuestionario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7865FF),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Finalizar cuestionario',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
