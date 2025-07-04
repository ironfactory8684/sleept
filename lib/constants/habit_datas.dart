import 'dart:ui';

import '../utils/app_colors.dart';

Map habitData ={
  '운동':{
    'items':{
      '줄넘기 100회':{
        'title':'줄넘기 100회',
        'descript':'유산소 운동 중 가장 간단하고 효과적'
      },
      '자전거 타기 1시간':{
        'title':'자전거 타기 1시간',
        'descript':'하체 근육을 강화하고 체지방을 태우는 데 효과적'
      },
      '푸쉬업 20회 2세트':{
        'title':'푸쉬업 20회 2세트',
        'descript':'상체 근육을 강화하는 운동'
      },
      '런닝머신 1시간':{
        'title':'런닝머신 1시간',
        'descript':'실내에서 쉽게 할 수 있는 유산소 운동'
      },
      '스쿼트 30회 2세트':{
        'title':'스쿼트 30회 2세트',
        'descript':'다리 근육을 강화 하는 운동'
      },
    },
    'iconPath':'assets/svg/icon_clover.svg',
    'image':'athletic.jpg',
    'subtitle':'적당한 운동과 수면초보 루틴!',
    'tags': ['#땀흘리기', '#유산소운동', '#쉬운운동'],
    'description':'30분에서 1시간 정도 땀이 나는 운동을 해주면 깊은 수면에 도움이 돼요. 단, 수면 시간과 가까운 시간에 실행하는 것은 수면에 방해가 됨으로 잠들기 3-4시간 전에 실행 해주세요.',
    'iconColor': Color(0xFFECFF87),
  },
  '스트레칭':{
    'items':{
      '목 스트레칭 5분':{
        'title':'목 스트레칭 5분',
        'descript':'목 주변 근육을 풀어주어 긴장 완화'
      },
      '요가 자세 10분':{
        'title':'요가 자세 10분',
        'descript':'전신의 이완을 돕고 수면 준비'
      },
      '햄스트링 스트레칭 5분':{
        'title':'햄스트링 스트레칭 5분',
        'descript':'다리 뒤 근육을 풀어 피로 감소'
      },
    },
    'iconPath':'assets/svg/icon_stairs.svg',
    'subtitle':'낮에도 하고 밤에도 하는 스트레칭',
    'tags': ['#꿀잠', '#숙면요가', '#상하체스트레칭'],
    'description':'잠들기 전 짧은 스트레칭은 근육 긴장 완화에 도움을 주어 숙면을 돕습니다.',
    'iconColor': Color(0xFFFF879D),
  },
  '일상':{
    'items':{
      '스마트폰 사용 중단':{
        'title':'스마트폰 사용 중단',
        'descript':'블루라이트 사용 줄이고 숙면 유도'
      },
      '따뜻한 물 마시기':{
        'title':'따뜻한 물 200ml 마시기',
        'descript':'체온을 안정시켜 숙면에 도움'
      },
      '가벼운 산책 10분':{
        'title':'가벼운 산책 10분',
        'descript':'심박수 낮추고 몸의 긴장 완화'
      },
    },
    'iconPath':'assets/svg/icon_cloud.svg',
    'subtitle':'카페인 대신 물 마시도록 습관 들이기',
    'tags': ['#수분섭취', '#카페인조절', '#일상루틴'],
    'description':'카페인 조절과 충분한 수분 섭취, 가벼운 산책이 몸의 밸런스를 유지해 숙면을 돕습니다.',
    'iconColor': Color(0xFF87BEFF),
  },
  '명상':{
    'items':{
      '호흡 명상 5분':{
        'title':'호흡 명상 5분',
        'descript':'깊은 호흡으로 마음 안정'
      },
      '마인드풀니스 10분':{
        'title':'마인드풀니스 10분',
        'descript':'현재에 집중해 스트레스 감소'
      },
      '바디 스캔 명상 5분':{
        'title':'바디 스캔 명상 5분',
        'descript':'신체 각 부위 이완 상태 확인'
      },
    },
    'iconPath':'assets/svg/icon_circle.svg',
    'subtitle':'잡 생각을 비워주고 마음을 가볍게 만들어주는 힐링 명상하기',
    'tags':  ['#힐링명상', '#생각정리'],
    'description':'명상은 마음을 진정시키고 스트레스를 줄여 깊은 수면을 유도합니다.',
    'iconColor': Color(0xFFFFC887),
  }
};