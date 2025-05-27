import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sleept/constants/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleept/features/tracking/components/build_tracking_content.dart';
import 'package:sleept/features/tracking/service/audio_analyzer.dart';
import 'dart:typed_data';
import 'package:sleept/features/habit/service/habit_database.dart';
import 'package:sleept/models/snoring_event.dart';
import 'package:sleept/models/sleep_talking_event.dart';
import 'package:sleept/models/sleep_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:intl/intl.dart';
import 'components/build_time_selection_background.dart';
import 'components/build_time_selection_content.dart';
import 'components/build_tracking_background.dart';
import 'sleep_results_screen.dart';
import 'package:sleept/services/supabase_service.dart';

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

  // Audio recording variables
  FlutterSoundRecorder? _mRecorder;
  bool _mRecorderIsInited = false;
  String? _currentRecordingPath;
  Codec _codec = Codec.aacADTS; // Using AAC for better compression
  bool _isRecording = false;
  int _recordingSegmentIndex = 0;
  Timer? _segmentSplitTimer;
  DateTime? _sessionStartTime;
  String _sessionDirectory = '';

  // Sleep event detection variables
  bool _isSnoring = false;
  DateTime? _snoreStartTime;
  bool _isTalking = false;
  DateTime? _talkStartTime;

  // Audio analysis variables
  StreamController<Uint8List>? _audioStreamController;
  StreamSubscription? _audioStreamSubscription;
  List<SnoringEvent> _snoringEvents = [];
  List<SleepTalkingEvent> _sleepTalkingEvents = [];
  final AudioAnalyzer _audioAnalyzer = AudioAnalyzer();

  // Background processing flag
  bool _isBackgroundProcessingEnabled = false;

  @override
  void initState() {
    super.initState();
    _mRecorder = FlutterSoundRecorder();
    _openTheRecorder();

    // Ensure we have a directory to store all session recordings
    _prepareSessionDirectory();
  }

  /// Prepares a directory for storing this sleep session recordings
  Future<void> _prepareSessionDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final sessionName =
        'sleep_session_${DateFormat('yyyyMMdd_HHmmss').format(now)}';
    _sessionDirectory = '${appDir.path}/sessions/$sessionName';

    // Create the session directory if it doesn't exist
    final directory = Directory(_sessionDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
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

    // Record session start time
    _sessionStartTime = DateTime.now();

    // Start audio recording with segmentation
    await _startAudioCapture();

    // Setup segment splitter timer
    _segmentSplitTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (_isRecording) {
        _rotateAudioSegment();
      }
    });

    // Track remaining time until alarm
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });

    // Enable background processing
    _isBackgroundProcessingEnabled = true;
  }

  Future<void> _stopTracking() async {
    // Check if session duration is less than 30 minutes
    if (_sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!);
      if (sessionDuration.inMinutes < 30) {
        // Show warning dialog
        final bool? proceed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('수면 분석 경고'),
              content: const Text('30분 이상 분석해야 제대로된 수면 결과를 얻을 수 있습니다. 정말로 종료하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('종료'),
                ),
              ],
            );
          },
        );
        
        // If user chooses to cancel, don't proceed with stopping tracking
        if (proceed != true) {
          return;
        }
      }
    }
  
    // Cancel all timers
    _timer?.cancel();
    _segmentSplitTimer?.cancel();

    // Stop audio capture
    await _stopAudioCapture();

    // Handle any active snoring event
    if (_isSnoring && _snoreStartTime != null) {
      final endTime = DateTime.now();
      final event = SnoringEvent(startTime: _snoreStartTime!, endTime: endTime);

      HabitDatabase.instance.createSnoringEvent(event);
      _snoringEvents.add(event);
      _snoreStartTime = null;
    }

    // Handle any active talking event
    if (_isTalking && _talkStartTime != null) {
      final endTime = DateTime.now();
      final event = SleepTalkingEvent(
        startTime: _talkStartTime!,
        endTime: endTime,
      );

      _sleepTalkingEvents.add(event);
      _talkStartTime = null;
    }

    // Create and save sleep session
    if (_sessionStartTime != null) {
      final sessionEndTime = DateTime.now();
      final session = SleepSession(
        startTime: _sessionStartTime!,
        endTime: sessionEndTime,
        sessionDirectory: _sessionDirectory,
        snoringEvents: _snoringEvents,
        sleepTalkingEvents: _sleepTalkingEvents,
        sleepScore: _calculateSleepScore(),
      );
      
      // Save to Supabase
      try {
        final supbaseService = SupabaseService.instance;
        final sessionId = await supbaseService.saveSleepSession(session);
        print('Successfully saved session to Supabase with ID: $sessionId');
      } catch (e) {
        print('Failed to save session to Supabase: $e');
      }

      // Navigate to sleep results screen
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SleepResultsScreen(session: session),
        ),
      );

      // Reset session data
      _snoringEvents = [];
      _sleepTalkingEvents = [];
    }

    setState(() {
      _isTracking = false;
      _remainingTime = Duration.zero;
      _isSnoring = false;
      _isTalking = false;
      _isBackgroundProcessingEnabled = false;
    });
  }

  /// Calculate a simple sleep score based on session data
  double _calculateSleepScore() {
    // This is a simplified example - a real implementation would have more sophisticated scoring
    if (_sessionStartTime == null) return 0.0;

    final sessionDuration =
        DateTime.now().difference(_sessionStartTime!).inMinutes;
    if (sessionDuration <= 0) return 0.0;

    // Calculate total time spent snoring in minutes
    final totalSnoringMinutes = _snoringEvents.fold<double>(
      0,
      (total, event) => total + event.duration.inMinutes,
    );

    // Calculate percentage of time spent snoring
    final snoringPercentage = (totalSnoringMinutes / sessionDuration) * 100;

    // Simple scoring formula: base score of 100, subtract points for snoring percentage
    final baseScore = 100.0;
    final snoringPenalty =
        snoringPercentage * 0.5; // 0.5 points per percent of snoring

    return (baseScore - snoringPenalty).clamp(0.0, 100.0);
  }

  Future<void> _openTheRecorder() async {
    // Request permissions
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      print('Microphone permission not granted!');
      _mRecorderIsInited = false;
      return;
    }

    // For background recording on iOS, we need to configure the audio session
    // No need for explicit audio permission beyond microphone permission

    if (_mRecorder == null) return;

    try {
      // Configure audio session for background recording
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );

      await _mRecorder!.openRecorder();

      // Enable background recording (important for sleep tracking)
      await _mRecorder!.setSubscriptionDuration(
        const Duration(milliseconds: 500),
      );
      _mRecorderIsInited = true;
      print('Recorder opened successfully and configured for background use.');
    } catch (e) {
      print('Error opening recorder: $e');
      _mRecorderIsInited = false;
    }
  }

  // This method has been moved to the AudioAnalyzer service

  /// Start recording audio for sleep tracking
  Future<void> _startAudioCapture() async {
    if (!_mRecorderIsInited || _mRecorder == null || _isRecording) {
      print('Recorder not initialized or already recording.');
      return;
    }

    try {
      // Initialize recording segment index
      _recordingSegmentIndex = 0;

      // Create file path for the first segment
      _currentRecordingPath =
          '${_sessionDirectory}/segment_$_recordingSegmentIndex.aac';

      // Create a StreamController for real-time audio analysis
      _audioStreamController = StreamController<Uint8List>();

      // Set up stream processing for audio analysis
      _audioStreamSubscription = _audioStreamController!.stream.listen((
        Uint8List pcmData,
      ) {
        final float32List = _audioAnalyzer.convertPCMToFloat32(pcmData);
        final analysisResult = _audioAnalyzer.analyzeAudioSegment(float32List);

        // Handle snoring detection
        final bool snoringDetected = analysisResult['isSnoring'] as bool;
        final double energy = analysisResult['energy'] as double;

        if (snoringDetected && !_isSnoring) {
          // Start of a snoring event
          _snoreStartTime = DateTime.now();
          setState(() => _isSnoring = true);
          print('Snoring started at: $_snoreStartTime (Energy: $energy)');
        } else if (!snoringDetected && _isSnoring) {
          // End of a snoring event
          final endTime = DateTime.now();
          if (_snoreStartTime != null) {
            final event = SnoringEvent(
              startTime: _snoreStartTime!,
              endTime: endTime,
              intensity: energy,
            );

            // Save to database
            HabitDatabase.instance.createSnoringEvent(event);

            // Add to in-memory list for session summary
            _snoringEvents.add(event);

            print(
              'Snoring ended at: $endTime. Duration: ${endTime.difference(_snoreStartTime!)}',
            );
          }
          _snoreStartTime = null;
          setState(() => _isSnoring = false);
        }

        // Handle sleep talking detection
        final bool talkingDetected = analysisResult['isTalking'] as bool;

        if (talkingDetected && !_isTalking) {
          // Start of a sleep talking event
          _talkStartTime = DateTime.now();
          setState(() => _isTalking = true);
          print('Sleep talking started at: $_talkStartTime');
        } else if (!talkingDetected && _isTalking) {
          // End of a sleep talking event
          final endTime = DateTime.now();
          if (_talkStartTime != null) {
            final event = SleepTalkingEvent(
              startTime: _talkStartTime!,
              endTime: endTime,
              audioPath: _currentRecordingPath,
              intensity: energy,
            );

            // Add to in-memory list (would save to database in real implementation)
            _sleepTalkingEvents.add(event);

            print(
              'Sleep talking ended at: $endTime. Duration: ${endTime.difference(_talkStartTime!)}',
            );
          }
          _talkStartTime = null;
          setState(() => _isTalking = false);
        }
      });

      // Start recording to file and stream
      await _mRecorder!.startRecorder(
        toStream: _audioStreamController!.sink,
        codec: _codec,
        numChannels: 1,
        sampleRate: 44100,
        toFile: _currentRecordingPath,
      );

      setState(() {
        _isRecording = true;
      });
      print('Audio capture started to: $_currentRecordingPath');
    } catch (e) {
      print('Error starting audio capture: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  /// Rotate to a new audio segment file without stopping recording
  Future<void> _rotateAudioSegment() async {
    if (!_isRecording || _mRecorder == null) return;

    try {
      // Stop current recording
      await _stopAudioCapture();

      // Increment segment index
      _recordingSegmentIndex++;

      // Start new recording
      await _startAudioCapture();

      print('Rotated to new audio segment: $_currentRecordingPath');
    } catch (e) {
      print('Error rotating audio segment: $e');
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
        print('Audio capture stopped: $_currentRecordingPath');

        // Optionally process the completed audio file for more detailed analysis
        if (_currentRecordingPath != null &&
            File(_currentRecordingPath!).existsSync()) {
          print(
            'Audio file available for post-processing at: $_currentRecordingPath',
          );
          // In a real app, you might want to queue this file for further processing
          // _queueAudioFileForProcessing(_currentRecordingPath!);
        }
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
                  isTalking: _isTalking,
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
