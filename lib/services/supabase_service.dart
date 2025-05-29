import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sleept/models/sleep_session.dart';
import 'package:sleept/models/snoring_event.dart';
import 'package:sleept/models/sleep_talking_event.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' hide User;

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
    final userId = client.auth.currentUser?.id;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Save session data
    await client.from('sleep_sessions').insert({
      'id': sessionId,
      'user_id': userId,
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

  Future<AuthResponse> signInWithKakao() async {
    try {
      final rawNonce = client.auth.generateRawNonce();
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken? token;

      if (isInstalled) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print(token);
        } catch (error) {
          // 카카오톡에 로그인 실패하면 웹 계정 로그인
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡 미설치: 웹 계정 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }


      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.accessToken,
        nonce: rawNonce,
      );

    } on AuthException catch (e) {
      print('SupabaseService: 카카오 로그인 에러: ${e.message}');
      // UI 레이어에서 에러 메시지를 SnackBar 등으로 표시할 수 있도록 Throws
      rethrow;
    } catch (e) {
      print('SupabaseService: 예기치 않은 오류 발생: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithApple() async {
    try {

      final rawNonce = client.auth.generateRawNonce();
      // Hash the generated nonce using SHA-256
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      // Show Apple sign-in widget and request authentication from the user
      // Return authentication information including specified scopes and nonce
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException(
          'Could not find ID Token from generated credential.',
        );
      }

      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

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

  /// Update user profile with nickname
  Future<void> updateUserProfile(String nickname) async {
    // Get current user ID
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Update user metadata in the profiles table
    await client.from('profiles').upsert({
      'id': userId,
      'nickname': nickname,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  /// Check if user profile exists (to determine if user is new)
  Future<bool> isNewUser() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await client
        .from('profiles')
        .select('nickname')
        .eq('id', userId)
        .maybeSingle();
    
    // If no profile found or nickname is empty, consider as new user
    return response == null || (response['nickname'] == null || response['nickname'] == '');
  }

  /// Check if user is authenticated
  bool get isUserAuthenticated => isAuthenticated.value;

  /// Get current user
  User? get user => currentUser.value;

  /// Get sleep sessions for the current user
  /// If [date] is provided, returns sessions for that specific date
  Future<List<SleepSession>> getSleepSessions({DateTime? date}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Build query for sleep sessions
    var query = client.from('sleep_sessions')
        .select('''
          *,
          snoring_events(*),
          sleep_talking_events(*)
        ''')
        .eq('user_id', userId)
        .order('start_time', ascending: false);
    
    // Filter by date if specified
    if (date != null) {
      // Will do date filtering in memory after fetching data
      // as the Supabase filter methods are having compatibility issues
    }
    
    final response = await query;
    
    // Convert response to SleepSession objects
    List<SleepSession> sessions = response.map((sessionData) {
      // Extract and convert snoring events
      final snoringEvents = (sessionData['snoring_events'] as List).map((e) {
        return SnoringEvent(
          startTime: DateTime.parse(e['start_time']),
          endTime: DateTime.parse(e['end_time']),
        );
      }).toList();
      
      // Extract and convert sleep talking events
      final sleepTalkingEvents = (sessionData['sleep_talking_events'] as List).map((e) {
        return SleepTalkingEvent(
          startTime: DateTime.parse(e['start_time']),
          endTime: DateTime.parse(e['end_time']),
          transcription: e['transcript'] ?? '',
        );
      }).toList();
      
      // Create SleepSession object
      return SleepSession(
        startTime: DateTime.parse(sessionData['start_time']),
        endTime: DateTime.parse(sessionData['end_time']),
        sessionDirectory: sessionData['session_directory'],
        snoringEvents: snoringEvents,
        sleepTalkingEvents: sleepTalkingEvents,
        sleepScore: sessionData['sleep_score'],
        sleepStages: sessionData['sleep_stages'],
      );
    }).toList();
    
    // If date filter is specified, filter the sessions in memory
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      sessions = sessions.where((session) {
        return session.startTime.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
               session.startTime.isBefore(endOfDay);
      }).toList();
    }
    
    return sessions;
  }

  /// Get sleep session by ID
  Future<SleepSession?> getSleepSessionById(String sessionId) async {
    final response = await client.from('sleep_sessions')
        .select('''
          *,
          snoring_events(*),
          sleep_talking_events(*)
        ''')
        .eq('id', sessionId)
        .maybeSingle();
    
    if (response == null) {
      return null;
    }
    
    // Extract and convert snoring events
    final snoringEvents = (response['snoring_events'] as List).map((e) {
      return SnoringEvent(
        startTime: DateTime.parse(e['start_time']),
        endTime: DateTime.parse(e['end_time']),
      );
    }).toList();
    
    // Extract and convert sleep talking events
    final sleepTalkingEvents = (response['sleep_talking_events'] as List).map((e) {
      return SleepTalkingEvent(
        startTime: DateTime.parse(e['start_time']),
        endTime: DateTime.parse(e['end_time']),
        transcription: e['transcript'] ?? '',
      );
    }).toList();
    
    // Create SleepSession object
    return SleepSession(
      startTime: DateTime.parse(response['start_time']),
      endTime: DateTime.parse(response['end_time']),
      sessionDirectory: response['session_directory'],
      snoringEvents: snoringEvents,
      sleepTalkingEvents: sleepTalkingEvents,
      sleepScore: response['sleep_score'],
      sleepStages: response['sleep_stages'],
    );
  }
}
