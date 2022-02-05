import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grader/models/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:grader/modules/semester_slide.dart';
import '../db/database_manager.dart';
import 'semester_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final String title = 'CGPA Calculator';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = DatabaseManager.instance;

  Future<Map> _loadJson(String jsonFileName) async {
    final String response =
        await rootBundle.loadString('assets/jsons/$jsonFileName');
    return await json.decode(response);
  }

  Future<void> _gatherCourseData(String revisionYear, String courseKey) async {
    Map courses = await _loadJson('courses.json');
    String courseFileName = courses[revisionYear][courseKey]['file'];
    Map subjectDetails = await _loadJson(courseFileName);
    // print(subjectDetails);

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> preferences = {};
    preferences['selectedRevision'] = prefs.getString('selectedRevision')!;
    preferences['selectedCourse'] = prefs.getString('selectedCourse')!;
    preferences['userName'] = prefs.getString('userName')!;
    bool loadTheDB = prefs.getBool('loadDBwithDefault') ?? true;

    if (loadTheDB) {
      await _gatherCourseData(preferences['selectedRevision'] as String,
          preferences['selectedCourse'] as String);
    }
    preferences['semTables'] = prefs.getStringList('semTables')!;

    prefs.setBool('loadDBwithDefault', false);
    return preferences;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
            future: _loadPreferences(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SemesterPage(
                    semTableList: (snapshot.data as Map)['semTables']);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Container();
              } else {
                return Container();
              }
            }),
      ),
    );
  }
}
