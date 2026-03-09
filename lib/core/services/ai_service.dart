import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiPromptService {
  late final GenerativeModel _model;

  AiPromptService({required String apiKey}) {
     // NOTE: In production, the API key should not be hardcoded, but securely provided.
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<Map<String, String>?> generateSentence({
    required String englishWord,
    required String level,
  }) async {
    final prompt = '''
Sen uzman bir İngilizce öğretmenisin. Öğrencinin seviyesi: $level.
Lütfen "$englishWord" kelimesini anlamlı ve doğal bir şekilde kullanan, $level seviyesine uygun, günlük hayatta kullanılabilecek örnek bir İngilizce cümle oluştur. 
Ardından bu cümlenin anlaşılır bir Türkçe çevirisini yap.

Yanıtını sadece aşağıdaki JSON formatında ver, başka hiçbir açıklama veya markdown metni (örneğin ```json vb.) ekleme:
{
  "sentence": "İngilizce cümle buraya",
  "translation": "Türkçe çeviri buraya"
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        String jsonText = response.text!;
        // Remove markdown backticks if Gemini accidentally adds them
        if (jsonText.startsWith('```')) {
          final lines = jsonText.split('\\n');
          if (lines.length >= 2) {
            lines.removeAt(0); // remove ```json
            if (lines.last.trim() == '```') {
              lines.removeLast(); // remove closing ```
            }
            jsonText = lines.join('\\n');
          }
        }
        
        final Map<String, dynamic> data = jsonDecode(jsonText.trim());
        return {
          'sentence': data['sentence']?.toString() ?? '',
          'translation': data['translation']?.toString() ?? '',
        };
      }
    } catch (e) {
      print('AI Service Error: \$e');
      return null;
    }
    return null;
  }
}
