import 'package:flutter/material.dart';
import 'package:sleept/services/supabase_service.dart';
import 'package:sleept/features/home/home_screen.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Animation variables
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _formFadeInAnimation;

  bool _showWelcomeText = true;
  bool _showInputForm = false;
  bool _moveTextUp = false;
  String _welcomeText = '환영합니다';

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create animations
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _formFadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start initial animation
    _animationController.forward();

    // Schedule text change and form display
    Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        _showWelcomeText = false;
      });

      _animationController.reset();
      _animationController.forward();

      Timer(const Duration(milliseconds: 400), () {
        setState(() {
          _welcomeText = '앞으로 당신을\n어떤 이름으로 불러드릴까요?';
          _showWelcomeText = true;
        });
      });

      Timer(const Duration(milliseconds: 800), () {
        setState(() {
          _showInputForm = true;
          _moveTextUp = true;
        });
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveNicknameAndNavigate() async {
    final nickname = nameController.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _errorMessage = '닉네임을 입력해주세요';
      });
      return;
    }

    if (nickname.length > 5) {
      setState(() {
        _errorMessage = '닉네임은 최대 5글자까지 가능합니다';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Update the user's profile with the nickname
      await SupabaseService.instance.updateUserProfile(nickname);

      if (mounted) {
        // Navigate to home screen and clear the navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '닉네임 저장에 실패했습니다. 다시 시도해주세요.';
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
      backgroundColor: Color(0xFF181520),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // Welcome text with animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  top:
                      _moveTextUp
                          ? MediaQuery.of(context).size.height / 2 -
                              68 -
                              100 // 28px above text field
                          : MediaQuery.of(context).size.height / 2 - 100,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity:
                        _showWelcomeText
                            ? _fadeInAnimation.value
                            : _fadeOutAnimation.value,
                    child: Text(
                      _welcomeText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Input form (only visible after animation)
            if (_showInputForm)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _formFadeInAnimation.value,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          maxLength: 5,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '닉네임 입력 (최대 5글자)',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            counterStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Error message (if any)
            if (_showInputForm && _errorMessage != null)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _formFadeInAnimation.value,
                    child: Positioned(
                      top: MediaQuery.of(context).size.height / 2 + 50,
                      left: 40,
                      right: 40,
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),

            // Bottom button (only visible after animation)
            if (_showInputForm)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _formFadeInAnimation.value,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _saveNicknameAndNavigate,
                        child: Container(
                          width: 87,
                          height: 87,
                          margin: const EdgeInsets.only(bottom: 46),
                          alignment: Alignment.center,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF3F298C),
                            shape: OvalBorder(),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    '완료',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Min Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
