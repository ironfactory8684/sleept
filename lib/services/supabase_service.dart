import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleept/models/sleep_session.dart';
import 'package:sleept/models/snoring_event.dart';
import 'package:sleept/models/sleep_talking_event.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Service class for Supabase operations
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  final uuid = const Uuid();

  // Authentication state
  ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
  ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  SupabaseService._internal();

  /// Initialize Supabase
  Future<void> initialize() async {
    // Get credentials from .env file
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception('Supabase credentials not found in .env file');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Check if user is already logged in
    final session = client.auth.currentSession;
    if (session != null) {
      isAuthenticated.value = true;
      currentUser.value = session.user;
    }

    // Listen for auth state changes
    client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          isAuthenticated.value = true;
          currentUser.value = session?.user;
          break;
        case AuthChangeEvent.signedOut:
          isAuthenticated.value = false;
          currentUser.value = null;
          break;
        default:
          break;
      }
    });
  }

  /// Get Supabase client
  SupabaseClient get client => Supabase.instance.client;

  /// Save sleep session to Supabase
  Future<String> saveSleepSession(SleepSession session) async {
    final sessionId = uuid.v4();

    // Save session data
    await client.from('sleep_sessions').insert({
      'id': sessionId,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime.toIso8601String(),
      'session_directory': session.sessionDirectory,
      'sleep_score': session.sleepScore,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Save snoring events
    for (var event in session.snoringEvents) {
      await saveSnoringEvent(event, sessionId);
    }

    // Save sleep talking events
    for (var event in session.sleepTalkingEvents) {
      await saveSleepTalkingEvent(event, sessionId);
    }

    return sessionId;
  }

  /// Save snoring event to Supabase
  Future<void> saveSnoringEvent(SnoringEvent event, String sessionId) async {
    await client.from('snoring_events').insert({
      'id': uuid.v4(),
      'session_id': sessionId,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'duration_seconds': event.duration.inSeconds,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Save sleep talking event to Supabase
  Future<void> saveSleepTalkingEvent(
    SleepTalkingEvent event,
    String sessionId,
  ) async {
    await client.from('sleep_talking_events').insert({
      'id': uuid.v4(),
      'session_id': sessionId,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'duration_seconds': event.duration.inSeconds,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signInWithKakao() async {
    try {
      var result = await client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: dotenv.env['SUPABASE_URL'],
        // redirectTo: 'sleeptapp://callback',
         authScreenLaunchMode: LaunchMode.inAppWebView,
      );
      print(result);
    } on AuthException catch (e) {
      print('SupabaseService: 카카오 로그인 에러: ${e.message}');
      // UI 레이어에서 에러 메시지를 SnackBar 등으로 표시할 수 있도록 Throws
      rethrow;
    } catch (e) {
      print('SupabaseService: 예기치 않은 오류 발생: $e');
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    try {
      var result = await client.auth.signInWithOAuth(
        OAuthProvider.apple,
        // redirectTo:  'https://skrydutblxnoscfwtgzi.supabase.co/auth/v1/callback',
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );
      print(result);
    } on AuthException catch (e) {
      print('SupabaseService: 애플 로그인 에러: ${e.message}');
      // UI 레이어에서 에러 메시지를 SnackBar 등으로 표시할 수 있도록 Throws
      rethrow;
    } catch (e) {
      print('SupabaseService: 예기치 않은 오류 발생: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    final response = await client.auth.signUp(email: email, password: password);
    return response;
  }

  /// Sign out current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Check if user is authenticated
  bool get isUserAuthenticated => isAuthenticated.value;

  /// Get current user
  User? get user => currentUser.value;
}
