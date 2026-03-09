import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

class SpellingMasteryScreen extends StatefulWidget {
  const SpellingMasteryScreen({super.key});

  @override
  State<SpellingMasteryScreen> createState() => _SpellingMasteryScreenState();
}

class _SpellingMasteryScreenState extends State<SpellingMasteryScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFinished = false;
  int _score = 0;
  bool _hasChecked = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await DatabaseHelper.instance.getAllWords();
    if (words.isNotEmpty) {
      words.shuffle();
      setState(() {
        _words = words.take(10).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    if (_currentIndex < _words.length) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.speak(_words[_currentIndex].english);
    }
  }

  void _checkAnswer() {
    if (_hasChecked) return;
    
    final answer = _controller.text.trim().toLowerCase();
    final correctAnswer = _words[_currentIndex].english.toLowerCase();

    setState(() {
      _hasChecked = true;
      if (answer == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _hasChecked = false;
      });
    } else {
      setState(() => _isFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_words.isEmpty) return _buildEmptyState();
    if (_isFinished) return _buildResultState();

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Spelling Mastery')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _words.length,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 32),
            Text(
              'Kelimeyi yazın:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              currentWord.turkish,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 32),
            IconButton(
              onPressed: _speak,
              icon: const Icon(Icons.volume_up, size: 48, color: Colors.orangeAccent),
            ),
            const Text('Dinlemek için dokunun', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'İngilizce karşılığını yazın...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onSubmitted: (_) => _checkAnswer(),
              enabled: !_hasChecked,
            ),
            const SizedBox(height: 24),
            if (!_hasChecked)
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('KONTROL ET'),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _controller.text.trim().toLowerCase() == currentWord.english.toLowerCase()
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _controller.text.trim().toLowerCase() == currentWord.english.toLowerCase()
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _controller.text.trim().toLowerCase() == currentWord.english.toLowerCase()
                          ? 'Mükemmel!'
                          : 'Hata! Doğru cevap: ${currentWord.english}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _controller.text.trim().toLowerCase() == currentWord.english.toLowerCase()
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextWord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(_currentIndex < _words.length - 1 ? 'SIRADAKİ' : 'SONUÇLARI GÖR'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Spelling Mastery')),
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

  Widget _buildResultState() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text('Tebrikler!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Skorun: $_score / ${_words.length}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
