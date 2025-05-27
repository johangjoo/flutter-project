import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:guitarplayer/component/guitarButton.dart';
import 'package:guitarplayer/component/guitarpan.dart';
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
  final ScrollController _scrollCtrl = ScrollController();
  final AudioPlayer _player = AudioPlayer();
  late final List<AudioPlayer> _stringPlayers;
  void initState() {
    super.initState();
    // guitart 버튼을 누르면 guitar앱으로 가지면서 가로모드가 켜지게
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _stringPlayers = List.generate(6, (_) => AudioPlayer());

    Future.wait(_stringPlayers.asMap().entries.map((e) {
      final idx = e.key;        // 0~5
      final player = e.value;
      return player.setAsset(
          'assets/sounds/string_${idx+1}_fret_0.mp3'
      );
    }));
  }

  void dispose() {
    // 나가게 되면 세로로 돌아가게 설정
    _scrollCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  /// 세미톤(n) → pitch factor: 2^(n/12)
  double _semitoneToPitch(int semitones) => pow(2, semitones / 12).toDouble();

  /// stringNum: 1~6, fretIndex: 0~(총프렛수-1)
  Future<void> _playNote(int stringNum, int fretIndex) async {
    // 1) 해당 줄용 플레이어 가져오기 (stringNum=1→_stringPlayers[0])
    final player = _stringPlayers[stringNum - 1];

    // 2) 재생 위치를 처음으로 돌립니다.
    await player.seek(Duration.zero);

    // 3) 피치 계산: 기본 semitone + 프렛 인덱스
    final baseSemitones = 6 - stringNum;
    final totalSemitones = baseSemitones + fretIndex;
    final pitch = _semitoneToPitch(totalSemitones);

    // 4) 피치만 설정하고 재생
    await player.setPitch(pitch);
    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    const int frets = 16;
    const double imgWidth = 1279.0;
    final double phoneW = MediaQuery.of(context).size.width;

    // 1/9: left panel, 8/9: fretboard viewport
    final double leftW = phoneW / 9;
    final double boardW = phoneW - leftW;

    const double btnH = 44.0;
    const double topPad = 18.0;
    // 뷰포트 높이
    final imgDisplayH = 300.0;

    // 1279px 기준 구간별 픽셀너비
    const List<double> fretwidths = [
      50.04, 53.02, 56.17, 59.50,
      63.05, 66.80, 70.76, 74.97,
      79.43, 84.16, 89.17, 94.47,
      100.07, 106.03, 112.34, 119.01,
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // ─── 왼쪽 컨트롤 ─────────────────────────────
            SizedBox(
              width: leftW,
              child: Column(
                children: const [
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: null, child: Text('핑거')),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: null, child: Text('스트로크')),
                ],
              ),
            ),

            // ─── 오른쪽: 스크롤 가능한 프렛보드 뷰포트 ────
            SizedBox(
              width: boardW,
              height: imgDisplayH,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: imgWidth,
                  height: imgDisplayH,
                  child: Stack(
                    children: [
                      // 1) 전체 기타 이미지 (원본 폭 1279px)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Image.asset(
                          'assets/imgs/guitarImg.png',
                          width: imgWidth,
                          height: imgDisplayH,
                          fit: BoxFit.none,
                        ),
                      ),

                      // 2) 버튼 오버레이 (topPad 만큼 아래에서 시작)
                      Positioned(
                        left: 0,
                        top: topPad,
                        child: Column(
                          children: List.generate(6, (row) {
                            final int stringNum = 6 - row; // 위쪽이 6번줄
                            return Row(
                              children: List.generate(frets, (col) {
                                final int fretNum = frets - 1 - col; // 왼쪽이 16프렛
                                return SizedBox(
                                  width: fretwidths[col],
                                  height: btnH,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      print('String: $stringNum, Fret: $fretNum');
                                      _playNote(stringNum, fretNum);
                                    },
                                    child: SizedBox(
                                    width: fretwidths[col],
                                    height: btnH,
                                  ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
