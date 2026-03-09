import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../models/word_model.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishController = TextEditingController();
  final _turkishController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPremium = prefs.getBool('isPremium') ?? false;
    });
  }

  @override
  void dispose() {
    _englishController.dispose();
    _turkishController.dispose();
    super.dispose();
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final englishWord = _englishController.text.trim();
      final turkishWord = _turkishController.text.trim();

      String generatedSentence = '';
      String generatedTranslation = '';

      // NOTE: Manual AI generation trigger is now moved to WordDetailsScreen

      // Create new Word object
      final word = Word(
        english: englishWord,
        turkish: turkishWord,
        levelScore: 0, // Initial score for flashcards/tests
        aiSentence: generatedSentence,
        aiSentenceTr: generatedTranslation,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Insert into local DB
      await DatabaseHelper.instance.insertWord(word);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelime başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields after success
      _englishController.clear();
      _turkishController.clear();
      
      // Optionally navigate back
      // Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: \$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kelime Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _englishController,
                  decoration: const InputDecoration(
                    labelText: 'İngilizce Kelime',
                    prefixIcon: Icon(Icons.language),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen İngilizce bir kelime girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _turkishController,
                  decoration: const InputDecoration(
                    labelText: 'Türkçe Anlamı',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen kelimenin Türkçe anlamını girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveWord,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            _isPremium ? Icons.auto_awesome : Icons.info_outline, 
            color: Theme.of(context).colorScheme.primary, 
            size: 32
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Kelimeyi kaydettikten sonra detay ekranına giderek seviyene uygun bir AI cümlesi oluşturabilirsin.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
