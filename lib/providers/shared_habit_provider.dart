import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/features/habit/model/shared_habit_list_model.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';

// State notifier for the shared habit list creation form
class SharedHabitFormNotifier extends StateNotifier<SharedHabitFormState> {
  SharedHabitFormNotifier(this._habitService) : super(SharedHabitFormState());
  
  final HabitSupabaseService _habitService;
  
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }
  
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }
  
  void updateImageUrl(String imageUrl) {
    state = state.copyWith(imageUrl: imageUrl);
  }
  
  void updateIsPublic(bool isPublic) {
    state = state.copyWith(isPublic: isPublic);
  }
  
  void setHabits(List<Map<String, dynamic>> habits) {
    state = state.copyWith(habits: habits);
  }
  
  // TODO: Implement this method when ready to handle image uploads to Supabase Storage
  Future<String?> uploadImage(String localImagePath) async {
    // Future implementation for uploading images to Supabase Storage
    // For now, just return the local path
    return localImagePath;
    
    // Example implementation (commented out):
    // try {
    //   final fileName = path.basename(localImagePath);
    //   final storageResponse = await _habitService.supabase
    //     .storage
    //     .from('habit_images')
    //     .upload('user_habit_lists/${DateTime.now().millisecondsSinceEpoch}_$fileName', 
    //            File(localImagePath));
    //   final imageUrl = _habitService.supabase
    //     .storage
    //     .from('habit_images')
    //     .getPublicUrl(storageResponse);
    //   return imageUrl;
    // } catch (e) {
    //   print('Error uploading image: $e');
    //   return null;
    // }
  }
  
  Future<String?> saveSharedHabitList() async {
    try {
      if (state.habits.isEmpty) {
        return null; // No habits selected
      }
      
      // Store image if available (in the future, use uploadImage() here)
      String? imageUrl = state.imageUrl;
      
      final id = await _habitService.createSharedHabitList(
        title: state.title,
        description: state.description,
        imageUrl: imageUrl,
        habits: state.habits,
        isPublic: state.isPublic,
      );
      
      // Reset form state after successful save
      state = SharedHabitFormState();
      
      return id;
    } catch (e) {
      print('Error saving shared habit list: $e');
      rethrow;
    }
  }
}

// State for the form
class SharedHabitFormState {
  final String title;
  final String description;
  final String? imageUrl;
  final bool isPublic;
  final List<Map<String, dynamic>> habits;

  const SharedHabitFormState({
    this.title = '',
    this.description = '',
    this.imageUrl,
    this.isPublic = false,
    this.habits = const [],
  });

  SharedHabitFormState copyWith({
    String? title,
    String? description,
    String? imageUrl,
    bool? isPublic,
    List<Map<String, dynamic>>? habits,
  }) {
    return SharedHabitFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      habits: habits ?? this.habits,
    );
  }
}

// Providers
final sharedHabitFormProvider = StateNotifierProvider<SharedHabitFormNotifier, SharedHabitFormState>((ref) {
  final habitService = HabitSupabaseService.instance;
  return SharedHabitFormNotifier(habitService);
});

// Provider for fetching all public shared habit lists
final publicSharedHabitsProvider = FutureProvider<List<SharedHabitList>>((ref) async {
  final habitService = HabitSupabaseService.instance;
  return await habitService.getPublicSharedHabitLists();
});

// Provider for fetching user's own shared habit lists
final userSharedHabitsProvider = FutureProvider<List<SharedHabitList>>((ref) async {
  final habitService = HabitSupabaseService.instance;
  return await habitService.getUserSharedHabitLists();
});

// Provider for fetching a specific shared habit list by ID
final sharedHabitListByIdProvider = FutureProvider.family<SharedHabitList?, String>((ref, id) async {
  final habitService = HabitSupabaseService.instance;
  return await habitService.getSharedHabitListById(id);
});
