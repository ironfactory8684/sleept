import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/habit_datas.dart';
import 'package:sleept/constants/text_styles.dart';
import 'package:sleept/features/habit/components/habit_item.dart';

import 'model/habit_data.dart';
import 'components/habit_dialog.dart';
import 'package:sleept/features/habit/service/habit_database.dart';

class HabitDetailScreen extends StatefulWidget {
  final String type;


  const HabitDetailScreen({
    super.key,
    required this.type,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  // 운동 데이터 리스트 (실제 앱에서는 API 등에서 가져올 수 있습니다)
  late final List _exerciseList;

  late Map habitItem;
  String? selectItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    habitItem = habitData[widget.type];
    setState(() {
      _exerciseList=  habitItem['items'].keys.toList();
    });


  }


  void _showHabitDialog() {
    if (selectItem==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 운동을 선택해주세요.'),
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

        var diffDay= end.difference(start);

        final completed = end.isBefore(DateTime.now());
        final habit = HabitModel(
          type: widget.type,
          selectedHabit: selectItem!,
          startDate: start,
          endDate: end,
          duration:diffDay.inDays,
          count: 0,
          isCompleted: completed,
        );
        await HabitDatabase.instance.create(habit);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('습관이 생성되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          for (var item in _exerciseList) {
            item.isSelected = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // 전체 화면 배경색 (예시)
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0, // 이미지 높이
            floating: false,
            pinned: true, // 스크롤 시 앱바 고정 여부
            snap: false,
            backgroundColor: Colors.grey[900], // 앱바 배경색
            leading: IconButton( // 뒤로가기 버튼
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // TODO: 뒤로가기 로직 구현
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/${habitItem['image']}', // TODO: 상단 이미지 경로로 변경
                fit: BoxFit.cover,
              ),
              // 이미지가 축소될 때 제목이 나타나지 않도록 비워둡니다.
              // title: Text("운동 루틴"), // 필요하다면 제목 추가
              // titlePadding: EdgeInsets.zero,
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
                          SvgPicture.asset(habitItem['iconPath']), // 아이콘 예시
                          const SizedBox(width: 8),
                          Text(
                            widget.type,
                            style: TextStyle(
                              color: Colors.yellow[700], // 텍스트 색상 (예시)
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        habitItem['subtitle'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        habitItem['description'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // 운동 아이템 리스트
                ListView.builder(
                  padding: EdgeInsets.zero, // SliverList 내부 ListView의 패딩 제거
                  shrinkWrap: true, // ScrollView 내부에 있기 때문에 true로 설정
                  physics: const NeverScrollableScrollPhysics(), // ScrollView 내부에 있기 때문에 스크롤 비활성화
                  itemCount: _exerciseList.length,
                  itemBuilder: (context, index) {
                    final item = habitItem['items'][_exerciseList[index]];
                    return HabitItem(
                      imagePath: "assets/images/${item['image']}",
                      title: item['title'],
                      subtitle: item['descript'],
                      initialIsChecked: item['title']==selectItem,
                      onChanged: (bool? newValue) {
                        if(newValue!=null){
                          if(newValue){
                           setState(() {
                             selectItem = item['title'];
                           });
                          }else{
                            selectItem = null;
                          }
                        }

                        //
                        // setState(() {
                        //   _exerciseList[index].isSelected = newValue ?? false;
                        // });
                        // TODO: 선택된 아이템에 대한 로직 처리 (예: 상태 관리 업데이트)
                      },
                    );
                  },
                ),
                const SizedBox(height: 20), // 버튼 위 여백
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, // 버튼 배경색 (예시)
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:_showHabitDialog,
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
  }
}
