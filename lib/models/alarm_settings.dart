

enum AlarmSound {
  soothing,
  clear,
  gentle,
  peaceful,
  calm,
  morning
}

class AlarmSettings {
  final bool enabled;
  final double volume;
  final bool vibrationEnabled;
  final AlarmSound selectedSound;

  AlarmSettings({
    this.enabled = false,
    this.volume = 0.5,
    this.vibrationEnabled = false,
    this.selectedSound = AlarmSound.soothing,
  });

  AlarmSettings copyWith({
    bool? enabled,
    double? volume,
    bool? vibrationEnabled,
    AlarmSound? selectedSound,
  }) {
    return AlarmSettings(
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      selectedSound: selectedSound ?? this.selectedSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'volume': volume,
      'vibrationEnabled': vibrationEnabled,
      'selectedSound': selectedSound.index,
    };
  }

  factory AlarmSettings.fromJson(Map<String, dynamic> json) {
    return AlarmSettings(
      enabled: json['enabled'] as bool,
      volume: json['volume'] as double,
      vibrationEnabled: json['vibrationEnabled'] as bool,
      selectedSound: AlarmSound.values[json['selectedSound'] as int],
    );
  }

  @override
  String toString() {
    return 'AlarmSettings(enabled: $enabled, volume: $volume, vibrationEnabled: $vibrationEnabled, selectedSound: $selectedSound)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AlarmSettings &&
        other.enabled == enabled &&
        other.volume == volume &&
        other.vibrationEnabled == vibrationEnabled &&
        other.selectedSound == selectedSound;
  }

  @override
  int get hashCode {
    return enabled.hashCode ^
        volume.hashCode ^
        vibrationEnabled.hashCode ^
        selectedSound.hashCode;
  }
}
