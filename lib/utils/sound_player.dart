import 'package:audioplayers/audioplayers.dart';
import 'package:sleept/models/alarm_settings.dart';

class SoundPlayer {
  static final SoundPlayer _instance = SoundPlayer._internal();
  factory SoundPlayer() => _instance;
  SoundPlayer._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  AlarmSound? _currentlyPlayingSound;
  
  // Map alarm sounds to their corresponding asset paths using existing files
  final Map<AlarmSound, String> _soundPaths = {
    AlarmSound.soothing: 'music/soothing-deep-sleep-music-432-hz-191708.mp3',
    AlarmSound.clear: 'music/the-old-water-mill-meditation-8005.mp3',
    AlarmSound.gentle: 'music/bathroom-chill-background-music-14977.mp3',
    AlarmSound.peaceful: 'music/midnight-forest-184304.mp3',
    AlarmSound.calm: 'music/quiet-sleep-2-263254.mp3',
    AlarmSound.morning: 'music/deep-relaxing-music-144008.mp3',
  };
  
  // Play a preview of the selected alarm sound
  Future<void> playSound(AlarmSound sound, double volume) async {
    if (_currentlyPlayingSound != null) {
      await stopSound();
    }
    
    _currentlyPlayingSound = sound;
    final soundPath = _soundPaths[sound];
    
    if (soundPath != null) {
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(AssetSource(soundPath));
    }
  }
  
  // Stop playing the current sound
  Future<void> stopSound() async {
    if (_currentlyPlayingSound != null) {
      await _audioPlayer.stop();
      _currentlyPlayingSound = null;
    }
  }
  
  // Dispose the audio player
  Future<void> dispose() async {
    await stopSound();
    await _audioPlayer.dispose();
  }
}
