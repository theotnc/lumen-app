# Lumen - Handoff Mac

## Contexte
App Flutter catholique "Lumen - Compagnon Catholique", prête pour soumission App Store.
Développée sur Windows, build final sur Mac via Xcode.

## État actuel
- ✅ Code complet, `flutter analyze` → 0 erreurs
- ✅ Bundle ID : `com.cathoapp.lumen`
- ✅ Firebase configuré (Auth, Firestore, Google Sign-In, Apple Sign-In)
- ✅ 4 produits in-app purchase créés dans App Store Connect
- ✅ App créée dans App Store Connect ("Lumen - Compagnon Catholique")
- ✅ Politique de confidentialité : https://lumenprivacy.netlify.app
- ✅ Compte de test Firebase créé : test@lumen-app.fr
- ✅ Code sur GitHub : https://github.com/theotnc/lumen-app
- ⏳ Build iOS + archive + upload → À FAIRE SUR MAC

## Identifiants importants
- **Bundle ID** : `com.cathoapp.lumen`
- **Firebase project** : `catho-app-f8a0f`
- **Apple Team ID** : `ZFPBJ3LKA3`
- **App Store Connect** : "Lumen - Compagnon Catholique" (ID 6762096179)
- **Compte de test** : test@lumen-app.fr / Lumen2026!
- **Privacy Policy** : https://lumenprivacy.netlify.app
- **Support URL** : https://lumenprivacy.netlify.app
- **Contact** : txrnink@pm.me

## Clé Groq à remettre
Dans `lib/core/config.dart`, remplacer `GROQ_API_KEY` par la vraie clé `gsk_...`
⚠️ Ne pas commit cette clé sur GitHub

## Étapes restantes sur Mac

### 1. Setup
```bash
git clone https://github.com/theotnc/lumen-app.git
cd lumen-app
flutter pub get
```
Puis remettre la clé Groq dans `lib/core/config.dart`.

### 2. Build iOS release
```bash
flutter build ios --release --no-codesign
```

### 3. Xcode — Signature & Archive
1. Ouvrir `ios/Runner.xcworkspace` dans Xcode (pas .xcodeproj)
2. Sélectionner **Runner** → **Signing & Capabilities**
3. Team : sélectionner `ZFPBJ3LKA3`
4. Signing Certificate : **Automatically manage signing**
5. Menu **Product** → **Archive**
6. Une fois archivé → **Distribute App** → **App Store Connect** → **Upload**

### 4. App Store Connect — finaliser
Après upload (30-60 min pour processing) :
- Sélectionner le build dans la section "Build"
- Associer les 4 in-app purchases
- Vérifier la fiche (description, screenshots, privacy URL)
- Cliquer **Submit for Review**

### 5. Screenshots encore manquants
Si pas encore fait : prendre des screenshots sur simulateur iPhone 15 Pro Max (6.7") et iPhone 14 Plus (6.5") — 3 minimum par taille.

```bash
# Lancer sur simulateur
flutter run
```

## Structure du projet
```
lib/
  core/
    config.dart          ← clé Groq ici
    theme.dart           ← design tokens (gold #C9A844, dark)
    models/
    services/
      church_service.dart  ← charge 33K églises depuis assets/
      auth_service.dart
  features/
    auth/
    bible/
    churches/            ← carte + GPS
    community/           ← "Ensemble"
    donations/           ← 4 produits in-app
    home/                ← profil + edit profil
    notifications/
    pilgrimage/          ← 22 routes
    prayers/
assets/
  churches_france.json   ← 33 453 églises (3.4 MB, offline)
  bible-master/json/     ← Bible fr_apee.json offline
docs/
  privacy.html           ← politique de confidentialité
```

## Notes importantes
- L'assistant IA utilise l'API Groq (gratuite) — modèle llama-3.1-8b-instant
- Firebase Storage non activé (pas de plan Blaze) → pas de photo de profil
- Overpass API appelé seulement si <3 églises dans le bundle pour la zone
- Règles Firestore déployées et correctes
