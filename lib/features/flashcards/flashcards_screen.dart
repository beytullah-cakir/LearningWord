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
  bool _isExiting = false;


  @override
  void initState() {
    super.initState();
    _wordsFuture = DatabaseHelper.instance.getAllWords();
    _initTts();
  }

  @override
  void dispose() {
    super.dispose();
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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final words = snapshot.data;
          if (words == null || words.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.style_outlined, size: 64, color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No words added yet.',
                      style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blueGrey.shade400, fontSize: 13),
                        ),
                        Text(
                          '${_currentIndex + 1} / ${words.length}',
                          style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / words.length,
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      if (_currentIndex == words.length - 1 &&
                          notification.metrics.pixels > notification.metrics.maxScrollExtent + 40) {
                        if (!_isExiting) {
                          _isExiting = true;
                          Navigator.pop(context);
                        }
                      }
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: words.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: FlipCard(
                          direction: FlipDirection.HORIZONTAL,
                          front: _buildCardSide(
                            context,
                            title: 'Word',
                            content: word.word,
                            color: Colors.white,
                            textColor: Colors.blueGrey.shade900,
                            isFront: true,
                          ),
                          back: _buildCardSide(
                            context,
                            title: 'Meaning',
                            content: word.meaning,
                            color: const Color(0xFF6366F1),
                            textColor: Colors.white,
                            isFront: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: isFront ? Colors.black.withOpacity(0.05) : const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: isFront ? Border.all(color: Colors.grey.shade100) : null,
      ),
      child: Stack(
        children: [
          if (isFront)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF6366F1), size: 28),
                  onPressed: () => _speak(content),
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: isFront ? Colors.blueGrey.shade200 : Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: isFront ? Colors.blueGrey.shade100 : Colors.white.withOpacity(0.3),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to flip',
                  style: TextStyle(
                    color: isFront ? Colors.blueGrey.shade100 : Colors.white.withOpacity(0.3),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
