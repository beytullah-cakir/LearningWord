import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadWords();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
    await _flutterTts.speak(_words[_currentIndex].word);
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
    final correct = _words[_currentIndex].word.toLowerCase();
    final recognized = _text.toLowerCase();

    if (recognized.contains(correct) || correct.contains(recognized) && recognized.length > 2) {
      setState(() {
        _lastFeedback = "Great! You pronounced it correctly. (Score: ${(_confidence * 100).toInt()})";
        _audioPlayer.play(AssetSource('sounds/success.mp3'));
      });
    } else if (recognized.isEmpty) {
      setState(() {
        _lastFeedback = "I couldn't hear anything, try again.";
      });
    } else {
      setState(() {
        _lastFeedback = "You should practice a bit more. I heard: '$recognized'";
        _audioPlayer.play(AssetSource('sounds/fail.mp3'));
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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Voice Shadowing', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'LISTEN AND REPEAT',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade200, letterSpacing: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentWord.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900, letterSpacing: -1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentWord.meaning,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    IconButton(
                      iconSize: 56,
                      onPressed: _speak,
                      icon: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up_rounded, color: Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (_lastFeedback != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _lastFeedback!.contains('Great!') || _lastFeedback!.contains('correctly') 
                        ? const Color(0xFF10B981).withOpacity(0.1) 
                        : const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _lastFeedback!.contains('correctly') || _lastFeedback!.contains('Great')
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _lastFeedback!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _lastFeedback!.contains('correctly') || _lastFeedback!.contains('Great')
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              Text(
                _isListening ? 'Listening...' : (_text.isNotEmpty ? 'Heard: $_text' : 'Ready?'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTapDown: (_) => _listen(),
                onTapUp: (_) => _listen(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isListening ? const Color(0xFFF43F5E) : const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? const Color(0xFFF43F5E) : const Color(0xFF6366F1)).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hold to speak',
                style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 48),
              if (_lastFeedback != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex < _words.length - 1 ? 'NEXT WORD' : 'COMPLETE',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: const Text('Voice Shadowing', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.amber),
              ),
              const SizedBox(height: 24),
              Text(
                'No words added yet.',
                style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
