
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  final String? materiaNombre;
  final String? materiaDescripcion;

  AIService({
    this.materiaNombre,
    this.materiaDescripcion,
  });

  late final GenerativeModel _modelo =
      FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.5-flash-lite',
    systemInstruction: Content.text(
      materiaNombre == null
          ? 'Eres StudyAI, un asistente educativo especializado. '
              'Ayudas a estudiantes a aprender diferentes materias. '
              'Explica los temas de manera clara, sencilla y ordenada. '
              'Cuando resuelvas ejercicios, muestra el procedimiento '
              'paso a paso. Responde en español, salvo que el usuario '
              'solicite otro idioma.'
          : 'Eres StudyAI, un tutor especializado en la materia '
              '$materiaNombre. '
              'La descripción de esta materia es: '
              '${materiaDescripcion ?? "Sin descripción"}. '
              'Responde las preguntas centrándote en esta materia. '
              'Explica los conceptos de manera clara y sencilla. '
              'Cuando resuelvas ejercicios, muestra el procedimiento '
              'paso a paso. Utiliza ejemplos relacionados con la materia. '
              'Responde en español, salvo que el usuario solicite '
              'otro idioma.',
    ),
  );

  ChatSession? _chat;

  // Iniciar o recuperar una conversación.
  void iniciarConversacion({
    List<Map<String, dynamic>> historial = const [],
  }) {
    final contenidos = historial.map((mensaje) {
      final texto = mensaje['texto'] as String;
      final esUsuario = mensaje['esUsuario'] as bool;

      return Content(
        esUsuario ? 'user' : 'model',
        [TextPart(texto)],
      );
    }).toList();

    _chat = _modelo.startChat(history: contenidos);
  }

  // Enviar preguntas normales a Gemini.
  Future<String> enviarPregunta(String pregunta) async {
    _chat ??= _modelo.startChat();

    final respuesta = await _chat!.sendMessage(
      Content.text(pregunta),
    );

    return respuesta.text ??
        'No pude generar una respuesta. Inténtalo nuevamente.';
  }

  // Generar un cuestionario automáticamente.
  Future<List<Map<String, dynamic>>> generarCuestionario({
    required String tema,
    required int cantidad,
    required String dificultad,
  }) async {
    final materia = materiaNombre ?? 'Conocimientos generales';

    final prompt = '''
Genera un cuestionario educativo para StudyAI.

MATERIA: $materia
TEMA: $tema
DESCRIPCIÓN DE LA MATERIA: ${materiaDescripcion ?? 'No especificada'}
CANTIDAD DE PREGUNTAS: $cantidad
DIFICULTAD: $dificultad

INSTRUCCIONES:
1. Todas las preguntas deben estar relacionadas con el tema indicado.
2. Cada pregunta debe tener exactamente cuatro alternativas.
3. Solo debe existir una respuesta correcta.
4. Las alternativas incorrectas deben ser creíbles.
5. Incluye una explicación clara de por qué la respuesta es correcta.
6. Evita preguntas repetidas.
7. Utiliza español claro y apropiado para estudiantes.
8. No incluyas información ajena al tema.

FORMATO OBLIGATORIO:
Devuelve únicamente un arreglo JSON válido, sin Markdown,
sin bloques de código y sin texto adicional.

Cada pregunta debe tener esta estructura:

{
  "pregunta": "Texto de la pregunta",
  "opciones": [
    "Alternativa A",
    "Alternativa B",
    "Alternativa C",
    "Alternativa D"
  ],
  "respuestaCorrecta": 0,
  "explicacion": "Explicación de la respuesta correcta"
}

IMPORTANTE:
- respuestaCorrecta debe ser un número entre 0 y 3.
- El número representa la posición de la alternativa correcta.
- Genera exactamente $cantidad preguntas.
''';

    final respuesta = await _modelo.generateContent([
      Content.text(prompt),
    ]);

    final texto = respuesta.text;

    if (texto == null || texto.trim().isEmpty) {
      throw Exception('Gemini no generó el cuestionario.');
    }

    // Limpiar posibles bloques Markdown.
    String jsonTexto = texto.trim();

    if (jsonTexto.startsWith('```')) {
      jsonTexto = jsonTexto
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '');
    }

    // Convertir la respuesta JSON en una lista.
    final datos = jsonDecode(jsonTexto);

    if (datos is! List) {
      throw Exception('El formato del cuestionario no es válido.');
    }

    final preguntas = datos.map((elemento) {
      if (elemento is! Map) {
        throw Exception('Una pregunta tiene un formato incorrecto.');
      }

      final pregunta = Map<String, dynamic>.from(elemento);

      if (pregunta['pregunta'] is! String ||
          pregunta['opciones'] is! List ||
          pregunta['explicacion'] is! String ||
          pregunta['respuestaCorrecta'] is! int) {
        throw Exception('Una pregunta tiene datos incompletos.');
      }

      final opciones = pregunta['opciones'] as List;
      final correcta = pregunta['respuestaCorrecta'] as int;

      if (opciones.length != 4 ||
          opciones.any((opcion) => opcion is! String) ||
          correcta < 0 ||
          correcta > 3) {
        throw Exception('Las alternativas de una pregunta no son válidas.');
      }

      return pregunta;
    }).toList();

    if (preguntas.length != cantidad) {
      throw Exception(
        'El cuestionario no contiene las $cantidad preguntas solicitadas.',
      );
    }

    return preguntas;
  }
    // Generar un cuestionario utilizando un documento PDF.
  Future<List<Map<String, dynamic>>> generarCuestionarioDesdePDF({
    required Uint8List archivoPDF,
    required int cantidad,
    required String dificultad,
  }) async {
    final materia = materiaNombre ?? 'Conocimientos generales';

    final prompt = '''
Analiza cuidadosamente el documento PDF adjunto.

Eres StudyAI, un asistente educativo especializado.

MATERIA: $materia
DESCRIPCIÓN: ${materiaDescripcion ?? 'No especificada'}
CANTIDAD DE PREGUNTAS: $cantidad
DIFICULTAD: $dificultad

INSTRUCCIONES:
1. Utiliza exclusivamente la información del documento.
2. Genera preguntas que evalúen la comprensión del contenido.
3. Cada pregunta debe tener exactamente cuatro alternativas.
4. Solo debe existir una respuesta correcta.
5. Las alternativas incorrectas deben ser creíbles.
6. Incluye una explicación clara de cada respuesta.
7. No inventes información que no aparezca en el documento.
8. Evita preguntas repetidas.
9. Responde en español.
10. Genera exactamente $cantidad preguntas.

FORMATO OBLIGATORIO:
Devuelve únicamente un arreglo JSON válido, sin Markdown,
sin bloques de código y sin texto adicional.

Cada pregunta debe tener esta estructura:

{
  "pregunta": "Texto de la pregunta",
  "opciones": [
    "Alternativa A",
    "Alternativa B",
    "Alternativa C",
    "Alternativa D"
  ],
  "respuestaCorrecta": 0,
  "explicacion": "Explicación de la respuesta correcta"
}

IMPORTANTE:
- respuestaCorrecta debe ser un número entre 0 y 3.
- El número representa la posición de la alternativa correcta.
- Genera exactamente $cantidad preguntas.
''';

    final documento = InlineDataPart('application/pdf', archivoPDF);

    final respuesta = await _modelo.generateContent([
      Content.multi([
        TextPart(prompt),
        documento,
      ]),
    ]);

    final texto = respuesta.text;

    if (texto == null || texto.trim().isEmpty) {
      throw Exception('Gemini no pudo analizar el documento PDF.');
    }

    String jsonTexto = texto.trim();

    if (jsonTexto.startsWith('```')) {
      jsonTexto = jsonTexto
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '');
    }

    final datos = jsonDecode(jsonTexto);

    if (datos is! List) {
      throw Exception('El formato del cuestionario no es válido.');
    }

    final preguntas = datos.map((elemento) {
      if (elemento is! Map) {
        throw Exception('Una pregunta tiene un formato incorrecto.');
      }

      final pregunta = Map<String, dynamic>.from(elemento);

      if (pregunta['pregunta'] is! String ||
          pregunta['opciones'] is! List ||
          pregunta['explicacion'] is! String ||
          pregunta['respuestaCorrecta'] is! int) {
        throw Exception('Una pregunta tiene datos incompletos.');
      }

      final opciones = pregunta['opciones'] as List;
      final correcta = pregunta['respuestaCorrecta'] as int;

      if (opciones.length != 4 ||
          opciones.any((opcion) => opcion is! String) ||
          correcta < 0 ||
          correcta > 3) {
        throw Exception('Las alternativas no son válidas.');
      }

      return pregunta;
    }).toList();

    if (preguntas.length != cantidad) {
      throw Exception(
        'El cuestionario no contiene las $cantidad preguntas solicitadas.',
      );
    }

    return preguntas;
  }
}
