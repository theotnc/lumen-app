# 📱 PROJET APPLICATION CATHOLIQUE - DOCUMENTATION COMPLÈTE

**Date:** Avril 2026  
**Statut:** Phase de définition - Phase 1 (MVP)  
**Chef d'orchestre:** Toi  
**Assistant technique:** Claude  

---

## 🎯 VISION GÉNÉRALE DU PROJET

**Nom de l'app:** 📖 **Bible**  
**Logo:** 🐟 Poisson (icône catholique traditionnelle)  
**Région de départ:** 🗺️ Sud-Ouest de la France  

Créer une application catholique innovante pour iPhone (iOS) qui combine:
- 📖 Lecture de la Bible
- ⛪ Localisation des églises et horaires des messes
- 📿 Catalogue de prières
- 🔔 Notifications de prière
- 💰 Modèle freemium avec dons

**Objectif:** Aider les catholiques en France à pratiquer leur foi au quotidien.

---

## 📋 PHASE 1 - MVP (Minimum Viable Product)

### Fonctionnalités à développer en priorité:

#### **1. 📖 BIBLE INTÉGRÉE**

**Spécifications:**
- ✅ Faisabilité: TRÈS FACILE (2/5 difficulté)
- ✅ Coût annuel: 0€ (traduction gratuite en domaine public)
- ⏱️ Temps estimé: 1-2 semaines

**Traduction choisie:** 
- **Louis Segond 1910** (domaine public, très populaire)
- Alternative: Nouvelle Edition de Genève (aussi domaine public)
- Raison: Traductions gratuites et légales, parfaitement autorisées pour monétisation indirecte (dons)

**API recommandée:** API.Bible (Digital Bible Library)
- Gratuite et bien documentée
- Pas de problème de monétisation indirecte (dons autorisés)
- Support pour les traductions domaine public

**Fonctionnalités:**
- Lecture des versets (Ancien + Nouveau Testament)
- Traduction: Louis Segond 1910
- Recherche par mot-clé
- Marquer des favoris
- Annotations personnelles
- Interface claire et lisible

**Step-by-step:**
1. Choisir API.Bible comme source avec traduction Louis Segond
2. S'inscrire et obtenir une clé API
3. Implémenter en Swift (intégrer avec URLSession)
4. Stocker la clé API en backend (sécurité)
5. Créer l'interface de lecture
6. Ajouter la recherche
7. Implémenter le système de favoris (CloudKit ou Firebase)

---

#### **2. ⛪ LOCALISATION DES ÉGLISES + MAPKIT**

**Spécifications:**
- ✅ Faisabilité: POSSIBLE (3-4/5 difficulté)
- ✅ Coût annuel: 0€ (MapKit est gratuit)
- ⏱️ Temps estimé: 2-3 semaines

**Région focus:** Sud-Ouest de la France (Bordeaux, Toulouse, Bayonne, Pau, Périgueux, Agen, etc.)

**Technologie:** MapKit (natif Apple) - GRATUIT, contrairement à Google Maps

**Fonctionnalités:**
- Afficher les églises à proximité sur une carte
- Filtre par distance (5km, 10km, 25km, custom)
- Informations de chaque église:
  - Nom et adresse
  - Téléphone
  - Site web
  - Horaires des messes
  - Coordonnées GPS
- Directions (Apple Maps, Waze, Google Maps)
- Recherche par nom ou ville

**Step-by-step:**
1. Intégrer MapKit dans Swift
2. Demander permission de localisation
3. Créer une base de données Firebase avec les églises du Sud-Ouest
4. Structure de données église:
   ```
   {
     id: string,
     nom: string,
     adresse: string,
     latitude: number,
     longitude: number,
     telephone: string,
     siteWeb: string,
     diocese: string,
     horaires: {
       lundi: [],
       mardi: [],
       mercredi: [],
       jeudi: [],
       vendredi: [],
       samedi: [],
       dimanche: []
     }
   }
   ```
5. Afficher les marqueurs sur la carte
6. Implémenter les filtres de distance
7. Ajouter les détails au tap sur un marqueur
8. Géolocaliser l'utilisateur (permissions)

---

#### **3. 🕐 HORAIRES DES MESSES - SYSTÈME HYBRIDE**

**Spécifications:**
- ⚠️ Faisabilité: COMPLEXE (4/5 difficulté)
- ✅ Coût annuel: 0€
- ⏱️ Temps estimé: 1-2 mois (dépend de la source)

**Approche choisie: MIX DONNÉES MANUELLES + CROWDSOURCING**

**Phase 1 - MVP:** Données de base
- Remplir manuellement les horaires des églises principales du Sud-Ouest
- Villes focus: Bordeaux, Toulouse, Bayonne, Pau, Périgueux, Agen, Arcachon, Limoges
- Ou par diocèse du Sud-Ouest (Bordeaux, Agen, Bayonne, Pamiers, Tarbes, Auch, Cahors, Périgueux)

**Phase 2 - Améliorations:** Crowdsourcing
- Les utilisateurs peuvent ajouter/modifier les horaires
- Système de modération:
  - Les horaires ajoutés doivent être vérifiés par un admin avant publication
  - Historique des changements
  - Notation de fiabilité (date de dernière mise à jour)

**Structure de données:**
```
{
  egliseId: string,
  jour: string (lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche),
  heure: string (HH:MM format 24h),
  type: string (Messe, Rosaire, Confessions, Adoration),
  langue: string (Français, Latin, etc),
  celebrant: string (optionnel),
  notes: string (optionnel - ex: "dernière dimanche du mois"),
  dateModification: timestamp,
  modifierPar: userId,
  verifiee: boolean
}
```

**Step-by-step:**
1. Créer une collection Firebase "horaires"
2. Remplir manuellement pour les 8 principales villes du Sud-Ouest
3. Implémenter l'interface pour afficher les horaires par église
4. Filtrer les horaires par jour/heure/type
5. Afficher "Messe prochaine" en gros
6. Implémenter le système d'ajout d'horaires par les users (Phase 2)
7. Ajouter la modération (Phase 2)

---

#### **4. 📿 CATALOGUE DE PRIÈRES**

**Spécifications:**
- ✅ Faisabilité: TRÈS FACILE (1/5 difficulté)
- ✅ Coût annuel: 0€
- ⏱️ Temps estimé: 1 semaine

**Fonctionnalités:**
- Prières classiques:
  - Notre Père
  - Ave Maria
  - Je vous salue Marie
  - Gloire soit au Père
  - Credo
  - Confiteor
  - Bénédicité
  - Acte de contrition
  - Salve Regina
- Rosaire (mystères joyeux, douloureux, glorieux, lumineux)
- Litanies (Litanie de la Sainte Vierge, du Sacré-Cœur, etc)
- Prières des Saints
- Novenas populaires
- Recherche par mot-clé
- Favoris

**Optionnel - Phase 2:**
- Audio (texte-vers-parole natif iOS)
- Compteur (nombre d'Ave Maria récitées)
- Rosaire interactif avec guidage

**Structure de données:**
```
{
  id: string,
  titre: string,
  categorie: string (Classique, Rosaire, Litanie, Saint, Novena, etc),
  contenu: string (texte complet de la prière),
  audio: URL (optionnel - Phase 2),
  longueur: number (minutes estimées de récitation),
  dateAjout: timestamp
}
```

**Step-by-step:**
1. Créer une base de données locale (CoreData) ou Firebase avec les prières
2. Remplir avec les prières catholiques classiques (domaine public)
3. Créer l'interface de liste par catégorie
4. Détail de chaque prière au tap
5. Implémenter la recherche
6. Système de favoris (côté client, synced avec Firebase)
7. Optionnel Phase 2: intégrer TTS (Text-To-Speech) natif iOS

---

#### **5. 🔔 NOTIFICATIONS DE PRIÈRE**

**Spécifications:**
- ✅ Faisabilité: TRÈS FACILE (1/5 difficulté)
- ✅ Coût annuel: 0€
- ⏱️ Temps estimé: 2-3 jours

**Horaires choisis:** 12h et 18h
- 12h: Prière du midi (Angelus)
- 18h: Prière du soir (Vêpres)

**Fonctionnalités:**
- Notifications programmées pour inviter l'utilisateur à prier
- Heures par défaut: 12h et 18h
- Contenu variable:
  - Versets bibliques du jour
  - Invitation à la prière (Angelus à 12h, Vêpres à 18h)
  - Saint du jour
  - Pensée spirituelle du jour
- Utilisateur peut:
  - Personnaliser les heures (ajouter 6h, 9h, etc)
  - Choisir la fréquence
  - Activer/désactiver globalement
  - Choisir le type de contenu

**Step-by-step:**
1. Utiliser UserNotifications framework (natif iOS)
2. Demander les permissions au lancement
3. Créer les notifications programmées (12h + 18h par défaut)
4. Interface de paramétrage:
   - Toggle On/Off par notification
   - Picker pour personnaliser les heures
   - Choisir le type de contenu (verset, invitation, pensée)
   - Silencieux/Non silencieux
5. Backend: stocker les préférences de l'utilisateur dans Firebase
6. Notifications persistantes (relancer même après redémarrage)

---

#### **6. 💰 SYSTÈME DE DONS IN-APP**

**Spécifications:**
- ✅ Faisabilité: TRÈS FACILE (1/5 difficulté)
- ✅ Coût annuel: 0€ (Apple gère)
- ⏱️ Temps estimé: 2-3 jours

**Montants de dons:** 1€, 2€, 5€, 10€ + Montant custom
- Apple prend 30% des dons - c'est autorisé pour les apps gratuites avec In-App Purchases

**Montants réels reçus:**
- 1€ → tu reçois 0,70€
- 2€ → tu reçois 1,40€
- 5€ → tu reçois 3,50€
- 10€ → tu reçois 7,00€

**Fonctionnalités:**
- Écran "Soutenir le développeur" accessible depuis:
  - Menu principal (bouton cœur)
  - Paramètres
- Message personnalisé: "Aidez-moi à continuer ce projet de foi"
- Afficher les montants en gros + description
- Aucune restriction de features pour ceux qui ne donnent pas
- Remerciement après don (pop-up ou message)
- Compteur: "X personnes ont soutenu ce projet"
- Historique des dons (optionnel - pour transparence)

**Step-by-step:**
1. Intégrer StoreKit 2 (Apple officiel)
2. Créer les In-App Purchases dans App Store Connect:
   - bible.donation.1euro
   - bible.donation.2euros
   - bible.donation.5euros
   - bible.donation.10euros
   - bible.donation.custom (si possible)
3. Implémenter l'interface de don
4. Gérer les transactions et acknowledgements
5. Tracking des dons en backend (pour stats/gratitude)
6. Message de remerciement personnalisé

---

## 🔐 AUTHENTIFICATION & COMPTES UTILISATEURS

**Important:** Les utilisateurs auront besoin d'un compte pour:
- Sauvegarder les favoris (Bible + Prières)
- Synchroniser entre appareils
- Sauvegarder les paramètres (notifications)
- Ajouter des horaires (crowdsourcing Phase 2)

**Options d'authentification choisies (par ordre de priorité):**
1. ✅ Apple Sign-In (natif iOS, simple, sécurisé)
2. ✅ Email + mot de passe (classique, universel)
3. 🟡 Google Sign-In (optionnel, bonus)

**Backend:** FIREBASE (Google)
- **Avantages:** 
  - Setup rapide (2-4h)
  - Authentification intégrée (Apple, Email, Google)
  - Database temps réel (Firestore)
  - Gratuit jusqu'à 50k opérations/jour
  - Pas besoin de gérer l'infrastructure
  - Scalable automatiquement
  
- **Coût:** 0€ les 6 premiers mois (probablement)

**Step-by-step Firebase:**
1. Créer un projet Firebase Console
2. Configurer les authentifications:
   - Apple Sign-In
   - Email/Password
   - Google Sign-In (bonus)
3. Activer les règles de sécurité
4. Créer la database Firestore
5. Implémenter en Swift avec Firebase SDK
6. Gérer les tokens de session

---

## 👥 GESTION DES UTILISATEURS & RÔLES

### **Profils utilisateurs:**

1. **UTILISATEUR LAMBDA** (MVP)
   - Peut: lire la Bible, voir les églises, consulter les horaires, avoir des notifications
   - Peut: marquer les favoris (Bible + Prières), créer des annotations
   - Ne peut pas: modifier les horaires (Phase 2)
   - Permissions: Localisation (optionnelle), Notifications

2. **CONTRIBUTEUR** (Phase 2)
   - Peut: ajouter/modifier les horaires des églises
   - Peut: signaler une erreur
   - Les modifications sont en attente de modération
   - Réputation: nombre de contributions validées

3. **MODÉRATEUR** (Phase 2)
   - Approuve les nouveaux horaires ajoutés par les contributeurs
   - Peut éditer directement les horaires
   - Supprime les données incorrectes
   - Répond aux signalements

4. **ADMINISTRATEUR**
   - Gère tout: utilisateurs, contenus, modérateurs
   - Access total à la base de données
   - Statistiques d'usage
   - Gestion des dons/revenus

### **Structure utilisateur Firebase:**
```
{
  uid: string (unique ID Firebase),
  email: string,
  displayName: string,
  photoURL: string (optionnel),
  role: string (user, contributor, moderator, admin),
  createdAt: timestamp,
  preferences: {
    notificationHours: [12, 18],
    notificationEnabled: boolean,
    bibleFavorites: [string],
    prayerFavorites: [string],
    churchFavorites: [string],
    distanceRadius: number (km),
    language: string
  },
  stats: {
    contributionsCount: number,
    approvedCount: number,
    donateTotalAmount: number (€)
  }
}
```

---

## 🏗️ ARCHITECTURE TECHNIQUE

### **Stack technologique:**

```
┌──────────────────────────────┐
│   iOS App (Swift)            │
│   - SwiftUI (UI Framework)   │
│   - MapKit (Cartes)          │
│   - UserNotifications        │
│   - StoreKit 2 (Dons)        │
│   - URLSession (API Calls)   │
│   - CoreData (Local Cache)   │
└────────────┬─────────────────┘
             │
    ┌────────▼──────────────────┐
    │  FIREBASE (Google Cloud)  │
    │  - Authentication         │
    │  - Firestore DB           │
    │  - Cloud Storage          │
    │  - Realtime Updates       │
    └───────────────────────────┘
             │
    ┌────────▼──────────────────┐
    │  EXTERNAL APIs            │
    │  - API.Bible              │
    │  - MapKit Tiles           │
    └───────────────────────────┘
```

### **Données stockées localement (iPhone):**
- Versets favoris (CoreData)
- Prières favorites (CoreData)
- Cache de la Bible (pour mode offline)
- Paramètres de notifications
- Historique de lecture (optionnel)
- Synchronisation avec iCloud (CloudKit)

### **Données stockées en cloud (Firebase Firestore):**
- Compte utilisateur + préférences
- Églises et leurs horaires
- Modifications apportées par les contributeurs
- Historique des contributions
- Modération des horaires
- Statistiques d'usage
- Dons (cryptés)

---

## 📱 SPÉCIFICATIONS GÉNÉRALES

### **Plateforme:**
- **Principal:** iOS 14.0+ (iPhone)
- **Bonus Phase 2:** iPad
- **Bonus Phase 3:** Mac (via Catalyst)

### **Design & Branding:**
- **Nom de l'app:** 📖 **Bible** (provisoire)
- **Logo:** 🐟 **Poisson** (symbole catholique traditionnel, ichthys)
- **Style:** Moderne + minimaliste + respectueux + zen
- **Couleur dominante:** À définir (suggestion: bleu ciel ou violet liturgique)
- **Couleurs secondaires:** Or, blanc, tons pastel
- **Police:** San Francisco (native iOS)
- **Icons:** SF Symbols (Apple) + Custom icons (poisson)
- **Atmosphère:** Calme, contemplative, invitante

### **Langage:**
- Interface en Français (principal)
- Option pour ajouter d'autres langues:
  - Anglais
  - Latin
  - Espagnol (Phase 2)

### **Accessibilité:**
- ✅ Support VoiceOver (très important pour une app spirituelle)
- ✅ Contraste WCAG AA minimum
- ✅ Tailles de police ajustables (Dynamic Type)
- ✅ Mode sombre complet
- ✅ Descriptions alternatives pour images
- ✅ Support des sous-titres pour audio (Phase 2)

### **Performance:**
- App légère (moins de 200MB)
- Chargement rapide (< 2 secondes au démarrage)
- Offline capability (Bible + prières en local)
- Optimisé pour batterie

---

## 📊 ROADMAP - PHASES DE DÉVELOPPEMENT

### **PHASE 1 - MVP (6-8 semaines)**
**Objectif:** App fonctionnelle avec les basics, prête pour App Store

**Semaines:**
- **Semaine 1-2:** Setup Xcode + Firebase + Project Structure
- **Semaine 2-3:** Authentification (Apple Sign-In + Email)
- **Semaine 3-4:** Bible + Interface de lecture + Recherche
- **Semaine 4-5:** MapKit + Affichage des églises du Sud-Ouest
- **Semaine 5-6:** Horaires manuels (10 villes principales)
- **Semaine 6-7:** Catalogue de prières + Favoris
- **Semaine 7-7.5:** Notifications (12h + 18h)
- **Semaine 7.5-8:** Dons In-App + Paramètres
- **Semaine 8:** Testing, bug fixes, App Store prep

**Deliverable:**
- App fonctionnelle complète
- Prête à soumettre à l'App Store
- Documentée et testée
- Version 1.0

---

### **PHASE 2 - AMÉLIORATIONS (4-6 semaines)**
**Objectif:** Engagement communautaire + Plus de contenu

- ✅ Système de crowdsourcing (contributeurs)
- ✅ Modération des horaires (modérateurs)
- ✅ Étendre à plus de villes du Sud-Ouest
- ✅ Audio pour prières (TTS)
- ✅ Rosaire interactif
- ✅ Community features
- ✅ Statistiques utilisateur
- ✅ Amélioration UI/UX basée sur feedback
- ✅ Support multi-langues (Latin, Anglais)

**Version:** 1.1, 1.2, 1.3

---

### **PHASE 3 - FUTUR (Long-term)**
**Après consolidation du MVP:**

- 🚀 IA Spiritual Companion (Point 1 innovation)
- 🚀 Rosaire AR en 3D (Point 2 innovation)
- 🚀 Streaming de messes (Point 4 innovation)
- 🚀 Communauté de prière en direct (Point 3 innovation)
- 🚀 Android (React Native ou Flutter)
- 🚀 Apple Watch support
- 🚀 Synchronisation iCloud avancée
- 🚀 Expansions géographiques (France entière, Europe)

---

## ✅ CHECKLIST PRÉ-DÉVELOPPEMENT

**Validé par le chef d'orchestre:**

- [x] Nom: **Bible** (provisoire)
- [x] Logo: **🐟 Poisson**
- [x] Région: **Sud-Ouest de la France**
- [x] Traduction Bible: **Louis Segond 1910** (gratuit, légal, populaire)
- [x] Horaires notifications: **12h (Angelus) + 18h (Vêpres)**
- [x] Montants dons: **1€, 2€, 5€, 10€ + Custom**
- [x] Backend: **Firebase**
- [x] Authentification: **Apple Sign-In + Email**
- [x] Focus Phase 1: **Basics uniquement** (Bible, églises, horaires, prières, notifications, dons)
- [x] Phase 2: **Community features** (Rosaire interactif, etc)

**À finaliser avant de coder:**
- [ ] Couleur dominante définitive
- [ ] Design du logo (sketch/image)
- [ ] Listes des 10 villes Sud-Ouest prioritaires
- [ ] Contacts diocèses (optionnel Phase 1)
- [ ] App Store name + description (réserver l'app)

---

## 🚀 NOTES IMPORTANTES

### **1. Horaires des messes = point critique**
- ❌ Pas d'API centralisée en France
- ✅ Solution MVP: Remplir manuellement (1-2 mois)
- ✅ Solution long-terme: Crowdsourcing + Partenariats diocèses
- 💡 Contacter diocèses du Sud-Ouest pour partenariat progressif

### **2. Légalité & Compliance**
- ✅ Monétisation par dons = autorisée par Apple
- ✅ Bible Louis Segond 1910 = domaine public (pas de coûts)
- ✅ Prières classiques = domaine public
- ✅ Pas de données personnelles sensibles (RGPD OK)
- ✅ Privacy policy simple et transparente

### **3. Sécurité Firebase**
- ✅ Règles de sécurité strictes (Firestore)
- ✅ Validation côté serveur (Cloud Functions)
- ✅ Pas de données sensibles en local
- ✅ Chiffrement des transactions dons
- ✅ API keys en backend (jamais en client)

### **4. Modération future (Phase 2)**
- Système de flagging pour les horaires incorrects
- Admin dashboard pour approuver/rejeter
- Historique complet des modifications
- Réputation des contributeurs

### **5. Accessibilité - Important**
- VoiceOver pour lire la Bible en audio
- Contraste OK pour mode sombre/clair
- Dynamic Type pour ajuster tailles polices
- Essentiellement pour app spirituelle = inclusive

---

## 📞 CONTACTS À PRÉVOIR (Phase 2+)

**Pour expansions futures:**
- Diocèses du Sud-Ouest (Bordeaux, Agen, Bayonne, etc)
- Églises pour autoriser streaming
- Développeurs qui voudraient contribuer
- Influenceurs catholiques (promotion)

---

## 🎼 PROCHAINES ÉTAPES

1. ✅ **Document approuvé par chef d'orchestre**
2. ⏳ **Passer cette doc à Claude Code via shell** (prochaine étape)
3. ⏳ **Claude Code crée le projet Xcode complet**
4. ⏳ **Setup Firebase + API keys**
5. ⏳ **Commencer le développement Phase 1**
6. ⏳ **Testing + Itérations**
7. ⏳ **Soumission App Store**
8. ⏳ **Launch v1.0**

---

## 📄 DOCUMENT INFO

- **Créé:** Avril 2026
- **Version:** 2.0 (Updated avec infos du chef)
- **Format:** Markdown
- **Pour:** Transmission à Claude Code
- **Status:** Prêt au développement
- **Confidentiel:** Non (peut être partagé)

---

**Document finalisé et validé ✅**  
**Prêt à lancer le développement avec Claude Code!** 🚀
