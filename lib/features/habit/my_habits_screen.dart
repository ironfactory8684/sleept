import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/model/habit_model.dart';
import 'package:sleept/features/habit/model/shared_habit_list_model.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';
import 'package:sleept/features/habit/shared_habit_detail_screen.dart';
import 'package:sleept/providers/auth_provider.dart';
import 'package:sleept/providers/habit_provider.dart';
import 'package:sleept/providers/shared_habit_provider.dart';

class MyHabitsScreen extends ConsumerStatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  ConsumerState<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends ConsumerState<MyHabitsScreen> with WidgetsBindingObserver {
  // 화면 포커스를 감지하는 FocusNode
  late FocusNode _screenFocusNode;

  @override
  void initState() {
    super.initState();
    // 화면이 활성화될 때마다 데이터를 갱신하기 위해 WidgetsBindingObserver 등록
    WidgetsBinding.instance.addObserver(this);
    
    // FocusNode 초기화 및 리스너 추가
    _screenFocusNode = FocusNode();
    _screenFocusNode.addListener(_onFocusChange);
    
    // 초기화 시 데이터 갱신
    _refreshData();
    
    // 화면이 초기화될 때 다시 한번 데이터 강제 갱신을 위해 비동기 처리
    Future.delayed(Duration.zero, () {
      ref.invalidate(userHabitsProvider);
    });
  }

  // FocusNode의 포커스 변경 시 호출
  void _onFocusChange() {
    // 포커스를 받았을 때 데이터 갱신
    if (_screenFocusNode.hasFocus) {
      _refreshData();
    }
  }

  @override
  void dispose() {
    // 옵저버 및 FocusNode 해제
    WidgetsBinding.instance.removeObserver(this);
    _screenFocusNode.removeListener(_onFocusChange);
    _screenFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 다시 활성화될 때 데이터 갱신
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 이것은 사용자가 다른 화면에서 돌아왔을 때도 호출되지만
    // 초기화 때도 호출되므로 관리가 필요합니다
    _refreshOnFocusGain();
  }
  
  // 로컬에 마지막으로 갱신된 시간을 저장합니다
  DateTime? _lastRefreshTime;
  
  // 최소한 1초 이상 간격을 두고 갱신합니다
  void _refreshOnFocusGain() {
    final now = DateTime.now();
    if (_lastRefreshTime == null || now.difference(_lastRefreshTime!).inSeconds > 1) {
      _refreshData();
      _lastRefreshTime = now;
    }
  }

  // 화면으로 돌아올 때 데이터 갱신
  void _refreshData() {
    // 사용자 습관 데이터 갱신
    ref.invalidate(userHabitsProvider);
    // 사용자 공유 습관 목록 갱신
    ref.invalidate(userSharedHabitsProvider);
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isLogin = authState is AuthStateAuthenticated;

    if (!isLogin) {
      return Scaffold(
        backgroundColor: AppColors.mainBackground,
        appBar: AppBar(
          backgroundColor: AppColors.mainBackground,
          elevation: 0,
          title: const Text('내 습관 목록', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '로그인이 필요합니다',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // 로그인 화면으로 이동
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('로그인하기'),
              ),
            ],
          ),
        ),
      );
    }

    // 사용자 습관 데이터 불러오기
    final userHabitsAsync = ref.watch(userHabitsProvider);
    
    // 사용자의 공유 습관 리스트 불러오기
    final userSharedHabitsAsync = ref.watch(userSharedHabitsProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        title: const Text('내 습관 목록', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Focus(
        focusNode: _screenFocusNode,
        child: userHabitsAsync.when(
        data: (habits) {
          // 이제 공유 습관 목록도 불러올 것이므로 우선 스크롤 가능한 컨테이너로 변경
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 내 습관 섹션 타이틀
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '내 습관',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                
                // 습관이 없을 때 표시
                if (habits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            '아직 등록된 습관이 없습니다',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // 습관이 있을 때 목록 표시
                if (habits.isNotEmpty)
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,  // Column 내부에서 사용하기 위해 필요
                    physics: const NeverScrollableScrollPhysics(),  // 주 스크롤이 작동하도록 이 리스트는 스크롤 비활성화
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return _buildHabitCard(context, habit, ref);
                    },
                  ),
                  
                // 내 공유 습관 섹션
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '내가 만든 공유 습관',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                
                // 사용자 공유 습관 리스트 불러오기
                userSharedHabitsAsync.when(
                  data: (sharedHabitLists) {
                    if (sharedHabitLists.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                '아직 공유한 습관 목록이 없습니다',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // 공유 습관 목록을 가로 스크롤 형태로 표시
                    return Container(
                      height: 200,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: sharedHabitLists.length,
                        itemBuilder: (context, index) {
                          return _buildSharedHabitCard(context, sharedHabitLists[index]);
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '공유 습관 데이터를 불러오는데 실패했습니다: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            '데이터를 불러오는데 실패했습니다: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // 습관 화면으로 이동
          Navigator.of(context).pushNamed('/habit');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 공유 습관 카드 빌드
  Widget _buildSharedHabitCard(BuildContext context, SharedHabitList sharedHabitList) {
    return GestureDetector(
      onTap: () {
        // 공유 습관 상세 페이지로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SharedHabitDetailScreen(
              sharedHabitId: sharedHabitList.id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 상단 영역
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: sharedHabitList.imageUrl != null
                  ? Image.network(
                      sharedHabitList.imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: AppColors.primary.withOpacity(0.2),
                        child: const Icon(Icons.image, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      height: 100,
                      color: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.image, color: AppColors.primary),
                    ),
            ),
            // 텍스트 정보 영역
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sharedHabitList.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sharedHabitList.description ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  // 습관 개수 표시
                  Text(
                    '습관 ${sharedHabitList.habits.length}개',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
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

  Widget _buildHabitCard(BuildContext context, Map<String, dynamic> habitData, WidgetRef ref) {
    final habit = HabitModel.fromMap(habitData);
    final startDate = DateFormat('yyyy.MM.dd').format(habit.startDate);
    final endDate = DateFormat('yyyy.MM.dd').format(habit.endDate);
    final now = DateTime.now();
    
    // 진행 상황 계산
    final totalDays = habit.endDate.difference(habit.startDate).inDays;
    final passedDays = now.difference(habit.startDate).inDays;
    final progress = passedDays / totalDays;
    final normalizedProgress = progress < 0 
        ? 0.0 
        : progress > 1 
            ? 1.0 
            : progress;

    // 트래킹 데이터 가져오기
    final trackingAsync = ref.watch(habitTrackingProvider(habit.id ?? ''));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF242030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    habit.selectedHabit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    habit.type,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$startDate ~ $endDate',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // 진행 바
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: normalizedProgress,
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 10,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '완료 횟수: ${habit.count}/${habit.duration}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                trackingAsync.when(
                  data: (trackingData) {
                    final isCompletedToday = trackingData.any((tracking) {
                      final date = DateTime.parse(tracking['completion_date']);
                      return date.year == now.year && 
                             date.month == now.month && 
                             date.day == now.day;
                    });
                    
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompletedToday 
                            ? Colors.grey 
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: isCompletedToday
                          ? null
                          : () => _markHabitComplete(context, habit, ref),
                      child: Text(
                        isCompletedToday ? '오늘 완료' : '완료하기',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  error: (_, __) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _markHabitComplete(context, habit, ref),
                    child: const Text('완료하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markHabitComplete(BuildContext context, HabitModel habit, WidgetRef ref) async {
    try {
      // 1. 트래킹 데이터 추가
      await HabitSupabaseService.instance.addHabitTracking(
        habitId: habit.id!,
        completionDate: DateTime.now(),
      );
      
      // 2. 습관 카운트 증가
      await HabitSupabaseService.instance.updateUserHabit(
        habitId: habit.id!,
        count: (habit.count ?? 0) + 1,
        isCompleted: habit.duration != null && (habit.count ?? 0) + 1 >= habit.duration!,
      );
      
      // 3. 데이터 갱신
      ref.invalidate(userHabitsProvider);
      ref.invalidate(habitTrackingProvider(habit.id!));
      
      // 4. 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('습관 완료 처리되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
