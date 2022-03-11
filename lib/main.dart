import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grader/page/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grader/page/home_page.dart';
import './page/onboarding_page.dart';

bool isFirstOpen = true;
void main() async {
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.blue,
  // ));
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'GPA Calculator',
      theme: ThemeData(
        brightness: Brightness.light,
        splashColor: const Color(0xFFCDA14B),
        backgroundColor: const Color(0xFFF5F5F1),
        disabledColor: const Color(0xFFB2B2B2),
        fontFamily: 'RobotoSlab',
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD83E3E),
          ),
          headline2: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFFD83E3E),
          ),
          // headline3: TextStyle(
          //   fontSize: 30.0,
          //   fontWeight: FontWeight.w500,
          //   color: Color(0xFFD83E3E),
          // ),
          headline4: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFFD83E3E),
          ),
          bodyText1: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: Color(0xFF000000),
          ),
          bodyText2: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Color(0xFF000000),
          ),
          subtitle1: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Color(0xFF888888),
          ),
          subtitle2: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Color(0xFF888888),
          ),
          // headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          // bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        // colorScheme: ColorScheme.fromSwatch(
        //   // primarySwatch: primarySwatch, // as above
        //   // primaryColorDark: primaryColorDark, // as above
        //   accentColor: Color(0xFFCDA14B),
        //   // cardColor: Color(0xFFFF0000),
        //   backgroundColor: Color(0xFFF50000),
        //   errorColor: Colors.red[700],
        //   brightness: Brightness.light,

        // ),
        cardTheme: const CardTheme(
          color: Color(0xFFEFEDE3),
        ),
      ),
      home: FutureBuilder<Map>(
        future: _loadDataOnOpen(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data as Map)['isFirstOpen'] ?? true
                ? OnBoardingPage()
                : const MainPage();
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
