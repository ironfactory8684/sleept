import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the current authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider to get the current user's nickname
final userNicknameProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (authState is AuthStateAuthenticated) {
    try {
      // Fetch the user profile from Supabase
      final response = await SupabaseService.instance.client
          .from('profiles')
          .select('nickname')
          .eq('id', authState.user.id)
          .single();
      
      return response['nickname'] as String?;
    } catch (e) {
      return null;
    }
  }
  
  return null;
});

/// Authentication state class
abstract class AuthState {
  const AuthState();
}

/// State when the user is not authenticated
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// State when the user is authenticated
class AuthStateAuthenticated extends AuthState {
  final User user;
  
  const AuthStateAuthenticated(this.user);
}

/// Notifier for authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(
    SupabaseService.instance.isUserAuthenticated 
      ? AuthStateAuthenticated(SupabaseService.instance.user!)
      : const AuthStateUnauthenticated()
  ) {
    // Listen to auth state changes
    SupabaseService.instance.isAuthenticated.addListener(_onAuthStateChanged);
  }
  
  void _onAuthStateChanged() {
    if (SupabaseService.instance.isUserAuthenticated && SupabaseService.instance.user != null) {
      state = AuthStateAuthenticated(SupabaseService.instance.user!);
    } else {
      state = const AuthStateUnauthenticated();
    }
  }
  
  @override
  void dispose() {
    SupabaseService.instance.isAuthenticated.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
