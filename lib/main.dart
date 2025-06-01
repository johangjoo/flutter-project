import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:guitarplayer/homescreen/homescreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
