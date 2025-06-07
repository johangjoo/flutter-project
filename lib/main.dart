import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:guitarplayer/homescreen/homescreen.dart';

void main() async{
  //Hive로컬 저장소를 앱시작시 준비해놓게 하기 위해 플러터 엔진을 선초기화해주고
  WidgetsFlutterBinding.ensureInitialized();
  //hive와의 연결및 초기화를 해주고 runAPp을 실행한다
  await Hive.initFlutter();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}
