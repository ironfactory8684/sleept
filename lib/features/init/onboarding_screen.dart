import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/buttons/step_progress_button.dart';
import '../sign/auth_wrapper.dart'; // For pi

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;

  final List titles = [
    '나의 수면 상태를\n구체적으로 알 수 있어요',
    '편안하게 그리고 천천히\n잠에 빠져보세요',
    '건강한 습관을 만들고\n달성 카드를 획득해요',
  ];
  final List subTitles = [
    '내가 왜 잠을 제대로 잘 수 없었는지\n다양한 정보와 설명을 제공해요',
    '수면 트래킹을 통해 사용자에 최적화 된\n수면 콘텐츠와 습관을 추천해드려요',
    '완성보다는 행동으로 실행한 것에 의미를 두고\n멋진 그래픽으로 이루어진 달성카드를 받아요 ',
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Define sizes for the inner circle and the border thickness

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
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SvgPicture.asset(
                  'assets/svg/onboarding_${step + 1}.svg',
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Text(
                      titles[step],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  const SizedBox(height: 22),
                    Text(
                      subTitles[step],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(
                          0xFFAAA8B4,
                        ) /* Primitive-Color-gray-400 */,
                        fontSize: 16,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  const SizedBox(height: 80),
                  StepProgressButton(
                    totalSteps: 2,
                    currentStep: step,
                    onPressed: () async {
                      // This onTap logic is from your previous conversation.
                      // You can modify it to cycle through different button states if needed.
                      if (step < 2) {
                        step++;
                      } else {
                        final pref = await SharedPreferences.getInstance();
                        await pref.setBool('isInit', true);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AuthWrapper()),
                          ModalRoute.withName('/'),
                        );
                      }
                      setState(() {
                        // Rebuilds the widget to reflect changes in 'step'
                        // (though for this specific image, the border is static)
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

