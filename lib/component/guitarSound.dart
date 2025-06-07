import 'dart:math';
import 'package:just_audio/just_audio.dart';

class GuitarSound {
  // 6줄 각각 플레이어
  final List<AudioPlayer> players = List.generate(6, (_) => AudioPlayer());

  // 각 줄별 fret0 음원 파일 경로 (줄 1~6)
  final List<String> noteAssets = [
    'assets/sounds/string_1_fret_0.wav',
    'assets/sounds/string_2_fret_0.wav',
    'assets/sounds/string_3_fret_0.wav',
    'assets/sounds/string_4_fret_0.wav',
    'assets/sounds/string_5_fret_0.wav',
    'assets/sounds/string_6_fret_0.wav',
  ];

  /// 초기화: 각 줄 fret0 음원 미리 로딩
  Future<void> load() async {
    await Future.wait(players.asMap().entries.map((entry) {
      int sIdx = entry.key;
      AudioPlayer player = entry.value;
      print("Preloading asset: ${noteAssets[sIdx]}"); // 디버깅용 로그
      return player.setAsset(noteAssets[sIdx]);
    }));
  }

  /// (내부) 세미톤 → 피치변환
  double semitoneToPitch(int semitones) => pow(2, semitones / 12).toDouble();

  /// 줄, 프렛 입력받아 음 재생: 줄 1~6, 프렛 0~N
  Future<void> playNote(int stringNum, int fretNum) async {
    final player = players[stringNum - 1];
    print("Playing asset: ${noteAssets[stringNum - 1]}");
    await player.setAsset(noteAssets[stringNum - 1]);
    await player.setPitch(semitoneToPitch(fretNum));
    await player.seek(Duration.zero);
    await player.play();
  }

  //일시정지, 다른 녹음본 텝, 뒤로가기등 했을때 모든 플레이어 정지시키는거 추가
  void stopAll() {
    for (final player in players) {
      player.stop();
    }
  }

  void dispose() {
    for (var p in players) {
      p.dispose();
    }
  }
}
