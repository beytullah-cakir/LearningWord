import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  final List<Word>? customWords;
  const QuizScreen({super.key, this.customWords});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Word> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedOptionIndex;
  List<String> _currentOptions = [];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<void> _loadQuiz() async {
    final allWords = widget.customWords ?? await DatabaseHelper.instance.getAllWords();
    if (allWords.length < 4) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _questions = [];
        });
      }
      return;
    }

    // Sort by levelScore (lowest first) and then pick words
    final sortedWords = List<Word>.from(allWords)..sort((a, b) => a.levelScore.compareTo(b.levelScore));
    // Take the 15 lowest score words and shuffle them to pick 10
    final pool = sortedWords.take(20).toList()..shuffle();
    _questions = pool.take(10).toList();
    
    _generateOptions(allWords);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateOptions(List<Word> allWords) {
    if (_questions.isEmpty) return;
    
    final correctWord = _questions[_currentQuestionIndex];
    List<String> options = [correctWord.meaning];
    
    // Get wrong options
    final random = Random();
    while (options.length < 4) {
      final randomWord = allWords[random.nextInt(allWords.length)];
      if (!options.contains(randomWord.meaning)) {
        options.add(randomWord.meaning);
      }
    }
    
    options.shuffle();
    _currentOptions = options;
  }

  void _handleOptionTap(int index) {
    if (_answered) return;
    
    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      final currentWord = _questions[_currentQuestionIndex];
      if (_currentOptions[index] == currentWord.meaning) {
        _score++;
        _audioPlayer.play(AssetSource('sounds/success.mp3'));
        // Increment levelScore
        DatabaseHelper.instance.updateWord(currentWord.copyWith(
          levelScore: currentWord.levelScore + 1,
        ));
      } else {
        _audioPlayer.play(AssetSource('sounds/fail.mp3'));
      }
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedOptionIndex = null;
      });
      final allWords = await DatabaseHelper.instance.getAllWords();
      _generateOptions(allWords);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, size: 64, color: Colors.amber),
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueGrey.shade900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $_score / ${_questions.length}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _score > (_questions.length / 2) ? 'Great job!' : 'You need more practice.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Go to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
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
                   'You need at least 4 words to start a quiz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade900, fontWeight: FontWeight.w700),
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

    final currentWord = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Quiz', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $_score',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
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
                      children: [
                        Text(
                          'WHAT IS THE MEANING OF THIS WORD?',
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
                          currentWord.word,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.blueGrey.shade900,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(4, (index) {
                    final option = _currentOptions[index];
                    return _buildOptionTile(index, option, currentWord.meaning);
                  }),
                ],
              ),
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'SEE RESULTS',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index, String option, String correctAnswer) {
    Color borderColor = Colors.transparent;
    Color bgColor = Colors.white;
    Color textColor = Colors.blueGrey.shade700;
    IconData? icon;

    if (_answered) {
      if (option == correctAnswer) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(0.1);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
      } else if (index == _selectedOptionIndex) {
        borderColor = const Color(0xFFF43F5E);
        bgColor = const Color(0xFFF43F5E).withOpacity(0.1);
        textColor = const Color(0xFFF43F5E);
        icon = Icons.cancel_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleOptionTap(index),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _answered && option == correctAnswer
                          ? const Color(0xFF10B981).withOpacity(0.2)
                          : _answered && index == _selectedOptionIndex
                              ? const Color(0xFFF43F5E).withOpacity(0.2)
                              : Colors.grey.shade100,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _answered && option == correctAnswer
                              ? const Color(0xFF10B981)
                              : _answered && index == _selectedOptionIndex
                                  ? const Color(0xFFF43F5E)
                                  : Colors.blueGrey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textColor),
                    ),
                  ),
                  if (icon != null) Icon(icon, color: borderColor, size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
