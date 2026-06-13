import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';
import '../../components/premium_background.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: LucideIcons.layoutDashboard,
      title: 'Vitajte v Centralnom Dashboarde',
      description: 'Jedno centráne miesto pre správu všetkých vašich projektov, chýb a analýz.',
      color: AppTheme.primary,
    ),
    OnboardingPage(
      icon: LucideIcons.bug,
      title: 'Sledovanie chýb',
      description: 'Vytvárajte, sledujte a spravujte chyby naprieč projektmi s detailným sledovaním stavu.',
      color: AppTheme.error,
    ),
    OnboardingPage(
      icon: LucideIcons.users,
      title: 'Tímová spolupráca',
      description: 'Pridelujte úlohy, komunikujte s tímom a udržujte všetkých informovaných.',
      color: AppTheme.success,
    ),
    OnboardingPage(
      icon: LucideIcons.barChart2,
      title: 'Analytika a Prehľady',
      description: 'Získajte prehľad o stave projektov, výkone tímu a trendoch chýb.',
      color: AppTheme.info,
    ),
    OnboardingPage(
      icon: LucideIcons.bot,
      title: 'AI Asistent',
      description: 'Použite umelú inteligenciu na analýzu chýb a generovanie riešení.',
      color: const Color(0xFFFBBC04),
    ),
    OnboardingPage(
      icon: LucideIcons.video,
      title: 'Video Dashboard',
      description: 'Integrovať video obsahy priamo do vášho dashboardu pre lepšie sledovanie.',
      color: const Color(0xFF9333EA),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      widget.onComplete();
                    },
                    child: Text(
                      'Preskočiť',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Dot indicators
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildDotIndicators(),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white30, width: 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Späť',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          widget.onComplete();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Ďalej' : 'Začať',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: page.color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: page.color,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isLight ? Colors.black87 : Colors.white,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: isLight ? Colors.black54 : Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDotIndicators() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final List<Widget> indicators = [];

    for (int i = 0; i < _pages.length; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentPage == i
                ? AppTheme.primary
                : (isLight ? Colors.black26 : Colors.white24),
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return indicators;
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
