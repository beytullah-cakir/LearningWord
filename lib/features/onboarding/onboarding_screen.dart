import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  
  String? _selectedLanguage;
  String? _selectedLevel;

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'icon': '🇺🇸'},
    {'name': 'German', 'icon': '🇩🇪'},
    {'name': 'Spanish', 'icon': '🇪🇸'},
    {'name': 'French', 'icon': '🇫🇷'},
    {'name': 'Turkish', 'icon': '🇹🇷'},
    {'name': 'Italian', 'icon': '🇮🇹'},
  ];

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  void _onNext() {
    if (_currentPageIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutBack,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedLanguage == null || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both language and level.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetLanguage', _selectedLanguage!);
    await prefs.setString('userLevel', _selectedLevel!);
    await prefs.setBool('hasCompletedOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPageIndex = index),
                children: [
                  _buildWelcomePage(),
                  _buildFeaturePage(),
                  _buildLanguageSelectionPage(),
                  _buildLevelSelectionPage(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildBasePage(
      icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFF6366F1),
      title: 'Welcome to LearnWords',
      description: 'Your AI-powered journey to mastering any language starts here. Add your own words and watch them come to life.',
    );
  }

  Widget _buildFeaturePage() {
    return _buildBasePage(
      icon: Icons.bolt_rounded,
      iconColor: const Color(0xFFF59E0B),
      title: 'Smart Learning',
      description: 'Benefit from tiered reviews, sentence building challenges, and instant AI feedback tailored to your progress.',
    );
  }

  Widget _buildLanguageSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language_rounded, size: 80, color: Color(0xFF10B981)),
          const SizedBox(height: 32),
          const Text(
            'What language are you learning?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectedLanguage == lang['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedLanguage = lang['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF10B981) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? const Color(0xFF10B981).withOpacity(0.3) : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(lang['icon']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            lang['name']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up_rounded, size: 80, color: Color(0xFF6366F1)),
          const SizedBox(height: 32),
          const Text(
            'What is your current level?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This helps the AI create sentences that match your skills.',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _levels.map((level) {
              final isSelected = _selectedLevel == level;
              return GestureDetector(
                onTap: () => setState(() => _selectedLevel = level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      level,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildBasePage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: iconColor),
          ),
          const SizedBox(height: 64),
          Text(
            title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade400, height: 1.5, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPageIndex == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPageIndex == index ? const Color(0xFF6366F1) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          ElevatedButton(
            onPressed: _onNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              _currentPageIndex == 3 ? 'GET STARTED' : 'NEXT',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
