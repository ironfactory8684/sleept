import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/components/habit_item.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';
import 'package:sleept/providers/habit_provider.dart';
import 'package:sleept/providers/auth_provider.dart';

import 'components/habit_dialog.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String type;

  const HabitDetailScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  List<String> _exerciseList = [];
  Map<String, dynamic> habitItem = {};
  String? selectItem;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 데이터는 build 메소드에서 Riverpod을 통해 가져옵니다.
  }


  void _showHabitDialog() {
    final authState = ref.read(authProvider);
    final bool isLogin = authState is AuthStateAuthenticated;
    
    if (!isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 후 이용 가능합니다.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    if (selectItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 습관을 선택해주세요.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HabitDialog();
      },
    ).then((result) async {
      if (result != null && result is Map<String, DateTime>) {
        final start = result['startDate']!;
        final end = result['endDate']!;

        var diffDay = end.difference(start);
        final completed = end.isBefore(DateTime.now());
        
        try {
          // Supabase에 습관 저장
          await HabitSupabaseService.instance.createUserHabit(
            type: widget.type,
            selectedHabit: selectItem!,
            startDate: start,
            endDate: end,
            duration: diffDay.inDays,
            isCompleted: completed,
          );
          
          // 사용자 습관 목록 갱신 (캐시 무효화)
          ref.invalidate(userHabitsProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('습관이 생성되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            selectItem = null;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('습관 생성에 실패했습니다: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });  
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod을 사용해 습관 카테고리 데이터 가져오기
    final habitCategoriesAsync = ref.watch(habitCategoriesProvider);
    
    return habitCategoriesAsync.when(
      data: (categories) {
        // 해당 카테고리 데이터 가져오기
        habitItem = categories[widget.type] ?? {};
        
        // 아이템 리스트 업데이트
        if (habitItem.containsKey('items')) {
          _exerciseList = (habitItem['items'] as Map<String, dynamic>).keys.toList();
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFF181520),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                snap: false,
                backgroundColor: Colors.grey[900],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/images/${habitItem['image']}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(habitItem['iconPath']),
                              const SizedBox(width: 8),
                              Text(
                                widget.type,
                                style: TextStyle(
                                  color: Colors.yellow[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            habitItem['subtitle'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            habitItem['description'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 습관 아이템 리스트
                    if (_exerciseList.isNotEmpty)
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _exerciseList.length,
                        itemBuilder: (context, index) {
                          final itemKey = _exerciseList[index];
                          final item = (habitItem['items'] as Map<String, dynamic>)[itemKey];
                          
                          return HabitItem(
                            title: item['title'],
                            subtitle: item['descript'],
                            initialIsChecked: item['title'] == selectItem,
                            onChanged: (bool? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectItem = newValue ? item['title'] : null;
                                });
                              }
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _showHabitDialog,
              child: const Text(
                '내 습관으로 생성하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFF181520),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF181520),
        body: Center(
          child: Text(
            '데이터를 불러오는데 실패했습니다: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
