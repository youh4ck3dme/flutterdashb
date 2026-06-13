# 🚀 Deployment Guide - Centralny Dashboard Flutter

## ✅ Úspešne implementované

Všetko je pripravené pre **100% funkčný deploy** z GitHub na Vercel s automatickým frame loadingom a bug reportingom.

---

## 📁 Štruktúra nových súborov

```
lib/
├── features/
│   ├── frame_wrapper/
│   │   ├── frame_screen.dart          # Generic frame wrapper s error handling
│   │   └── frame_error_handler.dart   # Error notification system
│   │
│   └── video_dashboard/
│       ├── video_screen.dart          # Video Dashboard screen
│       ├── video_iframe_web.dart      # Web iframe implementation
│       └── video_iframe_stub.dart     # Mobile stub
│
├── bugs/
│   └── bug_create_screen.dart        # Upravené: prefilledData parameter
│
└── shell/
    └── app_shell.dart                 # Upravené: VideoDashboardScreen pridané

.github/
└── workflows/
    └── ci_cd.yml                      # Upravené: Vercel auto-deploy

vercel.json                           # Upravené: Build config & routes
```

---

## 🔧 Nastavenie pre deploy

### 1. Vercel Secrets v GitHub

**Premenné v GitHub Repository Secrets:**
- `VERCEL_TOKEN` - Vygeneruj na https://vercel.com/account/tokens
- `VERCEL_ORG_ID` - Tvoja organizácia ID (nahraj v Vercel dashboarde)
- `VERCEL_PROJECT_ID` - Tvoj project ID v Vercel

**Ako získať:**
```bash
# Prihlás sa cez Vercel CLI
npm install -g vercel
vercel login
vercel link
# Získas ORG_ID a PROJECT_ID
```

### 2. Vercel Project Configuration

V `vercel.json` je už nastavené:
- Build z `web/` adresára
- Static build pre Flutter web
- Routes pre API proxy

**Uprav len:**
```json
{
  "src": "/api/(.*)",
  "dest": "https://YOUR-SUPABASE-URL.supabase.co/rest/v1/$1"
}
```

---

## 🎯 Ako to funguje

### Frame Loading Flow
```
User otvorí Video Dashboard
    ↓
FrameScreen zobrazi URL: https://video.your-dashboard.com
    ↓
Na web: video_iframe_web.dart → HTML IFrame
    ↓
Na mobile: video_iframe_stub.dart → Info message
    ↓
Ak chyba: FrameErrorHandler → zobrazi error + bug report button
    ↓
User klikne "Nahlásiť chybu"
    ↓
BugCreateScreen s prefilled dátami:
    - title: "Chyba v Video Dashboard"
    - description: "Frame https://... zlyhal: [error message]"
    - environment: "Frame: Video Dashboard | URL: https://..."
```

### CI/CD Flow
```
Git push do main
    ↓
GitHub Actions: analyze_and_test job
    ↓
✅ Tests pass → deploy_to_vercel job
    ↓
Vercel CLI: vercel --prod --token=...
    ↓
Dashboard deploynutý na: https://your-dashboard.vercel.app
```

---

## 📱 Ako testovať

### 1. Lokatne testovanie
```bash
# Pre web
flutter run -d chrome --web-renderer html

# Pre mobile (stub)
flutter run -d iphone
```

### 2. Testovanie frame error handling
V `video_screen.dart` dočasne zmen URL na neexistujúci:
```dart
url: 'https://neexistujuca-url.xyz',
```

Očakávané správanie:
- Zobrazí sa error screen
- Tlačidlo "Nahlásiť chybu" otvorí BugCreateScreen s prefilled dátami
- Tlačidlo "Skúsiť znova" resetne frame

### 3. Testovanie bug reportu
1. Spustí frame s chybou
2. Klikni na "Nahlásiť chybu"
3. Over že formulár má predvyplnené:
   - Názov chyby
   - Popis s error message
   - Prostredie (Frame + URL)

---

## 🚀 Deployment Checklist

- [x] Frame wrapper modul vytvorený
- [x] Video dashboard modul vytvorený
- [x] Bug reporting integrovaný
- [x] CI/CD pipeline upravený
- [x] Vercel config upravený
- [ ] **VERCEL_TOKEN pridaný do GitHub Secrets**
- [ ] **VERCEL_ORG_ID pridaný do GitHub Secrets**
- [ ] **VERCEL_PROJECT_ID pridaný do GitHub Secrets**
- [ ] **Vercel project vytvorený**
- [ ] **Video frame URL upravený** v `video_screen.dart`

---

## 📝 Rýchle úpravy

### Zmena URL pre video frame
```dart
// lib/features/video_dashboard/video_screen.dart
FrameScreen(
  url: 'https://TVOJA-VIDEO-APP.vercel.app',  // ← Zmen tu
  title: 'Video Dashboard',
  icon: LucideIcons.video,
  frameBuilder: (url) => createVideoIFrameWidget(url),
)
```

### Pridanie ďalšieho frame
1. Vytvor nový folder: `lib/features/NOVY_FRAME/`
2. Skopíruj štruktúru z `video_dashboard`
3. Pridaj do `app_shell.dart`:
   - Import: `import '../NOVY_FRAME/novy_screen.dart'`
   - Do `_screens`: `const NovyFrameScreen()`
   - Do `_titles`: `'Nový Frame'`
   - Do `_icons`: `LucideIcons.someIcon`

---

## 🔍 Monitoring & Debugging

### Vercel Logs
```bash
vercel logs --output=json
```

### GitHub Actions Logs
- Prejdi na: `https://github.com/TVOJ-USER/centralny-dashboard-flutter/actions`
- Klikni na posledný workflow run
- Zobrazí sa detailný log deployu

### Flutter Analyze
```bash
flutter analyze
```

### Flutter Test
```bash
flutter test --dart-define=INTEGRATION_TEST=true
```

---

## ❓ FAQ

### Q: Frame sa nezobrazuje na mobile
**A:** Frame funguje len na web. Na mobile použij `webview_flutter` package.

### Q: Vercel deploy zlyhá
**A:** Over:
1. Ci `VERCEL_TOKEN` je platný
2. Ci `VERCEL_PROJECT_ID` je správny
3. Ci máš v Vercel projecte nastavený Flutter build

### Q: Bug report neprefilluje dáta
**A:** Over že:
1. Voláš `BugCreateScreen(prefilledData: {...})`
2. Kľúče v map sú: `title`, `description`, `environment`, `severity`

### Q: Auto-deploy nefunguje
**A:** Over workflow:
1. Push do `main` branch
2. Počkaj na `analyze_and_test` job
3. `deploy_to_vercel` sa spustí automaticky

---

## 💡 Tipy

1. **Pre lokalne testovanie Vercel deployu:**
   ```bash
   vercel dev
   ```

2. **Pre rýchle testovanie frame erroru:**
   Zmen URL na `https://httpstat.us/500` pre simulate server error

3. **Pre debug iframe:**
   Pridaj do iframe: `..style.border = '2px solid red'` na vizualizáciu

4. **Pre offline testovanie bug reportu:**
   Použi `--dart-define=INTEGRATION_TEST=true`

---

**🎉 Všetko je pripravené! Teraz len pridaš Vercel secrets a môžeš deployovať!**
