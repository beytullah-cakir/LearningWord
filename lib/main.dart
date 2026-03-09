import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      title: 'VocabFlow AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 2,
        ),
      ),
      home: hasCompletedOnboarding ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
