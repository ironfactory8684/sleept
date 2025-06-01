import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/models/alarm_settings.dart';
import 'package:sleept/providers/alarm_settings_provider.dart';
import 'package:sleept/utils/sound_player.dart';

class TrackingSettingScreen extends ConsumerStatefulWidget {
  const TrackingSettingScreen({super.key});

  @override
  ConsumerState<TrackingSettingScreen> createState() => _TrackingSettingScreenState();
}

class _TrackingSettingScreenState extends ConsumerState<TrackingSettingScreen> {
  final SoundPlayer _soundPlayer = SoundPlayer();
  AlarmSound? _previewingSound;
  
  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  // Play a preview of the selected sound
  void _previewSound(AlarmSound sound, double volume) {
    setState(() {
      _previewingSound = sound;
    });
    _soundPlayer.playSound(sound, volume);
  }
  
  // Stop the sound preview
  void _stopPreview() {
    setState(() {
      _previewingSound = null;
    });
    _soundPlayer.stopSound();
  }
  
  @override
  Widget build(BuildContext context) {
    final alarmSettings = ref.watch(alarmSettingsProvider);
    final alarmSettingsNotifier = ref.watch(alarmSettingsProvider.notifier);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1B26),
        title: const Text('알람 설정', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save settings and navigate back
              Navigator.of(context).pop();
            },
            child: const Text('완료', style: TextStyle(color: Color(0xFF724BFF))),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 알람 허용 스위치
              _buildSettingItem(
                title: '알람 허용',
                trailing: Switch(
                  value: alarmSettings.enabled,
                  onChanged: (value) => alarmSettingsNotifier.toggleAlarm(value),
                  activeColor: const Color(0xFF724BFF),
                  trackColor: MaterialStateProperty.resolveWith((states) => 
                    states.contains(MaterialState.selected) 
                      ? const Color(0xFF724BFF).withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3)
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 음량 조절 슬라이더
              const Text('음량 조절', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4.0,
                  activeTrackColor: const Color(0xFF724BFF),
                  inactiveTrackColor: Colors.grey.withOpacity(0.3),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF724BFF).withOpacity(0.2),
                ),
                child: Slider(
                  value: alarmSettings.volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) => alarmSettingsNotifier.setVolume(value),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 진동 스위치
              _buildSettingItem(
                title: '진동',
                trailing: Switch(
                  value: alarmSettings.vibrationEnabled,
                  onChanged: (value) => alarmSettingsNotifier.toggleVibration(value),
                  activeColor: const Color(0xFF724BFF),
                  trackColor: MaterialStateProperty.resolveWith((states) => 
                    states.contains(MaterialState.selected) 
                      ? const Color(0xFF724BFF).withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3)
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 알람음 선택
              const Text('알람음', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              
              // 알람음 라디오 버튼 목록
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.soothing,
                title: '아침 햇살과 새소리',
              ),
              
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.clear,
                title: '숲속 냇가에 흐르는 물',
              ),
              
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.gentle,
                title: '명랑한 빗과 음악',
              ),
              
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.peaceful,
                title: '격렬한 파도',
              ),
              
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.calm,
                title: '느리게 흘러가는 마음',
              ),
              
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.morning,
                title: '다정함과 따뜻한 차',
              ),
              
              _buildAlarmSoundOption(
                context: context,
                alarmSettings: alarmSettings,
                alarmSettingsNotifier: alarmSettingsNotifier,
                sound: AlarmSound.morning,
                title: '미라클 모닝',
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingItem({required String title, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        trailing,
      ],
    );
  }
  
  Widget _buildAlarmSoundOption({
    required BuildContext context, 
    required AlarmSettings alarmSettings,
    required AlarmSettingsNotifier alarmSettingsNotifier,
    required AlarmSound sound,
    required String title,
    bool isLast = false,
  }) {
    
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          trailing: _previewingSound == sound
            ? IconButton(
                icon: const Icon(Icons.stop_circle, color: Color(0xFF724BFF)),
                onPressed: _stopPreview,
              )
            : IconButton(
                icon: const Icon(Icons.play_circle, color: Colors.grey),
                onPressed: () => _previewSound(sound, ref.read(alarmSettingsProvider).volume),
              ),
          leading: Radio<AlarmSound>(
            value: sound,
            groupValue: alarmSettings.selectedSound,
            onChanged: (value) {
              if (value != null) {
                alarmSettingsNotifier.setAlarmSound(value);
                _previewSound(value, alarmSettings.volume);
              }
            },
            fillColor: MaterialStateProperty.resolveWith((states) => 
              states.contains(MaterialState.selected) 
                ? const Color(0xFF724BFF)
                : Colors.grey
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Color(0xFF2D2B38)),
      ],
    );
  }
}
