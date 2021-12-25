import 'package:flutter/material.dart';

class EditGradePage extends StatefulWidget {
  const EditGradePage({Key? key}) : super(key: key);

  @override
  _EditGradePageState createState() => _EditGradePageState();
}

class _EditGradePageState extends State<EditGradePage> {
  void _backToHomePage(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text('Press'),
        onPressed: () {
          _backToHomePage(context);
        },
      ),
    );
  }
}
