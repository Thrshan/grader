import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grader/page/home_page.dart';
import './page/onboarding_page.dart';

bool isFirstOpen = true;
void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  // isFirstOpen = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  Future<Map> _loadDataOnOpen() async {
    Map loadedData = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await Future.delayed(const Duration(seconds: 5), () => {});

    loadedData['isFirstOpen'] = prefs.getBool('isFirstOpen') ?? true;
    return loadedData;
    // return true;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'GPA Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<Map>(
        future: _loadDataOnOpen(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data as Map)['isFirstOpen'] ?? true
                ? OnBoardingPage()
                : const HomePage();
          } else {
            return Container(
              color: Colors.white,
            );
          }
        },
      ),
    );
  }
}
