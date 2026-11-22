
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../services/ai_service.dart';
import '../services/conversation_service.dart';

class ChatScreen extends StatefulWidget {
  final String? conversacionId;
  final String? materiaId;
  final String? materiaNombre;
  final String? materiaDescripcion;

  const ChatScreen({
    super.key,
    this.conversacionId,
    this.materiaId,
    this.materiaNombre,
    this.materiaDescripcion,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final mensajeController = TextEditingController();
  final scrollController = ScrollController();

  final ConversationService conversationService =
      ConversationService();

  late final AIService aiService;

  String? conversacionId;

  bool cargando = false;
  bool cargandoHistorial = false;

  final List<Map<String, dynamic>> mensajes = [];

  @override
  void initState() {
    super.initState();

    aiService = AIService(
      materiaNombre: widget.materiaNombre,
      materiaDescripcion: widget.materiaDescripcion,
    );

    conversacionId = widget.conversacionId;

    if (conversacionId != null) {
      cargarMensajesAnteriores();
    } else {
      mensajes.add({
        'texto': widget.materiaNombre == null
            ? '¡Hola! Soy StudyAI, tu asistente de aprendizaje. '
                '¿Qué te gustaría aprender hoy?'
            : '¡Hola! Soy tu tutor de ${widget.materiaNombre}. '
                'Puedes preguntarme cualquier cosa sobre esta materia.',
        'esUsuario': false,
      });
    }
  }

  Future<void> cargarMensajesAnteriores() async {
    setState(() {
      cargandoHistorial = true;
    });

    try {
      final mensajesGuardados =
          await conversationService.obtenerMensajes(
        conversacionId!,
        materiaId: widget.materiaId,
      );

      if (!mounted) return;

      aiService.iniciarConversacion(
        historial: mensajesGuardados,
      );

      setState(() {
        mensajes.clear();
        mensajes.addAll(mensajesGuardados);
      });

      desplazarAlFinal();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar el historial: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargandoHistorial = false;
        });
      }
    }
  }

  Future<void> enviarMensaje() async {
    final texto = mensajeController.text.trim();

    if (texto.isEmpty || cargando || cargandoHistorial) return;

    setState(() {
      mensajes.add({
        'texto': texto,
        'esUsuario': true,
      });

      cargando = true;
    });

    mensajeController.clear();
    desplazarAlFinal();

    try {
      // Crear conversación si es la primera pregunta.
      if (conversacionId == null) {
        final titulo = texto.length > 40
            ? '${texto.substring(0, 40)}...'
            : texto;

        conversacionId =
            await conversationService.crearConversacion(
          titulo,
          materiaId: widget.materiaId,
        );
      }

      // Guardar pregunta del estudiante.
      await conversationService.guardarMensaje(
        conversacionId: conversacionId!,
        texto: texto,
        esUsuario: true,
        materiaId: widget.materiaId,
      );

      // Consultar a Gemini.
      final respuesta = await aiService.enviarPregunta(texto);

      // Guardar respuesta de Gemini.
      await conversationService.guardarMensaje(
        conversacionId: conversacionId!,
        texto: respuesta,
        esUsuario: false,
        materiaId: widget.materiaId,
      );

      if (!mounted) return;

      setState(() {
        mensajes.add({
          'texto': respuesta,
          'esUsuario': false,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensajes.add({
          'texto': 'No pude completar la operación. '
              'Comprueba tu conexión e inténtalo nuevamente.\n\n'
              'Detalle: $e',
          'esUsuario': false,
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });

        desplazarAlFinal();
      }
    }
  }

  // Convierte el Markdown y las fórmulas LaTeX en widgets.
  Widget construirRespuesta(String texto) {
    final patron = RegExp(
      r'(\$\$[\s\S]*?\$\$|\$[^$\n]+\$)',
    );

    final coincidencias = patron.allMatches(texto);

    if (coincidencias.isEmpty) {
      return construirMarkdown(texto);
    }

    final widgets = <Widget>[];
    int posicion = 0;

    for (final coincidencia in coincidencias) {
      if (coincidencia.start > posicion) {
        final parteTexto = texto.substring(
          posicion,
          coincidencia.start,
        );

        if (parteTexto.trim().isNotEmpty) {
          widgets.add(construirMarkdown(parteTexto));
        }
      }

      final formulaCompleta = coincidencia.group(0)!;

      final esFormulaBloque =
          formulaCompleta.startsWith(r'$$');

      final formula = esFormulaBloque
          ? formulaCompleta.substring(
              2,
              formulaCompleta.length - 2,
            ).trim()
          : formulaCompleta.substring(
              1,
              formulaCompleta.length - 1,
            ).trim();

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              formula,
              mathStyle: esFormulaBloque
                  ? MathStyle.display
                  : MathStyle.text,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
        ),
      );

      posicion = coincidencia.end;
    }

    if (posicion < texto.length) {
      final parteFinal = texto.substring(posicion);

      if (parteFinal.trim().isNotEmpty) {
        widgets.add(construirMarkdown(parteFinal));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // Interpreta títulos, negritas, listas y otros formatos Markdown.
  Widget construirMarkdown(String texto) {
    

    return MarkdownBody(
      data: texto,
      selectable: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
        h1: const TextStyle(
          color: Color(0xFFB8A9FF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: Color(0xFFB8A9FF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: Color(0xFFB8A9FF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        strong: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: Colors.white70,
          fontStyle: FontStyle.italic,
        ),
        listBullet: const TextStyle(
          color: Color(0xFFB8A9FF),
          fontSize: 15,
        ),
        code: const TextStyle(
          color: Color(0xFFB8A9FF),
          backgroundColor: Color(0xFF252D48),
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF252D48),
          borderRadius: BorderRadius.circular(10),
        ),
        blockquote: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white24),
          ),
        ),
      ),
    );
  }

  void desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    mensajeController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esChatPorMateria = widget.materiaNombre != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(
              Icons.psychology_alt_rounded,
              color: Color(0xFF9B8CFF),
              size: 30,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'StudyAI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  esChatPorMateria
                      ? 'Tutor de ${widget.materiaNombre}'
                      : 'Tu asistente inteligente',
                  style: const TextStyle(
                    color: Color(0xFFB7B9D0),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cargandoHistorial
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9B8CFF),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(18),
                    itemCount: mensajes.length + (cargando ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == mensajes.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Color(0xFF9B8CFF),
                            ),
                          ),
                        );
                      }

                      final mensaje = mensajes[index];
                      final esUsuario =
                          mensaje['esUsuario'] as bool;

                      return Align(
                        alignment: esUsuario
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.85,
                          ),
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: esUsuario
                                ? const Color(0xFF7865FF)
                                : const Color(0xFF191F38),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: esUsuario
                              ? Text(
                                  mensaje['texto'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                )
                              : construirRespuesta(
                                  mensaje['texto'] as String,
                                ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF141A30),
              border: Border(
                top: BorderSide(color: Colors.white12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mensajeController,
                    enabled: !cargando && !cargandoHistorial,
                    style: const TextStyle(color: Colors.white),
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF252D48),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => enviarMensaje(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF7865FF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed:
                        (cargando || cargandoHistorial)
                            ? null
                            : enviarMensaje,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
