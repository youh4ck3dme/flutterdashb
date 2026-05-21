# Centralny Bug Tracker Dashboard 🚀

Prémiová, responzívna a offline-first Flutter aplikácia pre centralizovanú správu chýb (bug tracking), navrhnutá s dôrazom na vizuálnu dokonalosť (sklenený/glassmorphic dizajn, animácie) a robustný offline-first prístup.

Aplikácia je uložená v adresári:
**`/Users/erikbabcan/.gemini/antigravity/scratch/centralny-dashboard-flutter`**

---

## 🔗 Produkčné URL adresy

Pri nasadení do produkcie sa používajú nasledujúce URL adresy a služby:

*   **Vercel Production Domain:** [https://web-h4ck3d.vercel.app](https://web-h4ck3d.vercel.app)
*   **Firebase Web App (Hosting):** [https://machinegunslots.web.app](https://machinegunslots.web.app) (alt: [https://machinegunslots.firebaseapp.com](https://machinegunslots.firebaseapp.com))
*   **Supabase Database & Auth API:** [https://dehhwfgxocctagfvqsjr.supabase.co](https://dehhwfgxocctagfvqsjr.supabase.co)
*   **WordPress Live Site:** [https://h4ck3d.me](https://h4ck3d.me)
*   **Tailscale Health Gate:** [https://macbook-air-uvatea-erik.tail8c034f.ts.net/health](https://macbook-air-uvatea-erik.tail8c034f.ts.net/health)

---

## 🛠️ Dev Setup a Spustenie Projektu

Na lokálny vývoj a testovanie aplikácie postupujte podľa nasledujúcich krokov:

### 1. Príprava prostredia (Prerequisites)
*   Nainštalovaný **Flutter SDK** (verzia `^3.12.0` alebo novšia).
*   Pre mobilný vývoj: Android Studio (s Android SDK) / Xcode (s CocoaPods pre iOS/macOS).
*   Pre webový vývoj: Prehliadač Chrome.

### 2. Inštalácia závislostí
Stiahnite a nainštalujte všetky potrebné balíčky (dependencies) pre projekt:
```bash
flutter pub get
```

### 3. Konfigurácia Secrets (`secrets.json`)
Všetky citlivé prístupové kľúče (Supabase, Firebase, WordPress) sú uložené v súbore `secrets.json` v koreňovom adresári projektu. Tento súbor **je ignorovaný systémom Git** (nachádza sa v `.gitignore`).

Pre správne fungovanie skopírujte súbor `secrets.json.example` pod názvom `secrets.json` a doplňte doň reálne kľúče:
```json
{
  "VITE_SUPABASE_URL": "https://dehhwfgxocctagfvqsjr.supabase.co",
  "VITE_SUPABASE_PUBLISHABLE_KEY": "vaš-anon-kľúč",
  "VITE_FIREBASE_API_KEY": "vaš-firebase-api-kľúč",
  "VITE_FIREBASE_AUTH_DOMAIN": "machinegunslots.firebaseapp.com",
  "VITE_FIREBASE_PROJECT_ID": "machinegunslots",
  "VITE_FIREBASE_STORAGE_BUCKET": "machinegunslots.firebasestorage.app",
  "VITE_FIREBASE_MESSAGING_SENDER_ID": "sender-id",
  "VITE_FIREBASE_APP_ID": "app-id",
  "VITE_FIREBASE_MEASUREMENT_ID": "measurement-id",
  "VITE_WORDPRESS_PUBLIC_SITE_URL": "https://h4ck3d.me"
}
```

### 4. Lokálne spustenie (Development Mode)
Pre spustenie aplikácie na vašom zariadení (web, emulátor, mobil) použite parameter `--dart-define-from-file`, ktorý zabezpečí načítanie všetkých premenných zo `secrets.json`:
```bash
# Spustenie na predvolenom zariadení
flutter run --dart-define-from-file=secrets.json

# Ak chcete spustiť na konkrétnom zariadení (napr. Chrome pre web)
flutter run -d chrome --dart-define-from-file=secrets.json
```

### 5. Zostavenie pre produkciu (Production Build)
Ak chcete vygenerovať finálny produkčný build (napríklad pre web):
```bash
flutter build web --dart-define-from-file=secrets.json
```

---

## ⚙️ Generovanie kódu (Build Runner) a Web Workaround

### 1. Zmena dátových modelov (Isar Database)
Ak zmeníte modely databázy v `lib/core/isar_models.dart`, musíte znova vygenerovať databázový kód:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2. Aplikovanie Web Patche pre JavaScript (`dart2js`)
Isar DB generuje veľké 64-bitové identifikátory, ktoré presahujú limit presnosti JavaScriptu ($2^{53} - 1$), čo pri zostavovaní pre web spôsobuje kompilačnú chybu:
`Error: The integer literal ... can't be represented exactly in JavaScript.`

Preto sme vytvorili automatický **patchovací skript**, ktorý prepíše generované literály na bitové operácie kompatibilné s JS (`(high << 32) | low`).

**Dôležité:** Po každom úspešnom spustení `build_runner build` musíte spustiť tento skript, inak webový build zlyhá:
```bash
dart run tool/patch_isar_web.dart
```

---

## 🧪 Testovanie

Projekt obsahuje unit testy, testy lokálnej databázy a komplexné E2E headless testy simulujúce reálny tok (prihlásenie, nahlásenie chyby, chat s AI, odhlásenie).

Na overenie chodu v testovacom režime je nutné nastaviť príznak `INTEGRATION_TEST=true`, aby aplikácia v testoch nevolala Google Fonts API cez internet (keďže HTTP požiadavky sú v testoch zakázané):

```bash
flutter test --dart-define-from-file=secrets.json --dart-define=INTEGRATION_TEST=true
```

---

## 📁 Štruktúra priečinkov v lib/

*   `lib/core/` - Hlavné zdieľané služby:
    *   `auth_provider.dart` & `data_provider.dart` - Správa stavu a synchronizácia dát.
    *   `config.dart` - Načítanie premenných prostredia.
    *   `isar_service.dart` & `isar_models.dart` - Offline NoSQL databáza.
    *   `theme.dart` - Glassmorphic dizajn systém (Indigo & Emerald).
*   `lib/features/` - Samostatné funkčné celky aplikácie:
    *   `auth/` - Prihlasovanie a registrácia (Firebase).
    *   `dashboard/` - Prehľad chýb, grafy a štatistiky.
    *   `projects/` - Prehľad spravovaných projektov.
    *   `bugs/` - Tabuľky, Kanban nástenka a zakladanie bugov.
    *   `analytics/` - Pokročilé charty.
    *   `ai_assistant/` - AI Chat interface s mock asistentom.
    *   `settings/` - Nastavenia profilu používateľa.
    *   `shell/` - Responzívny navigačný panel (sidebar pre web/desktop, drawer pre mobil).
