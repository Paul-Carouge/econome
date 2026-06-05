# Économe — Application de finances personnelles

> **Par Paul Carouge** — [LinkedIn](https://linkedin.com/in/pcarouge) · [GitHub](https://github.com/Paul-Carouge)

**Économe** est une application mobile de gestion budgétaire conçue pour vous aider à suivre vos dépenses, respecter votre budget mensuel, épargner pour vos objectifs, et maîtriser vos achats impulsifs. 100% locale, gratuite, sans publicité.

[![Dernière version](https://img.shields.io/github/v/release/Paul-Carouge/econome?label=version&color=F59E0B)](https://github.com/Paul-Carouge/econome/releases)
[![Licence MIT](https://img.shields.io/badge/licence-MIT-blue)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter)](https://flutter.dev)

---

## ✨ Fonctionnalités

| | Fonctionnalité | Description |
|---|---------------|-------------|
| 📊 | **Tableau de bord mensuel** | Revenus, dépenses, solde, graphique camembert par catégorie |
| 💰 | **Transactions** | Ajout, modification, suppression — revenus et dépenses |
| 🔍 | **Recherche et filtres** | Recherche textuelle, filtre par catégorie, par type |
| 🎯 | **Budget mensuel** | Définissez une limite, suivi visuel avec barre de progression colorée |
| 🏦 | **Objectifs d'épargne** | Suivez votre progression vers vos objectifs financiers |
| 🛑 | **Anti-achat impulsif** | Période de refroidissement avec notification de rappel |
| 📁 | **Export CSV** | Exportez vos transactions pour les analyser dans Excel |
| 🌙 | **Thème sombre** | Interface Material 3 sombre, animations fluides |
| 🔒 | **100% privé** | Toutes vos données restent sur votre appareil — pas de compte, pas de cloud |

## 📸 Captures d'écran

*À venir*

## 🛠️ Stack technique

- **[Flutter](https://flutter.dev)** 3.44 / Dart 3.12 — Framework cross-platform
- **[Riverpod](https://riverpod.dev)** 3.2 — Gestion d'état moderne et typée
- **[Drift](https://drift.simonbinder.eu)** 2.33 — Base de données SQLite réactive
- **[GoRouter](https://pub.dev/packages/go_router)** 17.3 — Navigation déclarative
- **[fl_chart](https://pub.dev/packages/fl_chart)** 1.2 — Graphiques et visualisations
- **[Material 3](https://m3.material.io)** — Design System Google, thème dark zinc & amber

## 📦 Installation

Téléchargez le dernier APK :

[**⬇️ Télécharger Économe v1.2.2**](https://github.com/Paul-Carouge/econome/releases/download/v1.2.2/econome-v1.2.2.apk)

Ou compilez depuis les sources :

```bash
git clone https://github.com/Paul-Carouge/econome.git
cd econome
flutter pub get
dart run build_runner build
flutter build apk --release
```

L'APK se trouve dans `build/app/outputs/flutter-apk/econome-release.apk`.

## 📋 Prérequis

- Flutter SDK 3.44+
- Dart SDK 3.12+
- Android SDK (pour le build APK)

## 🧪 Tests

```bash
cd econome
./scripts/run_tests.sh
```

## 📄 Licence

Projet open source sous licence **MIT** — réalisé par [Paul Carouge](https://linkedin.com/in/pcarouge).

---

<p align="center">
  <sub>Conçu avec ❤️ par Paul Carouge —</sub>
  <a href="https://github.com/Paul-Carouge/econome">GitHub</a> ·
  <a href="https://linkedin.com/in/pcarouge">LinkedIn</a>
</p>
