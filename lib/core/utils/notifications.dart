import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum ToastType { success, error, info }

/// Affiche un toast élégant dans le thème Budgethink.
/// Utilisation : `showBudgethinkToast(context, 'Transaction ajoutée', ToastType.success);`
void showBudgethinkToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  HapticFeedback.lightImpact();

  final cs = Theme.of(context).colorScheme;
  final IconData icon;
  final Color iconColor;

  switch (type) {
    case ToastType.success:
      icon = Icons.check_circle_rounded;
      iconColor = AppTheme.greenAccent;
    case ToastType.error:
      icon = Icons.error_rounded;
      iconColor = AppTheme.redAccent;
    case ToastType.info:
      icon = Icons.info_rounded;
      iconColor = AppTheme.amberAccent;
  }

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: cs.surface,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: iconColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
}

/// Helper pour les toasts de succès
void showSuccess(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
  showBudgethinkToast(context, message, type: ToastType.success, actionLabel: actionLabel, onAction: onAction);
}

/// Helper pour les toasts d'erreur
void showError(BuildContext context, String message) {
  showBudgethinkToast(context, message, type: ToastType.error, duration: const Duration(seconds: 4));
}

/// Helper pour les toasts d'information
void showInfo(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
  showBudgethinkToast(context, message, type: ToastType.info, actionLabel: actionLabel, onAction: onAction);
}
