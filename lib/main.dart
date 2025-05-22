import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleept/features/init/home_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'constants/colors.dart'; // DateFormat 초기화 위해 impor
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 배경 투명
      systemNavigationBarColor: AppColors.meditationColor,
      statusBarIconBrightness: Brightness.light, // 흰색 아이콘
    ),
  );
  await initializeDateFormatting('ko_KR', null); // 한국어 로케일 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleept',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF724BFF)),
      ),
      home: const HomeNavigation(),
    );
  }
}
