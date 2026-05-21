# Centralny Bug Tracker Dashboard 🚀

Prémiová, responzívna a offline-first Flutter aplikácia pre centralizovanú správu chýb (bug tracking), navrhnutá s dôrazom na vizuálnu dokonalosť (sklenený/glassmorphic dizajn, animácie) a robustný offline-first prístup.

Aplikácia slúži ako kompletný prepis a vylepšenie pôvodnej React + TypeScript verzie do multiplatformového prostredia Flutter (iOS, Android, Web, macOS, Windows, Linux).

---

## 🔗 Produkčné URL adresy

Pri nasadení do produkcie sa používajú nasledujúce URL adresy a služby:

*   **Firebase Web App (Hosting):** [https://machinegunslots.web.app](https://machinegunslots.web.app) (alt: [https://machinegunslots.firebaseapp.com](https://machinegunslots.firebaseapp.com))
*   **Supabase Database & Auth API:** [https://dehhwfgxocctagfvqsjr.supabase.co](https://dehhwfgxocctagfvqsjr.supabase.co)
*   **WordPress Live Site:** [https://h4ck3d.me](https://h4ck3d.me)
*   **Tailscale Health Gate:** [https://macbook-air-uvatea-erik.tail8c034f.ts.net/health](https://macbook-air-uvatea-erik.tail8c034f.ts.net/health)

---

## 🛠️ Architektúra a technológie

Aplikácia je postavená na moderných základoch s cieľom zabezpečiť plynulý chod na webe aj mobilných zariadeniach:

1.  **State Management & Services:**
    *   `Provider` na správu stavu a závislostí.
    *   `SupabaseService` a `FirebaseService` pre autentifikáciu a synchronizáciu dát v reálnom čase (Real-time).
2.  **Offline-first databáza:**
    *   `Isar NoSQL Database` zabezpečuje lokálne ukladanie dát, bleskové vyhľadávanie a plnú funkčnosť bez pripojenia k sieti.
    *   Obsahuje plne funkčnú integráciu pre synchronizáciu lokálnych zmien so vzdialenou databázou Supabase po obnovení pripojenia.
3.  **UI & UX Design System:**
    *   **Glassmorphic Design:** Rozhranie využíva moderný vizuálny štýl s polopriehľadnými kartami (`BackdropFilter` na rozmazanie pozadia), jemnými gradientmi a prepracovanými mikro-animáciami.
    *   **Dark Mode:** Konzistentný a oči šetriaci tmavý režim (Indigo & Emerald motív).
    *   **Responzivita:** Prispôsobuje sa všetkým veľkostiam obrazoviek pomocou špeciálneho layout gridu (Mobil 📱 -> Tablet 📐 -> Desktop 💻).

---

## 🔑 Nastavenie Secrets (`secrets.json`)

Všetky citlivé prístupové údaje a API kľúče sú uložené v súbore `secrets.json` v koreňovom adresári projektu. Tento súbor **je bezpečne ignorovaný systémom Git** (nachádza sa v `.gitignore`), aby sa predišlo úniku kľúčov do repozitára.

### Formát súboru `secrets.json`
Vytvorte súbor `secrets.json` na základe vzoru `secrets.json.example`:

```json
{
  "VITE_SUPABASE_URL": "https://dehhwfgxocctagfvqsjr.supabase.co",
  "VITE_SUPABASE_PUBLISHABLE_KEY": "vaš-anon-kľúč",
  "VITE_FIREBASE_API_KEY": "váš-firebase-api-kľúč",
  "VITE_FIREBASE_AUTH_DOMAIN": "machinegunslots.firebaseapp.com",
  "VITE_FIREBASE_PROJECT_ID": "machinegunslots",
  "VITE_FIREBASE_STORAGE_BUCKET": "machinegunslots.firebasestorage.app",
  "VITE_FIREBASE_MESSAGING_SENDER_ID": "sender-id",
  "VITE_FIREBASE_APP_ID": "app-id",
  "VITE_FIREBASE_MEASUREMENT_ID": "measurement-id",
  "VITE_WORDPRESS_PUBLIC_SITE_URL": "https://h4ck3d.me"
}
```

---

## 🚀 Spustenie a zostavenie (Build)

Flutter automaticky načítava súbor `secrets.json` pomocou nového parametra `--dart-define-from-file`.

### Lokálne spustenie (Development)
```bash
# Spustenie aplikácie na predvolenom zariadení
flutter run --dart-define-from-file=secrets.json
```

### Zostavenie pre Web (Production Build)
```bash
# Kompilácia pre web s načítaním produkčných kľúčov
flutter build web --dart-define-from-file=secrets.json
```

---

## 🧪 Testovanie

Aplikácia obsahuje komplexné unit testy, widget testy a E2E (End-to-End) scenáre simulujúce reálne správanie používateľa.

### Spustenie všetkých testov lokálne
Na správne spustenie UI/E2E testov v bezhlavom režime bez vyžadovania reálneho sťahovania Google písiem počas testu použite parameter `INTEGRATION_TEST=true`:

```bash
flutter test --dart-define-from-file=secrets.json --dart-define=INTEGRATION_TEST=true
```

Tento príkaz spustí:
1.  **Unit testy modelov** (kontrola serializácie/deserializácie Project, Bug).
2.  **Isar headless testy** (verifikácia otvorenia a inicializácie offline databázy).
3.  **Kompletné E2E testy** (simulácia prihlásenia, vytvorenia chyby, komunikácie s AI asistentom, úpravy profilu a odhlásenia).

---

## 💡 Technické vychytávky (Web workarounds)

### Riešenie 64-bitových integerov pre JavaScript (`dart2js`)
Isar DB generuje pre svoje kolekcie a indexy veľké 64-bitové identifikátory (napr. `1115865611252199017`). Keďže JavaScript reprezentuje čísla len do presnosti $2^{53} - 1$, Dart kompilátor (`dart2js`) by pri bežnom zostavení zlyhal s chybou:
`Error: The integer literal ... can't be represented exactly in JavaScript.`

**Riešenie:** V súbore `lib/core/isar_models.g.dart` sme nahradili problematické číselné literály dynamickým bitovým posunom za behu kompilácie:
`((high << 32) | low)` (napr. `(259807802 << 32) | 1632598633`).
Tento prístup obchádza statickú kontrolu parsera `dart2js` a umožňuje 100% čistú kompiláciu pre web pri zachovaní plnej funkčnosti Isar DB na mobilných platformách.
