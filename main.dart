import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const GuitarApp());
}

class GuitarApp extends StatelessWidget {
  const GuitarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GuitarScreen(),
    );
  }
}

class NoteEvent {
  final int stringNumber;
  final int fretNumber;
  final Duration timestamp;

  NoteEvent({required this.stringNumber, required this.fretNumber, required this.timestamp});
}

class GuitarScreen extends StatefulWidget {
  const GuitarScreen({super.key});

  @override
  State<GuitarScreen> createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  final player = AudioPlayer();
  final Stopwatch recorder = Stopwatch();
  final List<NoteEvent> recordedNotes = [];
  bool isRecording = false;

  void onStringPluck(int stringNum) {
    int fretNum = 0; // 기본 0프렛
    final time = recorder.elapsed;
    if (isRecording) {
      recordedNotes.add(NoteEvent(
        stringNumber: stringNum,
        fretNumber: fretNum,
        timestamp: time,
      ));
    }
    playSound(stringNum, fretNum);
  }

  void playSound(int stringNum, int fretNum) async {
    final filename = 'sounds/string_${stringNum}_fret_${fretNum}.mp3';
    await player.play(AssetSource(filename));
  }

  void startRecording() {
    recordedNotes.clear();
    recorder.reset();
    recorder.start();
    setState(() {
      isRecording = true;
    });
    Future.delayed(const Duration(minutes: 1), stopRecording);
  }

  void stopRecording() {
    if (!recorder.isRunning) return;
    recorder.stop();
    setState(() {
      isRecording = false;
    });
  }

  void playRecording() {
    for (var event in recordedNotes) {
      Future.delayed(event.timestamp, () {
        playSound(event.stringNumber, event.fretNumber);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    int stringNum = index + 1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onStringPluck(stringNum),
                        child: Container(
                          width: double.infinity,
                          color: Colors.brown[100 * (stringNum % 9)],
                          alignment: Alignment.center,
                          child: Text(
                            'String $stringNum',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Container(
                height: 100,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isRecording ? null : startRecording,
                      child: const Text('녹음 시작'),
                    ),
                    ElevatedButton(
                      onPressed: isRecording ? stopRecording : null,
                      child: const Text('녹음 종료'),
                    ),
                    ElevatedButton(
                      onPressed: playRecording,
                      child: const Text('재생'),
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
