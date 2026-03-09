import 'package:flutter/material.dart';
import 'spelling_mastery_screen.dart';
import 'speed_match_screen.dart';
import 'voice_shadowing_screen.dart';
import 'quiz_screen.dart'; // This is the original multiple choice quiz

class LearningModulesScreen extends StatelessWidget {
  const LearningModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenme Modülleri', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
        children: [
          _buildModuleCard(
            context,
            title: 'Spelling Mastery',
            subtitle: 'Yazma yeteneğini geliştir',
            icon: Icons.edit_note,
            color: Colors.blueAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpellingMasteryScreen())),
          ),
          _buildModuleCard(
            context,
            title: 'Speed Match',
            subtitle: 'Zamana karşı eşleştir',
            icon: Icons.bolt,
            color: Colors.orangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeedMatchScreen())),
          ),
          _buildModuleCard(
            context,
            title: 'Voice Shadowing',
            subtitle: 'Telaffuzunu puanla',
            icon: Icons.record_voice_over,
            color: Colors.pinkAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceShadowingScreen())),
          ),
          _buildModuleCard(
            context,
            title: 'Multiple Choice',
            subtitle: 'Klasik test modu',
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
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
