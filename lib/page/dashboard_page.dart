import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  Future<Map<String, Object>> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, Object> preferences = {};
    // preferences['selectedRevision'] = prefs.getString('selectedRevision')!;
    // preferences['selectedCourse'] = prefs.getString('selectedCourse')!;
    preferences['userName'] = prefs.getString('userName')!;
    return preferences;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _loadPreferences(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Column(
                children: [
                  Text('Dashboard here'),
                  Text((snapshot.data as Map)['userName']),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
