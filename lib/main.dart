import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart'; // DateFormat 초기화 위해 impor
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleept/features/init/onboarding_screen.dart';
import 'package:sleept/services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sleept/features/sign/auth_wrapper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  await initializeDateFormatting('ko_KR', null); // 한국어 로케일 초기화
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Error loading environment variables: $e');
  }

  //📲 runApp 호출 전 Flutter SDK 초기화 해주는 부분
  KakaoSdk.init(
    nativeAppKey: dotenv.get("KAKAO_NATIVE_APP_KEY"),
    javaScriptAppKey: dotenv.get("KAKAO_JAVASCRIPT_APP_KEY"),
  );
  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isInit = prefs.getBool('isInit') ?? false;
  print(isInit);
  runApp(ProviderScope(child: MyApp(isInit:isInit)));
}

class MyApp extends StatelessWidget {
  final bool isInit;
  const MyApp({super.key, required this.isInit});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleept',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF724BFF)),
        fontFamily: 'MinSans',
      ),
      home: isInit? AuthWrapper():OnboardingScreen(),
    );
  }
}
