import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:guitarplayer/component/guitarRecord.dart';
import 'package:guitarplayer/component/guitarSound.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({super.key});
  @override
  State<PlayListScreen> createState() => PlayListScreenState();
}

class PlayListScreenState extends State<PlayListScreen> {
  List<GuitarRecording> recordings = [];
  int? expandedIdx; // 재생목록에 갤럭시처럼 확장후 재생을 구현을 위해 확장된 목록의 index
  GuitarSound? soundEngine;// 구현해놓은 기타 사운드 엔진 가져옴
  Timer? timer; //시간관련 동작을 위해 진행상황을 콜백하는 용도
  double elapsed = 0.0; //경과시간 시작은0초라서 0초로 초기화
  int eventIdx = 0;
  //event는 guitarrecord의 event인데
  //안에 저장되어있는 것들은 string, fret ,time3가지가 저장되어있다
  //이게 리스트로 저장되어있어서 시간에 맞는 음을 실행시키는 방법을 사용
  //실제 녹음보다는 이 프로그램에 맞는 녹음방법 생성
  bool isPlaying = false;

  //확장된 재생목록의 인덱스 비어있으면 null, 아니면 녹음본중 된 index번째 녹음본가져오기
  GuitarRecording? get expandedRec =>
      expandedIdx == null ? null : recordings[expandedIdx!];

  //가져온 녹음본의 총 재생길이를 가져오는 비어있으면 0.0초(취소,확장안됨) 있다면 이벤트의의 마지막리스트
  //는 총길이의 초를 가지고 있다 => 이걸 가져와서 총길이로 한다
  double get totalDuration => expandedRec?.events.isEmpty ?? true
      ? 0.0
      : expandedRec!.events.last.time;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    loadRecordings();
  }

  @override
  void dispose() {
    timer?.cancel();
    soundEngine?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  //로드가되면
  void loadRecordings() async {
    //guitarrecord에있는 모든 레코딩파일을 받아오고
    final list = await loadAllRecordings();
    //setstate로 다시 빌드해준다
    setState(() {
      recordings = list;
      expandedIdx = null;
      soundEngine?.dispose();
      soundEngine = null;
      timer?.cancel();
      elapsed = 0.0;
      isPlaying = false;
    });
  }

  void deleteRecords(int idx) async {
    await deleteRecording(recordings[idx].id);
    //guiarRecord에있는 삭제함수발생 및 로드(setstate)
    loadRecordings();
  }

  //실행할 녹음본 클릭했을때 불러올 것들
  void expandTile(int idx) {
    if (expandedIdx == idx) return; // 이미 열려있으면 무시
    setState(() {
      expandedIdx = idx;             //확장인덱스
      soundEngine?.dispose();        //기존 사운드엔진있으면 종로
      soundEngine = GuitarSound();   //사운드엔진 생성
      soundEngine!.load();           //사운드엔진 샘플초기화(0~6번줄)
      timer?.cancel();               //재생중이던 타이머있으면 정지
      elapsed = 0.0;                 //재생시간0초초기화
      eventIdx = 0;                  //이벤트인덱스 0초로 초기화
      isPlaying = false;             //재생중x로 초기화 재생버튼을 눌러야 실행
    });
  }

  //플레이 함수
  void play() {
    //녹은본이 없거나, 재생중x 면 return
    if (expandedRec == null || isPlaying) return;
    setState(() => isPlaying = true);
    //재생중 true로 바꿔주고
    //타이머지정 해주는데 Timer.periodic=> 지정시간마다 콜백해주는 즉0.02초마다 콜백해줌
    timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (!isPlaying) return;
      //재생중이 아니면 return stop하지 않는이유는 새로만들고 삭제하는과정이 생겨서 그냥 return만해서 밑의 함수만 실행 x
      elapsed += 0.02;
      //0.02초지나가고 현재시간이하의 이벤트를 재생시키고
      //이벤트 인덱스 지금 인덱스 < 내가가지고 있는 모든 이벤트 개수가 충족되고
      // 지금 이벤트인덱스에 해당하는 시간이 현재 진행시간보다 작다면
      while (eventIdx < expandedRec!.events.length &&
          expandedRec!.events[eventIdx].time <= elapsed) {
        final ev = expandedRec!.events[eventIdx];
        //재생해야할 이벤트를 가져오고
        //playNote로 이벤트에 저장된 sting, fret실행
        soundEngine!.playNote(ev.stringNum, ev.fretNum);
        eventIdx++;
        //인덱스 증가
      }
      //총길이보다 넘는다면 자동으로 멈추게
      setState(() {});
      if (elapsed >= totalDuration) stop();
    });
  }

  void pause() {
    //재생상태 변환
    setState(() => isPlaying = false);
  }

  void stop() {
    //타이머 캔슬아니면 캔슬시키고
    timer?.cancel();
    //재생시간, 인덱스, 재생상테 전부 변환
    setState(() {
      elapsed = 0.0;
      eventIdx = 0;
      isPlaying = false;
    });
  }

  //slider위젯에 들어갈 함수인데
  //매개변수로 받은 재생시간을 가져와서
  void seek(double v) {
    setState(() {
      elapsed = v;
      //이벤트인덱스위치를 찾고
      eventIdx = expandedRec!.events.indexWhere((e) => e.time >= v);
      //이벤트가없다면(끝이라면) 이벤트길이만큼 맞춰준다
      if (eventIdx < 0) eventIdx = expandedRec!.events.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('녹음 재생목록')),
      body: ListView.builder(
        //리스트뷰, 녹음본 길이만큼
        itemCount: recordings.length,

        itemBuilder: (context, idx) {
          final rec = recordings[idx];
          final isExpanded = expandedIdx == idx;
          //녹음본, 확장된부분 가져오고
          return Column(
            children: [
              ListTile(
                //listtile사용해서 정렬, 규격은 대충 맞게, 녹
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                title: Text('녹음본:\n${rec.id}', style: TextStyle(fontSize: 15)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isExpanded
                      //실행여부에 따라 플레이버튼이랑 일시정지버튼이랑
                          ? (isPlaying ? Icons.pause : Icons.play_arrow)
                          : Icons.play_arrow),
                      onPressed: () {
                        if (!isExpanded) {
                          expandTile(idx);
                        }
                        if (isPlaying) {
                          pause();
                        } else {
                          play();
                        }
                      },
                    ),
                    //삭제버튼
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteRecords(idx),
                    ),
                  ],
                ),
                //원하는 녹음본 탭하면 그 인덱스에맞는 저거 불러와짐 listtitle의ontap
                onTap: () => expandTile(idx),
              ),
              //갤럭시 녹음앱처럼 누르면 샥 펼쳐지고 닫혀지고 그런 과정을 애니메이션처럼
              //부드럽게 보여주는 container
              AnimatedContainer(
                //애니메이션 작동시간, 변하는 높이, 등 지정해서 바꾸기
                duration: Duration(milliseconds: 220),
                height: isExpanded ? 110 : 0,
                curve: Curves.easeInOut,//애니메이션속도를 커브곡선그리는 느낌으로 느리다빠르다느리다
                padding: EdgeInsets.symmetric(horizontal: 18),//안에 여백
                child: isExpanded//확장이되면
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Slider(
                      //펼쳐지면 슬라이더가 펼쳐지고 초기화시킨다
                      min: 0,
                      max: totalDuration,
                      value: elapsed.clamp(0, totalDuration),
                      onChanged: seek,//슬라이더전용함수 위에만들어둠
                    ),
                    Row(
                      //재생 시간 현재초
                      children: [
                        Text(
                          '${elapsed.toStringAsFixed(2)} / ${totalDuration.toStringAsFixed(2)}초',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                )
                    : null,
              ),
              Divider(height: 1, thickness: 0.6),//리스트 구분선
            ],
          );
        },
      ),
    );
  }
}
