import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guitarplayer/component/guitarSound.dart';
import 'package:guitarplayer/component/guitarRecord.dart';
import 'playList.dart';

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
  late final RecordingController _recorder;
  late final GuitarSound _soundEngine;
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _recordTimer;
  double _recordElapsedSec = 0.0;
  final double _recordMaxSec = 60.0;
  bool _isRecording = false;

  void initState() {
    super.initState();
    _soundEngine = GuitarSound();
    _soundEngine.load();
    _recorder = RecordingController();
    // guitart 버튼을 누르면 guitar앱으로 가지면서 가로모드가 켜지게
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);
    //기타의 이미지가 오른쪽 끝 부터 시작해서 시작하면 initstate에서 스크롤을 오른쪽 끝으로 바꿔준다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    });
  }


  void dispose() {
    // 나가게 되면 세로로 돌아가게 설정
    _soundEngine.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  //프렛버튼 누를때 실행 되는 함수
  void _onNotePressed(int stringNum, int fretNum) {
    _soundEngine.playNote(stringNum, fretNum);
    _recorder.recordFret(stringNum, fretNum);
  }

  //레코딩 시작할 때
  void _startRecording() {
    _recorder.startRecording();
    setState(() {
      _isRecording = true;
      _recordElapsedSec = 0.0;
    });
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordElapsedSec += 0.1;
        if (_recordElapsedSec >= _recordMaxSec) {
          _stopRecording();
        }
      });
    });
  }

  //레코딩 멈출때
  Future<void> _stopRecording() async {
    _recorder.stopRecording();
    await saveRecording(GuitarRecording(
      id: DateTime.now().toIso8601String(),
      events: List.of(_recorder.events),
    ));
    setState(() {
      _isRecording = false;
      _recordTimer?.cancel();
      _recordElapsedSec = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const int frets = 16;
    const double imgWidth = 1279.0;
    final double phoneW = MediaQuery
        .of(context)
        .size
        .width;

    // 1/9: left panel, 8/9: fretboard viewport
    final double leftW = phoneW / 9;
    final double boardW = phoneW - leftW;

    const double btnH = 44.0;
    const double topPad = 10.0;
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
        child: Column(
          //전체와 녹음바
          children: [

            Expanded(
              child: Row(
                children: [
                  // ─── 왼쪽 버튼 패널 ───
                  SizedBox(
                    width: leftW,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isRecording ? null : _startRecording,
                          child: Text('녹음'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isRecording ? _stopRecording : null,
                          child: Text('정지'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PlayListScreen()),
                            );
                          },
                          child: Text('재생 목록'),
                        ),
                      ],
                    ),
                  ),
                  // ─── 오른쪽 프렛보드 ───
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: imgWidth,
                        height: imgDisplayH,
                        child: Stack(
                          children: [
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
                            // 버튼 오버레이
                            Positioned(
                              left: 0,
                              top: topPad,
                              child: Column(
                                children: List.generate(6, (row) {
                                  final int stringNum = 6 - row;
                                  return Row(
                                    children: List.generate(frets, (col) {
                                      final int fretNum = frets - 1 - col;
                                      return SizedBox(
                                        width: fretwidths[col],
                                        height: btnH,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            print(
                                                'String: $stringNum, Fret: $fretNum');
                                            _onNotePressed(stringNum, fretNum);
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
            // ─── 하단 진행바/타이머 (녹음 중에만) ───
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 24.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _recordElapsedSec / _recordMaxSec,
                      minHeight: 8.0,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '녹음 중: ${_recordElapsedSec.toStringAsFixed(
                          1)} / $_recordMaxSec 초',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}