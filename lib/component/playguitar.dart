import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
//landscape모드 사용

class GuitarApp extends StatelessWidget {
  const GuitarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: GuitarScreen());
  }
}

class GuitarScreen extends StatefulWidget {
  const GuitarScreen({super.key});

  @override
  State<GuitarScreen> createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  //Offset하면x,y둘다 되서 이미지의x만 받아서 최대최소 정해놓고 이동시키게함
  double imgX = 0;
  bool _initialized = false;
  final AudioPlayer _player = AudioPlayer();

  void initState() {
    super.initState();
    // guitart 버튼을 누르면 guitar앱으로 가지면서 가로모드가 켜지게
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void dispose() {
    // 나가게 되면 세로로 돌아가게 설정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _player.dispose();
    super.dispose();
  }

  /// 세미톤(n) → pitch factor: 2^(n/12)
  double _semitoneToPitch(int semitones) => pow(2, semitones / 12).toDouble();

  /// stringNum: 1~6 → semitones = (6 - stringNum)
  Future<void> _playString(int stringNum) async {
    // 0프렛 음원 경로
    final assetPath = 'assets/sounds/string_${stringNum}_fret_0.mp3';
    // string6=0st, string5=+1st … string1=+5st
    final semitones = 6 - stringNum;
    final pitch = _semitoneToPitch(semitones);

    // just_audio 순서대로 호출
    await _player.setAsset(assetPath);
    await _player.setPitch(pitch);
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = 700;
    final double imgWidth = 1279.0;
    const double buttonWidth = 200.0;
    //위는 화면 실행 기기 최대길이와 이미지 길이
    //아래는 화면에 보이게될 부분
    final double minX = 0;
    final double maxX = (imgWidth - screenWidth).clamp(0, double.infinity);
    //이미지 시작시 오른쪽 부터 보이게 해야하기때문에
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          imgX = maxX;
          _initialized = true;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: buttonWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('핑거')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: () {}, child: Text('스트로크')),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  //builder: 하면 위잿않에 부모위잿을 바탕으로하는 위젯? 같은거를 구현가능? 잘 모름
                  return GestureDetector(
                    onPanUpdate:
                        (d) => setState(() {
                          //바뀐 이미지 x값 받아오기
                          final nextX = imgX - d.delta.dx;
                          imgX = nextX.clamp(minX, maxX);
                        }),
                    child: Stack(
                      children: [
                        Positioned(
                          left: -imgX,
                          top: 0, //위아래 고정 좌우 움직이기
                          child: Image.asset(
                            'assets/imgs/guitarImg.png',
                            width: 1279,
                            fit: BoxFit.none,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
