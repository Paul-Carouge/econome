import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:econome/data/database/app_database.dart';

// ─── Singleton Plugin ─────────────────────────────────────────────────

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

/// Android notification channel for cooling-period reminders.
const String _coolingChannelId = 'econome_cooling';
const String _coolingChannelName = 'Période de refroidissement';
const String _coolingChannelDesc =
    'Notifications quand la période de refroidissement d\'un achat impulsif se termine.';

/// Notification ID base — add [impulseId] to get unique IDs per item.
const int _coolingBaseId = 1000;

// ─── Initialization ───────────────────────────────────────────────────

/// Initializes the flutter_local_notifications plugin.
///
/// Must be called once before any scheduling / showing methods.
/// Call from `main()` or the first screen that needs notifications.
Future<void> initNotificationService() async {
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _plugin.initialize(initSettings);
}

// ─── Cooling Reminder ─────────────────────────────────────────────────

/// Schedules a local notification that fires when the [item]'s cooling
/// period ends, reminding the user to either approve or dismiss it.
Future<void> scheduleCoolingReminder(ImpulseItem item) async {
  final coolingEnd = DateTime.tryParse(item.coolingUntil);
  if (coolingEnd == null) return;

  final now = DateTime.now();
  if (coolingEnd.isBefore(now)) return; // Already expired

  final androidDetails = AndroidNotificationDetails(
    _coolingChannelId,
    _coolingChannelName,
    channelDescription: _coolingChannelDesc,
    importance: Importance.high,
    priority: Priority.defaultPriority,
    icon: '@mipmap/ic_launcher',
    category: AndroidNotificationCategory.reminder,
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  // Format amount without trailing zeros
  final amountStr = item.amount == item.amount.roundToDouble()
      ? '${item.amount.toInt()} €'
      : '${item.amount.toStringAsFixed(2)} €';

  // Convert the cooling end DateTime to a TZDateTime in the local timezone
  final scheduledDate = tz.TZDateTime.from(coolingEnd, tz.local);

  await _plugin.zonedSchedule(
    _coolingBaseId + item.id,
    '⏰ Période de refroidissement terminée',
    'Vous pouvez maintenant approuver ou ignorer « ${item.name} » ($amountStr).',
    scheduledDate,
    details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

/// Cancels a previously scheduled cooling reminder for [impulseId].
Future<void> cancelCoolingReminder(int impulseId) async {
  await _plugin.cancel(_coolingBaseId + impulseId);
}

/// Cancels **all** scheduled cooling reminders.
Future<void> cancelAllCoolingReminders() async {
  await _plugin.cancelAll();
}
