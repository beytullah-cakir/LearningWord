import 'package:flutter/material.dart';
import 'spelling_mastery_screen.dart';
import 'speed_match_screen.dart';
import 'voice_shadowing_screen.dart';
import 'quiz_screen.dart';
import '../../core/localization/app_translation.dart';

class LearningModulesScreen extends StatefulWidget {
  const LearningModulesScreen({super.key});

  @override
  State<LearningModulesScreen> createState() => _LearningModulesScreenState();
}

class _LearningModulesScreenState extends State<LearningModulesScreen> {
  final translation = LanguageManager();

  @override
  void initState() {
    super.initState();
    translation.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    translation.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(translation.tr('learning_modules'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
        children: [
          _buildModuleCard(
            context,
            title: translation.tr('spelling'),
            subtitle: translation.tr('spelling_subtitle'),
            icon: Icons.edit_note,
            color: Colors.blueAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpellingMasteryScreen())),
          ),
          _buildModuleCard(
            context,
            title: translation.tr('speed_match'),
            subtitle: translation.tr('speed_match_subtitle'),
            icon: Icons.bolt,
            color: Colors.orangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeedMatchScreen())),
          ),
          _buildModuleCard(
            context,
            title: translation.tr('voice_shadowing'),
            subtitle: translation.tr('voice_subtitle'),
            icon: Icons.record_voice_over,
            color: Colors.pinkAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceShadowingScreen())),
          ),
          _buildModuleCard(
            context,
            title: translation.tr('multiple_choice'),
            subtitle: translation.tr('quiz_subtitle'),
            icon: Icons.quiz,
            color: Colors.tealAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
