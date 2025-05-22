import 'package:flutter/cupertino.dart';
import '../../../../utils/app_colors.dart';

class SleepHeaderText extends StatelessWidget {
  final String text;

  const SleepHeaderText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        height: 1.5,
      ),
    );
  }
}
