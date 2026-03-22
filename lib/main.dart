import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for all platforms (Web, Windows, Mobile etc.)
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.initHive();
  await dbHelper.seedDatabaseManual();

  final prefs = await SharedPreferences.getInstance();
  final bool hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(VocabFlowApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class VocabFlowApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const VocabFlowApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnWords AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF8B5CF6), // Purple
          surface: Colors.white,
          background: const Color(0xFFF8F9FE),
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: SplashScreen(hasCompletedOnboarding: hasCompletedOnboarding),
    );
  }
}
