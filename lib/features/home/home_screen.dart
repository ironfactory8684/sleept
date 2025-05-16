import 'package:flutter/material.dart';
import 'package:sleept/features/home/home_habit_screen.dart';

import '../../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this,initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: TabBar(
                controller: _tabController,
                tabs: const [Tab(text: '나의 수면'), Tab(text: '나의 습관')],
                labelStyle: TextStyle(
                  color: Colors.white /* Primitive-Color-White */,
                  fontSize: 20,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
                indicatorColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Content for '나의 수면' tab
                  Center(child: Text('나의 수면 Content')),
                  // Content for '나의 습관' tab
                  HomeHabitScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}


