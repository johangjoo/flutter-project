import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

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
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guitar: 6→1 String Pitch')),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: _imagePosition.dx,
              top: _imagePosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _imagePosition += details.delta;
                  });
                },
                child: Image.asset(
                  'assets/imgs/assetimg/guitarImg.png',
                  width: 120,
                  height: 120,
                ),
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
