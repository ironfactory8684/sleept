import 'package:flutter/material.dart';

class HabitItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool initialIsChecked; // 선택 상태를 받을 변수
  final ValueChanged<bool?>? onChanged; // 선택 상태 변경 시 호출될 콜백

  const HabitItem({
    Key? key,
    required this.title,
    required this.subtitle,
    this.initialIsChecked = false, // 기본값은 false
    this.onChanged,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: initialIsChecked? Border.all(color: Color(0xFF724BFF)) : null,
        color: Color(0xFF242030), // 아이템 배경색 (예시)
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: initialIsChecked,
            onChanged: (bool? newValue) {

                onChanged!(newValue);
            },
            activeColor: Color(0xFF724BFF), // 체크박스 활성 색상 (예시)
            checkColor: Colors.black, // 체크 표시 색상
            side: BorderSide(color: Colors.grey[600]!), // 체크박스 테두리 색상
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}