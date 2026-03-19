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
    var check = await (Connectivity().checkConnectivity());
    if (check.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userLevel = prefs.getString('userLevel') ?? 'A1';
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
        await DatabaseHelper.instance.updateWord(updatedWord);
        setState(() => _currentWord = updatedWord);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İnternet Bağlantısı Gerekli'),
        content: const Text('Yapay zeka ile cümle oluşturabilmek için aktif bir internet bağlantınızın olması gerekmektedir.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(_currentWord.english, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
            ),
            onPressed: () => _confirmDelete(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
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
                children: [
                  Text(
                    _currentWord.english,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentWord.turkish,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366F1), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Örnek Cümle (AI)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentWord.aiSentence.isNotEmpty) ...[
              _buildSentenceCard(_currentWord.aiSentence, _currentWord.aiSentenceTr),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateAISentence,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Yeni Cümle Oluştur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6366F1),
                  side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.2)),
                  elevation: 0,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, size: 40, color: Color(0xFF6366F1)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Henüz bir örnek cümle oluşturulmamış.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _generateAISentence,
                            icon: const Icon(Icons.bolt_rounded),
                            label: const Text('Hemen Oluştur'),
                          ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),
            Text(
              "Eklenme Tarihi: ${DateTime.parse(_currentWord.createdAt).toLocal().toString().split('.').first}",
              style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceCard(String sentence, String translation) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sentence,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade900,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFF1F5F9)),
          ),
          Text(
            translation,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w500,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Kelimeyi Sil', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('${_currentWord.english} kelimesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Sil', style: TextStyle(fontWeight: FontWeight.bold)),
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

