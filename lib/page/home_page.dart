import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grader/models/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:grader/modules/semester_slide.dart';
import '../db/database_manager.dart' as db;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final String title = 'CGPA Calculator';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map> _loadJson(String jsonFileName) async {
    final String response =
        await rootBundle.loadString('assets/jsons/$jsonFileName');
    return await json.decode(response);
  }

  Future<Map<String, Object>> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> preferences = {};
    preferences['selectedRevision'] = prefs.getString('selectedRevision')!;
    preferences['selectedCourse'] = prefs.getString('selectedCourse')!;
    preferences['userName'] = prefs.getString('userName')!;
    // Map courses = await _loadJson('courses.json');
    // String courseFileName = (courses)[preferences['selectedRevision']]
    //     [preferences['selectedCourse']]['file'];
    // preferences['courseDetail'] = await _loadJson(courseFileName);

    return preferences;
  }

  Future<bool> _hiveThing() async {
    var table = 'TestTable';
    var sub = Subject(
      name: 'testnName',
      code: 'testjCode',
      credit: 2,
      elective: 0,
      grade: " ",
    );
    print(sub);
    await db.DatabaseManager.instance.dropTable(table);
    await db.DatabaseManager.instance.createTable(table);
    var res = await db.DatabaseManager.instance.create(table, sub);
    print(res);
    var query = await db.DatabaseManager.instance.readAll(table);
    print('From Query');
    print(query);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
            future: _hiveThing(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Column(
                    children: [
                      Text(snapshot.data.toString()),
                      // Text((snapshot.data as Map)['selectedRevision']),
                      // Text((snapshot.data as Map)['selectedCourse']),
                      // Text((snapshot.data as Map)['courseDetail']
                      //         ['semesterKeys']
                      //     .toString()),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }
}
