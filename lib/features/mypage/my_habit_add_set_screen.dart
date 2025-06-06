import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../constants/colors.dart';
import '../../providers/habit_provider.dart';
import '../../providers/shared_habit_provider.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';

class MyHabitAddSetScreen extends ConsumerStatefulWidget {
  const MyHabitAddSetScreen({super.key});

  @override
  ConsumerState<MyHabitAddSetScreen> createState() => _MyHabitAddSetScreenState();
}

class _MyHabitAddSetScreenState extends ConsumerState<MyHabitAddSetScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isPublic = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Set the selected habits in the form notifier when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedHabits = ref.read(selectedHabitItemsNotifierProvider);
      ref.read(sharedHabitFormProvider.notifier).setHabits(selectedHabits);
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      // In a real app, you would upload this to storage and get a URL
      // For now, we'll just store the path as a placeholder
      ref.read(sharedHabitFormProvider.notifier).updateImageUrl(pickedFile.path);
    }
  }
  
  Future<void> _saveSharedHabitList(BuildContext context) async {
    // Validate inputs
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }
    
    // Check if any habits are selected
    final selectedHabits = ref.read(selectedHabitItemsNotifierProvider);
    if (selectedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나 이상의 습관을 선택해주세요')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Update the form state with final values
    ref.read(sharedHabitFormProvider.notifier).updateTitle(_titleController.text);
    ref.read(sharedHabitFormProvider.notifier).updateDescription(_descriptionController.text);
    ref.read(sharedHabitFormProvider.notifier).updateIsPublic(_isPublic);
    
    try {
      final id = await ref.read(sharedHabitFormProvider.notifier).saveSharedHabitList();
      
      if (id != null && mounted) {
        // Success handling
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('습관 리스트가 성공적으로 저장되었습니다')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (mounted) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 중 오류가 발생했습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
            onTap: _isLoading ? null : () => _saveSharedHabitList(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _isLoading ? '저장 중...' : '완료',
                style: TextStyle(
                  color: _isLoading 
                    ? Colors.grey 
                    : const Color(0xFF724BFF) /* Primary-Color */,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '썸네일 및 상단 헤더 이미지',
                style: TextStyle(
                  color: Colors.white /* Primitive-Color-White */,
                  fontSize: 14,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF413D4F),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 11.5, vertical: 12),
                child: Stack(
                  children: [
                    Center(
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 22),
                                SvgPicture.asset('assets/svg/Icon_sleept_basic.svg'),
                                SizedBox(height: 21.7),
                                Text(
                                  '이미지가 없어도 기본 이미지로 적용됩니다.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFB8B6C0,
                                    ) /* Primitive-Color-gray-300 */,
                                    fontSize: 13,
                                    fontFamily: 'Min Sans',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 34,
                          height: 34,
                          padding: EdgeInsets.all(8),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.black.withValues(alpha: 178),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/svg/Icon_image_plus.svg',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Text(
                '리스트 이름',
                style: TextStyle(
                  color: Colors.white /* Primitive-Color-White */,
                  fontSize: 14,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF413D4F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _titleController,
                  maxLength: 31,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14),
                    border: InputBorder.none,
                    hintText: '이름을 입력해 주세요. (최대 31자)',
                    hintStyle: TextStyle(
                      color: const Color(
                        0xFFAAA8B4,
                      ) /* Primitive-Color-gray-400 */,
                      fontSize: 16,
                      fontFamily: 'Min Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    counterText: '',
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text(
                '상세 설명',
                style: TextStyle(
                  color: Colors.white /* Primitive-Color-White */,
                  fontSize: 14,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF413D4F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 68,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    hintText: '상세 설명을 입력해 주세요. (최대 68자)',
                    hintStyle: TextStyle(
                      color: const Color(
                        0xFFAAA8B4,
                      ) /* Primitive-Color-gray-400 */,
                      fontSize: 16,
                      fontFamily: 'Min Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '리스트 공개 허용',
                    style: TextStyle(
                      color: Colors.white /* Primitive-Color-White */,
                      fontSize: 14,
                      fontFamily: 'Min Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    padding: EdgeInsets.zero,
                    inactiveThumbColor: Colors.white,
                    trackOutlineWidth: WidgetStateProperty.resolveWith<double?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return 0;
                      }
                      return 0; // Use the default width.
                    }),
                    inactiveTrackColor: Color(0xFF413D4F),
                    activeColor: Colors.white,
                    activeTrackColor: Color(0xFF3BC849),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '공개를 허용하면 하단 탭 - 습관 에서 다른 유저들에게 내가 만든 습관 리스트가 공개됩니다',
                style: TextStyle(
                  color: const Color(0xFFB8B6C0) /* Primitive-Color-gray-300 */,
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
    );
  }
}
