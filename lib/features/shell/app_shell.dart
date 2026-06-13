import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/auth_provider.dart';
import '../../core/theme.dart';
import '../../core/theme_provider.dart';
import '../../core/responsive.dart';
import '../../components/premium_background.dart';

// Import features as we build them
import '../dashboard/dashboard_screen.dart';
import '../projects/projects_screen.dart';
import '../bugs/bugs_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../changelog/changelog_screen.dart';
import '../crm/screens/crm_dashboard_screen.dart';
import '../email_sender/email_sender_screen.dart';
import '../blueprints/blueprints_screen.dart';
import '../ico_atlas/ico_atlas_screen.dart';
import '../h4ck_arsenal/h4ck_arsenal_screen.dart';
import '../seo_ai/seo_ai_screen.dart';
import '../video_dashboard/video_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<int> _mobileScreenIndexes = [0, 3, 4, 5, 13];

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NotificationsScreen(),
    const SearchScreen(),
    const ProjectsScreen(),
    const BugsListScreen(),
    const CrmDashboardScreen(),
    const EmailSenderScreen(),
    const BlueprintsScreen(),
    const IcoAtlasScreen(),
    const H4ckArsenalScreen(),
    const VideoDashboardScreen(),
    const SeoAiScreen(),
    const AnalyticsScreen(),
    const AIAssistantScreen(),
    const SettingsScreen(),
    const ChangelogScreen(),
  ];

  final List<String> _titles = [
    'Prehľad',
    'Notifikácie',
    'Vyhľadávanie',
    'Projekty',
    'Zoznam chýb',
    'CRM',
    'Email Sender',
    'Blueprints',
    'IČO Atlas',
    'H4CK Arsenal',
    'Video Dashboard',
    'SEO AI',
    'Analytika',
    'AI Asistent',
    'Nastavenia',
    'Changelog',
  ];

  final List<IconData> _icons = [
    LucideIcons.layoutDashboard,
    LucideIcons.bell,
    LucideIcons.search,
    LucideIcons.folderKanban,
    LucideIcons.bug,
    LucideIcons.users,
    LucideIcons.mail,
    LucideIcons.layoutTemplate,
    LucideIcons.badgeInfo,
    LucideIcons.terminal,
    LucideIcons.video,
    LucideIcons.searchCode,
    LucideIcons.barChart2,
    LucideIcons.bot,
    LucideIcons.settings,
    LucideIcons.history,
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.profile;

    return PremiumBackground(
      child: Responsive(
        mobile: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            elevation: 0,
            title: Text(
              _titles[_selectedIndex],
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.logOut, size: 20),
                onPressed: () => authProvider.signOut(),
              ),
            ],
          ),
          drawer: _buildDrawer(authProvider),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _mobileScreenIndexes.contains(_selectedIndex)
                ? _mobileScreenIndexes.indexOf(_selectedIndex)
                : 0,
            onTap: (index) {
              setState(() {
                _selectedIndex = _mobileScreenIndexes[index];
              });
            },
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textSecondary,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(_icons[0]), label: 'Prehľad'),
              BottomNavigationBarItem(icon: Icon(_icons[3]), label: 'Projekty'),
              BottomNavigationBarItem(icon: Icon(_icons[4]), label: 'Chyby'),
              BottomNavigationBarItem(icon: Icon(_icons[5]), label: 'CRM'),
              const BottomNavigationBarItem(
                icon: Icon(LucideIcons.bot),
                label: 'AI',
              ),
            ],
          ),
        ),
        desktop: Row(
          children: [
            // Desktop Sidebar
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0x0EFFFFFF),
                border: Border(
                  right: BorderSide(color: Color(0x15FFFFFF), width: 1.0),
                ),
              ),
              child: Column(
                children: [
                  // App logo / header
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.shield,
                            color: AppTheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dashboard',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 20, letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Color(0x15FFFFFF)),
                  // Sidebar items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _screens.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: isSelected
                                  ? AppTheme.activeGlassDecoration(
                                      borderRadius: 8,
                                    )
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    _icons[index],
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _titles[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
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
                  const Divider(color: Color(0x15FFFFFF)),
                  // User Profile card & Sign Out
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          radius: 18,
                          child: Text(
                            (userProfile?.fullName ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile?.fullName ?? 'Používateľ',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                userProfile?.jobTitle ?? 'Vývojár',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Theme.of(context).brightness == Brightness.light
                                ? LucideIcons.moon
                                : LucideIcons.sun,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).toggleTheme();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.logOut,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () => authProvider.signOut(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: _screens[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(AuthProvider auth) {
    final userProfile = auth.profile;
    return Drawer(
      backgroundColor: const Color(0xFF0F0F11),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.transparent),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: Text(
                (userProfile?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            accountName: Text(userProfile?.fullName ?? 'Používateľ'),
            accountEmail: Text(auth.user?.email ?? ''),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _screens.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(
                    _icons[index],
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                  title: Text(
                    _titles[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    Navigator.pop(context); // Close drawer
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            title: const Text(
              'Odhlásiť sa',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              auth.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
