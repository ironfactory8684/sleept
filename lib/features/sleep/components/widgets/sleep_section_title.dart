import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

class SleepSectionTitle extends StatelessWidget {
  const SleepSectionTitle(this.title , {super.key, this.topPadding =36});

  final String title;
  final double? topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 16.0,
          top: topPadding!
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textWhite,
        ),
      ),
    );
  }
}
