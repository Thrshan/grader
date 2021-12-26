import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';
import 'package:grader/models/subject.dart';
import '../widgets/grade_wheel.dart';
import '../db/database_manager.dart';

class EditGradePage extends StatefulWidget {
  final List<Subject> subjectsOfSem;
  final String tableName;
  const EditGradePage(
      {required this.subjectsOfSem, required this.tableName, Key? key})
      : super(key: key);

  @override
  _EditGradePageState createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> {
  bool _showWheelFlag = false;
  double pressYPosition = 0;
  double dragYPosition = 0;
  double dragYDelta = 0;
  double prevDragYDelta = 0;
  double _angle = 0;
  double activeId = 0;
  double initAngle = 0;
  String subName = "";
  String subCode = "";
  final _db = DatabaseManager.instance;

  void _backToHomePage(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List<Subject> subjectsOfSemester = widget.subjectsOfSem;

    Map calculateIndentMotion(double linearChange, int noOfIndent) {
      double angleRad;
      double angleRatio = 0;
      double curveRatio = 0;
      double baseVal = 0;
      double varVal = 0;
      double angleDeg = 0;
      double angleDegMod = 0;
      double sectionAngle = 0;
      int indentNo = 0;
      angleRad = (linearChange / 700) * 4 * math.pi;

      // Converting to radian to degree, for easy calculation
      angleDeg = -(180 * angleRad) / math.pi;
      var rawAngle = angleDeg;
      var piMod = rawAngle % (360 / noOfIndent);
      angleRatio = piMod / (360 / noOfIndent);
      curveRatio = 1 / (1 + math.pow((angleRatio / (1 - angleRatio)), -6));
      baseVal = rawAngle >= 0
          ? (rawAngle / (360 / noOfIndent)).truncate() * (360 / noOfIndent)
          : ((rawAngle / (360 / noOfIndent)).truncate() - 1) *
              (360 / noOfIndent);
      varVal = rawAngle >= 0
          ? (rawAngle - baseVal) * curveRatio
          : (baseVal - rawAngle) * curveRatio;
      angleDeg = rawAngle >= 0 ? baseVal + varVal : baseVal - varVal;

      // converting degree back ro redian
      angleRad = -angleDeg * (math.pi / 180);

      // Figuring out where the wheel is landed
      angleDegMod = angleDeg % 360;
      sectionAngle = 360 / noOfIndent;
      indentNo = (angleDegMod / sectionAngle).round() % noOfIndent;
      indentNo = (indentNo - 1) % noOfIndent; // To show top one is selected

      return {"angle": angleRad, "gradeIndex": indentNo};
    }

    void _hideWheel() {
      setState(() {
        HapticFeedback.heavyImpact();
        _showWheelFlag = false;
      });
    }

    void _showWheel(Subject subject) {
      HapticFeedback.lightImpact();
      setState(() {
        _showWheelFlag = true;
        _angle = 0;
        subName = subject.name;
        subCode = subject.code;
        // initAngle = subs[id]["initAngle"] as double;
      });
    }

    void _rotateWheel(Subject subject, double dragYChange) {
      setState(() {
        Map calcRotation;
        calcRotation =
            calculateIndentMotion(dragYChange, globalData.noOfGrades);
        _angle = calcRotation["angle"] as double;

        // Later it should be ideal angle for that index
        subject.setGrade(
            globalData.grades[calcRotation["gradeIndex"]]["letter"] as String);
        _showWheelFlag = true;
        // initAngle = subs[id]["initAngle"] as double;
        subName = subject.name;
        subCode = subject.code;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Title'),
      ),
      body: Stack(
        children: [
          Card(
            // margin: EdgeInsets.all(20),
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, right: 10),
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          // borderRadius: BorderRadius.circular(14),
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: Colors.white70,
                        ),
                      ),
                      onTap: () {
                        _backToHomePage(context);
                      },
                    ),
                  ),
                  Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: subjectsOfSemester
                        .map(
                          (sub) => Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [Text(sub.name), Text(sub.code)],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onVerticalDragUpdate: (details) {
                                      dragYPosition = details.globalPosition.dy;
                                      dragYDelta =
                                          dragYPosition - pressYPosition;
                                      _rotateWheel(sub, dragYDelta);
                                      prevDragYDelta = dragYDelta;
                                    },
                                    onTapDown: (details) async {
                                      pressYPosition =
                                          details.globalPosition.dy;
                                      _showWheel(sub);
                                    },
                                    // onVerticalDragStart: (_) {
                                    //   HapticFeedback.mediumImpact();
                                    // },
                                    onVerticalDragEnd: (details) {
                                      _hideWheel();
                                    },
                                    onTapUp: (details) {
                                      _hideWheel();
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      height: 50,
                                      width: 50,
                                      margin: EdgeInsets.all(10),
                                      child: Center(child: Text(sub.grade)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      for (var subject in subjectsOfSemester) {
                        await _db.update(
                            widget.tableName, subject.id!, subject);
                        print(subject.grade);
                      }
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('loadFromDB', true);
                      _backToHomePage(context);
                    },
                    child: Text('dd'),
                  ),
                ],
              ),
            ),
          ),
          _showWheelFlag
              ? GradeWheel(
                  angle: _angle,
                  initAngle: initAngle,
                  subName: subName,
                  subCode: subCode,
                )
              : Container(),
        ],
      ),
    );
  }
}
