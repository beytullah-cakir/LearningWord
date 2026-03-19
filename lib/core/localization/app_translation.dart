import 'package:flutter/material.dart';

class AppTranslation {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'VocabFlow AI',
      'exercise': 'Exercise',
      'add': 'Add',
      'words': 'Words',
      'flashcards': 'Flashcards',
      'spelling': 'Spelling',
      'speed_match': 'Speed Match',
      'voice': 'Voice',
      'quiz': 'Quiz',
      'add_new_word': 'Add New Word',
      'english_word': 'English Word',
      'turkish_meaning': 'Turkish Meaning',
      'cancel': 'Cancel',
      'required': 'Required',
      'word_added': 'Word added successfully!',
      'error': 'Error',
      'my_words': 'My Words',
      'no_words': 'No words added yet.',
      'delete_word': 'Delete Word',
      'edit_word': 'Edit Word',
      'delete': 'Delete',
      'save': 'Save',
      'close': 'Close',
      'score': 'Score',
      'time_up': "Time's Up!",
      'again': 'Retry',
      'confirm_delete': 'Are you sure you want to delete the word',
      'insufficient_words': 'Insufficient Words',
      'need_at_least_1': 'Add at least 1 word to play Speed Match.',
      'understand_back': 'Got it, Go Back',
      'time_left': 'seconds left',
      'flip_to_translate': 'Tap to flip',
      'tap_to_generate': 'Tap to generate sentence',
      'example_sentence': 'Example Sentence:',
      'english': 'English',
      'turkish': 'Turkish',
      'back': 'Go Back',
      'your_score': 'Your Score',
      'try_again': 'Try Again',
      'seconds_left': 'seconds left',
      'need_words_game': 'You need at least 1 word to play Speed Match.',
      'write_the_word': 'Write the word:',
      'tap_to_listen': 'Tap to listen',
      'hint_write_english': 'Write the English equivalent...',
      'check': 'CHECK',
      'perfect': 'Perfect!',
      'error_correct_answer': 'Error! Correct answer:',
      'next': 'NEXT',
      'see_results': 'SEE RESULTS',
      'congrats': 'Congratulations!',
      'continue': 'Continue',
      'tap_to_speak': 'Tap to speak',
      'listening': 'Listening...',
      'matching': 'Matching...',
      'no_match': 'No match, try again!',
      'voice_shadowing': 'Voice Shadowing',
      'excellent_pronunciation': 'Great! You pronounced it correctly.',
      'could_not_hear': 'I couldn\'t hear anything, try again.',
      'try_a_bit_more': 'You should practice a bit more. I heard:',
      'heard': 'Heard',
      'listen_and_repeat': 'Listen and Repeat',
      'ready_to_start': 'Ready?',
      'hold_to_speak': 'Hold to speak',
      'next_word': 'NEXT WORD',
      'complete': 'COMPLETE',
      'quiz_completed': 'Quiz Completed!',
      'great_job': 'Great job!',
      'need_more_practice': 'You need more practice.',
      'go_to_home': 'Go to Home',
      'need_at_least_4_words': 'You need at least 4 words to start a quiz.',
      'question': 'Question',
      'what_is_meaning': 'WHAT IS THE MEANING OF THIS WORD?',
      'next_question': 'Next Question',
      'learning_modules': 'Learning Modules',
      'spelling_subtitle': 'Improve your writing skills',
      'speed_match_subtitle': 'Match against time',
      'voice_subtitle': 'Score your pronunciation',
      'quiz_subtitle': 'Classic test mode',
      'multiple_choice': 'Multiple Choice',
      'welcome': 'Welcome to VocabFlow AI!',
      'welcome_desc': 'Build your own vocabulary, improve your English with AI-powered example sentences.',
      'smart_learning': 'Smart Learning Modes',
      'smart_learning_desc': 'Continue learning words everywhere with flashcards and dynamic tests.',
      'select_level': 'Select Your English Level',
      'level_desc': 'It is important for us to generate suitable example sentences for you.',
      'start': 'Start',
      'next_btn': 'Next',
      'please_select_level': 'Please select an English level.',
      'select_level_to_continue': 'Please select a level to continue.',
      'no_internet': 'Internet connection required.',
      'generate_sentence': 'Generate Sentence',
    },
  };

  static String translate(String key, String lang) {
    return _translations['en']?[key] ?? key;
  }
}

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  String get currentLanguage => 'en';

  void toggleLanguage() {} // No-op
  void setLanguage(String lang) {} // No-op

  String tr(String key) {
    return AppTranslation.translate(key, 'en');
  }
}
