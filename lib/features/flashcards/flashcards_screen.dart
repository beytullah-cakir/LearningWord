import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late Future<List<Word>> _wordsFuture;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _wordsFuture = DatabaseHelper.instance.getAllWords();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final words = snapshot.data;
          if (words == null || words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.style_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('Henüz kelime eklemediniz.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Geri Dön'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / words.length,
                      backgroundColor: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentIndex + 1} / ${words.length}',
                      style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: words.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: _buildCardSide(
                          context,
                          title: 'İngilizce',
                          content: word.english,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          isFront: true,
                        ),
                        back: _buildCardSide(
                          context,
                          title: 'Türkçe',
                          content: word.turkish,
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          isFront: false,
                          example: word.aiSentence,
                          exampleTr: word.aiSentenceTr,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      label: 'Tekrar Et',
                      color: Colors.redAccent,
                      onTap: () => _nextCard(words.length),
                    ),
                    _buildActionButton(
                      icon: Icons.check,
                      label: 'Öğrendim',
                      color: Colors.greenAccent,
                      onTap: () => _nextCard(words.length),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required String title,
    required String content,
    required Color color,
    required Color textColor,
    required bool isFront,
    String? example,
    String? exampleTr,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 42,
                    ),
                  ),
                  if (!isFront) ...[
                    if (example != null && example.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white24, indent: 40, endIndent: 40),
                      const SizedBox(height: 20),
                      Text(
                        'Örnek Cümle:',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        example,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exampleTr ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 40),
                      const Divider(color: Colors.white10, indent: 40, endIndent: 40),
                      const SizedBox(height: 20),
                      Icon(Icons.auto_awesome, color: textColor.withOpacity(0.3), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Cümle oluşturmak için dokun',
                        style: TextStyle(
                          color: textColor.withOpacity(0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (isFront)
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.volume_up, color: textColor),
                onPressed: () => _speak(content),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: textColor.withOpacity(0.3), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Çevirmek için dokun',
                  style: TextStyle(color: textColor.withOpacity(0.3), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  void _nextCard(int total) {
    if (_currentIndex < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tebrikler!'),
          content: const Text('Tüm kelimeleri gözden geçirdiniz.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Tamamla'),
            ),
          ],
        ),
      );
    }
  }
}
