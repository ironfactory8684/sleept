import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/providers/auth_provider.dart';
import 'package:sleept/services/supabase_service.dart';

import '../../constants/colors.dart';

class MyaccountSettingScreen extends ConsumerStatefulWidget {
  const MyaccountSettingScreen({super.key});

  @override
  ConsumerState<MyaccountSettingScreen> createState() => _MyaccountSettingScreenState();
}

class _MyaccountSettingScreenState extends ConsumerState<MyaccountSettingScreen> {
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize nickname from user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNickname();
    });
  }
  
  Future<void> _initNickname() async {
    final authState = ref.read(authProvider);
    if (authState is AuthStateAuthenticated) {
      final userData = await ref.read(userNicknameProvider.future);
      if (userData != null && userData['nickname'] != null) {
        setState(() {
          nameController.text = userData['nickname'];
        });
      }
    }
  }
  
  Future<void> _updateNickname() async {
    final authState = ref.read(authProvider);
    if (authState is AuthStateAuthenticated) {
      setState(() {
        isLoading = true;
      });
      
      try {
        await SupabaseService.instance.client
            .from('profiles')
            .update({'nickname': nameController.text})
            .eq('id', authState.user.id);
            
        // Invalidate provider to refresh MyPage
        ref.invalidate(userNicknameProvider);
        
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate update was successful
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('닉네임 업데이트에 실패했습니다: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        title: Center(
          child: Text(
            '내 계정',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: isLoading ? null : _updateNickname,
            child: isLoading 
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF724BFF)))
              : Text(
                '완료',
              style: TextStyle(
                color: const Color(0xFF724BFF) /* Primary-Color */,
                fontSize: 16,
                fontFamily: 'Min Sans',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                '닉네임',
                style: TextStyle(
                  color: Colors.white /* Primitive-Color-White */,
                  fontSize: 14,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 5,
                  textAlign: TextAlign.center,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: '닉네임 입력 (최대 5글자)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
            ],
          ),
        ),
      ),
    );
  }
}
