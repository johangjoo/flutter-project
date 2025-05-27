import 'package:flutter/material.dart';

class guitarButtons extends StatelessWidget {
  //기타버튼 위젯
  //줄번호랑 프렛번호, 각 프렛이랑 줄에 맞는 버튼의 크기
  final int numStrings;
  final int numFrets;
  final double buttonWidth;
  final double buttonHeight;
  final void Function(int stringIndex, int fretIndex) onFretPressed;

  const guitarButtons({
    Key? key,
    this.numStrings = 6,
    required this.numFrets,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.onFretPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //6x16 줄x프렛이기때문에 먼저 column으로 줄6개 배치 후
      //row로 프렛 배치를 해준다
      children: List.generate(numStrings, (stringIndex) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(numFrets, (fretIndex) {
            // 화면 확인용 문자열 (String 번호, Fret 번호)
            final displayString = numStrings - stringIndex;
            final displayFret   = numFrets - fretIndex;
            return SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onFretPressed(stringIndex, fretIndex),
                child: Container(
                  color: Colors.white.withOpacity(0.9),
                  alignment: Alignment.center,
                  child: Text(
                    'S$displayString:F$displayFret',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
