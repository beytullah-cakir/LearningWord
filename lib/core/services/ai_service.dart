import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiPromptService {
  late final GenerativeModel _model;

  AiPromptService({required String apiKey}) {
     // NOTE: In production, the API key should not be hardcoded, but securely provided.
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<Map<String, String>?> generateSentence({
    required String word,
    required String level,
  }) async {
    final prompt = '''
You are an expert language teacher. The student's level is: $level.
Please create an example sentence that uses the word "$word" in a natural and meaningful context, appropriate for a $level learner.
Then provide a clear meaning or translation for that sentence.

Provide your response ONLY in the following JSON format. Do not add any other explanations or markdown:
{
  "sentence": "Example sentence here",
  "meaning": "Meaning or translation here"
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        String jsonText = response.text!.trim();
        // Remove markdown backticks if Gemini accidentally adds them
        if (jsonText.startsWith('```')) {
          final lines = jsonText.split('\n');
          if (lines.length >= 0) { // Safety check
            if (lines.isNotEmpty && lines.first.startsWith('```')) lines.removeAt(0);
            if (lines.isNotEmpty && lines.last.startsWith('```')) lines.removeLast();
            jsonText = lines.join('\n');
          }
        }
        
        final Map<String, dynamic> data = jsonDecode(jsonText.trim());
        return {
          'sentence': data['sentence']?.toString() ?? '',
          'meaning': data['meaning']?.toString() ?? '',
        };
      }
    } catch (e) {
      print('AI Service Error: $e');
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> checkSentence({
    required String word,
    required String userSentence,
  }) async {
    final prompt = '''
You are a language teacher. A student wrote this sentence using the word "$word":
"$userSentence"

Please check:
1. Is the word "$word" used correctly (grammatically and contextually)?
2. Is the sentence generally correct?

Provide your response ONLY in the following JSON format:
{
  "isCorrect": true,
  "feedback": "Your short feedback here"
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        String jsonText = response.text!.trim();
        if (jsonText.startsWith('```')) {
          final lines = jsonText.split('\n');
          if (lines.isNotEmpty && lines.first.startsWith('```')) lines.removeAt(0);
          if (lines.isNotEmpty && lines.last.startsWith('```')) lines.removeLast();
          jsonText = lines.join('\n');
        }
        
        final Map<String, dynamic> data = jsonDecode(jsonText.trim());
        return {
          'isCorrect': data['isCorrect'] as bool? ?? false,
          'feedback': data['feedback']?.toString() ?? 'No feedback provided.',
        };
      }
    } catch (e) {
      print('AI Sentence Check Error: $e');
      return null;
    }
    return null;
  }
}
