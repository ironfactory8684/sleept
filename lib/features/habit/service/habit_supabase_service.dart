import 'package:sleept/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class HabitSupabaseService {
  static final HabitSupabaseService instance = HabitSupabaseService._internal();
  final uuid = const Uuid();
  
  HabitSupabaseService._internal();

  /// Supabase 클라이언트 접근
  SupabaseClient get client => SupabaseService.instance.client;

  /// 현재 사용자 ID 가져오기
  String? get currentUserId => SupabaseService.instance.client.auth.currentUser?.id;

  /// 모든 카테고리 데이터 가져오기
  Future<Map<String, dynamic>> getAllHabitCategories() async {
    final response = await client.from('habit_categories').select('*');
    
    Map<String, dynamic> result = {};
    
    for (var category in response) {
      final categoryId = category['id'];
      final categoryName = category['name'];
      
      // 카테고리별 아이템 가져오기
      final items = await getHabitItemsByCategory(categoryId);
      
      result[categoryName] = {
        'items': items,
        'iconPath': category['icon_path'],
        'image': category['image'],
        'subtitle': category['subtitle'],
        'tags': category['tags'].split(','),
        'description': category['description'],
        'iconColor': int.parse(category['icon_color']),
      };
    }
    
    return result;
  }

  /// 특정 카테고리의 습관 아이템 가져오기
  Future<Map<String, dynamic>> getHabitItemsByCategory(String categoryId) async {
    final response = await client
        .from('habit_items')
        .select('*')
        .eq('category_id', categoryId);
    
    Map<String, dynamic> items = {};
    
    for (var item in response) {
      items[item['title']] = {
        'title': item['title'],
        'descript': item['description'],
      };
    }
    
    return items;
  }

  /// 사용자 습관 생성하기
  Future<String> createUserHabit({
    required String type,
    required String selectedHabit,
    required DateTime startDate,
    required DateTime endDate,
    required int duration,
    required bool isCompleted,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final habitId = uuid.v4();
    
    await client.from('user_habits').insert({
      'id': habitId,
      'user_id': userId,
      'type': type,
      'selected_habit': selectedHabit,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'duration': duration,
      'count': 0,
      'is_completed': isCompleted,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    return habitId;
  }

  /// 사용자의 모든 습관 가져오기
  Future<List<Map<String, dynamic>>> getUserHabits() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }
    
    final response = await client
        .from('user_habits')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return response.map((habit) => Map<String, dynamic>.from(habit)).toList();
  }

  /// 사용자 습관 업데이트
  Future<void> updateUserHabit({
    required String habitId,
    int? count,
    bool? isCompleted,
  }) async {
    final updateData = <String, dynamic>{};
    
    if (count != null) updateData['count'] = count;
    if (isCompleted != null) updateData['is_completed'] = isCompleted;
    
    if (updateData.isEmpty) return;
    
    await client
        .from('user_habits')
        .update(updateData)
        .eq('id', habitId);
  }

  /// 사용자 습관 트래킹 기록 추가
  Future<void> addHabitTracking({
    required String habitId,
    required DateTime completionDate,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }
    
    await client.from('habit_tracking').insert({
      'id': uuid.v4(),
      'habit_id': habitId,
      'user_id': userId,
      'completion_date': completionDate.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// 특정 습관의 트래킹 기록 가져오기
  Future<List<Map<String, dynamic>>> getHabitTracking(String habitId) async {
    final response = await client
        .from('habit_tracking')
        .select('*')
        .eq('habit_id', habitId)
        .order('completion_date', ascending: true);
    
    return response.map((tracking) => Map<String, dynamic>.from(tracking)).toList();
  }
}
