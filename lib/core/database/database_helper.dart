import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String _boxName = 'words_box';

  DatabaseHelper._init();

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<int> insertWord(Word word) async {
    final box = await _box;
    // We use a timestamp-based ID if not provided, or let Hive generate one
    final id = await box.add(word.toMap());
    // Update the record with its generated ID
    final wordWithId = word.copyWith(id: id);
    await box.put(id, wordWithId.toMap());
    return id;
  }

  Future<List<Word>> getAllWords() async {
    final box = await _box;
    final List<Word> words = [];
    
    for (var key in box.keys) {
      final map = Map<String, dynamic>.from(box.get(key));
      words.add(Word.fromMap({...map, 'id': key}));
    }
    
    // Sort by created_at DESC
    words.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return words;
  }

  Future<int> updateWord(Word word) async {
    if (word.id == null) return -1;
    final box = await _box;
    await box.put(word.id, word.toMap());
    return word.id!;
  }

  Future<int> deleteWord(int id) async {
    final box = await _box;
    await box.delete(id);
    return id;
  }

  Future<void> seedDatabaseManual() async {
    final box = await _box;
    if (box.isEmpty) {
      final List<Map<String, dynamic>> testWords = [
        {
          'english': 'Apple',
          'turkish': 'Elma',
          'level_score': 0,
          'ai_sentence': 'I ate a sweet apple this morning.',
          'ai_sentence_tr': 'Bu sabah tatlı bir elma yedim.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Book',
          'turkish': 'Kitap',
          'level_score': 0,
          'ai_sentence': 'She is reading an interesting book.',
          'ai_sentence_tr': 'İlginç bir kitap okuyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Computer',
          'turkish': 'Bilgisayar',
          'level_score': 0,
          'ai_sentence': 'He uses his computer for work.',
          'ai_sentence_tr': 'İşi için bilgisayarını kullanıyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Daughter',
          'turkish': 'Kız evlat',
          'level_score': 0,
          'ai_sentence': 'Their daughter is very talented.',
          'ai_sentence_tr': 'Kızları çok yetenekli.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Environment',
          'turkish': 'Çevre',
          'level_score': 0,
          'ai_sentence': 'We must protect our environment.',
          'ai_sentence_tr': 'Çevremizi korumalıyız.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Friend',
          'turkish': 'Arkadaş',
          'level_score': 0,
          'ai_sentence': 'A true friend is hard to find.',
          'ai_sentence_tr': 'Gerçek bir arkadaş bulmak zordur.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Guitar',
          'turkish': 'Gitar',
          'level_score': 0,
          'ai_sentence': 'He plays the guitar beautifully.',
          'ai_sentence_tr': 'Harika gitar çalıyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Hospital',
          'turkish': 'Hastane',
          'level_score': 0,
          'ai_sentence': 'The hospital is located downtown.',
          'ai_sentence_tr': 'Hastane şehir merkezinde bulunuyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Island',
          'turkish': 'Ada',
          'level_score': 0,
          'ai_sentence': 'They spent their vacation on a tropical island.',
          'ai_sentence_tr': 'Tatillerini tropik bir adada geçirdiler.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'english': 'Journey',
          'turkish': 'Yolculuk',
          'level_score': 0,
          'ai_sentence': 'The journey took several hours.',
          'ai_sentence_tr': 'Yolculuk birkaç saat sürdü.',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      for (final wordMap in testWords) {
        final id = await box.add(wordMap);
        await box.put(id, {...wordMap, 'id': id});
      }
    }
  }

  Future close() async {
    await Hive.close();
  }
}
