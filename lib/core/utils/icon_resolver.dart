import 'package:flutter/material.dart';
import 'package:econome/core/constants/app_constants.dart';

/// Résout une icône Material à partir d'une clé de catégorie.
///
/// Centralise la logique de résolution pour éviter la duplication
/// du pattern `AppConstants.categoryIcons[key] ?? Icons.category`.
IconData resolveCategoryIcon(String iconKey) {
  return AppConstants.categoryIcons[iconKey] ?? Icons.category;
}
