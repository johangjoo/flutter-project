import 'package:flutter/material.dart';
import 'package:guitarplayer/component/playguitar.dart';
import 'package:flutter/services.dart';
import 'package:guitarplayer/component/playList.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  //세로 고정 함수
  void _setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _setPortraitMode();
    //세로고정 시작
    return Scaffold(
      //이미지가가장 아래로 가게 stack을사용 후 어느 화면에서든 보이게 expand시키기
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/imgs/guitar.png',
            fit: BoxFit.cover, // 이미지가 화면을 채구에
          ),

          //중앙에 guitar, 재생목록 버튼
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
                      Navigator.push(//새 화면을 띄우는 함수
                        context,
                        MaterialPageRoute(builder: (context) => const GuitarScreen()),
                      );
                    },
                    //추천 받은 버튼 스타일 : 둥근 박스를 두개 써서 버튼임을 강조하고 약간 투명하게 하지만
                    //검게 만들어서 감?각 있께 마지막 컨테이너는 텍스트 컨테이너
                    style: OutlinedButton.styleFrom(
                      // 버튼의 기본 패딩을 제거해서 꽉 차게 함
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // 버튼의 기본 테두리는 투명하게 처리
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    //가장 밖 컨테이너
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        //두번째 컨테이너
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
                          ),
                          //마지막 컨테이너(텍스트)
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  //뭔가 그라데이션 써보고 싶었음
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
                        //재생목록화면으로 가는
                        MaterialPageRoute(builder: (_) => PlayListScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
                          ),
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
