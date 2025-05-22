import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/app_colors.dart'; // AppColors 임포트 (필요시 경로 수정)
import 'dart:ui'; // ImageFilter 사용 위해 추가
import 'package:sleept/features/sleep/service/favorites_database.dart';

import 'components/music_player_progress.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final String category;
  final String duration; // 실제 음악 파일 길이를 받아오는 것이 좋음
  final String musicPath; // 예: 'assets/music/song.mp3'

  const MusicPlayerScreen({
    super.key,
    required this.imagePath, // SleepScreen에서 전달받을 이미지
    required this.title,
    required this.category,
    required this.duration,
    required this.musicPath,
  });

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isFavorited = false; // 즐겨찾기 상태

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadFavoriteStatus();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // 로컬 파일 재생 설정 (AssetSource 사용)
      await _audioPlayer.setSource(AssetSource(widget.musicPath.replaceFirst('assets/', ''))); // assets/ 접두사 제거

      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) {
          setState(() => _duration = d);
        }
      });

      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) {
          setState(() => _position = p);
        }
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
         if (mounted) {
            setState(() {
             _isPlaying = state == PlayerState.playing;
           });
         }
      });

       // Optionally get the duration immediately, though onDurationChanged is preferred
       final duration = await _audioPlayer.getDuration();
       if (mounted && duration != null) {
           setState(() => _duration = duration);
       }


    } catch (e) {
      // Handle errors, e.g., file not found, decoding error
      print("Error loading audio source: $e");
      // Optionally show an error message to the user
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('음악 파일을 로드하는데 실패했습니다: ${widget.musicPath}')),
       );
    }
  }

  // DB에서 즐겨찾기 여부 로드
  Future<void> _loadFavoriteStatus() async {
    final fav = await FavoriteDatabase.instance.isFavorited(widget.musicPath);
    if (!mounted) return;
    setState(() => _isFavorited = fav);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // 피그마 디자인 요소 값 (픽셀 값을 논리적 픽셀로 변환 필요)
    // 실제 구현 시에는 테마나 반응형 크기 조정을 사용하는 것이 좋습니다.
    const double albumArtSize = 280.0; // 대략적인 크기 (Ellipse 105/106/107 기반)
    const double progressBarHeight = 4.0; // Rectangle 129 높이

    return Scaffold(

      body: Stack(
        children: [
          // 배경 이미지 및 블러 효과 (피그마 Rectangle 128)
          Positioned.fill(
            child: Image.asset(
              'assets/images/music_player_background.png', // 다운로드한 배경 이미지
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14), // 피그마 effect_DANMM6
              child: Container(
                color: Colors.black.withOpacity(0.6), // 피그마 배경 위 어두운 오버레이 유사하게
              ),
            ),
          ),

          // 컨텐츠 영역
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight, bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                // 상단 네비게이션 바 (피그마 navigation-bar)
                _buildAppBar(context),

                SizedBox(height: 34.0,),

                // 제목 및 카테고리
                _buildTitleAndCategory(),


                // 앨범 아트 (피그마 Ellipse 105/106/107)
                CircularMusicPlayer(
                  imageUrl:   widget.imagePath,
                  progress: 135 / 180, // 현재 재생시간 / 전체
                  current: Duration(minutes: 2, seconds: 15),
                  total: Duration(minutes: 3),
                ),

                // _buildAlbumArt(albumArtSize),

                const Spacer(flex: 1),



                const Spacer(flex: 2),

                // 프로그레스 바 (피그마 Frame 87)
                _buildProgressBar(progressBarHeight),

                 const SizedBox(height: 30), // 간격 조정
                // 자동 종료 토글 (피그마 Frame 254 & Text)
                _buildAutoOffToggle(),
                // 재생 컨트롤 버튼 (피그마 Frame 88)
                _buildControls(),

                const Spacer(flex: 1),



                 const SizedBox(height: 40), // 하단 여유 공간
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 14,bottom: 18, right: 6, left: 6),
      height: 56.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 뒤로가기 버튼 (icon-con-left)
          IconButton(
             icon: SvgPicture.asset(
                'assets/images/arrow_down_icon.svg', // 에셋 경로 확인 필요
                 width: 24, height: 24, colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)),
             onPressed: () => Navigator.of(context).pop(),
             padding: EdgeInsets.zero,
             constraints: BoxConstraints(),
          ),
          // 페이지 이름 (page-name) - 현재 재생 중인 곡 표시 가능
          Text(
          widget.category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite, // style_5UBC06
            ),
          ),
          // 더보기 버튼 (icon-con-right)
           IconButton(
             icon: SvgPicture.asset(
                 'assets/images/more_icon.svg', // 에셋 경로 확인 필요
                  width: 24, height: 24, colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)),
             onPressed: () {
               // 더보기 메뉴 표시 로직
             },
             padding: EdgeInsets.zero,
             constraints: BoxConstraints(),
           ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(double size) {
     // 피그마 Ellipse 105 (이미지), 106 (회색 테두리), 107 (그라데이션 테두리), 108 (빛 효과)
     return Center(
       child: Container(
         width: size + 16, // 테두리 두께 포함 크기 (4 * 2 * 2)
         height: size + 16,
         child: Stack(
           alignment: Alignment.center,
           children: [


             // 앨범 이미지 (Ellipse 105)
             ClipOval(
               child: Image.asset(
                 // widget.imagePath, // SleepScreen에서 받은 이미지 사용
                 widget.imagePath,
                 width: size - 8, // 안쪽 원 크기
                 height: size - 8,
                 fit: BoxFit.cover,
                 // 에러 처리 placeholder 추가 가능
                 errorBuilder: (context, error, stackTrace) {
                    return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.music_note, color: Colors.grey[600])
                    );
                 },
               ),
             ),
           ],
         ),
       ),
     );
  }

 Widget _buildTitleAndCategory() {
     return Padding(
       padding: const EdgeInsets.only(right: 95, left: 97), // 넓은 여백 고려
       child: Text(
         widget.title,
         textAlign: TextAlign.center,
         style: TextStyle(
           fontSize: 22,
           fontWeight: FontWeight.w700,
           color: AppColors.textWhite, // style_CR7KAC
           height: 1.5,
         ),
         maxLines: 2,
         overflow: TextOverflow.ellipsis,
       ),
     );
 }

 Widget _buildProgressBar(double height) {
   return Padding(
     padding: const EdgeInsets.symmetric(horizontal: 30.0), // 좌우 여백
     child: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         SliderTheme(
           data: SliderTheme.of(context).copyWith(
             trackHeight: height,
             thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0), // Ellipse 109 크기 유사하게
             overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
             activeTrackColor: AppColors.textWhite, // 활성 트랙 (피그마 흰색 부분)
             inactiveTrackColor: AppColors.heartIconBorder, // disabledGray -> heartIconBorder (#7E7993)
             thumbColor: AppColors.textWhite, // 슬라이더 핸들 색상
             overlayColor: AppColors.textWhite.withAlpha(0x29), // 터치 효과
           ),
           child: Slider(
             min: 0,
             max: _duration.inSeconds.toDouble(),
             value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
             onChanged: (value) async {
               final position = Duration(seconds: value.toInt());
               await _audioPlayer.seek(position);
               // Optionally resume playback if needed after seeking
               // await _audioPlayer.resume();
             },
           ),
         ),
         const SizedBox(height: 8),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               _formatDuration(_position),
               style: TextStyle(fontSize: 14, color: AppColors.textWhite.withOpacity(0.8)), // style_YPJ2F3 유사
             ),
             Text(
               _formatDuration(_duration), // 총 시간
               style: TextStyle(fontSize: 14, color: AppColors.textGray), // style_YPJ2F3 #8F8AA1 유사
             ),
           ],
         ),
       ],
     ),
   );
 }

  Widget _buildControls() {
    // 피그마 Frame 88 레이아웃: space-between, gap 30px
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0), // 전체 컨트롤 영역 패딩
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좋아요 버튼 (Icon_heart_large)
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/Icon_heart_large.svg', // 에셋 경로 확인 필요 (분홍색 하트)
              width: 28, height: 28,
               colorFilter: _isFavorited
                   ? null
                   : ColorFilter.mode(AppColors.heartIconBackground, BlendMode.srcIn), // 비활성화 시 필터 유지
             ),
             iconSize: 28,
             onPressed: () async {
              if (_isFavorited) {
                await FavoriteDatabase.instance.removeFavorite(widget.musicPath);
              } else {
                await FavoriteDatabase.instance.addFavorite(widget.musicPath);
              }
              setState(() => _isFavorited = !_isFavorited);
            },
          ),
          // 15초 뒤로 (Icon_rewind)
           IconButton(
             icon: SvgPicture.asset(
                 'assets/images/Icon_rewind.svg', // 에셋 경로 확인 필요
                 width: 28, height: 28,
                 colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                 ),
              iconSize: 28,
             onPressed: () async {
                final newPosition = _position - const Duration(seconds: 15);
                await _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
             },
           ),
          // 재생/일시정지 버튼 (Group 33)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.chipSelectedBackground, // primary -> chipSelectedBackground (#724BFF)
              shape: BoxShape.circle,
            ),
            child: IconButton(
               icon: SvgPicture.asset(
                 _isPlaying ? 'assets/images/Icon_stop.svg' : 'assets/images/play_icon.svg', // 에셋 경로 확인 필요
                 width: 32, height: 32,
                 colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                 ),
               iconSize: 32,
               onPressed: () async {
                  if (_isPlaying) {
                    await _audioPlayer.pause();
                  } else {
                     try {
                        // Ensure source is set before playing, especially if player was stopped/reset
                        // await _audioPlayer.setSource(AssetSource(widget.musicPath.replaceFirst('assets/', '')));
                        await _audioPlayer.resume();
                     } catch (e) {
                       print("Error resuming/playing audio: $e");
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('음악 재생에 실패했습니다.')),
                       );
                     }
                  }
               },
            ),
          ),
          // 15초 앞으로 (Icon_fast winding)
           IconButton(
             icon: SvgPicture.asset(
                 'assets/images/fastforward_15_icon.svg', // 에셋 경로 확인 필요
                 width: 28, height: 28,
                  colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                 ),
             iconSize: 28,
             onPressed: () async {
                final newPosition = _position + const Duration(seconds: 15);
                await _audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
             },
           ),
          // 반복 버튼 (Icon_ repeat)
           IconButton(
             icon: SvgPicture.asset(
                 'assets/images/Icon_repeat.svg', // 에셋 경로 확인 필요
                 width: 28, height: 28,
                  colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                 ),
              iconSize: 28,
             onPressed: () {
               // 반복 설정 로직 (예: setReleaseMode(ReleaseMode.loop))
                _audioPlayer.setReleaseMode(ReleaseMode.loop); // 예시: 무한 반복
                // TODO: 반복 상태 UI 업데이트 (아이콘 변경 등)
             },
           ),
        ],
      ),
    );
  }

   Widget _buildAutoOffToggle() {
    // 피그마 디자인 유사하게 구현
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '잠들면 어플 자동 종료',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textWhite.withOpacity(0.9), // style_HGMID7 유사
            ),
          ),
          const SizedBox(width: 12),
          // 토글 스위치 (피그마 Frame 254 - on 상태)
          // 실제로는 CupertinoSwitch 또는 custom 위젯 사용 권장
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.textWhite, // 피그마 fill_W8CG62
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'on',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.mainBackground, // 피그마 fill_VQHWGA (#131218)
              ),
            ),
          ),
        ],
      ),
    );
   }
} 