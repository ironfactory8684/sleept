import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleept/models/alarm_settings.dart';

class AlarmSettingsRepository {
  static const String _keyAlarmSettings = 'alarm_settings';

  // Save alarm settings to cache
  Future<void> saveAlarmSettings(AlarmSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_keyAlarmSettings, settingsJson);
  }

  // Get alarm settings from cache
  Future<AlarmSettings> getAlarmSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_keyAlarmSettings);

    if (settingsJson == null) {
      // Return default settings if no saved settings are found
      return AlarmSettings();
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(settingsJson);
      return AlarmSettings.fromJson(decoded);
    } catch (e) {
      // Return default settings if there was an error parsing
      print('Error parsing alarm settings: $e');
      return AlarmSettings();
    }
  }
}
