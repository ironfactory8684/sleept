import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/providers/shared_habit_provider.dart';

class SharedHabitDetailScreen extends ConsumerWidget {
  final String sharedHabitId;

  const SharedHabitDetailScreen({
    Key? key,
    required this.sharedHabitId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedHabitAsync = ref.watch(sharedHabitListByIdProvider(sharedHabitId));

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        title: const Text(
          '습관 리스트',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sharedHabitAsync.when(
        data: (sharedHabit) {
          if (sharedHabit == null) {
            return const Center(child: Text('습관 리스트를 찾을 수 없습니다.', style: TextStyle(color: Colors.white)));
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with image if available
                if (sharedHabit.imageUrl?.isNotEmpty == true)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: sharedHabit.imageUrl!.startsWith('http')
                            ? NetworkImage(sharedHabit.imageUrl!) as ImageProvider
                            : AssetImage("assets/images/habit_placeholder.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFF242030),
                    child: const Center(
                      child: Icon(
                        Icons.format_list_bulleted,
                        size: 64,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                
                // Title and description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sharedHabit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (sharedHabit.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          sharedHabit.description!,
                          style: const TextStyle(
                            color: Color(0xFFCECDD4),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      const Text(
                        '습관 목록',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // List of habits
                      ...List.generate(
                        sharedHabit.habits.length,
                        (index) => _buildHabitItem(sharedHabit.habits[index], index),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            '오류가 발생했습니다: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItem(Map<String, dynamic> habit, int index) {
    final title = habit['title'] ?? habit['name'] ?? '습관 ${index + 1}';
    final description = habit['description'] ?? '';
    final type = habit['type'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242030),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFCECDD4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (type.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
