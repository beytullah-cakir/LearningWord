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
          'word': 'Apple',
          'meaning': 'Elma',
          'level_score': 0,
          'ai_sentence': 'I ate a sweet apple this morning.',
          'ai_sentence_meaning': 'Bu sabah tatlı bir elma yedim.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Book',
          'meaning': 'Kitap',
          'level_score': 0,
          'ai_sentence': 'She is reading an interesting book.',
          'ai_sentence_meaning': 'İlginç bir kitap okuyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Computer',
          'meaning': 'Bilgisayar',
          'level_score': 0,
          'ai_sentence': 'He uses his computer for work.',
          'ai_sentence_meaning': 'İşi için bilgisayarını kullanıyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Daughter',
          'meaning': 'Kız evlat',
          'level_score': 0,
          'ai_sentence': 'Their daughter is very talented.',
          'ai_sentence_meaning': 'Kızları çok yetenekli.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Environment',
          'meaning': 'Çevre',
          'level_score': 0,
          'ai_sentence': 'We must protect our environment.',
          'ai_sentence_meaning': 'Çevremizi korumalıyız.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Friend',
          'meaning': 'Arkadaş',
          'level_score': 0,
          'ai_sentence': 'A true friend is hard to find.',
          'ai_sentence_meaning': 'Gerçek bir arkadaş bulmak zordur.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Guitar',
          'meaning': 'Gitar',
          'level_score': 0,
          'ai_sentence': 'He plays the guitar beautifully.',
          'ai_sentence_meaning': 'Harika gitar çalıyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Hospital',
          'meaning': 'Hastane',
          'level_score': 0,
          'ai_sentence': 'The hospital is located downtown.',
          'ai_sentence_meaning': 'Hastane şehir merkezinde bulunuyor.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Island',
          'meaning': 'Ada',
          'level_score': 0,
          'ai_sentence': 'They spent their vacation on a tropical island.',
          'ai_sentence_meaning': 'Tatillerini tropik bir adada geçirdiler.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Journey',
          'meaning': 'Yolculuk',
          'level_score': 0,
          'ai_sentence': 'The journey took several hours.',
          'ai_sentence_meaning': 'Yolculuk birkaç saat sürdü.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Library',
          'meaning': 'Kütüphane',
          'level_score': 0,
          'ai_sentence': 'I love spending time in the library.',
          'ai_sentence_meaning': 'Kütüphanede vakit geçirmeyi seviyorum.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Ocean',
          'meaning': 'Okyanus',
          'level_score': 0,
          'ai_sentence': 'The ocean is vast and deep.',
          'ai_sentence_meaning': 'Okyanus engin ve derindir.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Knowledge',
          'meaning': 'Bilgi',
          'level_score': 0,
          'ai_sentence': 'Knowledge is power.',
          'ai_sentence_meaning': 'Bilgi güçtür.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Freedom',
          'meaning': 'Özgürlük',
          'level_score': 0,
          'ai_sentence': 'Freedom is a basic human right.',
          'ai_sentence_meaning': 'Özgürlük temel bir insan hakkıdır.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Mountain',
          'meaning': 'Dağ',
          'level_score': 0,
          'ai_sentence': 'They climbed the highest mountain.',
          'ai_sentence_meaning': 'En yüksek dağa tırmandılar.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Patience',
          'meaning': 'Sabır',
          'level_score': 0,
          'ai_sentence': 'Patience is a virtue.',
          'ai_sentence_meaning': 'Sabır bir erdemdir.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Victory',
          'meaning': 'Zafer',
          'level_score': 0,
          'ai_sentence': 'They celebrated their victory.',
          'ai_sentence_meaning': 'Zaferlerini kutladılar.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Wonder',
          'meaning': 'Merak / Mucize',
          'level_score': 0,
          'ai_sentence': 'The world is full of wonder.',
          'ai_sentence_meaning': 'Dünya mucizelerle doludur.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Courage',
          'meaning': 'Cesaret',
          'level_score': 0,
          'ai_sentence': 'It takes courage to be yourself.',
          'ai_sentence_meaning': 'Kendin olmak cesaret ister.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word': 'Silence',
          'meaning': 'Sessizlik',
          'level_score': 0,
          'ai_sentence': 'Silence can be very powerful.',
          'ai_sentence_meaning': 'Sessizlik çok güçlü olabilir.',
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
