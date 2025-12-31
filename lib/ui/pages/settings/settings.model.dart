import 'package:flutter/material.dart';
import 'package:sentimento_app/services/notification_service.dart';

class SettingsModel extends ChangeNotifier {
  bool notificationsEnabled = true;
  List<NotificationSchedule> get schedules => NotificationService().schedules;

  void initState(BuildContext context) {
    _loadSettings();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    notificationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    await NotificationService().setNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> updateSchedule(
    NotificationSchedule schedule,
    bool isEnabled,
  ) async {
    final updated = NotificationSchedule(
      id: schedule.id,
      title: schedule.title,
      body: schedule.body,
      hour: schedule.hour,
      minute: schedule.minute,
      activeDays: schedule.activeDays,
      isEnabled: isEnabled,
    );
    await NotificationService().updateSchedule(updated);
    // NotificationService updates its own list, but we notify to refresh UI
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
