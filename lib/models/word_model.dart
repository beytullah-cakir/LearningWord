class Word {
  final int? id;
  final String english;
  final String turkish;
  final int levelScore;
  final String aiSentence;
  final String aiSentenceTr;
  final String createdAt;

  Word({
    this.id,
    required this.english,
    required this.turkish,
    required this.levelScore,
    required this.aiSentence,
    required this.aiSentenceTr,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'english': english,
      'turkish': turkish,
      'level_score': levelScore,
      'ai_sentence': aiSentence,
      'ai_sentence_tr': aiSentenceTr,
      'created_at': createdAt,
    };
  }

  static Word fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      english: map['english'] as String,
      turkish: map['turkish'] as String,
      levelScore: map['level_score'] as int,
      aiSentence: map['ai_sentence'] as String,
      aiSentenceTr: map['ai_sentence_tr'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Word copyWith({
    int? id,
    String? english,
    String? turkish,
    int? levelScore,
    String? aiSentence,
    String? aiSentenceTr,
    String? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      turkish: turkish ?? this.turkish,
      levelScore: levelScore ?? this.levelScore,
      aiSentence: aiSentence ?? this.aiSentence,
      aiSentenceTr: aiSentenceTr ?? this.aiSentenceTr,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
