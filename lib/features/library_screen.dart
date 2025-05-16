import 'package:flutter/material.dart';

import '../constants/colors.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {

  List itemList =[
    {'imagePath':'stretching', 'title':'스트레칭'},
    {'imagePath':'mediation', 'title':'명상'},
    {'imagePath':'podcast', 'title':'팟캐스트'},
    {'imagePath':'asmr', 'title':'ASMR'},
    {'imagePath':'whitenoise', 'title':'백색소음'},
    {'imagePath':'waves', 'title':'뇌파'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 33),
          child: Column(
            children: [
              Text(
                '쿨쿨돼지님의 라이브러리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 28,),
              Container(
                width: 343,
                padding: const EdgeInsets.all(6),
                decoration: ShapeDecoration(
                  color: const Color(0xFF2B2838) /* Primitive-Color-gray-850 */,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 1,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              '저장한 콘텐츠',
                              style: TextStyle(
                                color: const Color(0xFF242030) /* Primitive-Color-gray-900 */,
                                fontSize: 16,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              '습관 리스트',
                              style: TextStyle(
                                color: const Color(0xFF8E8AA1) /* Primitive-Color-gray-500 */,
                                fontSize: 16,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28,),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // Number of columns in the grid
                  crossAxisSpacing: 19,
                  // Space between columns
                  mainAxisSpacing: 28,
                  childAspectRatio: 162/226
                ),
                itemCount: itemList.length,
                // Number of items in the grid
                itemBuilder: (context, index) {
                  return wdgtItemCard(itemList[index]['imagePath'], itemList[index]['title'], 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  wdgtItemCard(String imagePath, String title, int count ){
    return Container(
      width: 162,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/library_$imagePath.jpg'),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Container(
            width: 54,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Min Sans',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
                SizedBox(
                  width: 54,
                  child: Text(
                    '총 $count개',
                    style: TextStyle(
                      color: const Color(0xFFB8B6C0) /* Primitive-Color-gray-300 */,
                      fontSize: 13,
                      fontFamily: 'Min Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



}
