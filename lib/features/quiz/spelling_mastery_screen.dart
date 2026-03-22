import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

import 'package:audioplayers/audioplayers.dart';

class SpellingMasteryScreen extends StatefulWidget {
  final List<Word>? customWords;
  const SpellingMasteryScreen({super.key, this.customWords});

  @override
  State<SpellingMasteryScreen> createState() => _SpellingMasteryScreenState();
}

class _SpellingMasteryScreenState extends State<SpellingMasteryScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _controller = TextEditingController();
  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFinished = false;
  int _score = 0;
  bool _hasChecked = false;
  bool _isCorrect = false;


  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<void> _loadWords() async {
    final words = widget.customWords ?? await DatabaseHelper.instance.getAllWords();
    if (words.isNotEmpty) {
      // Sort by levelScore (lowest first)
      final sortedWords = List<Word>.from(words)..sort((a, b) => a.levelScore.compareTo(b.levelScore));
      setState(() {
        // Take the 20 lowest score words and shuffle them to pick 10
        final pool = sortedWords.take(20).toList()..shuffle();
        _words = pool.take(10).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _speak() async {
    if (_currentIndex < _words.length) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.speak(_words[_currentIndex].word);
    }
  }

  void _checkAnswer() {
    if (_hasChecked) return;
    
    final answer = _controller.text.trim().toLowerCase();
    final correctAnswer = _words[_currentIndex].word.trim().toLowerCase();

    setState(() {
      _hasChecked = true;
      _isCorrect = answer == correctAnswer;
      if (_isCorrect) {
        _score++;
        _audioPlayer.play(AssetSource('sounds/success.mp3'));
        // Increment levelScore
        final currentWord = _words[_currentIndex];
        DatabaseHelper.instance.updateWord(currentWord.copyWith(
          levelScore: currentWord.levelScore + 1,
        ));
      } else {
        _audioPlayer.play(AssetSource('sounds/fail.mp3'));
      }
    });
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _hasChecked = false;
        _isCorrect = false;
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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Spelling', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blueGrey.shade400, fontSize: 13),
                ),
                Text(
                  '${_currentIndex + 1} / ${_words.length}',
                  style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _words.length,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(32),
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
                children: [
                  Text(
                    'WRITE THE WORD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade200,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentWord.meaning,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey.shade900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  IconButton(
                    onPressed: _speak,
                    icon: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up_rounded, size: 32, color: Color(0xFF6366F1)),
                    ),
                  ),
                  Text(
                    'Tap to listen',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey.shade200, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.blueGrey.shade900, fontWeight: FontWeight.w700),
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Write the word...',
                hintStyle: TextStyle(color: Colors.blueGrey.shade200, fontWeight: FontWeight.w500),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              onSubmitted: (_) => _checkAnswer(),
              enabled: !_hasChecked,
            ),
            const SizedBox(height: 24),
            if (!_hasChecked)
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('CHECK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isCorrect ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF43F5E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _isCorrect
                            ? 'Perfect!'
                            : 'Error! Correct answer: ${currentWord.word}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _isCorrect ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextWord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  _currentIndex < _words.length - 1 ? 'NEXT' : 'SEE RESULTS',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: const Text('Spelling', style: TextStyle(fontWeight: FontWeight.w900))),
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

  Widget _buildResultState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
              ),
              const SizedBox(height: 32),
              Text(
                'Congratulations!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900, letterSpacing: -1),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Score: $_score / ${_words.length}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF6366F1)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
