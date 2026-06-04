# Économe

Application de suivi budgétaire — Suivez vos dépenses, épargnez, et ne faites plus d'achats impulsifs.

## Fonctionnalités

- 📊 Tableau de bord mensuel avec soldes et catégories
- 💰 Gestion des transactions (revenus et dépenses)
- 🎯 Budgets mensuels par catégorie
- 🏦 Objectifs d'épargne avec suivi visuel
- 🛑 Anti-achat impulsif avec période de refroidissement
- 🎨 Interface Material 3 sombre, animations fluides
- 📱 100% locale — vos données restent sur votre appareil
- 🆓 Gratuite, open source, sans publicité

## Captures d'écran

*À venir*

## Technologies

- Flutter / Dart
- Riverpod (gestion d'état)
- Drift (base de données SQLite)
- GoRouter (navigation)
- Material 3 Design

## Installation

Téléchargez le dernier APK depuis la [page des releases](https://github.com/Paul-Carouge/econome/releases).

Ou clonez et construisez vous-même :

```bash
git clone https://github.com/Paul-Carouge/econome.git
cd econome
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

## Licence

MIT
