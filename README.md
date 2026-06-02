# 🚀 Centralny Dashboard — Flutter

> **Prémiová, offline-first Flutter webová aplikácia** pre centralizovanú správu chýb (bug tracking), projektov, AI asistenta a analytiky. Glassmorphic dark UI, plná Supabase + Firebase integrácia, nasadená na Vercel a Firebase Hosting.

---

## 🔗 Produkčné URL adresy

| Služba | URL |
|--------|-----|
| **Vercel (hlavná produkcia)** | [https://crm.nexify-studio.tech](https://crm.nexify-studio.tech) |
| **Firebase Hosting (záloha)** | [https://machinegunslots.web.app](https://machinegunslots.web.app) |
| **Firebase Hosting (alt)** | [https://machinegunslots.firebaseapp.com](https://machinegunslots.firebaseapp.com) |
| **Vercel Inspector** | [https://vercel.com/h4ck3d/web](https://vercel.com/h4ck3d/web) |
| **Firebase Console** | [https://console.firebase.google.com/project/machinegunslots](https://console.firebase.google.com/project/machinegunslots) |

---

## 🌐 API Endpointy

### Supabase REST API

Base URL: `https://dehhwfgxocctagfvqsjr.supabase.co`

| Endpoint | Metóda | Popis |
|----------|--------|-------|
| `/rest/v1/profiles` | GET, POST, PATCH | Profily používateľov (vyžaduje UUID) |
| `/rest/v1/bugs` | GET, POST, PATCH | Správa chýb / bug tickets |
| `/rest/v1/projects` | GET | Zoznam projektov |
| `/rest/v1/ai_conversations` | GET, POST | AI konverzácie (vyžaduje UUID) |
| `/rest/v1/ai_messages` | GET, POST | Správy v AI konverzáciách |
| `/auth/v1/token` | POST | Supabase autentifikácia (ak by sa používala) |

> ⚠️ **DÔLEŽITÉ:** Tabuľky `profiles` a `ai_conversations` používajú PostgreSQL `UUID` typ v stĺpci `user_id`. Firebase UIDs (28-znakové alfanumerické reťazce) sa vždy validujú pred odoslaním dopytu — ak nie sú UUID, dopyt sa vynechá a vráti sa prázdna hodnota.

**Hlavičky pre Supabase:**
```http
Authorization: Bearer <VITE_SUPABASE_PUBLISHABLE_KEY>
apikey: <VITE_SUPABASE_PUBLISHABLE_KEY>
Content-Type: application/json
```

---

### Firebase Auth API

Base URL: `https://identitytoolkit.googleapis.com/v1`

| Endpoint | Metóda | Popis |
|----------|--------|-------|
| `/accounts:signInWithPassword?key=<API_KEY>` | POST | Email/heslo prihlásenie |
| `/accounts:signUp?key=<API_KEY>` | POST | Registrácia |
| `/accounts:signInWithIdp?key=<API_KEY>` | POST | Google Sign-In (OAuth) |

**Firebase projekt ID:** `machinegunslots`  
**Firebase Auth Domain:** `machinegunslots.firebaseapp.com`

---

### WordPress API

Base URL: `https://h4ck3d.me/wp-json/wp/v2`

| Endpoint | Metóda | Popis |
|----------|--------|-------|
| `/posts` | GET | Zoznam príspevkov (changelog) |
| `/posts/{id}` | GET | Detail príspevku |

---

## 🗂️ Štruktúra projektu

```
centralny-dashboard-flutter/
├── lib/
│   ├── main.dart                    # Vstupný bod aplikácie
│   ├── core/
│   │   ├── config.dart              # AppConfig – načítanie dart-define premenných
│   │   ├── models.dart              # Dátové modely (AppUser, Bug, Project, Profile, ...)
│   │   ├── auth_provider.dart       # Firebase autentifikácia + stav používateľa
│   │   ├── data_provider.dart       # Správa dát, offline sync queue, Supabase operácie
│   │   ├── supabase_service.dart    # Supabase klient + UUID validácia
│   │   ├── firebase_service.dart    # Firebase Auth servis (email, Google)
│   │   ├── isar_service.dart        # Lokálna Isar DB – cache a offline queue
│   │   ├── isar_models.dart         # Isar schémy (IsarProject, IsarBug, IsarOfflineQueue)
│   │   ├── isar_models.g.dart       # Generovaný Isar kód (dart run build_runner build)
│   │   ├── theme.dart               # Dark glassmorphic téma
│   │   └── responsive.dart          # Responsívne breakpointy (desktop/tablet/mobile)
│   ├── components/
│   │   └── badges.dart              # Zdieľané UI komponenty (StatusBadge, SeverityBadge)
│   └── features/
│       ├── auth/                    # Prihlásenie, registrácia, Google Sign-In
│       ├── shell/                   # Navigačný shell (sidebar/drawer/bottom nav)
│       ├── dashboard/               # Hlavný prehľad – štatistiky, grafy
│       ├── bugs/                    # Zoznam chýb, detail, vytvorenie
│       ├── projects/                # Zoznam projektov
│       ├── analytics/               # Analytické grafy (fl_chart)
│       ├── ai_assistant/            # AI chat rozhranie
│       ├── settings/                # Nastavenia profilu
│       └── changelog/               # Changelog z WordPress
├── web/
│   └── index.html                   # Web vstupná stránka (s crossorigin manifest fix)
├── tool/
│   ├── patch_isar_web.dart          # Patch Isar 64-bit literálov pre JS kompatibilitu
│   └── download_isar.dart           # Stiahnutie libisar pre Linux CI
├── test/                            # Unit testy + E2E headless testy
├── integration_test/                # Flutter Integration Test súbory
├── supabase/                        # Supabase migrácie a edge funkcie
├── .github/workflows/ci_cd.yml      # GitHub Actions CI/CD pipeline
├── firebase.json                    # Firebase Hosting konfigurácia
├── .firebaserc                      # Firebase projekt: machinegunslots
├── vercel.json                      # Vercel SPA rewrite pravidlá
├── pubspec.yaml                     # Flutter závislosti
├── secrets.json                     # 🔒 PRIVÁTNE – ignorované Gitom (.gitignore)
└── secrets.json.example             # Šablóna pre secrets.json
```

---

## ⚙️ Konfigurácia – Secrets

Všetky citlivé kľúče sú **mimo Git repozitára** (súbor `secrets.json` je v `.gitignore`).

1. Skopíruj šablónu:
```bash
cp secrets.json.example secrets.json
```

2. Vyplň reálne hodnoty:
```json
{
  "VITE_SUPABASE_URL": "https://dehhwfgxocctagfvqsjr.supabase.co",
  "VITE_SUPABASE_PUBLISHABLE_KEY": "<supabase-anon-key>",
  "VITE_FIREBASE_API_KEY": "<firebase-api-key>",
  "VITE_FIREBASE_AUTH_DOMAIN": "machinegunslots.firebaseapp.com",
  "VITE_FIREBASE_PROJECT_ID": "machinegunslots",
  "VITE_FIREBASE_STORAGE_BUCKET": "machinegunslots.firebasestorage.app",
  "VITE_FIREBASE_MESSAGING_SENDER_ID": "408502804009",
  "VITE_FIREBASE_APP_ID": "1:408502804009:web:03a42eb1588f1db97d4638",
  "VITE_FIREBASE_MEASUREMENT_ID": "G-5YWJ1ZBT4M",
  "VITE_WORDPRESS_PUBLIC_SITE_URL": "https://h4ck3d.me"
}
```

> ⚠️ **Nikdy nepridávaj `secrets.json` do Gitu!** Obsahuje produkčné kľúče.

---

## 🛠️ Inštalácia a spustenie

### Požiadavky

- Flutter SDK `^3.12.0` (odporúčaný kanál: `stable`)
- Dart SDK `^3.12.0`
- Chrome (pre webový vývoj)
- Android Studio / Xcode (pre mobilný vývoj)

### 1. Inštalácia závislostí

```bash
cd centralny-dashboard-flutter
flutter pub get
```

### 2. Spustenie v development móde

```bash
# Web (Chrome)
flutter run -d chrome --dart-define-from-file=secrets.json

# Predvolené zariadenie
flutter run --dart-define-from-file=secrets.json

# macOS
flutter run -d macos --dart-define-from-file=secrets.json
```

### 3. Produkčný build

```bash
# Web build
flutter build web --dart-define-from-file=secrets.json

# Aplikovanie JS integer patchu pre Isar (povinné po každom build_runner!)
dart run tool/patch_isar_web.dart
```

---

## 🚀 Nasadenie (Deploy)

### Vercel (hlavná produkcia)

```bash
# Build
flutter build web --dart-define-from-file=secrets.json
dart run tool/patch_isar_web.dart

# Deploy
npx vercel deploy build/web --scope h4ck3d --prod --yes
```

**Produkčná URL:** [https://crm.nexify-studio.tech](https://crm.nexify-studio.tech)

### Firebase Hosting (záloha)

```bash
# Build
flutter build web --dart-define-from-file=secrets.json
dart run tool/patch_isar_web.dart

# Deploy
npx -y firebase-tools@latest deploy --only hosting --project machinegunslots
```

**Firebase URL:** [https://machinegunslots.web.app](https://machinegunslots.web.app)

---

## 🧪 Testovanie

### Spustenie všetkých testov

```bash
flutter test --dart-define=INTEGRATION_TEST=true
```

### Výsledky testov

| Test | Stav |
|------|------|
| `Model Mapping Tests – Project fromMap/toMap` | ✅ Passed |
| `Model Mapping Tests – Bug fromMap/toMap` | ✅ Passed |
| `Isar initialization in headless environment` | ✅ Passed |
| `Complete user workflow (login → bug → AI → profile → logout)` | ✅ Passed |
| `Side menu navigation tabs render successfully` | ✅ Passed |

### Flutter Analyze

```bash
flutter analyze
```

> Všetky `error` a `warning` sú vyriešené. Zostávajú len `info` (deprecated API, avoid_print) — neblokujú build.

---

## 🗄️ Databázová architektúra

### Supabase tabuľky (PostgreSQL)

| Tabuľka | Popis | Kľúč |
|---------|-------|------|
| `profiles` | Profil používateľa (fullName, jobTitle, avatar) | `user_id UUID` |
| `bugs` | Bug tickets | `id UUID` |
| `projects` | Projekty | `id UUID` |
| `ai_conversations` | AI chat konverzácie | `user_id UUID` |
| `ai_messages` | Správy v konverzáciách | `conversation_id UUID` |

### Lokálna Isar databáza (offline cache)

| Kolekcia | Popis |
|----------|-------|
| `IsarProject` | Cache projektov pre offline zobrazenie |
| `IsarBug` | Cache bug ticketov |
| `IsarOfflineQueue` | Fronta operácií čakajúcich na sync |

**Offline Sync Logic:**
1. Mutácia (vytvorenie/úprava bugu) sa vykoná lokálne v Isar ihneď
2. Operácia sa zaradí do `IsarOfflineQueue`
3. Background timer každých 10 sekúnd spracuje frontu
4. Po obnovení internetu sa operácie synchronizujú do Supabase v správnom poradí

---

## 🐛 Riešenie problémov

### Chyba: `400 Bad Request` pri Supabase dopyte

**Príčina:** Firebase UID nie je UUID formát (28-znakový alfanumerický reťazec).  
**Riešenie:** Implementovaná UUID validácia v `supabase_service.dart` — dopyty s ne-UUID sa automaticky vynechajú.

### Chyba: `401 Unauthorized` pre `manifest.json`

**Príčina:** Vercel Deployment Protection blokuje anonymné stiahnutie súborov.  
**Riešenie:** `<link rel="manifest" crossorigin="use-credentials" href="manifest.json">` v `web/index.html`.

### Chyba: `The integer literal can't be represented in JavaScript`

**Príčina:** Isar generuje 64-bit integer literály presahujúce JavaScript `Number.MAX_SAFE_INTEGER`.  
**Riešenie:** Po každom `build_runner build` spusti:
```bash
dart run tool/patch_isar_web.dart
```

### Regenerácia Isar schém

Po zmene `isar_models.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
dart run tool/patch_isar_web.dart  # Povinné pre web!
```

---

## 🔄 CI/CD Pipeline (GitHub Actions)

Automatický pipeline `.github/workflows/ci_cd.yml` sa spúšťa pri každom push na `main`/`master`:

```
1. Checkout repozitára
2. Setup Java 17 (Zulu)
3. Setup Flutter (stable)
4. flutter pub get
5. Stiahnutie libisar.so (Linux runner)
6. flutter analyze
7. flutter test --dart-define=INTEGRATION_TEST=true
```

---

## 📦 Závislosti (pubspec.yaml)

| Balíček | Verzia | Účel |
|---------|--------|------|
| `firebase_core` | ^4.9.0 | Firebase inicializácia |
| `firebase_auth` | ^6.5.1 | Firebase autentifikácia |
| `google_sign_in` | ^6.2.1 | Google OAuth |
| `supabase_flutter` | ^2.12.4 | Supabase klient |
| `provider` | ^6.1.5+1 | Stavový manažment |
| `isar` | ^3.1.0+1 | Lokálna NoSQL databáza |
| `isar_flutter_libs` | ^3.1.0+1 | Isar natívne knižnice |
| `path_provider` | ^2.1.5 | Cesta k lokálnemu úložisku |
| `fl_chart` | ^1.2.0 | Analytické grafy |
| `google_fonts` | ^8.1.0 | Typografia (Inter) |
| `lucide_icons_flutter` | ^3.1.14+1 | Ikony |
| `intl` | ^0.20.2 | Formátovanie dátumov |

---

## 🔐 Bezpečnosť

- `secrets.json` je v `.gitignore` — **nikdy sa nedostane do Gitu**
- Supabase používa Row Level Security (RLS) políce
- Firebase Auth spravuje všetky relácie používateľov
- UUID validácia bráni neplatným databázovým dopytom

---

## 👨‍💻 Lokálny vývoj — rýchle príkazy

```bash
# Inštalácia
flutter pub get

# Spustenie (web)
flutter run -d chrome --dart-define-from-file=secrets.json

# Testy
flutter test --dart-define=INTEGRATION_TEST=true

# Analýza kódu
flutter analyze

# Build (web)
flutter build web --dart-define-from-file=secrets.json
dart run tool/patch_isar_web.dart

# Deploy na Vercel
npx vercel deploy build/web --scope h4ck3d --prod --yes

# Deploy na Firebase Hosting
npx -y firebase-tools@latest deploy --only hosting --project machinegunslots

# Regenerácia Isar schém (po zmene modelov)
dart run build_runner build --delete-conflicting-outputs
dart run tool/patch_isar_web.dart
```

---

## 📝 Changelog

- **Jún 2026** — Firebase Hosting deploy, kompletné README
- **Máj 2026** — Produkčný hotfix: 400 Bad Request (Supabase UUID), 401 manifest (Vercel)
- **Máj 2026** — Nasadenie na Vercel ([https://web-h4ck3d.vercel.app](https://web-h4ck3d.vercel.app))
- **Máj 2026** — Flutter Web build opravený (Isar JS integer patch)
- **Máj 2026** — Migrácia z React + Vite do Flutter, offline-first architektúra s Isar

---

*Projekt: `centralny-dashboard-flutter` | Firebase: `machinegunslots` | Vercel: `h4ck3d`*
