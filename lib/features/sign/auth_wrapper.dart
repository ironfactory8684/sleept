import 'package:flutter/material.dart';
import 'package:sleept/features/init/home_navigation.dart';
import 'package:sleept/features/sign/login_screen.dart';
import 'package:sleept/services/supabase_service.dart';

/// AuthWrapper watches authentication state and shows the appropriate screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SupabaseService.instance.isAuthenticated,
      builder: (context, isAuthenticated, _) {
        if (isAuthenticated) {
          return const HomeNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
