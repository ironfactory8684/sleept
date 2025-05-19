import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BuildTrackingBackground extends StatelessWidget {
  const BuildTrackingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          width: MediaQuery.of(context).size.width,
          height: 322,
          child: Stack(
            children: [
              // 구름 이미지들
              Positioned(
                top: 0,
                left: -55,
                child: SvgPicture.asset(
                  'assets/images/cloud_1.svg', // 경로 확인!
                  width: 239,
                ),
              ),
              Positioned(
                top: 139,
                right: -40,
                child: SvgPicture.asset(
                  'assets/images/cloud_2.svg', // 경로 확인!
                  width: 203,
                ),
              ),
              Positioned(
                bottom: 0,
                left: -45,
                child: SvgPicture.asset(
                  'assets/images/cloud_3.svg', // 경로 확인!
                  width: 149,
                ),
              ),
              // 달 (경로 확인 필요)
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/moon_tracking.svg', // 경로 확인!
                        width: 202,
                        height: 209,
                      ),
                    ),
                  ],
                ),
              ),

              // // 별 효과들 (위치 및 색상 조정 가능)
              Positioned(
                top: 28,
                left: 80,
                child: SvgPicture.asset(
                  'assets/images/icon_star_1.svg', // 경로 확인!
                  width: 21,
                ),
              ),
              Positioned(
                bottom: 21,
                right: 48,
                child: SvgPicture.asset(
                  'assets/images/icon_star_2.svg', // 경로 확인!
                  width: 59,
                ),
              ),
              Positioned(
                top: 103,
                right: 180,
                child: SvgPicture.asset(
                  'assets/images/icon_star_3.svg', // 경로 확인!
                  width: 26,
                ),
              ),
              Positioned(
                top: 60,
                right: 130,
                child: SvgPicture.asset(
                  'assets/images/icon_star_4.svg', // 경로 확인!
                  width: 26,
                ),
              ),
              Positioned(
                bottom: 60,
                left: 130,
                child: SvgPicture.asset(
                  'assets/images/icon_star_5.svg', // 경로 확인!
                  width: 16,
                ),
              ),
            ],
          ),
        ),

        //
        // // 선 효과 (경로 확인 필요)
        // Positioned(
        //   top: 300, // 위치 조정 가능
        //   left: 0,
        //   right: 0,
        //   child: SvgPicture.asset(
        //     'assets/images/vector_line.svg', // 경로 확인!
        //     width: MediaQuery.of(context).size.width,
        //     fit: BoxFit.cover, // 화면 너비에 맞게 조절
        //   ),
        // ),
        //
        //
        //
      ],
    );
  }
}
