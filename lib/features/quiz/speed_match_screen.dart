import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';
import '../../core/localization/app_translation.dart';
import 'package:audioplayers/audioplayers.dart';

class SpeedMatchScreen extends StatefulWidget {
  const SpeedMatchScreen({super.key});

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
  final translation = LanguageManager();

  @override
  void initState() {
    super.initState();
    _loadData();
    translation.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    _timer?.cancel();
    translation.removeListener(_onLanguageChange);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onLanguageChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final words = await DatabaseHelper.instance.getAllWords();
    if (words.isNotEmpty) {
      setState(() {
        _allWords = words..shuffle();
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
      _englishList = _currentBatchWords.map((e) => e.english).toList()..shuffle();
      _turkishList = _currentBatchWords.map((e) => e.turkish).toList()..shuffle();
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
        final pairMatch = _currentBatchWords.any((w) => w.english == _selectedEnglish && w.turkish == _selectedTurkish);
        if (pairMatch) {
          _score += 10;
          _matchedPairsBatch.add(_selectedEnglish!);
          _matchedPairsBatch.add(_selectedTurkish!);
          _audioPlayer.play(AssetSource('sounds/success.mp3'));
          
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(translation.tr('time_up'), style: const TextStyle(color: Colors.white)),
        content: Text('${translation.tr('your_score')}: $_score', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: Text(translation.tr('try_again'), style: const TextStyle(color: Colors.deepPurpleAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(translation.tr('close'), style: const TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_allWords.isEmpty) return _buildEmptyState();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(translation.tr('speed_match'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '${translation.tr('score')}: $_score',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: _timeLeft < 10 ? Colors.redAccent : Colors.orangeAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _timeLeft / (_allWords.length * 8),
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft < 10 ? Colors.redAccent : Colors.orangeAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$_timeLeft ${translation.tr('seconds_left')}',
                  style: TextStyle(
                    color: _timeLeft < 10 ? Colors.redAccent : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                   _buildList(_englishList, true),
                   const SizedBox(width: 12),
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
      child: items.length > 10
          ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) => SizedBox(
                height: 70,
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
                  ? Colors.green.withOpacity(0.05)
                  : isSelected
                      ? Colors.deepPurple.withOpacity(0.3)
                      : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMatched
                    ? Colors.green.withOpacity(0.2)
                    : isSelected
                        ? Colors.deepPurpleAccent
                        : Colors.white10,
                width: isSelected || isMatched ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isMatched
                        ? Colors.white24
                        : isSelected
                            ? Colors.deepPurpleAccent
                            : Colors.white,
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(translation.tr('speed_match')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orangeAccent),
              ),
              const SizedBox(height: 24),
              Text(
                translation.tr('insufficient_words'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                translation.tr('need_words_game'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(translation.tr('back'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

