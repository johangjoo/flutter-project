import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
//녹음 구현
//string fret time 3개 필요
class RecordEvent {
  final int stringNum;
  final int fretNum;
  final double time; // 초 단위

  RecordEvent({required this.stringNum, required this.fretNum, required this.time});

  Map<String, dynamic> toJson() => {
    'stringNum': stringNum,
    'fretNum': fretNum,
    'time': time,
  };
  //recordevent에 입력받은 내용들을
  //저장시 tojson 불러올시 fromjson해서 가져옴
  factory RecordEvent.fromJson(Map<String, dynamic> json) => RecordEvent(
    stringNum: json['stringNum'],
    fretNum: json['fretNum'],
    time: json['time'],
  );

}

//녹음 컨트롤 하는 부분
class RecordingController {
  final List<RecordEvent> events = [];
  //녹음되는것들, 1분까지 stopwatch저장 레코딩중인지 아닌지 시간을 재는 객체
  Stopwatch? stopwatch;
  bool isRecording = false;

  void startRecording() {
    //레코딩 시작되면 새로운 스탑워치객체 생성하고 바로 시작하는 문법

    stopwatch = Stopwatch()..start();
    //직전까지 녹음된 기록이 있다면 clear, 레코딩중true
    events.clear();
    isRecording = true;
  }

  void stopRecording() {
    //스탑워치 정지하고 레코딩false전환
    if (isRecording && stopwatch != null) {
      // 실제 녹음이 종료된 시간을 기록하는 이벤트 추가
      // stringNum: -1 과 같이 실제 연주될 수 없는 값으로 구분합니다.
      double finalTime = stopwatch!.elapsedMilliseconds / 1000.0;
      events.add(RecordEvent(stringNum: -1, fretNum: -1, time: finalTime));
    }
    stopwatch?.stop();
    isRecording = false;
  }

  void recordFret(int string, int fret) {
    //레코딩이 아니거나 스탑워치가 비어있다면 return
    if (!isRecording || stopwatch == null) return;
    //레코딩 중이라면
    double timeSec = stopwatch!.elapsedMilliseconds / 1000.0;
    //시간정보를 stopwatch가 null이 아닐때 켜진다음에 시간을 받아와서(1000으로 나눠서 밀리초계산)
    //그러고 string, fret time정보를 events리스트에 recordevent객체 추가
    events.add(RecordEvent(stringNum: string, fretNum: fret, time: timeSec));
  }

//녹음 된것 리스트

}
//녹음된 것들을 관리하는 부분
class GuitarRecordings {
  final String id; //녹음본에id매기고
  final List<RecordEvent> events;

  GuitarRecordings({required this.id, required this.events});
  //tojson
  Map<String, dynamic> toJson() => {
    'id': id,
    'events': events.map((e) => e.toJson()).toList(),
  };



  //fromjson부분
  factory GuitarRecordings.fromJson(Map<String, dynamic> json) => GuitarRecordings(
    id: json['id'],
    events: (json['events'] as List).map((e) => RecordEvent.fromJson(e)).toList(),
  );
}

//녹음 저장 불러오기 삭제 정의
// 저장 함수
Future<void> saveRecording(GuitarRecordings rec) async {
  final box = await Hive.openBox('guitar_recordings');
  await box.put(rec.id, jsonEncode(rec.toJson()));
}

// 불러오기 함수 (리스트)
Future<List<GuitarRecordings>> loadAllRecordings() async {
  final box = await Hive.openBox('guitar_recordings');
  return box.values
      .map((e) => GuitarRecordings.fromJson(jsonDecode(e)))
      .toList();
}

// 삭제 함수
Future<void> deleteRecording(String id) async {
  final box = await Hive.openBox('guitar_recordings');
  await box.delete(id);
}