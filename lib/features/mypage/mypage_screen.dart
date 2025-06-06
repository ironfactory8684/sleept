import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/features/mypage/myaccount_setting_screen.dart';
import 'package:sleept/features/sign/login_screen.dart';
import 'package:sleept/providers/auth_provider.dart';
import 'package:sleept/services/supabase_service.dart';

import '../../constants/colors.dart';
import 'library_screen.dart';
import 'my_habit_list_screen.dart';

class MypageScreen extends ConsumerWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final bool isLogin = authState is AuthStateAuthenticated;
    final myInfo = ref.watch(userNicknameProvider);
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLogin
                  ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 38,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          myInfo.when(
                            data:
                                (myInfo) =>
                                    "${myInfo?['nickname']}님, 활기찬 하루 되세요",
                            loading: () => '로딩 중...',
                            error: (_, __) => '사용자님',
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Min Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '슬리핏과 함께한 지 ',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFCECDD4,
                                    ) /* Primitive-Color-gray-200 */,
                                    fontSize: 14,
                                    fontFamily: 'Min Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${myInfo.when(data: (myInfo) => "${myInfo?['days']}", loading: () => '로딩 중...', error: (_, __) => '0')}일',
                                  style: TextStyle(
                                    color: const Color(0xFF7A56FF),
                                    fontSize: 14,
                                    fontFamily: 'Min Sans',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                                TextSpan(
                                  text: '째✨',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFCECDD4,
                                    ) /* Primitive-Color-gray-200 */,
                                    fontSize: 14,
                                    fontFamily: 'Min Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 38),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(
                        0xFF2B2838,
                      ) /* Primitive-Color-gray-850 */,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Adding spacing through SizedBox between children
                      children: [
                        Text(
                          '로그인하고 수면 데이터를 직접 보고\n음악, 습관 등을 실행해보세요.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Min Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9.5,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(
                                0xFF724BFF,
                              ) /* Primary-Color */,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '로그인 하러 가기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LibraryScreen(),
                              ),
                            );
                          } else {
                            _showLoginRequiredDialog(context, '라이브러리');
                          }
                        },
                        child: Container(
                          height: 137,
                          padding: EdgeInsets.all(18),
                          alignment: Alignment.bottomCenter,
                          decoration: ShapeDecoration(
                            image: DecorationImage(image: AssetImage('assets/images/sleept_library.png')),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '라이브러리',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  MyHabitListScreen(),
                              ),
                            );
                            // Navigate to Habit List screen
                          } else {
                            _showLoginRequiredDialog(context, '습관 리스트');
                          }
                        },
                        child: Container(
                          height: 137,
                          padding: EdgeInsets.all(18),
                          alignment: Alignment.bottomCenter,
                          decoration: ShapeDecoration(
                            image: DecorationImage(image: AssetImage('assets/images/sleept_habit.png')),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '습관 리스트',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Text(
                      '설정',
                      style: TextStyle(
                        color: const Color(
                          0xFFAAA8B4,
                        ) /* Primitive-Color-gray-400 */,
                        fontSize: 13,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        color: const Color(
                          0xFF242030,
                        ) /* Primitive-Color-gray-900 */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        // Column doesn't have spacing property
                        // Adding spacing through SizedBox between children
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isLogin) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                        MyaccountSettingScreen(),
                                  ),
                                );
                              } else {
                                _showLoginRequiredDialog(context, '내 계정');
                              }
                            },
                            child: Text(
                              '내 계정',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          ),
                          Text(
                            '건강 앱 데이터 연동 허용',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '고객센터',
                      style: TextStyle(
                        color: const Color(
                          0xFFAAA8B4,
                        ) /* Primitive-Color-gray-400 */,
                        fontSize: 13,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        color: const Color(
                          0xFF242030,
                        ) /* Primitive-Color-gray-900 */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Text(
                            '사용 피드백 보내기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                          Text(
                            '1:1 문의하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                          Text(
                            '약관 및 개인정보 처리 동의',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Min Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    isLogin
                        ? GestureDetector(
                      onTap: () => _handleLogout(context, ref),
                      child: Text(
                        '로그아웃',
                        style: TextStyle(
                          color: const Color(
                            0xFF7E7893,
                          ) /* Primitive-Color-gray-600 */,
                          fontSize: 14,
                          fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: const Color(
                            0xFF514D60,
                          ) /* Primitive-Color-gray-700 */,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '로그인이 필요합니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Min Sans',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle logout process
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF2B2838),
                title: Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Min Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: Text(
                  '정말 로그아웃 하시겠습니까?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Min Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed) {
      // 로그아웃 처리
      await SupabaseService.instance.signOut();
      // Provider 업데이트는 자동으로 처리됨 (auth state 변경 시 notifier에서 자동 감지)

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그아웃 되었습니다')));
    }
  }

  /// Show a dialog that login is required to access this feature
  void _showLoginRequiredDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B2838),
            title: Text(
              '로그인이 필요합니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Min Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              '$featureName에 접근하려면 로그인이 필요합니다.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Min Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '취소',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Min Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  '로그인',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Min Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
