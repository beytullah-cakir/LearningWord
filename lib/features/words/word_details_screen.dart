import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/ai_service.dart';
import '../../models/word_model.dart';

class WordDetailsScreen extends StatefulWidget {
  final Word word;
  const WordDetailsScreen({super.key, required this.word});

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  late Word _currentWord;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentWord = widget.word;
  }

  Future<void> _generateAISentence() async {
    // 1. Check Internet Connection
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userLevel = prefs.getString('userLevel') ?? 'A1';

      // NOTE: In a real scenario, the API key should be stored securely.
      // For this task, I'll use a placeholder or assume it's pre-configured in the service.
      final aiService = AiPromptService(apiKey: 'YOUR_GEMINI_API_KEY_HERE');
      
      final result = await aiService.generateSentence(
        englishWord: _currentWord.english,
        level: userLevel,
      );

      if (result != null && result['sentence'] != null) {
        final updatedWord = _currentWord.copyWith(
          aiSentence: result['sentence']!,
          aiSentenceTr: result['translation']!,
        );

        // Save to SQLite
        await DatabaseHelper.instance.updateWord(updatedWord);

        setState(() {
          _currentWord = updatedWord;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cümle başarıyla oluşturuldu!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('AI yanıt vermedi.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İnternet Bağlantısı Gerekli'),
        content: const Text(
            'Yapay zeka ile cümle oluşturabilmek için aktif bir internet bağlantınızın olması gerekmektedir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentWord.english),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Word Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    _currentWord.english,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentWord.turkish,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI Sentence Section
            Text(
              'Örnek Cümle (AI)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 12),
            if (_currentWord.aiSentence.isNotEmpty) ...[
              _buildSentenceCard(_currentWord.aiSentence, _currentWord.aiSentenceTr),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _generateAISentence,
                icon: const Icon(Icons.refresh),
                label: const Text('Cümleyi Yeniden Oluştur'),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz bir örnek cümle oluşturulmamış.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _generateAISentence,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Örnek Cümle Oluştur'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),
            Text(
              "Eklenme Tarihi: ${DateTime.parse(_currentWord.createdAt).toLocal().toString().split('.').first}",
              style: const TextStyle(color: Colors.white24, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceCard(String sentence, String translation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sentence,
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10),
          ),
          Text(
            translation,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kelimeyi Sil'),
        content: Text('${_currentWord.english} kelimesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (result == true) {
      await DatabaseHelper.instance.deleteWord(_currentWord.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
