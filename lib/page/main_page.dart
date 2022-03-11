import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import './home_page.dart';
import './dashboard_page.dart';
import './semester_page.dart';
import '../db/database_manager.dart';
import 'package:grader/models/subject.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  Map<String, Object> _preferences = {};
  bool _prefChanged = true;

  final _db = DatabaseManager.instance;

  Future<Map> _loadJson(String jsonFileName) async {
    final String response =
        await rootBundle.loadString('assets/jsons/$jsonFileName');
    return await json.decode(response);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Future<void> _gatherCourseData(String revisionYear, String courseKey) async {
    Map courses = await _loadJson('courses.json');
    String courseFileName = courses[revisionYear][courseKey]['file'];
    Map subjectDetails = await _loadJson(courseFileName);
    print(subjectDetails);

    List<String> semesters = (subjectDetails['semesterKeys'] as List)
        .map((e) => e.toString())
        .toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('semTables', semesters);
    Map semAndSubMap = {};

    for (var sem in semesters) {
      semAndSubMap[sem] = (subjectDetails[sem] as List)
          .map((sub) => Subject(
                name: sub['name'] as String,
                code: sub['code'] as String,
                credit: sub['credit'] as int,
                elective: sub['elective'] as int,
                grade: 'X',
              ))
          .toList();
    }

    for (var sem in semesters) {
      await _db.dropTable(sem);
      await _db.createTable(sem);
      for (var sub in semAndSubMap[sem]) {
        await _db.create(sem, sub as Subject);
      }
    }
  }

  Future<Map<String, Object>> _loadPreferences() async {
    if (_prefChanged) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('loadingPreferences');
      // Map<String, Object> preferences = {};
      _preferences['selectedRevision'] = prefs.getString('selectedRevision')!;
      _preferences['selectedCourse'] = prefs.getString('selectedCourse')!;
      _preferences['userName'] = prefs.getString('userName')!;
      _preferences['selectedCourseName'] =
          prefs.getString('selectedCourseName')!;
      _preferences['selectedCourseType'] =
          prefs.getString('selectedCourseType')!;

      bool loadTheDB = prefs.getBool('loadDBwithDefault') ?? true;
      if (loadTheDB) {
        await _gatherCourseData(_preferences['selectedRevision'] as String,
            _preferences['selectedCourse'] as String);
      }
      _preferences['semTables'] = prefs.getStringList('semTables')!;

      prefs.setBool('loadDBwithDefault', false);
      _prefChanged = false;
    }
    return _preferences;
  }

  @override
  Widget build(BuildContext context) {
    // var navigationBarKey = GlobalKey();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: FutureBuilder(
        future: _loadPreferences(),
        builder: (context, snapshot) {
          // print(navigationBarKey.currentContext?.size);
          if (snapshot.hasData) {
            return PageView(
              controller: _pageController,
              children: [
                HomePage(data: (snapshot.data as Map<String, Object>)),
                HomePage(data: (snapshot.data as Map<String, Object>)),
                SemesterPage(semTableList: (snapshot.data as Map)['semTables']),
              ],
              physics: const NeverScrollableScrollPhysics(),
            );
          } else {
            return Container();
          }
        },
      ),

      //_widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        // key: navigationBarKey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Semesters',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Theme.of(context).backgroundColor,
        selectedItemColor: Theme.of(context).splashColor,
        unselectedItemColor: Theme.of(context).disabledColor,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        elevation: 0,
      ),
    );
  }
}
