import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/auth_provider.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

// Import features as we build them
import '../dashboard/dashboard_screen.dart';
import '../projects/projects_screen.dart';
import '../bugs/bugs_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../ai_assistant/ai_assistant_screen.dart';
import '../settings/settings_screen.dart';
import '../changelog/changelog_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProjectsScreen(),
    const BugsListScreen(),
    const AnalyticsScreen(),
    const AIAssistantScreen(),
    const SettingsScreen(),
    const ChangelogScreen(),
  ];

  final List<String> _titles = [
    'Prehľad',
    'Projekty',
    'Zoznam chýb',
    'Analytika',
    'AI Asistent',
    'Nastavenia',
    'Changelog',
  ];

  final List<IconData> _icons = [
    LucideIcons.layoutDashboard,
    LucideIcons.folderKanban,
    LucideIcons.bug,
    LucideIcons.barChart2,
    LucideIcons.bot,
    LucideIcons.settings,
    LucideIcons.history,
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.profile;

    return Scaffold(
      body: Responsive(
        mobile: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.35),
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
            currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.black.withOpacity(0.5),
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textSecondary,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(_icons[0]),
                label: 'Prehľad',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[1]),
                label: 'Projekty',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[2]),
                label: 'Chyby',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[3]),
                label: 'Analytika',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[4]),
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
                          const Icon(LucideIcons.shield, color: AppTheme.primary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dashboard',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 20,
                                    letterSpacing: 0.5,
                                  ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: isSelected
                                  ? AppTheme.activeGlassDecoration(borderRadius: 8)
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    _icons[index],
                                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _titles[index],
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 13,
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
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          radius: 18,
                          child: Text(
                            (userProfile?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile?.fullName ?? 'Používateľ',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                userProfile?.jobTitle ?? 'Vývojár',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.logOut, size: 16, color: AppTheme.textSecondary),
                          onPressed: () => authProvider.signOut(),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Scaffold(
                backgroundColor: AppTheme.background,
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
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
                  leading: Icon(_icons[index], color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
                  title: Text(_titles[index], style: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary)),
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
            title: const Text('Odhlásiť sa', style: TextStyle(color: Colors.redAccent)),
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
