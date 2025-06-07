import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guitarplayer/component/guitarSound.dart';
import 'package:guitarplayer/component/guitarRecord.dart';

class GuitarScreen extends StatefulWidget {
  const GuitarScreen({super.key});

  @override
  State<GuitarScreen> createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  double imgX = 0;//이미지를 좌우로 스크롤 해야해서 X값 변수 생성
  //외부에서 사운드엔진, 레코더생성
  late final RecordingController recorder;
  late final GuitarSound soundEngine;
  //material안에있는 크르롤 컨트롤러 생성
  final ScrollController scrollCtrl = ScrollController();
  //실시간 레코더 타이머생성
  Timer? recordTimer;
  //녹음 경과시간과 최대시간 생성
  double recordElapsedSec = 0.0;
  final double recordMaxSec = 60.0;
  //레코딩 여부 변수 생성
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    soundEngine = GuitarSound();
    soundEngine.load();
    recorder = RecordingController();
    //다 불러와서 초기화 해주고
    //가로모드 켜지게
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,

    ]);
    //모든 위젯트리가 빌드된 다음 발동하는 콜백함수
    //기타 이미지가 가장 오른쪽이 0프렛이기 때문에 이것으로 스크롤 포지션을 가장 끝으로
    //바꿔주어 0프렛이 바로 보이게 설정해준다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    // 나가게 되면 세로로 돌아가게 설정
    soundEngine.dispose();
    scrollCtrl.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

    ]);
    super.dispose();
  }

  //프렛버튼 누를때 실행 되는 함수
  //재생이랑 녹음에 둘다 넘기지만 녹음중이아니면 recordFret은 그냥 return된다.
  void onNotePressed(int stringNum, int fretNum) {
    soundEngine.playNote(stringNum, fretNum);
    recorder.recordFret(stringNum, fretNum);

  }

  //레코딩 시작할 때
  void startRecording() {
    recorder.startRecording();
    //위 함수가 발동되야 recordFretdl wpeofh wkrehdehlsek.
    setState(() {
      //setstate를 통해 녹음여부와 초를 초기화해주고 빌드
      isRecording = true;
      recordElapsedSec = 0.0;
    });
    //?-> null이 아니면 즉 레코드타이머가 혹시라도 켜져있으면 취소시키고 다시 만드는
    recordTimer?.cancel();
    //0.02초 주기로 콜백되는 레코드타이머 생성
    //0.02초마다 경과시간을 0.02초 늘리고 다시 빌드
    //녹음 최대시간넘어가면 알아서 멈춤
    recordTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        recordElapsedSec += 0.02;
        if (recordElapsedSec >= recordMaxSec) {
          stopRecording();
        }
      });
    });
  }

  //레코딩 멈출때
  Future<void> stopRecording() async {
    recorder.stopRecording();
    await saveRecording(GuitarRecordings(
      //id는 지금 현재 시간을 yyyy-mm--ddthh:mm:ss.mmmmm 표준문자열로 변환해서 지정
      id: DateTime.now().toIso8601String(),
      //이벤트는 레코드 활성화 시켰을때 받은 이벤트들을 리스트화새ㅓ
      events: List.of(recorder.events),
    ));
    setState(() {
      isRecording = false;
      recordTimer?.cancel();
      recordElapsedSec = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const int frets = 16;
    const double imgWidth = 1279.0;
    //프렛수와 이미지 최대 길이 지정 그리고 폰사이즈를 받아옴
    final double phoneW = MediaQuery
        .of(context)
        .size
        .width;

    // 왼쪽 1/9를 버튼전용으로 나머지를 기타전용으로
    final double leftW = phoneW / 9;

    //이미지 300중 6줄 대충 맨 아래랑 위 약간은 비워놔야해서 버튼 높이는 44
    // 44x6= 264 나머지 36 -> 18 만큼 높이뛰워줘야함
    const double btnH = 44.0;
    const double topPad = 18.0;
    // 이미지 높이가 300임
    final imgDisplayH = 300.0;

    // 1279px 기준 구간별 픽셀너비 프렛 공식을 이용해 적당히 나눈 프렛 길이
    //다 더하면 1278.99 (이미지 너비 = 1279)
    const List<double> fretwidths = [
      50.04, 53.02, 56.17, 59.50,
      63.05, 66.80, 70.76, 74.97,
      79.43, 84.16, 89.17, 94.47,
      100.07, 106.03, 112.34, 119.01,
    ];

    return Scaffold(
      //배경좀 그라데이션써서 그렇게 위화감 안들게
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4E342E),
              Color(0xFF795548),
              Color(0xFF4E342E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            //전체와 녹음바
            children: [

              Expanded(
                child: Row(
                  children: [
                    // 왼쪽 버튼쪽 패널
                    //첫 화면과 비슷하게 컨테이너 패딩 컨테이너 구조를 이용해 버튼 구현
                    SizedBox(
                      width: leftW,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                //누르면 isrecording이 true면 null(아무것도 안함) 아니면 녹음시작
                                onPressed: isRecording ? null : startRecording,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
                                      ),
                                      child: const Text(
                                        '녹음',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                //누르면 isrecording이 false면 null(아무것도 안함) 아니면 녹음정지
                                onPressed: isRecording ? stopRecording : null,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
                                      ),
                                      child: const Text(
                                        '정지',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                          ],
                        ),
                      ),
                    ),
                    // 오른쪽 기타 부분 패널
                    Expanded(
                      child: SingleChildScrollView(
                        //한 쪽으로만 스크롤 가능한 뷰로 만들음
                        controller: scrollCtrl,
                        //컨트롤러 지정해줘서 모든 위젯 로드된 후
                        //위에서 지정했던 콜백 이용해서 이미지 위치조정
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: imgWidth,
                          height: imgDisplayH,
                          //이미지 크기에 맞게 sizedox생성
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
                                  //List.generate함수는 row를 0부터 시작해 1씩 늘리는 내부적인 기능이 들어있는 함수도 매우 유용
                                  children: List.generate(6, (row) {
                                    final int stringNum = 6 - row;
                                    return Row(
                                      children: List.generate(frets, (col) {
                                        final int fretNum = frets - 1 - col;
                                        return SizedBox(
                                          //미리 지정해두었던 각 프렛의 길이와 버튼높이
                                          width: fretwidths[col],
                                          height: btnH,
                                          //각 위치에 맞게 GestureDetector가 만들어지게됨
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              onNotePressed(stringNum, fretNum);
                                            },
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
              // 레코딩 중일 때만 뜨는 하단 레코딩 바
              if (isRecording)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    //재생바를 위해 약간 여백
                      vertical: 8.0, horizontal: 24.0),
                  child: Column(
                    children: [
                      //재생 바 구현 경과시간/ 최종 초
                      LinearProgressIndicator(
                        value: recordElapsedSec / recordMaxSec,
                        minHeight: 8.0,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        //텍스트로도 보여줌
                        '녹음 중: ${recordElapsedSec.toStringAsFixed(//소수점 반환을 위해 사용
                            1)} / $recordMaxSec 초',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}