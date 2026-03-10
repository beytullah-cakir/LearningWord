import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

class VoiceShadowingScreen extends StatefulWidget {
  const VoiceShadowingScreen({super.key});

  @override
  State<VoiceShadowingScreen> createState() => _VoiceShadowingScreenState();
}

class _VoiceShadowingScreenState extends State<VoiceShadowingScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  double _confidence = 1.0;

  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _lastFeedback;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await DatabaseHelper.instance.getAllWords();
    if (words.isNotEmpty) {
      setState(() {
        _words = (words..shuffle()).take(10).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_words[_currentIndex].english);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _evaluatePronunciation();
    }
  }

  void _evaluatePronunciation() {
    final correct = _words[_currentIndex].english.toLowerCase();
    final recognized = _text.toLowerCase();

    if (recognized.contains(correct) || correct.contains(recognized) && recognized.length > 2) {
      setState(() {
        _lastFeedback = "Harika! Doğru telaffuz ettin. (Puan: ${(_confidence * 100).toInt()})";
      });
    } else if (recognized.isEmpty) {
      setState(() {
        _lastFeedback = "Bir şey duyamadım, tekrar deneyin.";
      });
    } else {
      setState(() {
        _lastFeedback = "Biraz daha çalışmalısın. Şunu duydum: '$recognized'";
      });
    }
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _text = '';
        _lastFeedback = null;
        _confidence = 1.0;
      });
    } else {
       Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_words.isEmpty) return _buildEmptyState();

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Shadowing')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Dinle ve Tekrar Et',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white38),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentWord.english,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentWord.turkish,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              IconButton(
                iconSize: 64,
                onPressed: _speak,
                icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
              ),
              const SizedBox(height: 48),
              if (_lastFeedback != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _lastFeedback!.contains('Harika') ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_lastFeedback!, textAlign: TextAlign.center),
                ),
              Text(
                _isListening ? 'Dinleniyor...' : (_text.isNotEmpty ? 'Duyulan: $_text' : 'Hazır mısın?'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTapDown: (_) => _listen(),
                onTapUp: (_) => _listen(),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _isListening ? Colors.red : Colors.deepPurple,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Basılı tutarak konuşun', style: TextStyle(color: Colors.white24, fontSize: 12)),
              const SizedBox(height: 32),
              if (_lastFeedback != null)
                ElevatedButton(
                  onPressed: _nextWord,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                  child: Text(_currentIndex < _words.length - 1 ? 'SIRADAKİ KELİME' : 'TAMAMLA'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Scaffold(
      appBar: AppBar(title: const Text('Voice Shadowing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Henüz kelime eklenmemiş!'),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Geri Dön')),
          ],
        ),
      ),
    );
  }
}
