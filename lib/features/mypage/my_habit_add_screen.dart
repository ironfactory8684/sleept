import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/features/mypage/my_habit_add_set_screen.dart';

import '../../providers/habit_provider.dart';

class MyHabitAddScreen extends ConsumerStatefulWidget {
  const MyHabitAddScreen({super.key});

  @override
  ConsumerState<MyHabitAddScreen> createState() => _MyHabitAddScreenState();
}

class _MyHabitAddScreenState extends ConsumerState<MyHabitAddScreen> {

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        title: Text(
          '습관 리스트 만들기',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // Get the selected habits from the provider and navigate to the next screen
              final selectedHabits = ref.read(selectedHabitItemsNotifierProvider);
              if (selectedHabits.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('최소 하나 이상의 습관을 선택해주세요')),
                );
                return;
              }
              
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const MyHabitAddSetScreen(),
              ));
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '다음',
                style: TextStyle(
                  color: const Color(0xFF724BFF) /* Primary-Color */,
                  fontSize: 16,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: const Color(
                      0xFF2B2838,
                    ) /* Primitive-Color-gray-850 */,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Text(
                          '내가 40% 이상 진행했던 습관, 직접 입력으로 최대 10가지 습관 리스트를 만들 수 있어요. ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Min Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Stack(),
                      ),
                    ],
                  ),
                ),

              ],
            ),
            /// 선택된 아이템들이들어갈자리 !!
            Consumer(
              builder: (context, ref, child) {
                final selectedHabits = ref.watch(selectedHabitItemsNotifierProvider);
                final selectedHabitsNotifier = ref.read(selectedHabitItemsNotifierProvider.notifier);
                if (selectedHabits.isEmpty) {
                  return Container( // Show a placeholder if no habits are selected
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: Text(
                      '선택된 습관이 없습니다. 아래에서 추가해주세요.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: selectedHabits.length,
                    itemBuilder: (ctx, idx) {
                      final category = selectedHabits[idx];
                      return widgetCategoryItem(category, true, selectedHabitsNotifier, context);
                    },
                  ),
                );
              },
            ),

            Container(
              width: 375,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF181520) /* Primitive-Color-Background */,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 12,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            // No longer watch here, will be watched inside Consumer in dialog

                            // Show dialog with available habits
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF242030),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        topRight: Radius.circular(18),
                                      ),
                                    ),
                                    child: SafeArea(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 56,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(dialogContext); // Use dialogContext
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.all(6),
                                                    padding: EdgeInsets.all(10),
                                                    child: SvgPicture.asset('assets/svg/Icon_closed.svg'),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
                                                  child: Text('습관 선택', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Pretendard', fontWeight: FontWeight.w700, height: 1.50)),
                                                ),
                                                // The '추가' text seems to be a label, if it's a button, its onTap needs to be defined
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
                                                  child: Text('추가', style: TextStyle(color: const Color(0xFF724BFF), fontSize: 16, fontFamily: 'Min Sans', fontWeight: FontWeight.w700, height: 1.50)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                                              // Use Consumer to rebuild the list when selected items change
                                              child: Consumer(
                                                builder: (context, ref, child) {
                                                  final allHabitsAsync = ref.watch(habitAllItemsProvider);
                                                  final selectedHabits = ref.watch(selectedHabitItemsNotifierProvider);
                                                  final selectedHabitsNotifier = ref.read(selectedHabitItemsNotifierProvider.notifier);

                                                  return allHabitsAsync.when(
                                                    data: (allHabits) {
                                                      // Filter out already selected habits
                                                      final availableHabits = allHabits.where((habit) => 
                                                        !selectedHabits.any((selected) => selected['id'] == habit['id'])
                                                      ).toList();

                                                      if (availableHabits.isEmpty) {
                                                         return Center(
                                                           child: Text(
                                                             '모든 습관이 선택되었거나 추가할 습관이 없습니다.', 
                                                             style: TextStyle(color: Colors.grey, fontSize: 14),
                                                             textAlign: TextAlign.center,
                                                            ),
                                                         );
                                                      }

                                                      return ListView.builder(
                                                        itemCount: availableHabits.length,
                                                        itemBuilder: (ctx, idx) {
                                                          final category = availableHabits[idx];
                                                          // Pass false for isCurrentlySelected as these are available items
                                                          return widgetCategoryItem(category, false, selectedHabitsNotifier, dialogContext);
                                                        },
                                                      );
                                                    },
                                                    loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                                    error: (error, stack) => Center(child: Text('데이터 로딩 실패: $error', style: TextStyle(color: Colors.white))),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );  
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(
                                  0xFF7E7893,
                                ) /* Primitive-Color-gray-600 */,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/Icon_plus_circle.svg',
                              ),
                              Text(
                                '습관 선택',
                                style: TextStyle(
                                  color:
                                  Colors.white /* Primitive-Color-White */,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(
                                0xFF7E7893,
                              ) /* Primitive-Color-gray-600 */,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            SvgPicture.asset('assets/svg/Icon_pencil.svg'),
                            Text(
                              '직접 입력',
                              style: TextStyle(
                                color: Colors.white /* Primitive-Color-White */,
                                fontSize: 14,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '0 / 10개',
                    style: TextStyle(
                      color: const Color(
                        0xFFB8B6C0,
                      ) /* Primitive-Color-gray-300 */,
                      fontSize: 14,
                      fontFamily: 'Min Sans',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetCategoryItem(Map<String, dynamic> category, bool isCurrentlySelected, SelectedHabitItemsNotifier notifier, BuildContext itemContext){
    bool isCheck = false;
    return GestureDetector(
      onTap: (){
      if (isCurrentlySelected) {
        notifier.removeHabit(category['id']);
      } else {
        // Check if the maximum number of selected habits (e.g., 10) has been reached
        // final selectedHabits = ref.read(selectedHabitItemsNotifierProvider); // Cannot use ref directly here
        // For now, let's assume SelectedHabitItemsNotifier handles max limit if needed, or do it in UI before calling addHabit
        notifier.addHabit(category);
        // Optionally, pop the dialog if an item is added from it
        // Navigator.pop(itemContext); 
      }
    },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: const Color(0xFF2B2838)))
        ),
        width: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: ShapeDecoration(
                            color: const Color(0x23FFB35A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 3,
                            children: [
                              Text(
                                category['habit_categories']['name'],
                                style: TextStyle(
                                  color: const Color(0xFFFFC887) /* Primitive-Color-Sub-Color-Orange */,
                                  fontSize: 13,
                                  fontFamily: 'Min Sans',
                                  fontWeight: FontWeight.w600,
                                  height: 1.31,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          category['title'],
                          style: TextStyle(
                            color: Colors.white /* Primitive-Color-White */,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    category['description'],
                    style: TextStyle(
                      color: const Color(0xFFCECDD4) /* Primitive-Color-gray-200 */,
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(isCurrentlySelected ? 'assets/svg/Icon_check_fill.svg' : 'assets/svg/Icon_plus_circle.svg')
          ],
        ),
      ),
    );
  }
}
