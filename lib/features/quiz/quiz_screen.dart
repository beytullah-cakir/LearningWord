import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final allWords = await DatabaseHelper.instance.getAllWords();
    if (allWords.length < 4) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _questions = [];
        });
      }
      return;
    }

    // Shuffle and pick 10 words (or all if less than 10)
    final shuffled = List<Word>.from(allWords)..shuffle();
    _questions = shuffled.take(10).toList();
    
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
    List<String> options = [correctWord.turkish];
    
    // Get wrong options
    final random = Random();
    while (options.length < 4) {
      final randomWord = allWords[random.nextInt(allWords.length)];
      if (!options.contains(randomWord.turkish)) {
        options.add(randomWord.turkish);
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
      if (_currentOptions[index] == _questions[_currentQuestionIndex].turkish) {
        _score++;
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Tamamlandı!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            Text(
              'Skorun: $_score / ${_questions.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _score > (_questions.length / 2) ? 'Harika gidiyorsun!' : 'Daha fazla çalışmalısın.',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orangeAccent),
                const SizedBox(height: 16),
                const Text(
                  'Quiz başlatmak için en az 4 kelime eklemelisiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentWord = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soru: ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    Text(
                      'Skor: $_score',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BU KELİMENİN ANLAMI NEDİR?',
                          style: TextStyle(
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentWord.english,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(4, (index) {
                    final option = _currentOptions[index];
                    return _buildOptionTile(index, option, currentWord.turkish);
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
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1 ? 'Sonraki Soru' : 'Sonuçları Gör',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index, String option, String correctAnswer) {
    Color? borderColor = Colors.white10;
    Color? bgColor = Theme.of(context).cardTheme.color;
    IconData? icon;

    if (_answered) {
      if (option == correctAnswer) {
        borderColor = Colors.greenAccent;
        bgColor = Colors.greenAccent.withOpacity(0.1);
        icon = Icons.check_circle;
      } else if (index == _selectedOptionIndex) {
        borderColor = Colors.redAccent;
        bgColor = Colors.redAccent.withOpacity(0.1);
        icon = Icons.cancel;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _handleOptionTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              if (icon != null) Icon(icon, color: borderColor),
            ],
          ),
        ),
      ),
    );
  }
}
