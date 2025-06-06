import 'package:sleept/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:sleept/features/habit/model/shared_habit_list_model.dart';

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
  Future<List<Map<String, dynamic>>> getHabitAllItems() async {
    final response = await client
        .from('habit_items')
        .select('*, habit_categories(*)');


    return response.map((item) => Map<String, dynamic>.from(item)).toList();
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

  /// 사용자의 단일 습관 가져오기
  Future<Map<String, dynamic>> getUserSingleHabit(habitId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final response = await client
        .from('user_habits')
        .select('*')
        .eq('user_id', userId)
        .eq('id',habitId)
        .order('created_at', ascending: false).single();

    print(response);

    return response;
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

    // 1. Insert into habit_tracking table
    await client.from('habit_tracking').insert({
      'id': uuid.v4(),
      'habit_id': habitId,
      'user_id': userId,
      'completion_date': completionDate.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });

    // 2. Fetch the current count from user_habit table
    // Assumes a unique row for this userId and habitId exists.
    // .single() will throw an error if not found or if multiple rows are returned.
    final userHabitData = await client
        .from('user_habit')
        .select('count')
        .eq('user_id', userId)
        .eq('habit_id', habitId)
        .single();

    final int currentCount = (userHabitData['count'] as int? ?? 0);
    final int newCount = currentCount + 1;

    // 3. Update the count in user_habit table
    await client
        .from('user_habit')
        .update({'count': newCount})
        .eq('user_id', userId)
        .eq('habit_id', habitId);
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

  /// 공유 습관 리스트 생성하기
  Future<String> createSharedHabitList({
    required String title,
    required String description,
    String? imageUrl,
    required List<Map<String, dynamic>> habits,
    required bool isPublic,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }

    final id = uuid.v4();
    
    // First, try to create the shared_habit_lists table if it doesn't exist
    // In a production environment, this would be done through migrations
    try {
      // Check if table exists by querying it
      await client.from('shared_habit_lists').select('id').limit(1);
      print('Table shared_habit_lists exists');
    } catch (e) {
      // Table doesn't exist - we'd need admin rights to create the table
      // In a real app, you would create the table through Supabase dashboard or migrations
      print('Table shared_habit_lists does not exist: $e');
      print('Please create the table with the following structure:');
      print('- id: uuid (primary key)');
      print('- user_id: uuid (foreign key to auth.users)');
      print('- title: text');
      print('- description: text');
      print('- image_url: text (nullable)');
      print('- habits: jsonb');
      print('- is_public: boolean');
      print('- created_at: timestamp with time zone');
      
      throw Exception('공유 습관 리스트 테이블이 존재하지 않습니다. 관리자에게 문의하세요.');
    }
    
    // Store the shared habit list
    await client.from('shared_habit_lists').insert({
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'habits': habits,
      'is_public': isPublic,
      'created_at': DateTime.now().toIso8601String(),
    });
    
    return id;
  }
  
  /// 공개된 공유 습관 리스트 가져오기
  Future<List<SharedHabitList>> getPublicSharedHabitLists() async {
    final response = await client
        .from('shared_habit_lists')
        .select()
        .eq('is_public', true)
        .order('created_at', ascending: false);
    
    return response.map((data) => SharedHabitList.fromJson(data)).toList();
  }
  
  /// 사용자 자신이 만든 공유 습관 리스트 가져오기
  Future<List<SharedHabitList>> getUserSharedHabitLists() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자가 로그인하지 않았습니다.');
    }
    
    final response = await client
        .from('shared_habit_lists')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return response.map((data) => SharedHabitList.fromJson(data)).toList();
  }
  
  /// 특정 ID의 공유 습관 리스트 가져오기
  Future<SharedHabitList?> getSharedHabitListById(String id) async {
    try {
      final response = await client
          .from('shared_habit_lists')
          .select()
          .eq('id', id)
          .single();
      
      return SharedHabitList.fromJson(response);
    } catch (e) {
      // If no habit list is found or other error occurs
      return null;
    }
  }
  
  /// 특정 공유 습관 리스트 가져오기
  Future<SharedHabitList> getSharedHabitList(String id) async {
    final response = await client
        .from('shared_habit_lists')
        .select('*')
        .eq('id', id)
        .single();
    
    return SharedHabitList.fromJson(response);
  }
}
