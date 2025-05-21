import 'package:flutter/material.dart';
import 'package:guitarplayer/component/playguitar.dart';
import 'package:flutter/services.dart';
//세로고정을 위한

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {

  void initState() {
    super.initState();
    // 세로모드 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //기타버튼
            SizedBox(
              width: 200,
              height: 100,
              child: OutlinedButton(
                //화면을 스택으로 올리려면 Navigator.push를 이용해서 올린다
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuitarApp()),
                  ).then((_){
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                  });//그냥 Navigator push로 쌓아올리기만하면 뒤돌아갔을때 가로모드에서 돌아오기전에
                  //homescreen이 나와서 가로모드에서의 homescreen이 나와 가로모드 디자인을 안한나는
                  //overflow현상이 일어나게된다
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade400, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Guitar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 16,),

            //피아노 버튼
            SizedBox(
              width: 200,
              height: 100,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade400, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Piano',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 16,),

            //메트로놈 버튼
            SizedBox(
              width: 200,
              height: 100,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade400, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Metronome',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
