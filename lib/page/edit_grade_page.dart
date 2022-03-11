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
  final int semNo;
  const EditGradePage(
      {required this.semNo,
      required this.subjectsOfSem,
      required this.tableName,
      Key? key})
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
  // bool _pageOpened = true;
  // Color _bgColor = Color(0xFFEFEDE3);
  final _db = DatabaseManager.instance;

  void _backToSemesterPage(context) {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
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
      backgroundColor: Theme.of(context).backgroundColor,
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: Stack(
        children: [
          Container(
            // duration: const Duration(milliseconds: 5000),
            color: Theme.of(context).backgroundColor,
            child: Column(
              children: [
                Container(
                  // width: double.infinity,
                  margin: EdgeInsets.only(left: 15, top: 50),
                  child: Hero(
                    tag: 'sem${widget.semNo}_no',
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Semester ${widget.semNo + 1}',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    children: subjectsOfSemester
                        .map(
                          (sub) => ListTile(
                            title: Hero(
                              tag: 'sem${widget.semNo}_subName_${sub.code}',
                              child: Text(
                                sub.name,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                            subtitle: Hero(
                              tag: 'sem${widget.semNo}_subCode_${sub.code}',
                              child: Text(
                                sub.code,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                            trailing: Hero(
                              tag: 'sem${widget.semNo}_subGrade_${sub.code}',
                              child: GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  dragYPosition = details.globalPosition.dy;
                                  dragYDelta = dragYPosition - pressYPosition;
                                  _rotateWheel(sub, dragYDelta);
                                  prevDragYDelta = dragYDelta;
                                },
                                onTapDown: (details) async {
                                  pressYPosition = details.globalPosition.dy;
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
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).splashColor,
                                    shape: BoxShape.circle,
                                  ),
                                  height: 50,
                                  width: 50,
                                  margin: EdgeInsets.all(6),
                                  child: Center(
                                      child: Text(
                                    sub.grade,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  )),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     child: Text('GPA'),
                //     margin: const EdgeInsets.only(bottom: 16),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _backToSemesterPage(context);
                      },
                      child: Container(
                          width: 70,
                          height: 40,
                          child: Center(child: Text('Close'))),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFF5353),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        for (var subject in subjectsOfSemester) {
                          await _db.update(
                              widget.tableName, subject.id!, subject);
                          // print(subject.grade);
                        }
                        // SharedPreferences prefs =
                        //     await SharedPreferences.getInstance();
                        // await prefs.setBool('loadDBwithDefault', true);
                        _backToSemesterPage(context);
                      },
                      child: Container(
                          width: 70,
                          height: 40,
                          child: Center(child: Text('Save'))),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFC57BFF),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                )
              ],
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
        currentIndex: 2,
        backgroundColor: Theme.of(context).backgroundColor,
        selectedItemColor: Theme.of(context).disabledColor,
        unselectedItemColor: Theme.of(context).disabledColor,
        type: BottomNavigationBarType.fixed,
        onTap: (_) {},
        elevation: 0,
      ),
    );
  }
}
