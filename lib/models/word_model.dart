class Word {
  final int? id;
  final String word;
  final String meaning;
  final int levelScore;
  final String aiSentence;
  final String aiSentenceMeaning;
  final String createdAt;

  Word({
    this.id,
    required this.word,
    required this.meaning,
    required this.levelScore,
    required this.aiSentence,
    required this.aiSentenceMeaning,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'word': word,
      'meaning': meaning,
      'level_score': levelScore,
      'ai_sentence': aiSentence,
      'ai_sentence_meaning': aiSentenceMeaning,
      'created_at': createdAt,
    };
  }

  static Word fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      word: map['word'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
      levelScore: map['level_score'] as int? ?? 0,
      aiSentence: map['ai_sentence'] as String? ?? '',
      aiSentenceMeaning: map['ai_sentence_meaning'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  Word copyWith({
    int? id,
    String? word,
    String? meaning,
    int? levelScore,
    String? aiSentence,
    String? aiSentenceMeaning,
    String? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      levelScore: levelScore ?? this.levelScore,
      aiSentence: aiSentence ?? this.aiSentence,
      aiSentenceMeaning: aiSentenceMeaning ?? this.aiSentenceMeaning,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
