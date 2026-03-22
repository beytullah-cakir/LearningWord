import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../core/services/ai_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SentenceChallengeScreen extends StatefulWidget {
  final List<Word> words;
  const SentenceChallengeScreen({super.key, required this.words});

  @override
  State<SentenceChallengeScreen> createState() => _SentenceChallengeScreenState();
}

class _SentenceChallengeScreenState extends State<SentenceChallengeScreen> {
  final AiPromptService _aiService = AiPromptService(apiKey: 'YOUR_GEMINI_API_KEY_HERE');
  final TextEditingController _controller = TextEditingController();
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _feedback;
  bool _isSuccess = false;

  Future<void> _checkSentence() async {
    final sentence = _controller.text.trim();
    if (sentence.isEmpty) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection for AI review.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final targetLang = prefs.getString('targetLanguage') ?? 'English';
      final wordObj = widget.words[_currentIndex];
      final result = await _aiService.checkSentence(
        word: wordObj.word,
        userSentence: sentence,
        targetLanguage: targetLang,
      );
      
      setState(() {
        if (result != null) {
          _isSuccess = result['isCorrect'] as bool? ?? false;
          _feedback = result['feedback']?.toString() ?? 'No feedback provided.';
        } else {
          _isSuccess = false;
          _feedback = "Could not check sentence now.";
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _feedback = "Error checking sentence. Please try again.";
        _isLoading = false;
      });
    }
  }

  void _next() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.clear();
        _feedback = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) return const Scaffold(body: Center(child: Text('No words to review.')));

    final word = widget.words[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Sentence Challenge', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MAKE A SENTENCE WITH THIS WORD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey.shade200,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Text(
                    word.word,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.meaning,
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              maxLines: 3,
              style: TextStyle(color: Colors.blueGrey.shade900, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Type your sentence here...',
                hintStyle: TextStyle(color: Colors.blueGrey.shade200),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_feedback != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isSuccess ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                ),
                child: Text(
                  _feedback!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isSuccess ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            if (_feedback == null)
              ElevatedButton(
                onPressed: _isLoading ? null : _checkSentence,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT SENTENCE', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                   _currentIndex < widget.words.length - 1 ? 'NEXT WORD' : 'FINISH CHALLENGE',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
