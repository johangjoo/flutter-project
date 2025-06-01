import 'dart:math';
import 'package:just_audio/just_audio.dart';

class GuitarSound {
  // 6줄 각각 플레이어
  final List<AudioPlayer> _players = List.generate(6, (_) => AudioPlayer());

  // 각 줄별 fret0 음원 파일 경로 (줄 1~6)
  final List<String> _noteAssets = [
    'assets/sounds/string_1_fret_0.wav',
    'assets/sounds/string_2_fret_0.wav',
    'assets/sounds/string_3_fret_0.wav',
    'assets/sounds/string_4_fret_0.wav',
    'assets/sounds/string_5_fret_0.wav',
    'assets/sounds/string_6_fret_0.wav',
  ];

  /// 초기화: 각 줄 fret0 음원 미리 로딩
  Future<void> load() async {
    await Future.wait(_players.asMap().entries.map((entry) {
      int sIdx = entry.key;
      AudioPlayer player = entry.value;
      print("Preloading asset: ${_noteAssets[sIdx]}"); // 디버깅용 로그
      return player.setAsset(_noteAssets[sIdx]);
    }));
  }

  /// (내부) 세미톤 → 피치변환
  double _semitoneToPitch(int semitones) => pow(2, semitones / 12).toDouble();

  /// 줄, 프렛 입력받아 음 재생: 줄 1~6, 프렛 0~N
  Future<void> playNote(int stringNum, int fretNum) async {
    final player = _players[stringNum - 1];
    print("Playing asset: ${_noteAssets[stringNum - 1]}");
    await player.setAsset(_noteAssets[stringNum - 1]);
    await player.setPitch(_semitoneToPitch(fretNum));
    await player.seek(Duration.zero);
    await player.play();
  }

  void dispose() {
    for (var p in _players) {
      p.dispose();
    }
  }
}
