import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

import 'package:audioplayers/audioplayers.dart';

class SpeedMatchScreen extends StatefulWidget {
  final List<Word>? customWords;
  const SpeedMatchScreen({super.key, this.customWords});

  @override
  State<SpeedMatchScreen> createState() => _SpeedMatchScreenState();
}

class _SpeedMatchScreenState extends State<SpeedMatchScreen> {
  List<Word> _allWords = [];
  List<Word> _currentBatchWords = [];
  List<String> _englishList = [];
  List<String> _turkishList = [];
  String? _selectedEnglish;
  String? _selectedTurkish;
  final List<String> _matchedPairsBatch = [];
  int _timeLeft = 0;
  Timer? _timer;
  bool _isLoading = true;
  int _score = 0;
  int _currentBatchIndex = 0;
  static const int batchSize = 5;
  final AudioPlayer _audioPlayer = AudioPlayer();


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }


  Future<void> _loadData() async {
    final words = widget.customWords ?? await DatabaseHelper.instance.getAllWords();
    if (words.isNotEmpty) {
      setState(() {
        // Sort by levelScore (lowest first)
        final sortedWords = List<Word>.from(words)..sort((a, b) => a.levelScore.compareTo(b.levelScore));
        // Take the 30 lowest score words and shuffle them to pick the set to play
        final pool = sortedWords.take(30).toList()..shuffle();
        _allWords = pool;
        _timeLeft = _allWords.length * 8; // Total time for all words
        _currentBatchIndex = 0;
        _score = 0;
        _loadNextBatch();
        _isLoading = false;
      });
      _startTimer();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _loadNextBatch() {
    final start = _currentBatchIndex * batchSize;
    if (start >= _allWords.length) {
      _timer?.cancel();
      _showResults();
      return;
    }

    final end = (start + batchSize < _allWords.length) ? start + batchSize : _allWords.length;
    _currentBatchWords = _allWords.sublist(start, end);
    
    setState(() {
      _englishList = _currentBatchWords.map((e) => e.word).toList()..shuffle();
      _turkishList = _currentBatchWords.map((e) => e.meaning).toList()..shuffle();
      _matchedPairsBatch.clear();
      _selectedEnglish = null;
      _selectedTurkish = null;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
        _showResults();
      }
    });
  }

  void _onItemTap(String val, bool isEnglish) {
    setState(() {
      if (isEnglish) {
        _selectedEnglish = val;
      } else {
        _selectedTurkish = val;
      }

      if (_selectedEnglish != null && _selectedTurkish != null) {
        final pairMatch = _currentBatchWords.any((w) => w.word == _selectedEnglish && w.meaning == _selectedTurkish);
        if (pairMatch) {
          _score += 10;
          _matchedPairsBatch.add(_selectedEnglish!);
          _matchedPairsBatch.add(_selectedTurkish!);
          _audioPlayer.play(AssetSource('sounds/success.mp3'));
          
          // Find the word that was matched and increment its levelScore
          try {
            final matchedWord = _currentBatchWords.firstWhere((w) => w.word == _selectedEnglish && w.meaning == _selectedTurkish);
            DatabaseHelper.instance.updateWord(matchedWord.copyWith(
              levelScore: matchedWord.levelScore + 1,
            ));
          } catch (e) {
            // Word not found in current batch (shouldn't happen)
          }
          
          if (_matchedPairsBatch.length == _currentBatchWords.length * 2) {
            // Batch completed
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _currentBatchIndex++;
                _loadNextBatch();
              }
            });
          }
        } else {
          _audioPlayer.play(AssetSource('sounds/fail.mp3'));
        }
        _selectedEnglish = null;
        _selectedTurkish = null;
      }
    });
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
                decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.timer_off_rounded, size: 64, color: Colors.amber),
              ),
              const SizedBox(height: 24),
              Text(
                'Time\'s Up!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade900),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Score: $_score',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF6366F1)),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Close', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_allWords.isEmpty) return _buildEmptyState();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Speed Match', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Score: $_score',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 13),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: _timeLeft < 10 ? const Color(0xFFF43F5E) : const Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _timeLeft / (_allWords.length * 8),
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft < 10 ? const Color(0xFFF43F5E) : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$_timeLeft seconds left',
                  style: TextStyle(
                    color: _timeLeft < 10 ? const Color(0xFFF43F5E) : Colors.blueGrey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildList(_englishList, true),
                  const SizedBox(width: 16),
                  _buildList(_turkishList, false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildList(List<String> items, bool isEnglish) {
    return Expanded(
      child: items.length > 8
          ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 64,
                child: _buildItem(items[index], isEnglish),
              ),
            )
          : Column(
              children: items.map((item) => Expanded(child: _buildItem(item, isEnglish))).toList(),
            ),
    );
  }

  Widget _buildItem(String item, bool isEnglish) {
    final isMatched = _matchedPairsBatch.contains(item);
    final isSelected = (isEnglish ? _selectedEnglish : _selectedTurkish) == item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: isMatched ? null : () => _onItemTap(item, isEnglish),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isMatched
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : isSelected
                      ? const Color(0xFF6366F1).withOpacity(0.12)
                      : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMatched
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isMatched
                        ? const Color(0xFF10B981).withOpacity(0.5)
                        : isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.blueGrey.shade800,
                    decoration: isMatched ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: const Text('Speed Match', style: TextStyle(fontWeight: FontWeight.w900))),
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
                'Insufficient Words',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade900),
              ),
              const SizedBox(height: 12),
              Text(
                'You need at least 1 word to play Speed Match.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

