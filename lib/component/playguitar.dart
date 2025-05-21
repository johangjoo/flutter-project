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
  Offset _imagePosition = const Offset(0, 0);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Play Guitar')),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() {
                  _imagePosition += d.delta;
                }),
                child: Stack(
                  children: [
                    Positioned(
                      left: _imagePosition.dx,
                      top: _imagePosition.dy,
                      child: Image.asset('assets/imgs/guitarImg.png'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) {
                  return ElevatedButton(
                    onPressed: () => _playString(i + 1),
                    child: Text('String ${i + 1}'),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
    /*
        child: RotatedBox(
          quarterTurns: 1,
          child: Column(
            children: List.generate(6, (i) {
              final stringNum = i + 1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _playString(stringNum),
                  child: Container(
                    color: Colors.brown[100 * (stringNum % 9)],
                    alignment: Alignment.center,
                    child: Text(
                      'String $stringNum',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );

            }
      ),
          ),
        ),
        */
  }
}
