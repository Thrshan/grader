import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SemesterSlide extends StatefulWidget {
  const SemesterSlide({Key? key}) : super(key: key);

  @override
  _SemesterSlideState createState() => _SemesterSlideState();
}

class _SemesterSlideState extends State<SemesterSlide> {
  Future<Map> _loadJson(String jsonFileName) async {
    final String response =
        await rootBundle.loadString('assets/jsons/$jsonFileName');
    return await json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
