# 🚀 COMPLETE IMPLEMENTATION GUIDE

**Všetko, čo chýba pre 100% profesionálnu Flutter Dashboard App**

Tento dokument obsahuje **kompletný kód** pre všetky chýbajúce funkcie.

---

## 📦 1. MOBILE WEBVIEW SUPPORT

### Step 1: Add dependencies to `pubspec.yaml`
```yaml
dependencies:
  webview_flutter: ^4.4.2
  webview_flutter_wkwebview: ^4.4.2  # iOS
  webview_flutter_android: ^4.2.6   # Android
```

### Step 2: Create `lib/features/frame_wrapper/frame_webview.dart`
```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FrameWebView extends StatefulWidget {
  final String url;
  final bool allowFullscreen;
  final bool allowCamera;
  final bool allowMicrophone;

  const FrameWebView({
    super.key,
    required this.url,
    this.allowFullscreen = true,
    this.allowCamera = false,
    this.allowMicrophone = false,
  });

  @override
  State<FrameWebView> createState() => _FrameWebViewState();
}

class _FrameWebViewState extends State<FrameWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavascriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => _isLoading = progress < 100);
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Chyba pri načítaní stránky',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Neznáma chyba',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _controller.reload();
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
              },
              child: const Text('Skúsiť znova'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
```

### Step 3: Update `video_iframe_web.dart` and `seo_ai_iframe_web.dart`
```dart
// For mobile support, use conditional import
import 'package:flutter/foundation.dart';
import 'frame_webview.dart' if (dart.library.html) 'video_iframe_web.dart';

Widget createVideoIFrameWidget(String url) {
  if (kIsWeb) {
    // Use HTML iframe on web
    return _createHtmlIFrame(url);
  } else {
    // Use WebView on mobile
    return FrameWebView(url: url);
  }
}
```

---

## 📊 2. OFFLINE SYNC STATUS INDICATOR

### Update `lib/features/shell/app_shell.dart`
```dart
// Add at the top
import '../core/data_provider.dart';

// In _AppShellState, update the body
@override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  final dataProvider = Provider.of<DataProvider>(context);
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
            // Sync Status Indicator
            if (dataProvider.isOffline)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.cloud_off, color: Colors.orange),
                  tooltip: 'Offline - zmeny sa synchronizujú neskôr',
                  onPressed: () => dataProvider.processOfflineQueue(),
                ),
              ),
            if (dataProvider.hasPendingSync)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sync, color: Colors.white70),
                      tooltip: 'Synchronizovať zmeny',
                      onPressed: () => dataProvider.processOfflineQueue(),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              onPressed: () => authProvider.signOut(),
            ),
          ],
        ),
        // ... rest of the code
      ),
      // ... rest of the code
    ),
  );
}
```

### Update `lib/core/data_provider.dart`
```dart
// Add these getters
bool get isOffline => _error != null && _error!.contains('offline');
bool get hasPendingSync => _offlineQueueLength > 0;
int get _offlineQueueLength => _offlineQueue?.length ?? 0;

// Add to constructor
DataProvider() {
  _init();
  // Start periodic sync check
  Timer.periodic(const Duration(seconds: 30), (timer) {
    if (hasPendingSync) {
      processOfflineQueue();
    }
  });
}
```

---

## 🔍 3. GLOBAL SEARCH

### Create `lib/features/search/search_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/data_provider.dart';
import '../core/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    
    final bugs = dataProvider.bugs.where((bug) {
      return bug.title.toLowerCase().contains(_query.toLowerCase()) ||
             bug.description.toLowerCase().contains(_query.toLowerCase()) ||
             bug.trackingId.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    final projects = dataProvider.projects.where((project) {
      return project.name.toLowerCase().contains(_query.toLowerCase()) ||
             project.description.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    setState(() {
      _results = [...bugs, ...projects];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Vyhľadaj...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            prefixIcon: Icon(LucideIcons.search, color: Colors.white70),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _results = []);
                    },
                  )
                : null,
          ),
          style: TextStyle(color: Colors.white, fontSize: 16),
          onSubmitted: (_) => _performSearch(),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(LucideIcons.search, color: AppTheme.primary),
              onPressed: _performSearch,
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.search, size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  Text(
                    'Zadajte vyhľadávaný výraz',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            )
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.xCircle, size: 64, color: Colors.white38),
                      const SizedBox(height: 16),
                      Text(
                        'Žiadne výsledky pre "$_query"',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white54,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    final isBug = item is Bug;
                    
                    if (isBug) {
                      final bug = item as Bug;
                      return _buildBugResult(bug);
                    } else {
                      final project = item as Project;
                      return _buildProjectResult(project);
                    }
                  },
                ),
    );
  }

  Widget _buildBugResult(Bug bug) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BugDetailScreen(bugId: bug.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.glassDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  bug.trackingId,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  bug.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              bug.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.severityColors[bug.severity]?.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppTheme.severityLabels[bug.severity] ?? bug.severity,
                    style: TextStyle(
                      color: AppTheme.severityColors[bug.severity],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.statusColors[bug.status]?.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppTheme.statusLabels[bug.status] ?? bug.status,
                    style: TextStyle(
                      color: AppTheme.statusColors[bug.status],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectResult(Project project) {
    return InkWell(
      onTap: () {
        // Navigate to project detail if exists
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.glassDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.folder, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (project.description.isNotEmpty)
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
```

### Update `lib/features/shell/app_shell.dart`
Add to imports:
```dart
import '../search/search_screen.dart';
```
Add to `_screens` list:
```dart
const SearchScreen(),
```
Add to `_titles` list:
```dart
'Hľadať',
```
Add to `_icons` list:
```dart
LucideIcons.search,
```

---

## 🔔 4. FIREBASE MESSAGING NOTIFICATIONS

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  firebase_messaging: ^14.7.0
```

### Step 2: Create `lib/core/notification_service.dart`
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotifications.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Handle when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    final data = message.data;
    if (data['type'] == 'bug') {
      // Navigator.pushNamed(context, '/bug/${data['id']}');
    } else if (data['type'] == 'project') {
      // Navigator.pushNamed(context, '/project/${data['id']}');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
```

### Step 3: Initialize in `main.dart`
```dart
import 'core/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        // ... existing providers
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## 📤 5. CSV DATA EXPORT

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  csv: ^5.1.1
  share_plus: ^7.2.1
```

### Step 2: Create `lib/core/export_service.dart`
```dart
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExportService {
  static Future<void> exportBugsToCSV(List<dynamic> bugs) async {
    // Convert bugs to CSV
    final List<List<dynamic>> rows = [];
    
    // Header row
    rows.add([
      'ID',
      'Tracking ID',
      'Title',
      'Description',
      'Status',
      'Severity',
      'Project',
      'Reporter',
      'Created At',
      'Updated At',
    ]);

    // Data rows
    for (final bug in bugs) {
      rows.add([
        bug.id,
        bug.trackingId,
        bug.title,
        bug.description,
        bug.status,
        bug.severity,
        bug.projectId,
        bug.reporterId,
        bug.createdAt.toIso8601String(),
        bug.updatedAt.toIso8601String(),
      ]);
    }

    // Convert to CSV string
    final csv = const ListToCsvConverter().convert(rows);

    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/bugs_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);

    // Share the file
    await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
  }

  static Future<void> exportProjectsToCSV(List<dynamic> projects) async {
    final List<List<dynamic>> rows = [];
    
    rows.add([
      'ID',
      'Name',
      'Description',
      'Created By',
      'Created At',
      'Updated At',
    ]);

    for (final project in projects) {
      rows.add([
        project.id,
        project.name,
        project.description,
        project.createdBy,
        project.createdAt.toIso8601String(),
        project.updatedAt.toIso8601String(),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/projects_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
  }
}
```

### Step 3: Add export buttons to `bugs_list_screen.dart`
```dart
// In the app bar or floating action button
ElevatedButton.icon(
  icon: Icon(LucideIcons.download, size: 16),
  label: Text('Export CSV', style: TextStyle(fontSize: 12)),
  onPressed: () {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    ExportService.exportBugsToCSV(dataProvider.bugs);
  },
)
```

---

## 👥 6. USER ROLES & PERMISSIONS

### Step 1: Update `lib/core/models.dart`
```dart
enum UserRole {
  admin,
  user,
  guest,
}

class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? jobTitle;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.jobTitle,
    this.role = UserRole.user,
    required this.createdAt,
    required this.updatedAt,
  });

  // Add fromJson factory
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      jobTitle: json['job_title'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'job_title': jobTitle,
    'role': role.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```

### Step 2: Update `lib/core/auth_provider.dart`
```dart
// Add role checking methods
bool get isAdmin => _userProfile?.role == UserRole.admin;
bool get isUser => _userProfile?.role == UserRole.user;
bool get isGuest => _userProfile?.role == UserRole.guest;

bool canEditBugs() => isAdmin || isUser;
bool canDeleteBugs() => isAdmin;
bool canManageUsers() => isAdmin;
```

---

## 🎬 7. ONBOARDING TUTORIAL

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  intro_slider: ^4.2.0
```

### Step 2: Create `lib/features/onboarding/onboarding_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<ContentConfig> get slides => [
    ContentConfig(
      title: "Vítajte v Dashboard",
      description: "Spravujte všetky svoje projekty a úlohy na jednom mieste",
      pathImage: "assets/images/onboarding1.png",
      backgroundColor: const Color(0xFF07080B),
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      descriptionStyle: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),
    ContentConfig(
      title: "Nahlásite Chyby",
      description: "Rýchle a ľahké hlásenie chýb s detailným popisom",
      pathImage: "assets/images/onboarding2.png",
      backgroundColor: const Color(0xFF07080B),
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      descriptionStyle: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),
    ContentConfig(
      title: "Prispôsobte si Tému",
      description: "Prepínajte medzi svetlým a tmavým režimom",
      pathImage: "assets/images/onboarding3.png",
      backgroundColor: const Color(0xFF07080B),
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      descriptionStyle: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      renderSkipBtn: Text(
        "Preskočiť",
        style: TextStyle(color: AppTheme.primary),
      ),
      renderNextBtn: Icon(
        LucideIcons.arrowRight,
        color: AppTheme.primary,
        size: 24,
      ),
      renderDoneBtn: Icon(
        LucideIcons.check,
        color: AppTheme.primary,
        size: 24,
      ),
      onDonePress: widget.onFinish,
      colorDot: AppTheme.primary.withValues(alpha: 0.3),
      colorActiveDot: AppTheme.primary,
      sizeDot: 10,
      typeDotAnimation: DotSliderAnimation.SIZE,
    );
  }
}
```

### Step 3: Update `main.dart` to show onboarding
```dart
// In AuthGate, check if user is new
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAuthenticated) {
      return const AuthScreen();
    }

    // Check if user needs onboarding
    if (authProvider.profile?.needsOnboarding ?? true) {
      return OnboardingScreen(
        onFinish: () {
          // Mark onboarding as completed
          authProvider.markOnboardingComplete();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppShell()),
          );
        },
      );
    }

    return const AppShell();
  }
}
```

---

## 🌍 8. LOCALIZATION (Slovak + English)

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

flutter:
  generate: true
```

### Step 2: Create localization files
```bash
mkdir -p lib/l10n
```

#### Create `lib/l10n/intl_en.arb`
```json
{
  "@": {
    "description": "English translations"
  },
  "welcome": "Welcome",
  "dashboard": "Dashboard",
  "projects": "Projects",
  "bugs": "Bugs",
  "crm": "CRM",
  "settings": "Settings",
  "search": "Search",
  "logIn": "Log In",
  "logOut": "Log Out",
  "save": "Save",
  "cancel": "Cancel",
  "reportBug": "Report Bug",
  "noResultsFound": "No results found",
  "loading": "Loading...",
  "offline": "Offline",
  "syncPending": "Sync Pending",
  "theme": "Theme",
  "lightMode": "Light Mode",
  "darkMode": "Dark Mode",
  "profile": "Profile",
  "email": "Email",
  "name": "Name",
  "jobTitle": "Job Title"
}
```

#### Create `lib/l10n/intl_sk.arb`
```json
{
  "@": {
    "description": "Slovenské preklady"
  },
  "welcome": "Vítajte",
  "dashboard": "Prehľad",
  "projects": "Projekty",
  "bugs": "Chyby",
  "crm": "CRM",
  "settings": "Nastavenia",
  "search": "Hľadať",
  "logIn": "Prihlásiť sa",
  "logOut": "Odhlásiť sa",
  "save": "Uložiť",
  "cancel": "Zrušiť",
  "reportBug": "Nahlásiť chybu",
  "noResultsFound": "Nenašli sa žiadne výsledky",
  "loading": "Načítavam...",
  "offline": "Offline",
  "syncPending": "Čaká na synchronizáciu",
  "theme": "Téma",
  "lightMode": "Svetlý režim",
  "darkMode": "Tmavý režim",
  "profile": "Profil",
  "email": "E-mail",
  "name": "Meno",
  "jobTitle": "Pracovná pozícia"
}
```

### Step 3: Use translations in code
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In build method
Text(AppLocalizations.of(context)!.welcome);

// In MaterialApp
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('sk'), // or 'en'
  // ...
);
```

---

## 🛡️ 9. SENTRY ERROR TRACKING

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  sentry_flutter: ^7.15.0
```

### Step 2: Initialize in `main.dart`
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_DSN_HERE';
      options.tracesSampleRate = 1.0;
      options.debug = kDebugMode;
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [...],
        child: const MyApp(),
      ),
    ),
  );
}
```

### Step 3: Catch errors globally
```dart
// Wrap your app with Sentry error widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      builder: (context, child) {
        return SentryErrorWidget(
          child: child!,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vyšla chyba'),
                  ElevatedButton(
                    onPressed: () {
                      Sentry.captureException(error, stackTrace: stackTrace);
                    },
                    child: Text('Nahlásiť'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## ⚡ 10. PERFORMANCE MONITORING

### Step 1: Add to `pubspec.yaml`
```yaml
dependencies:
  firebase_performance: ^0.9.3+12
```

### Step 2: Initialize in `main.dart`
```dart
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance monitoring
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  runApp(...);
}
```

### Step 3: Track custom traces
```dart
// In any screen or service
final trace = FirebasePerformance.instance.newTrace("load_bugs");
await trace.start();

// Your code
await dataProvider.fetchAllData();

await trace.stop();
```

---

## 📋 SUMMARY CHECKLIST

| Feature | Status | Files to Create/Modify |
|---------|--------|------------------------|
| ✅ Mobile WebView | Pending | `frame_webview.dart`, pubspec.yaml |
| ✅ Sync Status Indicator | Pending | `app_shell.dart`, `data_provider.dart` |
| ✅ Global Search | Pending | `search_screen.dart`, `app_shell.dart` |
| ✅ Firebase Messaging | Pending | `notification_service.dart`, main.dart |
| ✅ CSV Export | Pending | `export_service.dart`, bugs_list_screen.dart |
| ✅ User Roles | Pending | `models.dart`, `auth_provider.dart` |
| ✅ Onboarding | Pending | `onboarding_screen.dart`, main.dart |
| ✅ Localization | Pending | `intl_en.arb`, `intl_sk.arb`, main.dart |
| ✅ Sentry | Pending | main.dart |
| ✅ Performance | Pending | main.dart |

---

## 🚀 NEXT STEPS

1. **Pridaj dependencies** do `pubspec.yaml` podľa jednotlivých sekcií
2. **Spusti `flutter pub get`**
3. **Vytvor súbory** podľa šablón vyššie
4. **Testuj** každú funkciu jednotlivé
5. **Deploy** na Vercel

---

## 💡 TIPS

- **Pre development**: Použite `any` verzie v pubspec.yaml, potom ich upresnite pred production
- **Testujte na mobile**: `flutter run -d iphone` a `flutter run -d android`
- **Testujte offline**: Vypnite internet a overujte, že offline sync funguje
- **Monitorujte chyby**: Po pridaní Sentry overujte dashboard

---

**🎉 Všetko je pripravené! Teraz len implementujte podľa tohto návodu.**
