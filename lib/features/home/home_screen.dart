import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../words/add_word_screen.dart';
import '../words/words_list_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../quiz/learning_modules_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userLevel = '-';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app we would load actual stats from DatabaseHelper here
    setState(() {
      _userLevel = prefs.getString('userLevel') ?? 'A1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VocabFlow AI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              label: Text(_userLevel, style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hızlı İşlemler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildActionGrid(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionCard(
          title: 'Kelime Ekle',
          icon: Icons.add_circle_outline,
          color: Colors.blueAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddWordScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Flashcards',
          icon: Icons.style,
          color: Colors.deepOrangeAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FlashcardsScreen()),
            );
          },
        ),
        _buildActionCard(
          title: 'Quiz & Test',
          icon: Icons.quiz,
          color: Colors.pinkAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LearningModulesScreen()),
            );
          },
        ),

        _buildActionCard(
          title: 'Kelimelerim',
          icon: Icons.list_alt,
          color: Colors.tealAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordsListScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
