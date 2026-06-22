 Plan ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│                                                                                                                                  │
│  Plan d’implémentation – Refonte UI glassmorphism + Flow inscription                                                             │
│  ═══════════════════════════════════════════════════════════════════                                                             │
│                                                                                                                                  │
│  Contexte                                                                                                                        │
│  ────────                                                                                                                        │
│                                                                                                                                  │
│  L’application Flutter mobile-frontend utilise déjà Clean Architecture + BLoC + GoRouter. L’objectif est de reproduire fidèleme  │
│  nt les maquettes fournies (docs/log.png et docs/dash.png) et d’ajouter le flow d’inscription actuellement absent.               │
│                                                                                                                                  │
│  Réponses aux 4 questions ouvertes (validées)                                                                                    │
│  ────────────────────────────────────────────                                                                                    │
│                                                                                                                                  │
│  ┌───┬───────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │ # │ Question              │ Réponse validée                                                                                │  │
│  ├───┼───────────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────┤  │
│  │ 1 │ Nom de l’app          │ Bank App – affiché dans le logo et l’en-tête dashboard.                                        │  │
│  │ 2 │ Endpoint register     │ Backend prêt : POST /api/auth/register avec champs firstName, lastName, email, password, phone │  │
│  │   │                       │ .                                                                                              │  │
│  │ 3 │ OTP après inscription │ Oui, vérification OTP par email/SMS après la saisie des informations de sécurité. L’utilisateu │  │
│  │   │                       │ r retourne ensuite au login avec un message de succès.                                         │  │
│  │ 4 │ Logo                  │ Pas de fichier fourni. Je crée un logo vectoriel inline (widget Flutter personnalisé : losange │  │
│  │   │                       │ doré/dégradé) afin d’éviter toute dépendance externe.                                          │  │
│  └───┴───────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                                                  │
│  Flux cible                                                                                                                      │
│  ──────────                                                                                                                      │
│                                                                                                                                  │
│  Splash ──► Login ──► Dashboard                                                                                                  │
│              │           ▲                                                                                                       │
│              │           │                                                                                                       │
│              └── Sign Up ─┘                                                                                                      │
│                    │                                                                                                             │
│                    ▼                                                                                                             │
│              Register Step 1 (Identité)                                                                                          │
│                    │                                                                                                             │
│                    ▼                                                                                                             │
│              Register Step 2 (Sécurité)                                                                                          │
│                    │                                                                                                             │
│                    ▼                                                                                                             │
│              OTP Vérification                                                                                                    │
│                    │                                                                                                             │
│                    ▼                                                                                                             │
│              Login (message succès)                                                                                              │
│                                                                                                                                  │
│  État actuel confirmé                                                                                                            │
│  ────────────────────                                                                                                            │
│                                                                                                                                  │
│  • Architecture BLoC + Clean Arch : solide, conservée.                                                                           │
│  • login_screen.dart / dashboard_screen.dart : fonctionnels mais design basique.                                                 │
│  • Inscription : totalement absente (pas d’écran, BLoC, datasource, usecase, route).                                             │
│  • Police Inter référencée dans design_tokens.dart mais non déclarée dans pubspec.yaml.                                          │
│  • Aucun asset fonts/ ni images/.                                                                                                │
│  • Thème actuel bleu/vert, pas de glassmorphism.                                                                                 │
│                                                                                                                                  │
│  Approche retenue                                                                                                                │
│  ────────────────                                                                                                                │
│                                                                                                                                  │
│  Une seule approche, cohérente et minimaliste : ajouter une couche UI glassmorphism par-dessus l’architecture existante, ajoute  │
│  r le domaine/data d’inscription, puis refondre les écrans. Aucune modification fonctionnelle des flows existants (login, 2FA,   │
│  biométrie) ; on ne fait qu’améliorer leur UI.                                                                                   │
│                                                                                                                                  │
│  Étapes d’exécution                                                                                                              │
│  ──────────────────                                                                                                              │
│                                                                                                                                  │
│  Phase 1 – Fondations assets & thème                                                                                             │
│  ───────────────────────────────────                                                                                             │
│                                                                                                                                  │
│  1. Télécharger la police Inter (Google Fonts) et créer assets/fonts/Inter-Regular.ttf, Inter-Medium.ttf, Inter-SemiBold.ttf, I  │
│     r-Bold.ttf.                                                                                                                  │
│  2. Mettre à jour pubspec.yaml : ajouter la section fonts: et un section assets: pour les images futures.                        │
│  3. Refondre lib/design_tokens/design_tokens.dart avec les nouveaux tokens glassmorphism :                                       │
│    • navy900, navy800, teal400, teal300, tealGlow, gold500, glassWhite, glassBorder, etc.                                        │
│  4. Refondre lib/core/theme/app_theme.dart :                                                                                     │
│    • darkTheme par défaut, fond navy900, texte blanc/gris clair.                                                                 │
│    • InputDecorationTheme arrondie, fond glass, bordure teal focus glow.                                                         │
│    • ElevatedButtonTheme arrondi, gradient teal.                                                                                 │
│                                                                                                                                  │
│  Phase 2 – Widgets partagés glassmorphism                                                                                        │
│  ────────────────────────────────────────                                                                                        │
│                                                                                                                                  │
│  Créer lib/presentation/widgets/common/ : 5. glass_container.dart – container translucide avec BackdropFilter, bordure blanche   │
│  fine, radius 24. 6. animated_background.dart – fond navy avec 3 orbes teal animés (pulsation + dérive lente) via AnimatedPosit  │
│  ioned / Tween. 7. glass_text_field.dart – champ avec icône gauche, suffixe optionnel (œil), bordure teal glow au focus. 8. gla  │
│  ss_button.dart – bouton full-width avec gradient teal brillant, radius 16, état loading. 9. app_logo.dart – widget vectoriel l  │
│  osange doré + texte "Bank App".                                                                                                 │
│                                                                                                                                  │
│  Phase 3 – Flow d’authentification (inscription)                                                                                 │
│  ───────────────────────────────────────────────                                                                                 │
│                                                                                                                                  │
│  10. Data layer : ajouter register(String firstName, String lastName, String email, String password, String phone) dans AuthRem  │
│      ataSource et AuthRemoteDataSourceImpl → POST /api/auth/register.                                                            │
│  11. Repository : ajouter Future<Either<Failure, User>> register(...) dans AuthRepository et AuthRepositoryImpl.                 │
│  12. Use case : créer lib/domain/usecases/auth/register_usecase.dart.                                                            │
│  13. BLoC : ajouter RegisterRequested, VerifyOtpRequested dans auth_event.dart ; ajouter AuthRegisterSuccess, AuthOtpSent, Auth  │
│      erified dans auth_state.dart ; implémenter les handlers dans auth_bloc.dart.                                                │
│  14. Injection : enregistrer RegisterUseCase dans lib/injection_container.dart et l’injecter dans AuthBloc.                      │
│                                                                                                                                  │
│  Phase 4 – Écrans authentification                                                                                               │
│  ─────────────────────────────────                                                                                               │
│                                                                                                                                  │
│  15. Refondre lib/presentation/screens/auth/login_screen.dart :                                                                  │
│    • AnimatedBackground + GlassContainer centrée.                                                                                │
│    • Logo AppLogo.                                                                                                               │
│    • Champs email/password GlassTextField.                                                                                       │
│    • Bouton "Sign In" GlassButton.                                                                                               │
│    • Lien "Forgot password?".                                                                                                    │
│    • Ligne "Don’t have an account? Sign up".                                                                                     │
│    • Préserver la biométrie existante.                                                                                           │
│  16. Créer lib/presentation/screens/auth/register_screen.dart :                                                                  │
│    • Step 1 : prénom, nom, email, téléphone.                                                                                     │
│    • Step 2 : mot de passe, confirmation.                                                                                        │
│    • Bouton "Continue" / "Create Account".                                                                                       │
│    • Indicateur d’étapes (2 steps) avec barre de progression.                                                                    │
│    • Fond glassmorphism identique au login.                                                                                      │
│  17. Créer lib/presentation/screens/auth/register_otp_screen.dart :                                                              │
│    • Champ code OTP 6 chiffres.                                                                                                  │
│    • Bouton "Verify".                                                                                                            │
│    • Message de succès puis navigation /login.                                                                                   │
│  18. Mettre à jour lib/app.dart : ajouter les routes /register et /register/otp.                                                 │
│                                                                                                                                  │
│  Phase 5 – Dashboard & navigation                                                                                                │
│  ────────────────────────────────                                                                                                │
│                                                                                                                                  │
│  19. Refondre lib/presentation/screens/dashboard/dashboard_screen.dart selon la maquette :                                       │
│    • Fond navy uni (pas d’orbes ici).                                                                                            │
│    • En-tête : logo teal + "Welcome, John Doe" + avatar + icône cloche.                                                          │
│    • Carte solde principale glass : "Bank App Visa Debit", "Account Balance", "$32,845.50", "Available: $32,150.20 | Updated: J  │
│      now", "**** 4910  06/27".                                                                                                   │
│    • Raccourcis circulaires teal : Transfer, Pay Bills, Deposit.                                                                 │
│    • Section "Recent Transactions" avec carte glass et liste de 5 transactions (icônes, dates, montants +/-).                    │
│  20. Bottom nav bar : remplacer par Home, Payments, Activity, Profile avec icônes Material adaptées.                             │
│  21. Refondre lib/presentation/screens/splash/splash_screen.dart : fond navy + logo animé + transition vers /login ou /dashboar  │
│  22. Refondre secondaire : harmoniser transactions_screen.dart et profile_screen.dart avec le même thème sombre/glass (changeme  │
│      osmétique minimal).                                                                                                         │
│                                                                                                                                  │
│  Phase 6 – Tests & vérification                                                                                                  │
│  ──────────────────────────────                                                                                                  │
│                                                                                                                                  │
│  23. Lancer flutter pub get.                                                                                                     │
│  24. Lancer flutter analyze et corriger les erreurs.                                                                             │
│  25. Lancer flutter run sur appareil physique/émulateur et vérifier :                                                            │
│    • Splash → Login sans erreur.                                                                                                 │
│    • Login → Dashboard avec design glassmorphism.                                                                                │
│    • Register 2 steps → OTP → retour Login avec SnackBar succès.                                                                 │
│    • Biométrie toujours fonctionnelle.                                                                                           │
│    • Police Inter appliquée partout.                                                                                             │
│                                                                                                                                  │
│  Fichiers impactés (récapitulatif)                                                                                               │
│  ─────────────────────────────────                                                                                               │
│                                                                                                                                  │
│  • pubspec.yaml                                                                                                                  │
│  • lib/design_tokens/design_tokens.dart                                                                                          │
│  • lib/core/theme/app_theme.dart                                                                                                 │
│  • lib/data/datasources/auth_remote_datasource.dart                                                                              │
│  • lib/data/repositories/auth_repository_impl.dart                                                                               │
│  • lib/domain/repositories/auth_repository.dart                                                                                  │
│  • lib/domain/usecases/auth/register_usecase.dart                                                                                │
│  • lib/presentation/blocs/auth/auth_event.dart                                                                                   │
│  • lib/presentation/blocs/auth/auth_state.dart                                                                                   │
│  • lib/presentation/blocs/auth/auth_bloc.dart                                                                                    │
│  • lib/injection_container.dart                                                                                                  │
│  • lib/app.dart                                                                                                                  │
│  • lib/presentation/screens/auth/login_screen.dart                                                                               │
│  • lib/presentation/screens/auth/register_screen.dart (nouveau)                                                                  │
│  • lib/presentation/screens/auth/register_otp_screen.dart (nouveau)                                                              │
│  • lib/presentation/screens/dashboard/dashboard_screen.dart                                                                      │
│  • lib/presentation/screens/splash/splash_screen.dart                                                                            │
│  • lib/presentation/screens/transactions/transactions_screen.dart                                                                │
│  • lib/presentation/screens/profile/profile_screen.dart                                                                          │
│  • Nouveaux widgets : glass_container.dart, animated_background.dart, glass_text_field.dart, glass_button.dart, app_logo.dart    │
│                                                                                                                                  │
│  Critères d’acceptation                                                                                                          │
│  ──────────────────────                                                                                                          │
│                                                                                                                                  │
│  • flutter run compile sans erreur.                                                                                              │
│  • Login utilise le design glassmorphism exact de la maquette.                                                                   │
│  • Dashboard reproduit la carte solde, les 3 raccourcis et la liste des transactions.                                            │
│  • Le flow Register 2 steps + OTP est navigable et retourne au login.                                                            │
│  • L’appel POST /api/auth/register est câblé avec les bons champs.                                                               │
│  • La police Inter est active sur tous les textes.                                                                               │
│  • Le fond animé (orbes) apparaît sur les écrans d’authentification.                                                             │
│                                                                                                                                  │
╰─ C:\Users\jobel\.kimi\plans\black-bolt-quake-doctor-fate.md ─────────────────────────────────────────────────────────────────────╯

• Used ExitPlanMode
  Plan approved

• Le plan est approuvé. Je peux maintenant commencer l'implémentation. C'est une grande tâche, je vais utiliser un todo list pour su
  ivre la progression.

  Je vais commencer par:

  1. Télécharger la police Inter
  2. Créer les répertoires assets
  3. Mettre à jour pubspec.yaml
  4. Créer les widgets glassmorphism
  5. Refondre le thème
  6. Implémenter l'inscription
  7. Refondre les écrans
  8. Tester

  Je vais utiliser SetTodoList pour organiser le travail. Puis je commencerai par télécharger les fonts Inter depuis Google Fonts. J
  e peux utiliser curl pour télécharger.

  URL Google Fonts Inter: https://fonts.google.com/download?family=Inter

  Cela télécharge un zip. Je vais le faire via shell.

  Plan d'action détaillé:

  1. Créer assets/fonts et assets/images
  2. Télécharger Inter
  3. Extraire les 4 fonts nécessaires
  4. Mettre à jour pubspec.yaml
  5. Créer les widgets glassmorphism
  6. Mettre à jour design_tokens.dart et app_theme.dart
  7. Implémenter le register côté data/domain/bloc
  8. Créer les écrans register/otp
  9. Refondre login et dashboard
  10. Mettre à jour app.dart
  11. Tester

  Commençons.

• Plan approuvé. Je lance l’implémentation. Je vais d’abord préparer les assets (police Inter) puis construire les fondations UI gla
  ssmorphism.

• Used SetTodoList
  • Phase 1 : Assets fonts Inter + pubspec.yaml ←
  • Phase 2 : Tokens thème glassmorphism
  • Phase 3 : Widgets partagés glassmorphism
  • Phase 4 : Implémentation inscription (data/domain/bloc)
  • Phase 5 : Écrans auth (login/register/OTP)
  • Phase 6 : Dashboard + navigation + écrans secondaires
  • Phase 7 : Tests flutter analyze/run

• Je vais maintenant télécharger la police Inter. Je vais utiliser curl pour télécharger le zip depuis Google Fonts, puis l'extraire
  .

• Used Shell (cd /d/Bank/mobile-fronten...mp/inter && ls /tmp/inter)
  Failed with exit code: 9

• Le téléchargement a échoué car Google Fonts renvoie probablement une page HTML au lieu du zip. Je vais essayer une autre approche:
  utiliser les fichiers de police via un CDN direct, ou utiliser fontsource.

  Alternative: utiliser le repo github google/fonts. Les fichiers Inter sont disponibles ici: https://github.com/rsms/inter/releases

  Ou via: https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bslnt%2Cwght%5D.ttf

  Mais c'est une variable font. Pour Flutter, je peux utiliser une variable font, mais c'est plus simple d'avoir des fichiers statiq
  ues.

  Je peux aussi utiliser: https://cdn.jsdelivr.net/fontsource/fonts/inter@latest/

  Ou télécharger depuis: https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip

  Essayons avec le repo rsms/inter.

• Used Shell (cd /d/Bank/mobile-fronten... -name "*.otf" | head -20)

• Parfait, j'ai les polices. Je vais copier les 4 fichiers nécessaires (Regular, Medium, SemiBold, Bold) dans assets/fonts. Puis met
  tre à jour pubspec.yaml.

  Je vais utiliser les fichiers TTF dans extras/ttf car certains sont au format OTF. Les deux fonctionnent avec Flutter. Je vais pre
  ndre les TTF.

• Used Shell (cd /d/Bank/mobile-fronten.../ && ls -la assets/fonts/)

• Maintenant je vais mettre à jour pubspec.yaml. Je vais d'abord lire le fichier complet pour savoir où faire les modifications.

• Used ReadFile (mobile-frontend\pubspec.yaml)

• Je vais mettre à jour pubspec.yaml pour ajouter les fonts et assets. Je vais remplacer la section flutter.

• Used StrReplaceFile (mobile-frontend\pubspec.yaml)
  ╭─  +13 D:\Bank\mobile-frontend\pubspec.yaml  ───────────────────────────────────────────────────────────────────────────────────╮
  │ 41                                                                                                                             │
  │ 42   flutter:                                                                                                                  │
  │ 43     uses-material-design: true                                                                                              │
  │ 44 +   assets:                                                                                                                 │
  │ 45 +     - assets/images/                                                                                                      │
  │ 46 +   fonts:                                                                                                                  │
  │ 47 +     - family: Inter                                                                                                       │
  │ 48 +       fonts:                                                                                                              │
  │ 49 +         - asset: assets/fonts/Inter-Regular.ttf                                                                           │
  │ 50 +           weight: 400                                                                                                     │
  │ 51 +         - asset: assets/fonts/Inter-Medium.ttf                                                                            │
  │ 52 +           weight: 500                                                                                                     │
  │ 53 +         - asset: assets/fonts/Inter-SemiBold.ttf                                                                          │
  │ 54 +           weight: 600                                                                                                     │
  │ 55 +         - asset: assets/fonts/Inter-Bold.ttf                                                                              │
  │ 56 +           weight: 700                                                                                                     │
  ╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

• Phase 1 terminée. Maintenant Phase 2: tokens et thème. Je vais d'abord lire les fichiers existants pour les modifier correctement.

• Used ReadFile (mobile-frontend\lib\desig...tokens\design_tokens.dart)

• Used ReadFile (mobile-frontend\lib\core\theme\app_theme.dart)

• Je vais maintenant refondre design_tokens.dart avec les nouvelles couleurs glassmorphism, et app_theme.dart avec le thème sombre p
  ar défaut. Je vais conserver la structure mais ajuster les couleurs.

  Nouvelles couleurs:

  • navy900: 0xFF0A1628 (fond très sombre)
  • navy800: 0xFF0F2236
  • navy700: 0xFF152A40
  • teal400: 0xFF2DD4BF
  • teal300: 0xFF5EEAD4
  • teal500: 0xFF14B8A6
  • tealGlow: 0xFF2DD4BF avec opacité
  • gold500: 0xFFD4AF37
  • gold400: 0xFFE5C158
  • glassWhite: Colors.white.withOpacity(0.08)
  • glassBorder: Colors.white.withOpacity(0.15)

  Je vais réécrire design_tokens.dart complètement.

• Used WriteFile (mobile-frontend\lib\desig...tokens\design_tokens.dart)
  ╭─  +98 -20 D:\Bank\mobile-frontend\lib\design_tokens\design_tokens.dart  ───────────────────────────────────────────────────────╮
  │   1 - // design_tokens.dart – generated from shared design_tokens.json                                                         │
  │   1 + // design_tokens.dart – tokens visuels glassmorphism Bank App                                                            │
  │   2   import 'package:flutter/material.dart';                                                                                  │
  │   3                                                                                                                            │
  │   4   class DesignTokens {                                                                                                     │
  │   5 -   // Colors                                                                                                              │
  │   6 -   static const Color primary = Color(0xFF0066FF);                                                                        │
  │   7 -   static const Color primaryDark = Color(0xFF004C99);                                                                    │
  │   5 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │   6 +   //  Glassmorphism palette                                                                                              │
  │   7 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │   8 +   static const Color navy900 = Color(0xFF0A1628);                                                                        │
  │   9 +   static const Color navy800 = Color(0xFF0F2236);                                                                        │
  │  10 +   static const Color navy700 = Color(0xFF152A40);                                                                        │
  │  11 +   static const Color navy600 = Color(0xFF1B3450);                                                                        │
  │  12 +                                                                                                                          │
  │  13 +   static const Color teal500 = Color(0xFF14B8A6);                                                                        │
  │  14 +   static const Color teal400 = Color(0xFF2DD4BF);                                                                        │
  │  15 +   static const Color teal300 = Color(0xFF5EEAD4);                                                                        │
  │  16 +   static const Color tealGlow = Color(0xFF2DD4BF);                                                                       │
  │  17 +                                                                                                                          │
  │  18 +   static const Color gold500 = Color(0xFFD4AF37);                                                                        │
  │  19 +   static const Color gold400 = Color(0xFFE5C158);                                                                        │
  │  20 +   static const Color gold300 = Color(0xFFF5D47A);                                                                        │
  │  21 +                                                                                                                          │
  │  22 +   static const Color glassWhite = Color(0x14FFFFFF); // ~8% white                                                        │
  │  23 +   static const Color glassBorder = Color(0x26FFFFFF); // ~15% white                                                      │
  │  24 +   static const Color glassHighlight = Color(0x33FFFFFF); // ~20% white                                                   │
  │  25 +                                                                                                                          │
  │  26 +   // Legacy tokens (conservés pour compatibilité minimale)                                                               │
  │  27 +   static const Color primary = teal400;                                                                                  │
  │  28 +   static const Color primaryDark = navy700;                                                                              │
  │  29     static const Color backgroundLight = Color(0xFFFFFFFF);                                                                │
  │   9 -   static const Color backgroundDark = Color(0xFF121212);                                                                 │
  │  30 +   static const Color backgroundDark = navy900;                                                                           │
  │  31     static const Color surfaceLight = Color(0xFFF5F5F5);                                                                   │
  │  11 -   static const Color surfaceDark = Color(0xFF1E1E1E);                                                                    │
  │  12 -   static const Color error = Color(0xFFD32F2F);                                                                          │
  │  13 -   static const Color errorDark = Color(0xFF9A0007);                                                                      │
  │  14 -   static const Color success = Color(0xFF388E3C);                                                                        │
  │  15 -   static const Color warning = Color(0xFFFBC02D);                                                                        │
  │  32 +   static const Color surfaceDark = navy800;                                                                              │
  │  33 +   static const Color error = Color(0xFFEF4444);                                                                          │
  │  34 +   static const Color errorDark = Color(0xFFB91C1C);                                                                      │
  │  35 +   static const Color success = Color(0xFF22C55E);                                                                        │
  │  36 +   static const Color warning = Color(0xFFF59E0B);                                                                        │
  │  37                                                                                                                            │
  │  17 -   // Spacing (in logical pixels)                                                                                         │
  │  38 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  39 +   //  Gradients                                                                                                          │
  │  40 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  41 +   static const LinearGradient tealGradient = LinearGradient(                                                             │
  │  42 +     begin: Alignment.topLeft,                                                                                            │
  │  43 +     end: Alignment.bottomRight,                                                                                          │
  │  44 +     colors: [teal300, teal500],                                                                                          │
  │  45 +   );                                                                                                                     │
  │  46 +                                                                                                                          │
  │  47 +   static const LinearGradient tealGradientHorizontal = LinearGradient(                                                   │
  │  48 +     begin: Alignment.centerLeft,                                                                                         │
  │  49 +     end: Alignment.centerRight,                                                                                          │
  │  50 +     colors: [teal500, teal300, teal500],                                                                                 │
  │  51 +     stops: [0.0, 0.5, 1.0],                                                                                              │
  │  52 +   );                                                                                                                     │
  │  53 +                                                                                                                          │
  │  54 +   static const LinearGradient goldGradient = LinearGradient(                                                             │
  │  55 +     begin: Alignment.topLeft,                                                                                            │
  │  56 +     end: Alignment.bottomRight,                                                                                          │
  │  57 +     colors: [gold300, gold500],                                                                                          │
  │  58 +   );                                                                                                                     │
  │  59 +                                                                                                                          │
  │  60 +   static const LinearGradient backgroundGradient = LinearGradient(                                                       │
  │  61 +     begin: Alignment.topCenter,                                                                                          │
  │  62 +     end: Alignment.bottomCenter,                                                                                         │
  │  63 +     colors: [navy900, navy800],                                                                                          │
  │  64 +   );                                                                                                                     │
  │  65 +                                                                                                                          │
  │  66 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  67 +   //  Spacing (in logical pixels)                                                                                        │
  │  68 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  69     static const double spacing0 = 0.0;                                                                                    │
  │  70     static const double spacing1 = 4.0;                                                                                    │
  │  71     static const double spacing2 = 8.0;                                                                                    │
  │   ⋮                                                                                                                            │
  │  76     static const double spacing7 = 28.0;                                                                                   │
  │  77     static const double spacing8 = 32.0;                                                                                   │
  │  78                                                                                                                            │
  │  28 -   // Typography                                                                                                          │
  │  79 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  80 +   //  Typography                                                                                                         │
  │  81 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  82     static const String fontFamily = 'Inter';                                                                              │
  │  83     static const double fontSizeBase = 16.0;                                                                               │
  │  84     static const double lineHeightBase = 1.5;                                                                              │
  │  85     static const double letterSpacingBase = 0.02;                                                                          │
  │  86     static const FontWeight weightRegular = FontWeight.w400;                                                               │
  │  87     static const FontWeight weightMedium = FontWeight.w500;                                                                │
  │  88 +   static const FontWeight weightSemiBold = FontWeight.w600;                                                              │
  │  89     static const FontWeight weightBold = FontWeight.w700;                                                                  │
  │  90                                                                                                                            │
  │  37 -   // Animation                                                                                                           │
  │  91 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  92 +   //  Animation                                                                                                          │
  │  93 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  94     static const Duration durationFast = Duration(milliseconds: 150);                                                      │
  │  95     static const Duration durationMedium = Duration(milliseconds: 250);                                                    │
  │  96     static const Duration durationSlow = Duration(milliseconds: 350);                                                      │
  │  97     static const Curve easeStandard = Curves.easeInOut;                                                                    │
  │  98                                                                                                                            │
  │  43 -   // Helper methods for borders, shadows, etc.                                                                           │
  │  44 -   static BoxDecoration surfaceDecoration({bool dark = false}) {                                                          │
  │  99 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │ 100 +   //  Helpers                                                                                                            │
  │ 101 +   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │ 102 +   static BoxDecoration surfaceDecoration({bool dark = true}) {                                                           │
  │ 103       return BoxDecoration(                                                                                                │
  │  46 -       color: dark ? surfaceDark : surfaceLight,                                                                          │
  │  47 -       borderRadius: BorderRadius.circular(12),                                                                           │
  │ 104 +       color: dark ? glassWhite : surfaceLight,                                                                           │
  │ 105 +       borderRadius: BorderRadius.circular(16),                                                                           │
  │ 106 +       border: Border.all(color: glassBorder),                                                                            │
  │ 107         boxShadow: [                                                                                                       │
  │ 108           BoxShadow(                                                                                                       │
  │  50 -           color: Colors.black.withValues(alpha: 0.1),                                                                    │
  │  51 -           blurRadius: 8,                                                                                                 │
  │  52 -           offset: const Offset(0, 2),                                                                                    │
  │ 109 +           color: Colors.black.withValues(alpha: 0.2),                                                                    │
  │ 110 +           blurRadius: 24,                                                                                                │
  │ 111 +           offset: const Offset(0, 8),                                                                                    │
  │ 112           ),                                                                                                               │
  │ 113         ],                                                                                                                 │
  │ 114       );                                                                                                                   │
  │ 115 +   }                                                                                                                      │
  │ 116 +                                                                                                                          │
  │ 117 +   static BoxDecoration glassDecoration({                                                                                 │
  │ 118 +     double radius = 24,                                                                                                  │
  │ 119 +     Color? tint,                                                                                                         │
  │ 120 +     BorderSide? border,                                                                                                  │
  │ 121 +   }) {                                                                                                                   │
  │ 122 +     return BoxDecoration(                                                                                                │
  │ 123 +       color: tint ?? glassWhite,                                                                                         │
  │ 124 +       borderRadius: BorderRadius.circular(radius),                                                                       │
  │ 125 +       border: Border.fromBorderSide(border ?? const BorderSide(color: glassBorder)),                                     │
  │ 126 +       boxShadow: [                                                                                                       │
  │ 127 +         BoxShadow(                                                                                                       │
  │ 128 +           color: Colors.black.withValues(alpha: 0.25),                                                                   │
  │ 129 +           blurRadius: 30,                                                                                                │
  │ 130 +           offset: const Offset(0, 10),                                                                                   │
  │ 131 +         ),                                                                                                               │
  │ 132 +       ],                                                                                                                 │
  │ 133 +     );                                                                                                                   │
  ╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

• Maintenant je vais refondre app_theme.dart. Je vais conserver lightTheme mais la rendre basique, et refondre darkTheme avec les no
  uvelles couleurs glassmorphism. Je vais aussi m'assurer que la police Inter est appliquée via fontFamily.

• Used WriteFile (mobile-frontend\lib\core\theme\app_theme.dart)
  ╭─  +67 -57 D:\Bank\mobile-frontend\lib\core\theme\app_theme.dart  ──────────────────────────────────────────────────────────────╮
  │   3                                                                                                                            │
  │   4   class AppTheme {                                                                                                         │
  │   5     // ── Core Brand Colors ──                                                                                             │
  │   6 -   static const Color primaryColor = DesignTokens.primary;                                                                │
  │   6 +   static const Color primaryColor = DesignTokens.teal400;                                                                │
  │   7     static const Color secondaryColor = DesignTokens.success;                                                              │
  │   8     static const Color errorColor = DesignTokens.error;                                                                    │
  │   ⋮                                                                                                                            │
  │  12     static const Color surfaceColor = DesignTokens.surfaceLight;                                                           │
  │  13                                                                                                                            │
  │  14     // ── Dark Theme Colors ──                                                                                             │
  │  15 -   static const Color darkBackground = DesignTokens.backgroundDark;                                                       │
  │  16 -   static const Color darkSurface = DesignTokens.surfaceDark;                                                             │
  │  17 -   static const Color darkSurfaceLight = DesignTokens.surfaceDark;                                                        │
  │  18 -   static const Color darkBorder = DesignTokens.primaryDark;                                                              │
  │  19 -   static const Color darkTextPrimary = DesignTokens.primaryDark;                                                         │
  │  20 -   static const Color darkTextSecondary = DesignTokens.success;                                                           │
  │  15 +   static const Color darkBackground = DesignTokens.navy900;                                                              │
  │  16 +   static const Color darkSurface = DesignTokens.navy800;                                                                 │
  │  17 +   static const Color darkSurfaceLight = DesignTokens.glassWhite;                                                         │
  │  18 +   static const Color darkBorder = DesignTokens.glassBorder;                                                              │
  │  19 +   static const Color darkTextPrimary = Colors.white;                                                                     │
  │  20 +   static const Color darkTextSecondary = Color(0xFF94A3B8);                                                              │
  │  21 +                                                                                                                          │
  │  22 +   // ── Common text style helper ──                                                                                      │
  │  23 +   static TextStyle _textStyle(Color color, FontWeight weight, double size) {                                             │
  │  24 +     return TextStyle(                                                                                                    │
  │  25 +       fontFamily: DesignTokens.fontFamily,                                                                               │
  │  26 +       color: color,                                                                                                      │
  │  27 +       fontWeight: weight,                                                                                                │
  │  28 +       fontSize: size,                                                                                                    │
  │  29 +     );                                                                                                                   │
  │  30 +   }                                                                                                                      │
  │  31                                                                                                                            │
  │  32     // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  33     //  LIGHT THEME                                                                                                        │
  │   ⋮                                                                                                                            │
  │  35     static ThemeData get lightTheme {                                                                                      │
  │  36       return ThemeData(                                                                                                    │
  │  37         brightness: Brightness.light,                                                                                      │
  │  38 +       fontFamily: DesignTokens.fontFamily,                                                                               │
  │  39         primaryColor: primaryColor,                                                                                        │
  │  40         scaffoldBackgroundColor: backgroundColor,                                                                          │
  │  41         colorScheme: const ColorScheme.light(                                                                              │
  │   ⋮                                                                                                                            │
  │  78     }                                                                                                                      │
  │  79                                                                                                                            │
  │  80     // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  70 -   //  DARK THEME                                                                                                         │
  │  81 +   //  DARK THEME (default glassmorphism)                                                                                 │
  │  82     // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                       │
  │  83     static ThemeData get darkTheme {                                                                                       │
  │  84       return ThemeData(                                                                                                    │
  │  85         brightness: Brightness.dark,                                                                                       │
  │  86 +       fontFamily: DesignTokens.fontFamily,                                                                               │
  │  87         primaryColor: primaryColor,                                                                                        │
  │  88         scaffoldBackgroundColor: darkBackground,                                                                           │
  │  89         colorScheme: const ColorScheme.dark(                                                                               │
  │  78 -         primary: secondaryColor,                                                                                         │
  │  90 +         primary: primaryColor,                                                                                           │
  │  91           secondary: secondaryColor,                                                                                       │
  │  92           error: errorColor,                                                                                               │
  │  93           surface: darkSurface,                                                                                            │
  │   ⋮                                                                                                                            │
  │  95           onPrimary: Colors.white,                                                                                         │
  │  96           surfaceContainerHighest: darkSurfaceLight,                                                                       │
  │  97         ),                                                                                                                 │
  │  86 -       appBarTheme: const AppBarTheme(                                                                                    │
  │  98 +       appBarTheme: AppBarTheme(                                                                                          │
  │  99           backgroundColor: Colors.transparent,                                                                             │
  │ 100           foregroundColor: darkTextPrimary,                                                                                │
  │ 101           elevation: 0,                                                                                                    │
  │ 102           centerTitle: true,                                                                                               │
  │  91 -         titleTextStyle: TextStyle(                                                                                       │
  │  92 -           color: darkTextPrimary,                                                                                        │
  │  93 -           fontSize: 20,                                                                                                  │
  │  94 -           fontWeight: FontWeight.w700,                                                                                   │
  │ 103 +         titleTextStyle: _textStyle(darkTextPrimary, FontWeight.w700, 20).copyWith(                                       │
  │ 104             letterSpacing: 0.5,                                                                                            │
  │ 105           ),                                                                                                               │
  │  97 -         iconTheme: IconThemeData(color: secondaryColor),                                                                 │
  │ 106 +         iconTheme: const IconThemeData(color: primaryColor),                                                             │
  │ 107         ),                                                                                                                 │
  │  99 -       bottomNavigationBarTheme: const BottomNavigationBarThemeData(                                                      │
  │ 100 -         backgroundColor: darkSurface,                                                                                    │
  │ 101 -         selectedItemColor: secondaryColor,                                                                               │
  │ 108 +       bottomNavigationBarTheme: BottomNavigationBarThemeData(                                                            │
  │ 109 +         backgroundColor: DesignTokens.navy800.withValues(alpha: 0.95),                                                   │
  │ 110 +         selectedItemColor: primaryColor,                                                                                 │
  │ 111           unselectedItemColor: darkTextSecondary,                                                                          │
  │ 112           type: BottomNavigationBarType.fixed,                                                                             │
  │ 113           elevation: 8,                                                                                                    │
  │ 105 -         selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),                                        │
  │ 106 -         unselectedLabelStyle: TextStyle(fontSize: 11),                                                                   │
  │ 114 +         selectedLabelStyle: _textStyle(primaryColor, FontWeight.w600, 12),                                               │
  │ 115 +         unselectedLabelStyle: _textStyle(darkTextSecondary, FontWeight.w400, 11),                                        │
  │ 116         ),                                                                                                                 │
  │ 117         cardTheme: CardThemeData(                                                                                          │
  │ 109 -         color: darkSurface,                                                                                              │
  │ 118 +         color: darkSurfaceLight,                                                                                         │
  │ 119           shape: RoundedRectangleBorder(                                                                                   │
  │ 111 -           borderRadius: const BorderRadius.all(Radius.circular(16)),                                                     │
  │ 112 -           side: BorderSide(color: darkBorder.withValues(alpha: 0.5)),                                                    │
  │ 120 +           borderRadius: const BorderRadius.all(Radius.circular(20)),                                                     │
  │ 121 +           side: BorderSide(color: darkBorder.withValues(alpha: 0.6)),                                                    │
  │ 122           ),                                                                                                               │
  │ 123           elevation: 0,                                                                                                    │
  │ 124           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),                                                 │
  │ 125         ),                                                                                                                 │
  │ 126         elevatedButtonTheme: ElevatedButtonThemeData(                                                                      │
  │ 127           style: ElevatedButton.styleFrom(                                                                                 │
  │ 119 -           backgroundColor: secondaryColor,                                                                               │
  │ 120 -           foregroundColor: Colors.white,                                                                                 │
  │ 121 -           minimumSize: const Size(double.infinity, 50),                                                                  │
  │ 128 +           backgroundColor: primaryColor,                                                                                 │
  │ 129 +           foregroundColor: DesignTokens.navy900,                                                                         │
  │ 130 +           minimumSize: const Size(double.infinity, 56),                                                                  │
  │ 131             shape: RoundedRectangleBorder(                                                                                 │
  │ 123 -             borderRadius: BorderRadius.circular(12),                                                                     │
  │ 132 +             borderRadius: BorderRadius.circular(16),                                                                     │
  │ 133             ),                                                                                                             │
  │ 134             elevation: 0,                                                                                                  │
  │ 126 -           textStyle: const TextStyle(                                                                                    │
  │ 127 -             fontSize: 16,                                                                                                │
  │ 128 -             fontWeight: FontWeight.w700,                                                                                 │
  │ 135 +           textStyle: _textStyle(DesignTokens.navy900, FontWeight.w700, 16).copyWith(                                     │
  │ 136               letterSpacing: 0.5,                                                                                          │
  │ 137             ),                                                                                                             │
  │ 138           ),                                                                                                               │
  │ 139         ),                                                                                                                 │
  │ 140         outlinedButtonTheme: OutlinedButtonThemeData(                                                                      │
  │ 141           style: OutlinedButton.styleFrom(                                                                                 │
  │ 135 -           foregroundColor: secondaryColor,                                                                               │
  │ 136 -           side: const BorderSide(color: secondaryColor),                                                                 │
  │ 142 +           foregroundColor: primaryColor,                                                                                 │
  │ 143 +           side: const BorderSide(color: primaryColor),                                                                   │
  │ 144             minimumSize: const Size(double.infinity, 50),                                                                  │
  │ 145             shape: RoundedRectangleBorder(                                                                                 │
  │ 146               borderRadius: BorderRadius.circular(12),                                                                     │
  │   ⋮                                                                                                                            │
  │ 149         ),                                                                                                                 │
  │ 150         inputDecorationTheme: InputDecorationTheme(                                                                        │
  │ 151           border: OutlineInputBorder(                                                                                      │
  │ 145 -           borderRadius: BorderRadius.circular(12),                                                                       │
  │ 152 +           borderRadius: BorderRadius.circular(16),                                                                       │
  │ 153             borderSide: const BorderSide(color: darkBorder),                                                               │
  │ 154           ),                                                                                                               │
  │ 155           enabledBorder: OutlineInputBorder(                                                                               │
  │ 149 -           borderRadius: BorderRadius.circular(12),                                                                       │
  │ 156 +           borderRadius: BorderRadius.circular(16),                                                                       │
  │ 157             borderSide: const BorderSide(color: darkBorder),                                                               │
  │ 158           ),                                                                                                               │
  │ 159           focusedBorder: OutlineInputBorder(                                                                               │
  │ 153 -           borderRadius: BorderRadius.circular(12),                                                                       │
  │ 154 -           borderSide: const BorderSide(color: secondaryColor, width: 2),                                                 │
  │ 160 +           borderRadius: BorderRadius.circular(16),                                                                       │
  │ 161 +           borderSide: const BorderSide(color: primaryColor, width: 2),                                                   │
  │ 162           ),                                                                                                               │
  │ 163           filled: true,                                                                                                    │
  │ 164           fillColor: darkSurfaceLight,                                                                                     │
  │ 158 -         labelStyle: const TextStyle(color: darkTextSecondary),                                                           │
  │ 159 -         hintStyle: const TextStyle(color: darkTextSecondary),                                                            │
  │ 165 +         labelStyle: _textStyle(darkTextSecondary, FontWeight.w400, 14),                                                  │
  │ 166 +         hintStyle: _textStyle(darkTextSecondary, FontWeight.w400, 14),                                                   │
  │ 167           prefixIconColor: darkTextSecondary,                                                                              │
  │ 168           suffixIconColor: darkTextSecondary,                                                                              │
  │ 169         ),                                                                                                                 │
  │   ⋮                                                                                                                            │
  │ 172           thickness: 0.5,                                                                                                  │
  │ 173         ),                                                                                                                 │
  │ 174         listTileTheme: const ListTileThemeData(                                                                            │
  │ 168 -         iconColor: secondaryColor,                                                                                       │
  │ 175 +         iconColor: primaryColor,                                                                                         │
  │ 176           textColor: darkTextPrimary,                                                                                      │
  │ 177         ),                                                                                                                 │
  │ 178         tabBarTheme: const TabBarThemeData(                                                                                │
  │ 172 -         labelColor: secondaryColor,                                                                                      │
  │ 179 +         labelColor: primaryColor,                                                                                        │
  │ 180           unselectedLabelColor: darkTextSecondary,                                                                         │
  │ 174 -         indicatorColor: secondaryColor,                                                                                  │
  │ 181 +         indicatorColor: primaryColor,                                                                                    │
  │ 182           indicatorSize: TabBarIndicatorSize.label,                                                                        │
  │ 183         ),                                                                                                                 │
  │ 177 -       textTheme: const TextTheme(                                                                                        │
  │ 178 -         headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w800),                                   │
  │ 179 -         headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),                                  │
  │ 180 -         titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),                                      │
  │ 181 -         titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),                                     │
  │ 182 -         bodyLarge: TextStyle(color: darkTextPrimary),                                                                    │
  │ 183 -         bodyMedium: TextStyle(color: darkTextSecondary),                                                                 │
  │ 184 -         labelLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),                                      │
  │ 184 +       textTheme: TextTheme(                                                                                              │
  │ 185 +         headlineLarge: _textStyle(darkTextPrimary, FontWeight.w800, 32),                                                 │
  │ 186 +         headlineMedium: _textStyle(darkTextPrimary, FontWeight.w700, 28),                                                │
  │ 187 +         headlineSmall: _textStyle(darkTextPrimary, FontWeight.w700, 24),                                                 │
  │ 188 +         titleLarge: _textStyle(darkTextPrimary, FontWeight.w700, 20),                                                    │
  │ 189 +         titleMedium: _textStyle(darkTextPrimary, FontWeight.w600, 18),                                                   │
  │ 190 +         titleSmall: _textStyle(darkTextPrimary, FontWeight.w600, 16),                                                    │
  │ 191 +         bodyLarge: _textStyle(darkTextPrimary, FontWeight.w400, 16),                                                     │
  │ 192 +         bodyMedium: _textStyle(darkTextSecondary, FontWeight.w400, 14),                                                  │
  │ 193 +         bodySmall: _textStyle(darkTextSecondary, FontWeight.w400, 12),                                                   │
  │ 194 +         labelLarge: _textStyle(darkTextPrimary, FontWeight.w600, 14),                                                    │
  │ 195         ),                                                                                                                 │
  │ 196         snackBarTheme: SnackBarThemeData(                                                                                  │
  │ 187 -         backgroundColor: darkSurfaceLight,                                                                               │
  │ 188 -         contentTextStyle: const TextStyle(color: darkTextPrimary),                                                       │
  │ 197 +         backgroundColor: darkSurface,                                                                                    │
  │ 198 +         contentTextStyle: _textStyle(darkTextPrimary, FontWeight.w500, 14),                                              │
  │ 199           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),                                          │
  │ 200           behavior: SnackBarBehavior.floating,                                                                             │
  │ 201         ),                                                                                                                 │
  │ 202         dialogTheme: DialogThemeData(                                                                                      │
  │ 203           backgroundColor: darkSurface,                                                                                    │
  │ 204           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),                                          │
  │ 195 -         titleTextStyle: const TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w700),              │
  │ 196 -         contentTextStyle: const TextStyle(color: darkTextSecondary, fontSize: 16),                                       │
  │ 205 +         titleTextStyle: _textStyle(darkTextPrimary, FontWeight.w700, 20),                                                │
  │ 206 +         contentTextStyle: _textStyle(darkTextSecondary, FontWeight.w400, 16),                                            │
  │ 207         ),                                                                                                                 │
  │ 208         chipTheme: ChipThemeData(                                                                                          │
  │ 209           backgroundColor: darkSurfaceLight,                                                                               │
  │ 200 -         selectedColor: secondaryColor.withValues(alpha: 0.2),                                                            │
  │ 201 -         labelStyle: const TextStyle(color: darkTextPrimary),                                                             │
  │ 202 -         secondaryLabelStyle: const TextStyle(color: secondaryColor),                                                     │
  │ 210 +         selectedColor: primaryColor.withValues(alpha: 0.2),                                                              │
  │ 211 +         labelStyle: _textStyle(darkTextPrimary, FontWeight.w500, 12),                                                    │
  │ 212 +         secondaryLabelStyle: _textStyle(primaryColor, FontWeight.w500, 12),                                              │
  │ 213           side: const BorderSide(color: darkBorder),                                                                       │
  │ 214           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),                                          │
  │ 215         ),                                                                                                                 │
  │   ⋮                                                                                                                            │
  │ 220           ),                                                                                                               │
  │ 221         ),                                                                                                                 │
  │ 222         progressIndicatorTheme: const ProgressIndicatorThemeData(                                                          │
  │ 213 -         color: secondaryColor,                                                                                           │
  │ 223 +         color: primaryColor,                                                                                             │
  │ 224           linearTrackColor: darkBorder,                                                                                    │
  │ 225         ),                                                                                                                 │
  │ 226       );                                                                                                                   │
  ╰────────────────────────────────────────────────────────────────────