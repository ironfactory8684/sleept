import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Unused, can be removed if not used elsewhere
import 'package:sleept/components/am_pm_selector.dart';
import 'package:sleept/components/time_slot_picker.dart';
import 'package:sleept/constants/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleept/features/tracking/components/build_tracking_content.dart';
import 'dart:typed_data';
import 'package:sleept/features/habit/service/habit_database.dart';
import 'package:sleept/models/snoring_event.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'components/build_time_selection_background.dart';
import 'components/build_time_selection_content.dart';
import 'components/build_tracking_background.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isAm = true;
  int _selectedHour = 8;
  int _selectedMinute = 0;
  bool _isTracking = false;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  // FlutterSoundRecorder 관련 변수
  FlutterSoundRecorder? _mRecorder;
  bool _mRecorderIsInited = false;
  String? _mPath = 'temp_audio.pcm';
  Codec _codec = Codec.pcm16; // Using PCM 16-bit

  bool _isRecording = false;

  bool _isSnoring = false;
  DateTime? _snoreStartTime;

  // Changed from StreamController<FoodData> to StreamController<Uint8List>
  StreamController<Uint8List>? _audioStreamController;
  StreamSubscription? _audioStreamSubscription;


  @override
  void initState() {
    super.initState();
    _mRecorder = FlutterSoundRecorder();
    _openTheRecorder();
  }

  void _updateRemainingTime() {
    int targetHour = _selectedHour;
    if (!_isAm && targetHour != 12) {
      targetHour += 12;
    } else if (_isAm && targetHour == 12) {
      targetHour = 0; // Midnight 12 AM
    } else if (!_isAm && targetHour == 12) {
      targetHour = 12; // Noon 12 PM
    }

    final nowDateTime = DateTime.now();
    DateTime targetDateTime = DateTime(
      nowDateTime.year,
      nowDateTime.month,
      nowDateTime.day,
      targetHour,
      _selectedMinute,
    );

    if (targetDateTime.isBefore(nowDateTime)) {
      targetDateTime = targetDateTime.add(const Duration(days: 1));
    }

    setState(() {
      _remainingTime = targetDateTime.difference(nowDateTime);
    });

    if (_remainingTime.inSeconds <= 0) {
      _stopTracking();
      print("Alarm time!");
    }
  }

  Future<void> _startTracking() async {
    setState(() {
      _isTracking = true;
    });
    await _startAudioCapture();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    _stopAudioCapture();

    if (_isSnoring && _snoreStartTime != null) {
      final endTime = DateTime.now();
      HabitDatabase.instance.createSnoringEvent(
        SnoringEvent(startTime: _snoreStartTime!, endTime: endTime),
      );
      _snoreStartTime = null;
    }

    setState(() {
      _isTracking = false;
      _remainingTime = Duration.zero;
      _isSnoring = false;
    });
  }

  Future<void> _openTheRecorder() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('Microphone permission not granted!');
      _mRecorderIsInited = false;
      return;
    }

    if (_mRecorder == null) return;

    try {
      await _mRecorder!.openRecorder();
      _mRecorderIsInited = true;
      print('Recorder opened successfully.');
    } catch (e) {
      print('Error opening recorder: $e');
      _mRecorderIsInited = false;
    }
  }

  Float32List _convertPCMToFloat32(Uint8List pcmData) {
    final int samples = pcmData.length ~/ 2;
    final Float32List float32List = Float32List(samples);
    final ByteData byteData = pcmData.buffer.asByteData();

    for (int i = 0; i < samples; i++) {
      // Read 16-bit signed integer and normalize to -1.0 to 1.0
      // Ensure Endian.little or Endian.big matches your system/device's byte order
      final int sample = byteData.getInt16(i * 2, Endian.little);
      float32List[i] = sample / 32768.0; // Max value for int16 is 32767
    }
    return float32List;
  }

  Future<void> _startAudioCapture() async {
    if (!_mRecorderIsInited || _mRecorder == null || _isRecording) {
      print('Recorder not initialized or already recording.');
      return;
    }

    try {
      // 1. Create a StreamController for Uint8List
      _audioStreamController = StreamController<Uint8List>();

      // 2. Listen to the stream for processing
      // The `pcmData` here is directly Uint8List, no need for .data
      _audioStreamSubscription = _audioStreamController!.stream.listen((Uint8List pcmData) {
        final float32List = _convertPCMToFloat32(pcmData);

        final double energyThreshold = 0.1; // Tune this value based on testing
        double currentEnergy = 0.0;
        for (final sample in float32List) {
          currentEnergy += (sample * sample);
        }

        final bool snoringDetected = currentEnergy > energyThreshold;

        if (snoringDetected && !_isSnoring) {
          _snoreStartTime = DateTime.now();
          setState(() => _isSnoring = true);
          print('Snoring started at: $_snoreStartTime (Energy: $currentEnergy)');
        } else if (!snoringDetected && _isSnoring) {
          final endTime = DateTime.now();
          if (_snoreStartTime != null) {
            HabitDatabase.instance.createSnoringEvent(
              SnoringEvent(startTime: _snoreStartTime!, endTime: endTime),
            );
            print('Snoring ended at: $endTime. Duration: ${endTime.difference(_snoreStartTime!)} (Energy: $currentEnergy)');
          }
          _snoreStartTime = null;
          setState(() => _isSnoring = false);
        }
      });

      // 3. Pass the sink of the StreamController to toStream
      await _mRecorder!.startRecorder(
        toStream: _audioStreamController!.sink, // This now correctly expects StreamSink<Uint8List>
        codec: _codec,
        numChannels: 1,
        sampleRate: 44100,
        toFile: _mPath, // Path required even for streaming
      );

      setState(() {
        _isRecording = true;
      });
      print('Audio capture started.');
    } catch (e) {
      print('Error starting audio capture: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopAudioCapture() async {
    if (_isRecording && _mRecorder != null) {
      try {
        await _mRecorder!.stopRecorder();
        await _audioStreamSubscription?.cancel();
        await _audioStreamController?.close();
        _audioStreamController = null;
        _audioStreamSubscription = null;

        setState(() {
          _isRecording = false;
        });
        print('Audio capture stopped.');
      } catch (e) {
        print('Error stopping audio capture: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopAudioCapture();
    if (_mRecorder != null) {
      _mRecorder!.closeRecorder();
      _mRecorder = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: _isTracking ? Brightness.dark : Brightness.light,
      ),
    );

    final displayHour =
    _selectedHour == 0
        ? 12
        : (_selectedHour > 12 ? _selectedHour - 12 : _selectedHour);
    final displayMinute = _selectedMinute.toString().padLeft(2, '0');
    final displayAmPm = _isAm ? 'AM' : 'PM';

    return Scaffold(
      backgroundColor:
      _isTracking ? const Color(0xFF181621) : AppColors.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            _isTracking
                ? BuildTrackingBackground()
                : BuildTimeSelectionBackground(),
            _isTracking
                ? BuildTrackingContent(
              stopTracking: _stopTracking,
              displayHour: displayHour,
              remainingTime: _remainingTime,
              displayMinute: displayMinute,
              displayAmPm: displayAmPm,
              isSnoring: _isSnoring,
            )
                : BuildTimeSelectionContent(
              selectedMinute: _selectedMinute,
              selectedHour: _selectedHour,
              startTracking: _startTracking,
              onChangeAmPm: (value) {
                setState(() {
                  _isAm = value;
                });
              },
              onTimeChanged: (hour, minute) {
                setState(() {
                  _selectedHour = hour;
                  _selectedMinute = minute;
                });
              },
              isAm: _isAm,
            ),
          ],
        ),
      ),
    );
  }
}