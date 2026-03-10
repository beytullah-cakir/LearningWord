import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/database/database_helper.dart';
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
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kelimeyi Sil'),
          content: Text('${word.english} kelimesini silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await DatabaseHelper.instance.deleteWord(word.id!);
        _refreshWords();
      }
    }
  }

  void _showWordDetails(Word word) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                word.english,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                word.turkish,
                style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white10),
              ),
              const Text(
                'AI Örnek Cümle',
                style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  word.aiSentence.isNotEmpty ? word.aiSentence : 'Henüz cümle oluşturulmadı.',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                ),
              ),
              if (word.aiSentenceTr.isNotEmpty) ...[
                 const SizedBox(height: 8),
                 Text(
                  word.aiSentenceTr,
                  style: const TextStyle(fontSize: 14, color: Colors.white38),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editWord(Word word) async {
    final englishController = TextEditingController(text: word.english);
    final turkishController = TextEditingController(text: word.turkish);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kelimeyi Düzenle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: englishController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'İngilizce',
                  labelStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: turkishController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Türkçe',
                  labelStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal', style: TextStyle(color: Colors.white38)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (englishController.text.isNotEmpty && turkishController.text.isNotEmpty) {
                          final updatedWord = word.copyWith(
                            english: englishController.text.trim(),
                            turkish: turkishController.text.trim(),
                          );
                          await DatabaseHelper.instance.updateWord(updatedWord);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          _refreshWords();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Kelimelerim',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Word>>(
                  future: _wordsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final words = snapshot.data ?? [];

                    if (words.isEmpty) {
                      return const Center(
                        child: Text('Henüz kelime eklemedin.', style: TextStyle(color: Colors.white38)),
                      );
                    }

                    return ListView.builder(
                      itemCount: words.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Slidable(
                            key: ValueKey(word.id),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.45,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => _editWord(word),
                                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                  foregroundColor: Colors.blueAccent,
                                  icon: Icons.edit_rounded,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                SlidableAction(
                                  onPressed: (_) => _deleteWord(word),
                                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                                  foregroundColor: Colors.redAccent,
                                  icon: Icons.delete_rounded,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ],
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                title: Text(
                                  word.english,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Text(
                                  word.turkish,
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                trailing: word.aiSentence.isNotEmpty
                                    ? Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20)
                                    : null,
                                onTap: () => _showWordDetails(word),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
