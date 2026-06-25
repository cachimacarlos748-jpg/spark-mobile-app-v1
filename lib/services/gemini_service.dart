import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  static const String _apiKey = 'AQ.Ab8RN6IF7vrnUXhNiJxhWXjE60fiK7Tv5XN0ZXlWzIY-LH1FGg';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  static final Map<String, String> _modelMap = {
    'spark-3.1-flash-lite': 'gemini-1.5-flash',
    'spark-3.5-flash': 'gemini-2.0-flash',
    'spark-3.1-pro': 'gemini-2.0-pro',
    'spark-offline': 'gemini-1.5-flash',
  };

  static const String _systemPrompt = '''Eres Spark, un asistente de IA avanzado creado por SparkIA Studio. 
Tu nombre es Spark, no Gemini ni ningún otro nombre. 
Cuando alguien te pregunte quien eres o como te llamas, responde que eres Spark, un asistente inteligente de SparkIA Studio. 
Eres amable, útil, y experto en múltiples áreas incluyendo matemáticas, física, programación, escritura, análisis y mucho más. 
Siempre mantén tu identidad como Spark y nunca reveles que estás basado en Gemini. 
Responde en el idioma del usuario.''';

  static Future<String> sendMessage(
    String message, {
    String model = 'spark-3.5-flash',
    String reasoning = 'standard',
  }) async {
    try {
      final geminiModel = _modelMap[model] ?? 'gemini-2.0-flash';
      final url = Uri.parse(
        '$_baseUrl/$geminiModel:generateContent?key=$_apiKey',
      );

      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': message}
            ]
          }
        ],
        'systemInstruction': {
          'parts': [
            {'text': _systemPrompt}
          ]
        },
        'generationConfig': {
          'temperature': 0.9,
          'topP': 0.95,
          'topK': 40,
          'maxOutputTokens': 2048,
        }
      };

      // Add thinking for advanced reasoning
      if (reasoning == 'advanced' && geminiModel.contains('pro')) {
        requestBody['thinking'] = {
          'type': 'enabled',
          'budget_tokens': 2048
        };
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (content != null) {
          return content;
        } else {
          return 'No se pudo obtener una respuesta';
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Error desconocido';
        throw Exception('Error: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error al conectar con Spark: $e');
    }
  }

  static Future<String> generateImage(String prompt) async {
    // Placeholder for image generation
    // Will integrate with Gemini's image generation API
    return 'https://via.placeholder.com/512x512?text=Generated+Image';
  }

  static Future<String> transcribeAudio(String audioPath) async {
    // Placeholder for audio transcription
    return 'Transcripción de audio';
  }
}
