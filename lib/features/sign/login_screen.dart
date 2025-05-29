import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/services/supabase_service.dart';
import 'package:sleept/features/init/home_navigation.dart';
import 'package:sleept/features/sign/welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  // We don't need _obscurePassword as we're not showing a password field
  // bool _obscurePassword = true;
  String? _errorMessage;

  final SupabaseService _supabaseService = SupabaseService.instance;

  @override
  void dispose() {
    // ⭐️ 중요: 리스너 해제
    _supabaseService.isAuthenticated.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ⭐️ 중요: isAuthenticated ValueNotifier를 리스닝
    _supabaseService.isAuthenticated.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (_supabaseService.isAuthenticated.value) {
      // 로그인 성공 시 홈 페이지로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeNavigation()),
        );
      }
    }
  }

  Future<void> _handleKaKaoLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.instance.signInWithKakao();
      
      // Check if this is a new user who needs to set their nickname
      if (mounted) {
        final isNewUser = await SupabaseService.instance.isNewUser();
        
        if (isNewUser) {
          // New user - redirect to welcome screen to set nickname
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()), 
            (route) => false
          );
        } else {
          // Existing user - redirect to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeNavigation()), 
            (route) => false
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '로그인에 실패했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.instance.signInWithApple();
      
      // Check if this is a new user who needs to set their nickname
      if (mounted) {
        final isNewUser = await SupabaseService.instance.isNewUser();
        
        if (isNewUser) {
          // New user - redirect to welcome screen to set nickname
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()), 
            (route) => false
          );
        } else {
          // Existing user - redirect to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeNavigation()), 
            (route) => false
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = '로그인에 실패했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF13121F), // 상단 색상
              Color(0xFF13121F), // 중간 색상
              Color(0xFF2E235B), // 하단 색상
            ],
            stops: [0.0, 0.5, 0.707],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: SvgPicture.asset('assets/svg/login.svg')),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Spacer(),
                    // Show error message if there is one
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Show loading indicator if loading
                    if (_isLoading)
                      CircularProgressIndicator(color: Colors.white),

                    // Social login buttons
                    GestureDetector(
                      onTap: _handleKaKaoLogin,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFEE500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 9,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: SvgPicture.asset('assets/svg/kakao.svg'),
                            ),
                            Text(
                              '카카오 로그인',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 56,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 9,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: SvgPicture.asset('assets/svg/google.svg'),
                          ),
                          Text(
                            'Google 로그인',
                            style: TextStyle(
                              color: const Color(0xFF282828),
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Login button
                    GestureDetector(
                      onTap: _handleAppleLogin,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF050708),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 9,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: SvgPicture.asset('assets/svg/apple.svg'),
                            ),
                            Text(
                              'Apple 로그인',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      '먼저 둘러보기',
                      style: TextStyle(
                        color: const Color(
                          0xFFDEDDE2,
                        ) /* Primitive-Color-gray-100 */,
                        fontSize: 14,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
