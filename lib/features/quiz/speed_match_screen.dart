import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

class SpeedMatchScreen extends StatefulWidget {
  const SpeedMatchScreen({super.key});

  @override
  State<SpeedMatchScreen> createState() => _SpeedMatchScreenState();
}

class _SpeedMatchScreenState extends State<SpeedMatchScreen> {
  List<Word> _words = [];
  List<String> _englishList = [];
  List<String> _turkishList = [];
  String? _selectedEnglish;
  String? _selectedTurkish;
  List<String> _matchedPairs = [];
  int _timeLeft = 45;
  Timer? _timer;
  bool _isLoading = true;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final words = await DatabaseHelper.instance.getAllWords();
    if (words.length >= 6) {
      final selected = (words..shuffle()).take(6).toList();
      setState(() {
        _words = selected;
        _englishList = selected.map((e) => e.english).toList()..shuffle();
        _turkishList = selected.map((e) => e.turkish).toList()..shuffle();
        _isLoading = false;
      });
      _startTimer();
    } else {
      setState(() => _isLoading = false);
    }
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
        final pairMatch = _words.any((w) => w.english == _selectedEnglish && w.turkish == _selectedTurkish);
        if (pairMatch) {
          _score += 10;
          _matchedPairs.add(_selectedEnglish!);
          _matchedPairs.add(_selectedTurkish!);
          if (_matchedPairs.length == _words.length * 2) {
            _timer?.cancel();
            _showResults();
          }
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
        title: const Text('Süre Bitti!'),
        content: Text('Skorun: $_score'),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tekrar')),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          }, child: const Text('Kapat')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_words.isEmpty) return _buildEmptyState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Match'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('Score: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _timeLeft / 45,
                    color: _timeLeft < 10 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Text('$_timeLeft s', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildList(_englishList, true),
                _buildList(_turkishList, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<String> items, bool isEnglish) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isMatched = _matchedPairs.contains(item);
          final isSelected = (isEnglish ? _selectedEnglish : _selectedTurkish) == item;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: isMatched ? null : () => _onItemTap(item, isEnglish),
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: isMatched ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.deepPurple : Colors.white10),
                  ),
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Speed Match')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('En az 6 kelime eklemelisiniz!'),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Geri Dön')),
          ],
        ),
      ),
    );
  }
}
