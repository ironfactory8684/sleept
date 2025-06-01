import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/models/alarm_settings.dart';
import 'package:sleept/repositories/alarm_settings_repository.dart';

// Repository provider
final alarmSettingsRepositoryProvider = Provider<AlarmSettingsRepository>((ref) {
  return AlarmSettingsRepository();
});

// State notifier to manage the alarm settings state
class AlarmSettingsNotifier extends StateNotifier<AlarmSettings> {
  final AlarmSettingsRepository _repository;
  
  AlarmSettingsNotifier(this._repository) : super(AlarmSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.getAlarmSettings();
    state = settings;
  }

  Future<void> toggleAlarm(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _repository.saveAlarmSettings(state);
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _repository.saveAlarmSettings(state);
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _repository.saveAlarmSettings(state);
  }

  Future<void> setAlarmSound(AlarmSound sound) async {
    state = state.copyWith(selectedSound: sound);
    await _repository.saveAlarmSettings(state);
  }
}

// State notifier provider for alarm settings
final alarmSettingsProvider = StateNotifierProvider<AlarmSettingsNotifier, AlarmSettings>((ref) {
  final repository = ref.watch(alarmSettingsRepositoryProvider);
  return AlarmSettingsNotifier(repository);
});
