import 'package:flutter/material.dart';
import 'package:sleept/features/sleep/service/music_database.dart';
import '../../utils/app_colors.dart'; // AppColors 임포트
import 'components/widgets/sleep_chihp_list.dart';
import 'components/widgets/sleep_content_card.dart';
import 'components/widgets/sleep_header.dart';
import 'components/widgets/sleep_horizontal_list.dart';
import 'components/widgets/sleep_recent_play_list.dart';
import 'components/widgets/sleep_section_title.dart';
import 'package:sleept/models/music_model.dart';
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SleepHeaderDelegate(
                child: Container(
                  height: 190,
                  color: AppColors.mainBackground,
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 33,
                  ),
                  child: const SleepHeaderText(
                    text: 'Siha님, 지난 밤 수면을 보완해줄 \n잠 오는 콘텐츠 추천해드릴게요',
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SleepSectionTitle('최근 재생한 콘텐츠', topPadding: 0,)),
            SliverToBoxAdapter(child: SleepRecentPlayList()),
            SliverToBoxAdapter(child: const SizedBox(height: 39)),
            SliverToBoxAdapter(child: const SleepChihpList()),
            SliverToBoxAdapter(child: const SleepSectionTitle('이번주 조회수 Top 10', topPadding: 20)),
            SliverToBoxAdapter(
              child: SleepHorizontalList(
                cards: _musics.map((m) => SleepContentCard(
                  imagePath: m.imagePath,
                  title: m.title,
                  category: m.category,
                  duration: m.duration,
                  musicPath: m.musicPath,
                )).toList(),
              ),
            ),
            SliverToBoxAdapter(child: const SleepSectionTitle('스르륵 눈이 감기는 날', topPadding: 20)),
            SliverToBoxAdapter(
              child: SleepHorizontalList(
                cards: _musics.map((m) => SleepContentCard(
                  imagePath: m.imagePath,
                  title: m.title,
                  category: m.category,
                  duration: m.duration,
                  musicPath: m.musicPath,
                )).toList(),
              ),
            ),
            SliverToBoxAdapter(child: const SleepSectionTitle('편안한 자연의 소리', topPadding: 20)),
            SliverToBoxAdapter(
              child: SleepHorizontalList(
                cards: _musics.map((m) => SleepContentCard(
                  imagePath: m.imagePath,
                  title: m.title,
                  category: m.category,
                  duration: m.duration,
                  musicPath: m.musicPath,
                )).toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 67,),
            )
          ],
        ),
      ),
    );

  }


}

class _SleepHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SleepHeaderDelegate({required this.child});

  @override
  double get minExtent => 190;
  @override
  double get maxExtent => 190;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
