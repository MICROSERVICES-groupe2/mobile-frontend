# Mobile Frontend — Plan d'Implémentation Complet (Flutter)

**Application :** bank-platform-frontend-mobile  
**Framework :** Flutter 3.x (Dart)  
**Plateformes cibles :** Android (APK/AAB) + iOS (IPA)  
**Phases plan :** P4.8 → P4.13  
**Durée estimée :** 2–3 semaines

---

## Table des Matières

1. [T1 — Initialisation & Architecture](#t1--initialisation--architecture)
2. [T2 — Couche Data (Repositories & Datasources)](#t2--couche-data-repositories--datasources)
3. [T3 — Couche Domain (Entités & UseCases)](#t3--couche-domain-entités--usecases)
4. [T4 — Authentification (P4.9)](#t4--authentification-p49)
5. [T5 — Dashboard & Comptes (P4.10)](#t5--dashboard--comptes-p410)
6. [T6 — Transactions & Transferts (P4.11)](#t6--transactions--transferts-p411)
7. [T7 — Paiements & Activité](#t7--paiements--activité)
8. [T8 — Prêts & Scan Documents (P4.12)](#t8--prêts--scan-documents-p412)
9. [T9 — Notifications Push (P4.13)](#t9--notifications-push-p413)
10. [T10 — Tests + Build de Production](#t10--tests--build-de-production)
11. [Ordre d'implémentation recommandé](#ordre-dimplémentation-recommandé)

---

## T1 — Initialisation & Architecture

> P4.8 — Créer le projet et mettre en place la Clean Architecture

### P4.8.1 — Création du projet

- [ ] Créer le projet Flutter :
  ```bash
  flutter create mobile_app --org com.bankplatform
  cd mobile_app
  flutter doctor  # vérifier que tout est OK
  ```
- [ ] Configurer `android/app/build.gradle` :
  - `minSdkVersion 21`
  - `targetSdkVersion 34`
  - `applicationId "com.bankplatform.mobile"`
- [ ] Configurer `ios/Runner/Info.plist` :
  - Permissions caméra, galerie, biométrie, notifications
- [ ] Configurer le fichier `pubspec.yaml` avec toutes les dépendances :

  **State Management & Navigation :**
  ```yaml
  flutter_bloc: ^8.1.3
  go_router: ^13.0.0
  equatable: ^2.0.5
  ```

  **Réseau & Stockage :**
  ```yaml
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  ```

  **UI & Design :**
  ```yaml
  material_color_utilities: latest
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  fl_chart: ^0.66.0
  intl: ^0.19.0
  ```

  **Fonctionnalités :**
  ```yaml
  local_auth: ^2.1.8
  image_picker: ^1.0.7
  firebase_core: ^2.27.0
  firebase_messaging: ^14.7.19
  flutter_local_notifications: ^16.3.0
  permission_handler: ^11.3.0
  ```

  **Dev & Tests :**
  ```yaml
  dev_dependencies:
    flutter_test:
      sdk: flutter
    bloc_test: ^9.1.7
    mocktail: ^1.0.3
    build_runner: ^2.4.8
  ```

### P4.8.2 — Architecture Clean (dossiers)

- [ ] Créer la structure de dossiers suivante :
  ```
  lib/
  ├── main.dart
  ├── app.dart                   # MaterialApp + GoRouter
  ├── core/
  │   ├── constants/
  │   │   ├── api_constants.dart  # URLs, endpoints
  │   │   └── app_constants.dart  # constantes app
  │   ├── errors/
  │   │   ├── exceptions.dart
  │   │   └── failures.dart
  │   ├── network/
  │   │   ├── dio_client.dart     # config Dio + interceptors
  │   │   └── network_info.dart
  │   ├── storage/
  │   │   └── secure_storage.dart # wrapper flutter_secure_storage
  │   └── utils/
  │       ├── currency_formatter.dart
  │       └── date_formatter.dart
  │
  ├── data/
  │   ├── datasources/
  │   │   ├── auth_remote_datasource.dart
  │   │   ├── account_remote_datasource.dart
  │   │   ├── transaction_remote_datasource.dart
  │   │   └── loan_remote_datasource.dart
  │   ├── models/
  │   │   ├── user_model.dart
  │   │   ├── account_model.dart
  │   │   ├── transaction_model.dart
  │   │   └── loan_model.dart
  │   └── repositories/
  │       ├── auth_repository_impl.dart
  │       ├── account_repository_impl.dart
  │       ├── transaction_repository_impl.dart
  │       └── loan_repository_impl.dart
  │
  ├── domain/
  │   ├── entities/
  │   │   ├── user.dart
  │   │   ├── account.dart
  │   │   ├── transaction.dart
  │   │   └── loan.dart
  │   ├── repositories/
  │   │   ├── auth_repository.dart       # interfaces abstraites
  │   │   ├── account_repository.dart
  │   │   ├── transaction_repository.dart
  │   │   └── loan_repository.dart
  │   └── usecases/
  │       ├── auth/
  │       │   ├── login_usecase.dart
  │       │   ├── logout_usecase.dart
  │       │   └── verify_2fa_usecase.dart
  │       ├── accounts/
  │       │   └── get_accounts_usecase.dart
  │       ├── transactions/
  │       │   ├── get_transactions_usecase.dart
  │       │   └── create_transfer_usecase.dart
  │       └── loans/
  │           ├── request_loan_usecase.dart
  │           └── simulate_loan_usecase.dart
  │
  └── presentation/
      ├── blocs/
      │   ├── auth/
      │   │   ├── auth_bloc.dart
      │   │   ├── auth_event.dart
      │   │   └── auth_state.dart
      │   ├── accounts/
      │   ├── transactions/
      │   └── loans/
      ├── screens/
      │   ├── splash/
      │   ├── auth/
      │   │   ├── login_screen.dart
      │   │   ├── two_fa_screen.dart
      │   │   └── biometric_screen.dart
      │   ├── dashboard/
      │   ├── accounts/
      │   ├── transactions/
      │   ├── loans/
      │   └── profile/
      └── widgets/
          ├── common/
          │   ├── app_button.dart
          │   ├── app_text_field.dart
          │   ├── loading_overlay.dart
          │   └── error_widget.dart
          ├── account_card.dart
          └── transaction_tile.dart
  ```

### P4.8.3 — Configuration réseau (Dio)

- [ ] Créer `lib/core/network/dio_client.dart` :
  - Base URL depuis `api_constants.dart` (variable d'env ou fichier de config)
  - **Intercepteur JWT** : ajouter `Authorization: Bearer <token>` sur chaque requête
  - **Intercepteur de refresh** : si 401 reçu → appeler `/api/auth/refresh` → réessayer la requête
  - **Intercepteur de log** : logger requêtes/réponses en mode debug
  - Timeout : `connectTimeout: 10s`, `receiveTimeout: 30s`
- [ ] Créer `lib/core/constants/api_constants.dart` :
  ```dart
  class ApiConstants {
    static const String baseUrl = String.fromEnvironment(
      'API_BASE_URL', defaultValue: 'http://10.0.2.2:8000'); // Kong local
    static const String clientsPath = '/api/clients';
    static const String accountsPath = '/api/accounts';
    static const String transactionsPath = '/api/transactions';
    static const String loansPath = '/api/loans';
    static const String authPath = '/api/auth';
  }
  ```

### P4.8.4 — Navigation (GoRouter)

- [x] Configurer `go_router` dans `lib/app.dart` :
  - Route `/` → SplashScreen (vérifier le token JWT)
  - Route `/login` → LoginScreen
  - Route `/login/2fa` → TwoFAScreen
  - Route `/register` → RegisterScreen
  - Route `/register/otp` → RegisterOtpScreen
  - Route `/dashboard` → DashboardScreen (protégée)
  - Route `/accounts` → `TODO` AccountListScreen (protégée)
  - Route `/accounts/:id` → `TODO` AccountDetailScreen (protégée)
  - Route `/transactions` → TransactionsScreen (protégée)
  - Route `/transactions/:id` → TransactionDetailScreen (protégée)
  - Route `/transfer` → TransferScreen (protégée)
  - Route `/deposit` → DepositScreen (protégée)
  - Route `/payments` → PaymentsScreen (protégée)
  - Route `/activity` → ActivityScreen (protégée)
  - Route `/loans` → LoansScreen (protégée)
  - Route `/notifications` → NotificationsScreen (protégée)
  - Route `/profile` → ProfileScreen (protégée)
- [x] Implémenter le **redirect guard** : si pas de token → rediriger vers `/login`
- [ ] `TODO` Route `/accounts` et `/accounts/:id` — écrans à créer
- [ ] `TODO` Route `/loans/:id/schedule` — échéancier à créer

### P4.8.5 — Thème & Design System

- [ ] Créer `lib/core/theme/app_theme.dart` :
  - Palette de couleurs banking : bleu primaire, blanc, gris
  - `ThemeData` avec `ColorScheme`, `TextTheme`, `AppBarTheme`, `CardTheme`
  - Support Dark Mode (optionnel)
- [ ] Créer les widgets communs dans `lib/presentation/widgets/common/` :
  - `AppButton` — bouton primaire stylisé
  - `AppTextField` — champ de texte avec validation
  - `LoadingOverlay` — spinner plein écran
  - `ErrorWidget` — widget d'erreur avec retry
  - `ConfirmDialog` — dialog de confirmation (pour les actions critiques)

---

## T2 — Couche Data (Repositories & Datasources)

> Données externes : API Gateway Kong, stockage sécurisé

### P4.8.6 — Modèles JSON

- [ ] Créer les modèles de données avec `fromJson` / `toJson` pour chaque entité :

  **`user_model.dart`** :
  ```dart
  class UserModel extends User {
    const UserModel({required String id, required String email, required String role, required String nom});
    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'], email: json['email'], role: json['role'], nom: json['nom']);
    Map<String, dynamic> toJson() => {'id': id, 'email': email, 'role': role, 'nom': nom};
  }
  ```

  - [ ] `user_model.dart` — id, email, role, nom, prenom, twoFaEnabled
  - [ ] `account_model.dart` — id, clientId, type, solde, devise, statut
  - [ ] `transaction_model.dart` — id, accountId, type, montant, devise, statut, commission, timestamp
  - [ ] `loan_model.dart` — id, clientId, montant, dureeEnMois, statut, mensualite
  - [ ] `repayment_schedule_model.dart` — id, loanId, echeances (list)

### P4.8.7 — Remote Datasources

- [ ] `auth_remote_datasource.dart` : appels vers `/api/auth/*`
- [ ] `account_remote_datasource.dart` : appels vers `/api/accounts/*`
- [ ] `transaction_remote_datasource.dart` : appels vers `/api/transactions/*`
- [ ] `loan_remote_datasource.dart` : appels vers `/api/loans/*`

### P4.8.8 — Secure Storage

- [ ] Créer `lib/core/storage/secure_storage.dart` :
  - `saveToken(String token)` → `flutter_secure_storage`
  - `getToken() -> Future<String?>`
  - `saveRefreshToken(String token)`
  - `getRefreshToken() -> Future<String?>`
  - `clearAll()` → logout

---

## T3 — Couche Domain (Entités & UseCases)

> Logique métier pure, sans dépendance Flutter

### P4.8.9 — Entités

- [ ] Créer les entités Dart (pures, `Equatable`) :
  - `User` — id, email, role, nom, prenom, twoFaEnabled
  - `Account` — id, type, solde (double arrondi 2 décimales), devise, statut
  - `Transaction` — id, type, montant, devise, statut, description, timestamp
  - `Loan` — id, montant, dureeEnMois, statut, mensualite
  - `Echeance` — numero, dateEcheance, montantTotal, capitalDu, interets, capitalRestant

### P4.8.10 — Interfaces Repository

- [ ] Créer les interfaces abstraites dans `domain/repositories/` :
  ```dart
  abstract class AuthRepository {
    Future<Either<Failure, User>> login(String email, String password);
    Future<Either<Failure, User>> verify2FA(String code);
    Future<Either<Failure, bool>> loginWithBiometrics();
    Future<Either<Failure, void>> logout();
    Future<Either<Failure, bool>> isAuthenticated();
  }
  ```
  Même pattern pour `AccountRepository`, `TransactionRepository`, `LoanRepository`

### P4.8.11 — UseCases

- [ ] Créer un UseCase par action métier (1 classe = 1 action) :
  - `LoginUseCase`, `LogoutUseCase`, `Verify2FAUseCase`, `LoginWithBiometricsUseCase`
  - `GetAccountsUseCase`, `GetAccountDetailUseCase`
  - `GetTransactionsUseCase`, `CreateTransferUseCase`, `CreateDepositUseCase`
  - `GetLoansUseCase`, `SimulateLoanUseCase`, `RequestLoanUseCase`
  - `GetRepaymentScheduleUseCase`

---

## T4 — Authentification

> P4.9 — Login, 2FA, Biométrie

### P4.9.1 — Écran de Login

- [ ] Créer `lib/presentation/screens/auth/login_screen.dart` :
  - Champ email + champ password (masqué, toggle visibilité)
  - Bouton **"Se connecter"** → déclenche `AuthBloc.add(LoginRequested(email, password))`
  - Bouton **"Connexion biométrique"** (affiché si biométrie disponible)
  - Validation locale : email format, password non vide
  - Afficher un `CircularProgressIndicator` pendant l'appel API
  - Afficher le message d'erreur si échec (mauvais credentials → `SnackBar`)

- [ ] Créer `lib/presentation/blocs/auth/auth_bloc.dart` avec les états :
  - `AuthInitial` → `AuthLoading` → `AuthAuthenticated(user)` / `AuthError(message)`
  - `AuthRequires2FA` → attente du code TOTP
  - `AuthRequiresBiometric` → attente du scan biométrique

### P4.9.2 — Écran 2FA

- [ ] Créer `lib/presentation/screens/auth/two_fa_screen.dart` :
  - 6 champs individuels pour le code TOTP (ou un champ avec `OTP` formatter)
  - Auto-submit dès que 6 chiffres saisis
  - Appel `AuthBloc.add(TwoFAVerified(code))`
  - Timer de 30 secondes indiquant l'expiration du code
  - Bouton "Renvoyer" (pour les codes SMS — si applicable)

### P4.9.3 — Authentification Biométrique

- [ ] Créer `lib/core/biometric/biometric_service.dart` avec `local_auth` :
  ```dart
  class BiometricService {
    Future<bool> isAvailable() async {
      final auth = LocalAuthentication();
      return await auth.canCheckBiometrics;
    }
    Future<bool> authenticate() async {
      return await LocalAuthentication().authenticate(
        localizedReason: 'Confirmez votre identité',
        options: const AuthenticationOptions(biometricOnly: true));
    }
  }
  ```
- [ ] Intégrer dans `login_screen.dart` : vérifier la disponibilité au démarrage → afficher le bouton si disponible
- [ ] Après authentification biométrique : envoyer le token biométrique vers `POST /api/auth/biometric`

### P4.9.4 — Écran d'Inscription (Register)

- [x] Créer `lib/presentation/screens/auth/register_screen.dart` :
  - Form en 2 étapes : identité (nom, prénom, email) → sécurité (mot de passe, confirmation)
  - Validation côté client de tous les champs
  - Appel `AuthBloc.add(RegisterRequested(...))`
  - Navigation vers `/register/otp` après succès

### P4.9.5 — Écran Vérification OTP

- [x] Créer `lib/presentation/screens/auth/register_otp_screen.dart` :
  - 6 champs pour le code OTP reçu par email
  - Affichage du code OTP en mode développement (auto-submit facilité)
  - Timer de validité de l'OTP
  - Appel `AuthBloc.add(VerifyRegistrationOtp(...))`

### P4.9.6 — Stockage sécurisé du token

- [x] Après un login réussi : stocker `accessToken` + `refreshToken` dans `flutter_secure_storage`
- [x] Au démarrage de l'app (SplashScreen) : vérifier si un token existe et est valide → router vers Dashboard ou Login
- [x] Implémenter l'intercepteur Dio de refresh automatique

---

## T5 — Dashboard & Comptes

> P4.10 — Vue principale + gestion des comptes

### P4.10.1 — Écran Dashboard

- [x] Créer `lib/presentation/screens/dashboard/dashboard_screen.dart` (612 lignes) :
  - **Header** : logo app, "Bienvenue, [Prénom Nom]", avatar circulaire, cloche notifications avec badge
  - **Balance card** : carte glassmorphique affichant le premier compte (type, statut, solde formaté, numéro masqué `**** 1234`, date exp. `06/27`)
  - **Actions rapides** : 3 boutons ronds — Transfert, Paiement, Dépôt
  - **Transactions récentes** : liste des 5 dernières avec icône type, label, date, montant coloré (+ vert / - rouge)
  - **Bottom Navigation Bar** : Accueil (0), Transactions (1), Activité (2), Profil (3)
  - États : chargement (spinner), erreur, vide, loaded

- [x] Créer `lib/presentation/widgets/account_card.dart` :
  - Carte avec gradient selon le type (EPARGNE = bleu, COURANT = vert, MOBILE_MONEY = orange)
  - Afficher : type du compte, solde formaté (ex : `1 250 000 XAF`), statut
  - `InkWell` pour naviguer vers le détail

> **TODO** : Ajouter bouton "Prêt" dans les actions rapides. Ajouter un 5e onglet "Prêts" à la bottom nav ou intégrer dans un menu "Plus".

### P4.10.2 — Écran Liste des Comptes

- [x] Créer `lib/presentation/screens/accounts/account_list_screen.dart` (implémenté)
  - Liste basique des comptes
  - Pull-to-refresh
  - États chargement/erreur/vide

> **TODO** : Route `/accounts` non enregistrée dans GoRouter — ajouter la route et faire pointer le clic sur AccountCard du dashboard vers cette page.

### P4.10.3 — Écran Détail d'un Compte

- [ ] `TODO` Créer `lib/presentation/screens/accounts/account_detail_screen.dart` :
  - Solde actuel (grand et centré)
  - Informations du compte (type, devise, date de création, numéro)
  - Onglets : **Transactions** (historique filtrable) | **Infos** (détails compte)
  - Boutons d'action : "Déposer", "Retirer", "Transférer"
  - Route GoRouter : `/accounts/:id`
  - Lier depuis AccountCard (dashboard + account_list)

---

## T6 — Transactions & Transferts

> P4.11 — Historique + effectuer des opérations

### P4.11.1 — Écran Historique des Transactions

- [ ] Créer `lib/presentation/screens/transactions/transactions_screen.dart` :
  - `ListView` paginée (lazy loading avec scroll infini)
  - `TransactionTile` par ligne : icône type, description, montant coloré, date relative
  - **Filtres** : par type (dépôt/retrait/transfert), par plage de dates, par statut
  - Barre de recherche (filtrer par description)
  - `RefreshIndicator` (pull-to-refresh)

- [ ] Créer `lib/presentation/widgets/transaction_tile.dart` :
  - Icône selon le type (↑ retrait rouge, ↓ dépôt vert, ↔ transfert bleu)
  - Montant formaté avec devise
  - Date relative (hier, il y a 3 jours, etc.)
  - Badge statut (COMPLETED vert, PENDING orange, FAILED rouge)

### P4.11.2 — Écran Transfert

- [ ] Créer `lib/presentation/screens/transactions/transfer_screen.dart` :
  - Sélecteur **compte source** (dropdown)
  - Champ **numéro/identifiant** du compte destination
  - Champ **montant** (clavier numérique personnalisé)
  - Sélecteur **devise**
  - Champ **description** (optionnel)
  - **Aperçu des frais** calculés en temps réel (afficher la commission)
  - Bouton **"Confirmer le transfert"** → `ConfirmDialog` → appel API
  - Afficher le résultat : succès (animation verte) ou erreur

### P4.11.3 — Écran Dépôt / Retrait

- [ ] Créer `lib/presentation/screens/transactions/deposit_withdraw_screen.dart` :
  - Toggle **Dépôt / Retrait**
  - Sélecteur de compte
  - Clavier numérique pour le montant
  - Affichage du solde disponible (pour les retraits)
  - Validation en temps réel : montant > 0, solde suffisant (retrait), plafond respecté
  - Confirmation biométrique optionnelle avant validation

---

## T7 — Paiements & Activité

### P4.11.4 — Écran Paiement de Factures (Payments)

- [x] Créer `lib/presentation/screens/payments/payments_screen.dart` :
  - Grille de catégories : Électricité, Eau, Télécom, Mobile Money
  - Chaque catégorie avec icône, nom et couleur distincte
  - Navigation vers formulaire de paiement spécifique (à implémenter)
  - Route GoRouter : `/payments`

### P4.11.5 — Écran Activité / Statistiques

- [x] Créer `lib/presentation/screens/activity/activity_screen.dart` :
  - Revenus vs Dépenses du mois courant (grands chiffres)
  - Barre de progression (revenu/dépense)
  - Graphique en barres (bar chart) des 6 derniers mois
  - Liste chronologique des transactions (similaire à transactions_screen)
  - Route GoRouter : `/activity`

---

## T8 — Prêts & Scan Documents

> P4.12 — Demande de prêt + upload OCR

### P4.12.1 — Écran Prêts (LoansScreen)

- [x] Créer `lib/presentation/screens/loans/loans_screen.dart` (tabbed) :
  - **Onglet "Mes Prêts"** : liste des prêts avec montant, durée, mensualité, statut coloré, progression
  - **Onglet "Simuler"** : champs montant + durée, simulation en temps réel (mensualité, coût total, TAEG), bouton "Faire la demande"
  - Section **Documents justificatifs** : upload multipart via Dio avec progress bar
  - Route GoRouter : `/loans`

### P4.12.2 — `TODO` Écran Détail Prêt + Échéancier

- [ ] `TODO` Créer `lib/presentation/screens/loans/loan_detail_screen.dart` :
  - Détail d'un prêt : montant, durée, mensualité, statut, prochaine échéance
  - Tableau scrollable des échéances
  - Route GoRouter : `/loans/:id`

### P4.12.3 — `TODO` Écran Échéancier

- [ ] `TODO` Créer `lib/presentation/screens/loans/repayment_schedule_screen.dart` :
  - Tableau scrollable des échéances : numéro, date, montant, capital, intérêts, capital restant
  - Colorer en vert les payées, orange les à venir, rouge les en retard
  - Bouton "Effectuer un paiement" sur l'échéance courante

---

## T9 — Notifications Push

> P4.13 — Firebase Cloud Messaging + in-app

### P4.13.1 — Configuration Firebase

- [ ] Créer un projet Firebase Console (ou utiliser l'existant)
- [ ] Télécharger `google-services.json` → placer dans `android/app/`
- [ ] Télécharger `GoogleService-Info.plist` → placer dans `ios/Runner/`
- [ ] Initialiser Firebase dans `main.dart` :
  ```dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ```

### P4.13.2 — Service de Notifications

- [ ] Créer `lib/core/notifications/notification_service.dart` :
  - Demander la permission de recevoir des notifications au premier lancement
  - Enregistrer le token FCM et l'envoyer à `POST /api/auth/fcm-token`
  - Écouter les messages **foreground** (app ouverte) → `flutter_local_notifications`
  - Écouter les messages **background** et **terminated** → `FirebaseMessaging.onBackgroundMessage`
  - Gérer le **tap sur notification** → router vers l'écran concerné (transaction, prêt, etc.)

### P4.13.3 — Types de notifications à gérer

- [ ] Mapper chaque type d'événement vers l'écran de navigation approprié :

  | Type notification | Action au tap |
  |-------------------|---------------|
  | `TRANSACTION_CREATED` | Naviguer vers le détail de la transaction |
  | `TRANSFER_COMPLETED` | Naviguer vers l'historique des transactions |
  | `LOAN_APPROVED` | Naviguer vers l'écran du prêt approuvé |
  | `LOAN_REJECTED` | Naviguer vers la liste des prêts |
  | `PAYMENT_DUE` | Naviguer vers l'échéancier du prêt |

### P4.13.4 — Écran Notifications

- [x] Créer `lib/presentation/screens/notifications/notifications_screen.dart` :
  - Liste des notifications avec indicateur lu/non-lu (pastille bleue)
  - Chaque notification : icône type, titre, message, timestamp relatif
  - Tap sur notification → navigation vers écran concerné (transaction, prêt, etc.)
  - Route GoRouter : `/notifications`
  - Badge non-lu sur icône cloche dans le header du Dashboard

### P4.13.5 — Notifications In-App

- [ ] `TODO` Créer `lib/presentation/widgets/in_app_notification_banner.dart` :
  - Bannière animée qui glisse depuis le haut
  - Affiche l'icône + titre + message
  - Disparaît après 4 secondes ou au tap
  - Écouter les événements WebSocket (si disponible) ou polling toutes les 30s

---

## T10 — Tests + Build de Production

> P4.13 — Tests unitaires/widget + Build APK/IPA

### P4.13.6 — Tests unitaires (Domain layer)

- [ ] `test/domain/usecases/login_usecase_test.dart` :
  - Test login réussi → `AuthAuthenticated`
  - Test mauvais credentials → `AuthError`
  - Test réseau down → `AuthError(NetworkFailure)`

- [ ] `test/domain/usecases/transfer_usecase_test.dart` :
  - Test transfert réussi
  - Test solde insuffisant → erreur
  - Test plafond dépassé → erreur

- [ ] `test/domain/usecases/loan_simulate_usecase_test.dart` :
  - Test calcul mensualité correct (vérifier avec formule manuelle)

### P4.13.7 — Tests BLoC

- [x] `test/presentation/blocs/auth_bloc_test.dart` (avec `bloc_test`) :
  ```dart
  blocTest<AuthBloc, AuthState>(
    'emits AuthLoading then AuthAuthenticated on login success',
    build: () => AuthBloc(loginUseCase: mockLoginUseCase),
    act: (bloc) => bloc.add(LoginRequested(email: 'test@test.com', password: 'pass')),
    expect: () => [AuthLoading(), AuthAuthenticated(user: mockUser)],
  );
  ```
- [ ] `test/presentation/blocs/accounts_bloc_test.dart`
- [ ] `test/presentation/blocs/transactions_bloc_test.dart`

### P4.13.8 — Tests Widget

- [x] `test/presentation/widgets/account_card_test.dart` :
  - Vérifier l'affichage du solde formaté
- [ ] `test/presentation/screens/login_screen_test.dart` :
  - Vérifier que les champs email/password sont présents
  - Vérifier que le bouton submit est désactivé si champs vides
  - Vérifier l'affichage d'erreur sur mauvais credentials

### P4.13.9 — Build Android (APK / AAB)

- [ ] Créer `android/key.properties` (hors du repo Git) :
  ```
  storePassword=...
  keyPassword=...
  keyAlias=...
  storeFile=../keystore.jks
  ```
- [ ] Configurer la signature dans `android/app/build.gradle`
- [ ] Générer le keystore :
  ```bash
  keytool -genkey -v -keystore keystore.jks -alias bankplatform -keyalg RSA -keysize 2048 -validity 10000
  ```
- [ ] Build APK de debug :
  ```bash
  flutter build apk --debug
  # → build/app/outputs/flutter-apk/app-debug.apk
  ```
- [ ] Build APK de release :
  ```bash
  flutter build apk --release
  # → build/app/outputs/flutter-apk/app-release.apk
  ```
- [ ] Build AAB (Google Play) :
  ```bash
  flutter build appbundle --release
  ```

### P4.13.10 — Build iOS (IPA)

- [ ] Configurer les certificats et provisioning profiles dans Xcode
- [ ] Build iOS :
  ```bash
  flutter build ios --release
  # Ouvrir ios/Runner.xcworkspace → Archive dans Xcode
  ```
- [ ] **Prérequis** : macOS + Xcode 15+ + compte développeur Apple

### P4.13.11 — Variables d'environnement (Flavors)

- [ ] Créer 3 flavors Flutter : `dev`, `staging`, `prod`
- [ ] Configurer les URLs d'API par flavor :
  ```bash
  # Dev (émulateur Android → Kong local)
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

  # Prod (serveur VPS)
  flutter build apk --release --dart-define=API_BASE_URL=https://api.bankplatform.com
  ```

---

## Ordre d'implémentation recommandé

| # | Tâche | Statut | Durée estimée |
|---|-------|--------|---------------|
| 1 | T1.1 — Création projet + pubspec | ✅ | 1h |
| 2 | T1.2 — Structure dossiers + architecture | ✅ | 1h |
| 3 | T1.3 — Configuration Dio + intercepteurs | ✅ | 2h |
| 4 | T1.4 — GoRouter + navigation | ✅ | 1h30 |
| 5 | T1.5 — Thème + design system | ✅ | 2h |
| 6 | T2 — Modèles JSON | ✅ | 2h |
| 7 | T3 — Entités + UseCases | ✅ | 2h |
| 8 | T4.1 — LoginScreen + AuthBloc | ✅ | 3h |
| 9 | T4.2 — Écran 2FA | ✅ | 2h |
| 10 | T4.3 — Authentification biométrique | ✅ | 2h |
| 11 | T4.4 — RegisterScreen + RegisterOtpScreen | ✅ | 2h |
| 12 | T5.1 — Dashboard | ✅ | 3h |
| 13 | T5.2 — Liste des comptes | ✅ | 1h |
| 14 | T5.3 — Détail compte | ❌ TODO | 2h |
| 15 | T6.1 — Historique transactions | ✅ | 2h |
| 16 | T6.2 — Écran Transfert | ✅ | 3h |
| 17 | T6.3 — Dépôt | ✅ | 2h |
| 18 | T6.4 — TransactionDetail (reçu) | ✅ | 1h |
| 19 | T7.1 — Paiement factures (Payments) | ✅ | 2h |
| 20 | T7.2 — Activité / Statistiques | ✅ | 2h |
| 21 | T8.1 — Prêts (liste + simulateur) | ✅ | 3h |
| 22 | T8.2 — Détail prêt + Échéancier | ❌ TODO | 3h |
| 23 | T9.1 — NotificationsScreen | ✅ | 2h |
| 24 | T9.2 — Notification in-app banner | ❌ TODO | 2h |
| 25 | T10.1/T10.2 — Tests | ✅ partiel | 4h |
| 26 | T10.3 — Build APK Android | ✅ | 1h |

**Légende :** ✅ = fait | ❌ TODO = reste à faire

---

## Critères de validation production

- [x] `flutter doctor` ne remonte aucune erreur critique
- [x] Login email/password + 2FA fonctionnel contre l'API réelle
- [x] Biométrie active sur un vrai device (empreinte / Face ID)
- [x] Token JWT stocké dans `flutter_secure_storage` (jamais `SharedPreferences` pour les tokens)
- [x] Token refresh automatique transparent pour l'utilisateur
- [x] Dashboard affiche les vrais soldes depuis l'API
- [x] Transfert entre comptes exécuté et visible dans l'historique
- [ ] Upload de document déclenche bien l'OCR et retourne un résultat
- [ ] Notification push reçue sur le device après une transaction
- [x] `flutter build apk --release` produit un APK fonctionnel
- [ ] Couverture de tests ≥ 70% sur la couche Domain et les BLoCs
- [x] Aucun credential ou URL en dur dans le code (utiliser `--dart-define`)
