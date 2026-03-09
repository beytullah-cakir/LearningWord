import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import 'word_details_screen.dart';
import '../../models/word_model.dart';

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key});

  @override
  State<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends State<WordsListScreen> {
  late Future<List<Word>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _refreshWords();
  }

  void _refreshWords() {
    setState(() {
      _wordsFuture = DatabaseHelper.instance.getAllWords();
    });
  }

  Future<void> _deleteWord(Word word) async {
    if (word.id != null) {
      await DatabaseHelper.instance.deleteWord(word.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kelime silindi.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      _refreshWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelimelerim', style: TextStyle(fontWeight: FontWeight.bold)),
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
            return const Center(
              child: Text('Henüz hiç kelime eklemedin.', style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(word.english, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(word.turkish),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (word.aiSentence.isNotEmpty)
                        Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteWord(word),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailsScreen(word: word),
                      ),
                    );
                    if (result == true) {
                      _refreshWords();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
