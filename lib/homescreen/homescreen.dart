import 'package:flutter/material.dart';
import 'package:guitarplayer/component/playguitar.dart';
import 'package:flutter/services.dart';
import 'package:guitarplayer/component/playList.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Stack을 사용해 위젯을 겹겹이 쌓습니다.
      body: Stack(
        fit: StackFit.expand, // Stack의 자식들이 화면 전체를 채우도록 설정
        children: [
          // 1. 배경 이미지
          Image.asset(
            'assets/imgs/guitar.png', // 이미지 경로
            fit: BoxFit.cover, // 이미지가 화면을 가득 채우도록 설정
          ),

          // 2. 중앙 버튼
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 기타 버튼
                SizedBox(
                  width: 200,
                  height: 100,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GuitarApp()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      // 버튼의 기본 패딩을 제거해서 내부 컨텐츠가 꽉 차게 함
                      padding: EdgeInsets.zero,
                      // 버튼의 기본 테두리 모양
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // 버튼의 기본 테두리는 투명하게 처리 (우리가 직접 그릴 것이므로)
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    child: Container(
                      // 첫 번째 테두리 (바깥쪽, 가장 굵은 현)
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          // 두 번째 테두리 (안쪽, 얇은 현)
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
                          ),
                          // 실제 버튼 배경 및 텍스트
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: const Text(
                              'Guitar',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(1.0, 1.0)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ),

                const SizedBox(height: 24),

                // 재생 목록 버튼
                SizedBox(
                  width: 200,
                  height: 100,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlayListScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      // 버튼의 기본 패딩을 제거해서 내부 컨텐츠가 꽉 차게 함
                      padding: EdgeInsets.zero,
                      // 버튼의 기본 테두리 모양
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // 버튼의 기본 테두리는 투명하게 처리 (우리가 직접 그릴 것이므로)
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    child: Container(
                      // 첫 번째 테두리 (바깥쪽, 가장 굵은 현)
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          // 두 번째 테두리 (안쪽, 얇은 현)
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
                          ),
                          // 실제 버튼 배경 및 텍스트
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: const Text(
                              '재생 목록',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(1.0, 1.0)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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