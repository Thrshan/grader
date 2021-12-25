import 'package:flutter/material.dart';
import 'dart:ui';
import './arc_text.dart';
import '../modules/global.dart';

var globalData = Global();

class GradeWheel extends StatefulWidget {
  final double angle;
  final double initAngle;
  final String subName;
  final String subCode;

  const GradeWheel({
    required this.angle,
    required this.initAngle,
    required this.subName,
    required this.subCode,
    Key? key,
  }) : super(key: key);

  @override
  State<GradeWheel> createState() => _GradeWheelState();
}

class _GradeWheelState extends State<GradeWheel> {
  double pressYPosition = 0;
  double dragYPosition = 0;
  double dragYDelta = 0;
  double prevDragYDelta = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double _angle = widget.angle;

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: size.width,
            height: size.height,
            // color: Colors.blue,
          ),
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 50,
                bottom: 20,
              ),
              child: Column(
                children: [
                  Text(widget.subName),
                  Text(widget.subCode),
                ],
              ),
            ),
            Transform.rotate(
              angle: _angle,
              child: Center(
                child: Container(
                  // color: Colors.amber,
                  width: 300,
                  height: 300,
                  child: Stack(
                      alignment: Alignment.center,
                      children: globalData.grades
                          .map(
                            (grade) => ArcText(
                              angle: grade["angle"] as double,
                              letter: grade["letter"] as String,
                            ),
                          )
                          .toList()),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
