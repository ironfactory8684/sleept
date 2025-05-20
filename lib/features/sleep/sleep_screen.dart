import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 사용을 위해 추가
import 'package:sleept/features/sleep/service/music_database.dart';
import '../../utils/app_colors.dart'; // AppColors 임포트
import 'music_player_screen.dart'; // MusicPlayerScreen 임포트
import 'package:sleept/models/music_model.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  String selectedChip = '전체';
  final List<String> chips = ['전체', '팟캐스트', '명상', 'ASMR', '스트레칭'];
  List<MusicModel> _musics = [];  // DB에서 로드된 음악 목록

  @override
  void initState() {
    super.initState();
    _loadMusics();
  }

  Future<void> _loadMusics() async {
    final list = await MusicDatabase.instance.readAllMusics();
    if (!mounted) return;
    setState(() => _musics = list);
  }

  @override
  Widget build(BuildContext context) {
    // Status Bar 영역 확보 (피그마 디자인 참고)
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: statusBarHeight + 10, bottom: 100), // 상태바 높이 및 하단 네비게이션 바 고려
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단 텍스트
                    _buildHeaderText(),
                    const SizedBox(height: 24),

                    // 칩 (카테고리 필터)
                    _buildChips(),
                    const SizedBox(height: 24),

                    // 이번주 조회수 Top 10 섹션
                    _buildSectionTitle('이번주 조회수 Top 10'),
                    const SizedBox(height: 16),
                    // _buildTop10List(),
                    const SizedBox(height: 24),

                    // 최근 재생한 콘텐츠 섹션
                    _buildSectionTitle('최근 재생한 콘텐츠'),
                    const SizedBox(height: 16),
                    _buildRecentPlays(),
                    const SizedBox(height: 24),

                    // 스르륵 눈이 감기는 날 섹션
                    _buildSectionTitle('스르륵 눈이 감기는 날'),
                    const SizedBox(height: 16),
                    _buildHorizontalContentList(
                      _musics.map((m) =>
                        _buildContentCard(m.imagePath, m.title, m.category, m.duration, m.musicPath)
                      ).toList(),
                    ),
                    const SizedBox(height: 24),

                     // 편안한 자연의 소리 섹션
                    _buildSectionTitle('편안한 자연의 소리'),
                    const SizedBox(height: 16),
                     _buildHorizontalContentList(
                      _musics.map((m) =>
                        _buildContentCard(m.imagePath, m.title, m.category, m.duration, m.musicPath)
                      ).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 포근한 자장가 팟캐스트 (Featured Card)
                    // _buildFeaturedPodcastCard(),
                  ],
                ),
              ),
            ),
        
    );
  }

  // 상단 헤더 텍스트 위젯
  Widget _buildHeaderText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Siha님, 지난 밤 수면을 보완해줄\n잠 오는 콘텐츠 추천해드릴게요',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textWhite,
          height: 1.5, // lineHeight
        ),
      ),
    );
  }

  // 칩 리스트 위젯
  Widget _buildChips() {
    return Container(
      height: 36, // 피그마 Frame 14 높이 (padding 포함)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10), // 피그마 gap
        itemBuilder: (context, index) {
          final chipLabel = chips[index];
          final isSelected = selectedChip == chipLabel;
          return ChoiceChip(
            label: Text(chipLabel),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  selectedChip = chipLabel;
                });
              }
            },
            backgroundColor: AppColors.chipBackground,
            selectedColor: AppColors.chipSelectedBackground,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppColors.textWhite : AppColors.textGray,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // 피그마 padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // 피그마 borderRadius
              side: BorderSide.none,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

   // 섹션 타이틀 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textWhite,
        ),
      ),
    );
  }

  // Top 10 카드 위젯
  Widget _buildTop10Card(String rank, String imagePath, String title, String category, String duration, bool isLiked, String musicPath) {
    return GestureDetector(
       onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(
              imagePath: imagePath,
              title: title,
              category: category,
              duration: duration,
              musicPath: musicPath, // 전달받은 musicPath 사용
            ),
          ),
        );
      },
      child: Container(
        width: 162, // 피그마 Group 34624 너비 (추정)
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          children: [
            // 배경 이미지 및 그라데이션
            ClipRRect(
               borderRadius: BorderRadius.circular(18), // 피그마 Rectangle 71 borderRadius
               child: Container(
                 height: 240, // 임의 높이 지정
                  decoration: BoxDecoration(
                     image: DecorationImage(
                       image: AssetImage(imagePath),
                       fit: BoxFit.cover,
                     ),
                   ),
                  child: Container(
                      decoration: BoxDecoration(
                         gradient: LinearGradient(
                           begin: Alignment.topCenter,
                           end: Alignment.bottomCenter,
                           colors: [
                              Colors.transparent,
                              AppColors.mainBackground.withOpacity(0.4),
                              AppColors.mainBackground.withOpacity(1.0),
                           ],
                            stops: [0.0, 0.6, 1.0], // 피그마 그라데이션 stop 값 참고
                         ),
                      ),
                   ),
               )
            ),
            // 컨텐츠 내용
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // 피그마 style_7AVG7E / style_WK692V 유사하게
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                        height: 1.38,
                      ),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/music_icon_gray.svg', // 또는 music_icon_gray_2.svg
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(AppColors.textSubtleGray, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 4),
                        _buildTag(category, duration, AppColors.textSubtleGray),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // 랭크 표시
             Positioned(
               top: 12,
               left: 12,
               child: Container(
                 width: 30, // 크기 조정 필요
                 height: 30,
                 decoration: BoxDecoration(
                   color: AppColors.numberBadgeBackground,
                   shape: BoxShape.circle,
                 ),
                 child: Center(
                   child: Text(
                     rank,
                     style: TextStyle(
                       // 피그마 style_CDF07S 유사하게
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                       color: AppColors.textWhite,
                     ),
                   ),
                 ),
               ),
             ),
             // 좋아요 버튼
              Positioned(
               top: 12,
               right: 12,
               child: Container(
                  width: 30, // 크기 조정 필요
                  height: 30,
                  decoration: BoxDecoration(
                     color: isLiked ? AppColors.heartIconBackground : AppColors.outlineHeartIconBackground,
                     shape: BoxShape.circle,
                      border: Border.all(color: isLiked ? AppColors.heartIconBorder : AppColors.outlineHeartIconBorder, width: 1)
                  ),
                  child: Center(
                   child: SvgPicture.asset(
                       isLiked ? 'assets/images/heart_icon_filled.svg' : 'assets/images/heart_icon_outline.svg',
                       width: 16, // 아이콘 크기 조정 필요
                       height: 16,
                        colorFilter: ColorFilter.mode(isLiked ? AppColors.textWhite : AppColors.outlineHeartIconBorder, BlendMode.srcIn),
                    )
                  ),
               ),
             ),
          ],
        ),
      ),
    );
  }

 // Top 10 리스트 위젯
 Widget _buildTop10List() {
    return Container(
      height: 240, // 카드의 높이에 맞게 조정
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Row(
        
        
        children: [
          _buildTop10Card('1', 'assets/images/top_10_card_background_2.png', '신비로운 모래성에서 사각거리는 소리', 'ASMR', '2시간 30분', true, 'assets/music/sand_sound.mp3'),
          _buildTop10Card('2', 'assets/images/top_10_card_background_1.png', '비 내린 오후 숲 새들의 노래', '명상', '1시간 30분', false, 'assets/music/forest_bird_sound.mp3'),
          _buildTop10Card('3', 'assets/images/featured_card_background.png', '포근한 자장가 같은 속삭임 팟캐스트', '팟캐스트', '2시간 30분', false, 'assets/music/podcast_lullaby.mp3'), // 예시 데이터
          // ... 더 많은 카드 추가
        ],
      ),
      )
    );
 }

  // 최근 재생 카드 위젯
  Widget _buildRecentPlayCard(String imagePath, String title, String category, String totalTime, String remainingTime, double progress, String musicPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(
              imagePath: imagePath,
              title: title,
              category: category,
              duration: totalTime, // 전체 시간 전달
              musicPath: musicPath, // 전달받은 musicPath 사용
            ),
          ),
        );
      },
      child: Container(
        width: 309, // 피그마 Frame 117/118 너비
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(18), // 피그마 padding
        decoration: BoxDecoration(
          color: AppColors.recentPlayBackground,
          borderRadius: BorderRadius.circular(16), // 피그마 borderRadius
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 70, // 피그마 Rectangle 172 너비 추정
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20), // 피그마 gap
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 버튼과 텍스트 간격 최대화
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                         title,
                         style: TextStyle(
                           fontSize: 15,
                           fontWeight: FontWeight.w500,
                           color: AppColors.textWhite,
                         ),
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                      ),
                       const SizedBox(height: 2),
                      _buildTag(category, totalTime, AppColors.recentTagText), // 또는 recentTagText2
                    ],
                  ),
                   const SizedBox(height: 10), // 간격 조정
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                      remainingTime,
                                      style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.recentProgressText, // 또는 recentProgressText2
                                      ),
                                  ),
                                  const SizedBox(height: 7),
                                  // 프로그레스 바
                                  Container(
                                  width: 80, // 너비 조정 필요
                                  height: 6,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: AppColors.progressBackground,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                                      ),
                                  ),
                                  ),
                               ],
                           ),
                          // "이어서 재생" 버튼
                           OutlinedButton(
                              onPressed: () {},
                              child: Text(
                                  '이어서 재생',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.chipSelectedBackground, // 버튼 텍스트 색상
                                  ),
                                  ),
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.buttonBorder, width: 1),
                                  shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // 피그마 borderRadius
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6), // 피그마 padding
                                  minimumSize: Size(0, 30), // 버튼 최소 높이
                              ),
                          )

                      ],
                   )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 // 최근 재생 리스트 위젯
  Widget _buildRecentPlays() {
    return Container(
      height: 106, // 카드 높이에 맞게 조정
      child: ListView(
         scrollDirection: Axis.horizontal,
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         children: [
           _buildRecentPlayCard('assets/images/recent_play_image_1.png', '여유로운 낮잠같은 날', '팟캐스트', '1시간 30분', '30분 17초 남음', 0.7, 'assets/music/podcast_nap.mp3'),
           _buildRecentPlayCard('assets/images/recent_play_image_2.png', '여유로운 낮잠같은 날', '팟캐스트', '1시간 30분', '30분 17초 남음', 0.7, 'assets/music/podcast_nap.mp3'),
           // ... 더 많은 카드 추가
         ],
      ),
    );
  }


  // 일반 컨텐츠 카드 위젯 (가로 스크롤용)
  Widget _buildContentCard(String imagePath, String title, String category, String duration, String musicPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(
              imagePath: imagePath,
              title: title,
              category: category,
              duration: duration,
              musicPath: musicPath, // 전달받은 musicPath 사용
            ),
          ),
        );
      },
      child: Container(
        width: 162, // 피그마 Frame 너비
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16), // 피그마 Rectangle borderRadius
              child: Image.asset(
                imagePath,
                height: 110, // 이미지 높이 조정
                width: 162,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8), // 피그마 Frame gap
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // 내부 여백 조정
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textWhite,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2), // 피그마 Frame gap
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // 내부 여백 조정
              child: _buildTag(category, duration, AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }

  // 컨텐츠 태그 (카테고리 + 시간) 위젯
  Widget _buildTag(String category, String duration, Color textColor) {
     return Row(
       children: [
         Text(
           category,
           style: TextStyle(
             fontSize: 13,
             fontWeight: FontWeight.w500,
             color: textColor,
           ),
         ),
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 5.0),
           child: Container( // Ellipse 20
             width: 4,
             height: 4,
             decoration: BoxDecoration(
               color: AppColors.dotColor, // 피그마 Ellipse fill or recentDotColor
               shape: BoxShape.circle,
             ),
           ),
         ),
         Text(
           duration,
           style: TextStyle(
             fontSize: 13,
             fontWeight: FontWeight.w400,
             color: textColor,
           ),
         ),
       ],
     );
  }

   // 가로 스크롤 컨텐츠 리스트 위젯
   Widget _buildHorizontalContentList(List<Widget> cards) {
     return Container(
       height: 200, // 높이를 조금 더 넉넉하게 설정 (기존 180)
       child: ListView(
         scrollDirection: Axis.horizontal,
         padding: const EdgeInsets.symmetric(horizontal: 16.0), // 패딩 다시 추가
         children: cards,
       ),
     );
   }

   // 추천 팟캐스트 카드 위젯
   Widget _buildFeaturedPodcastCard() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
           height: 150, // 높이 조정
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(18), // 피그마 Rectangle 77 borderRadius
             image: DecorationImage(
               image: AssetImage('assets/images/featured_card_background.png'),
               fit: BoxFit.cover,
             ),
           ),
           child: Stack(
             children: [
               // 그라데이션 오버레이
               Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(18),
                   gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.mainBackground.withOpacity(0.4),
                        AppColors.mainBackground.withOpacity(1.0),
                      ],
                      stops: [0.0, 0.65, 1.0], // 피그마 그라데이션 stop 값 참고
                   ),
                 ),
               ),
               // 텍스트 및 태그
               Positioned(
                 bottom: 16,
                 left: 16,
                 right: 16,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       '포근한 자장가 같은\n속삭임 팟캐스트',
                       style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.w700,
                         color: AppColors.textWhite,
                         height: 1.5,
                       ),
                     ),
                     const SizedBox(height: 8),
                     Container( // 피그마 Rectangle 169 + Group 38 유사하게
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: AppColors.heartIconBackground, // 피그마 fill_CMLRR5
                         borderRadius: BorderRadius.circular(10),
                       ),
                       child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              SvgPicture.asset(
                                'assets/images/music_icon_white.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                               ),
                               const SizedBox(width: 5),
                               Text('팟캐스트', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textWhite)),
                               Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Container( // Ellipse 19
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.dotColor, // 피그마 fill_0C95R3
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Text('2시간 30분', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSubtleGray)), // textGray or textSubtleGray
                          ],
                       ),
                     )
                   ],
                 ),
               )
             ],
           ),
        ),
      );
   }
}