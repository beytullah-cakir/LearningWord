import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';
import 'spelling_mastery_screen.dart';
import 'speed_match_screen.dart';
import 'voice_shadowing_screen.dart';
import 'sentence_challenge_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Future<Map<String, List<Word>>> _dailyDataFuture;

  @override
  void initState() {
    super.initState();
    _dailyDataFuture = _loadDailyData();
  }

  Future<Map<String, List<Word>>> _loadDailyData() async {
    final allWords = await DatabaseHelper.instance.getAllWords();
    final now = DateTime.now();
    
    // Group A: Recent (0-1 day ago) -> Standard Exercises
    final yesterdayWords = allWords.where((w) {
      try {
        final createdAt = DateTime.parse(w.createdAt);
        final difference = now.difference(createdAt).inDays;
        return difference <= 1;
      } catch (e) {
        return false;
      }
    }).toList();

    // Group B: Slightly older (2 days ago) -> Sentence Building
    final dayBeforeWords = allWords.where((w) {
      try {
        final createdAt = DateTime.parse(w.createdAt);
        final difference = now.difference(createdAt).inDays;
        return difference >= 2 && difference <= 3; // Let's give a bit more range
      } catch (e) {
        return false;
      }
    }).toList();

    return {
      'yesterday': yesterdayWords,
      'dayBefore': dayBeforeWords,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Daily Challenge', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<Word>>>(
        future: _dailyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final yesterdayWords = data['yesterday'] ?? [];
          final dayBeforeWords = data['dayBefore'] ?? [];

          if (yesterdayWords.isEmpty && dayBeforeWords.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGoalHeader(yesterdayWords.length + dayBeforeWords.length),
                
                if (yesterdayWords.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader('YESTERDAY\'S WORDS', Icons.history_rounded),
                  const SizedBox(height: 16),
                  _buildExerciseGrid(context, yesterdayWords),
                ],

                if (dayBeforeWords.isNotEmpty) ...[
                  const SizedBox(height: 48),
                  _buildSectionHeader('OLDER WORDS: SENTENCE BUILDING', Icons.create_rounded),
                  const SizedBox(height: 16),
                  _buildSentenceChallengeCard(context, dayBeforeWords),
                ],

                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey.shade200),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.blueGrey.shade200,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceChallengeCard(BuildContext context, List<Word> words) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.create_rounded, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Sentence Building',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      'Use older words in sentences',
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => SentenceChallengeScreen(words: words)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('START SENTENCE BUILDING', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseGrid(BuildContext context, List<Word> words) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildExerciseCard(
          context,
          title: 'Spelling',
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF0EA5E9),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SpellingMasteryScreen(customWords: words)),
          ),
        ),
        _buildExerciseCard(
          context,
          title: 'Speed Match',
          icon: Icons.bolt_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SpeedMatchScreen(customWords: words)),
          ),
        ),
        _buildExerciseCard(
          context,
          title: 'Voice',
          icon: Icons.record_voice_over_rounded,
          color: const Color(0xFF8B5CF6),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VoiceShadowingScreen(customWords: words)),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready for today?',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Review $count new words!',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 24),
            Text(
              'No words today!',
              style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add some words and come back tomorrow.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
