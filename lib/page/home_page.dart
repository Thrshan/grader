import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grader/models/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:grader/modules/semester_slide.dart';
import '../db/database_manager.dart';
import 'semester_page.dart';

class HomePage extends StatefulWidget {
  Map<String, Object> data;
  HomePage({required this.data, Key? key}) : super(key: key);
  final String title = 'CGPA Calculator';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var usableHeight = constraints.maxHeight - statusBarHeight;
      print(widget.data);
      return Column(
        children: [
          SizedBox(height: statusBarHeight),
          SizedBox(height: usableHeight * 0.05),
          Container(
            height: usableHeight * 0.1,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: constraints.maxWidth * 0.1,
                    right: constraints.maxWidth * 0.07,
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 50,
                  ),
                ),
                Text(
                  widget.data['userName'] as String,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
