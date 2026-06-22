# bank-platform-frontend-mobile

Application mobile Flutter pour la plateforme bancaire distribuée.

## Technologies
- Flutter 3.x
- Dart
- flutter_bloc (state management)
- dio (HTTP)
- flutter_secure_storage
- local_auth (biométrie)
- image_picker
- firebase_messaging

## Structure (Clean Architecture)
- `lib/data/` - Data sources, repositories impl, models
- `lib/domain/` - Entities, use cases, repository interfaces
- `lib/presentation/` - Screens, widgets, blocs
- `test/` - Tests unitaires et widget

## Démarrage
```bash
flutter pub get
flutter run
```

## Build
```bash
flutter build apk --release
flutter build ios --release
```
