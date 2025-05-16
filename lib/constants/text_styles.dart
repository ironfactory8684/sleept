import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';

class AppTextStyles {
  // 습관 페이지 헤더 타이틀
  static const TextStyle mainHeaderTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.whiteText,
    height: 1.5,
  );
  
  // 습관 페이지 서브 타이틀
  static const TextStyle subHeaderTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.whiteText,
    height: 1.5,
  );
  
  // 카드 제목 스타일
  static const TextStyle cardTitle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.lightGreyText,
    height: 1.57,
  );
  
  // 퍼센트 텍스트
  static const TextStyle percentText = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.whiteText,
    height: 1.28,
  );
  
  // 카테고리 라벨
  static const TextStyle categoryLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.3,
  );
  
  // 상세 정보 텍스트
  static const TextStyle infoText = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.whiteText,
    height: 1.38,
  );
  
  // 칩 텍스트 활성화
  static const TextStyle chipTextActive = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.whiteText,
    height: 1.5,
  );
  
  // 칩 텍스트 비활성화
  static const TextStyle chipTextInactive = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: AppColors.greyText,
    height: 1.5,
  );
  
  // 카드 아이템 제목
  static const TextStyle cardItemTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.5,
  );
  
  // 카드 아이템 설명
  static const TextStyle cardItemDescription = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.whiteText,
    height: 1.5,
  );
  
  // 태그 텍스트
  static const TextStyle tagText = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors.tagText,
    height: 1.5,
  );
  
  // 탭바 텍스트 활성화
  static const TextStyle tabBarTextActive = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    color: AppColors.primary,
    height: 1.5,
  );
  
  // 탭바 텍스트 비활성화
  static const TextStyle tabBarTextInactive = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.inactiveTabText,
    height: 1.5,
  );
} 