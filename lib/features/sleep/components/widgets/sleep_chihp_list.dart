import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
class SleepChihpList extends StatefulWidget {
  const SleepChihpList({super.key});

  @override
  State<SleepChihpList> createState() => _SleepChihpListState();
}

class _SleepChihpListState extends State<SleepChihpList> {
  final List<String> chips = ['전체', '팟캐스트', '명상', 'ASMR', '스트레칭'];
  String selectedChip = '전체';
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      height: 60, // 피그마 Frame 14 높이 (padding 포함)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10), // 피그마 gap
        itemBuilder: (context, index) {
          final chipLabel = chips[index];
          final isSelected = selectedChip == chipLabel;
          return ChipTheme(
            data: ChipTheme.of(context).copyWith(side: BorderSide.none),
            child: ChoiceChip(

              label: Text(chipLabel),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedChip = chipLabel;
                  });
                }
              },
              backgroundColor: AppColors.chipBackground,
              selectedColor: AppColors.chipSelectedBackground,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.textWhite : AppColors.textGray,
              ), // 피그마 padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // 피그마 borderRadius
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
