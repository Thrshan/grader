import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final String title = 'CGPA Calculator';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String, String>> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> preferences = {};
    preferences['selectedRevision'] = prefs.getString('selectedRevision')!;
    preferences['selectedCourse'] = prefs.getString('selectedCourse')!;
    preferences['userName'] = prefs.getString('userName')!;

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
            future: loadPreferences(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Column(
                    children: [
                      Text((snapshot.data as Map)['selectedRevision']),
                      Text((snapshot.data as Map)['selectedCourse']),
                      Text((snapshot.data as Map)['userName']),
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
