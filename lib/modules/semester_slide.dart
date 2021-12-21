import 'package:flutter/material.dart';
import 'package:grader/models/subject.dart';

import '../db/database_manager.dart';

class SemesterSlide extends StatefulWidget {
  final List<String> semTableList;
  const SemesterSlide({required this.semTableList, Key? key}) : super(key: key);

  @override
  _SemesterSlideState createState() => _SemesterSlideState();
}

class _SemesterSlideState extends State<SemesterSlide> {
  int _index = 0;

  final _db = DatabaseManager.instance;

  Future<Map<String, List<Subject>>> _loadFromDB() async {
    Map<String, List<Subject>> allSub = {};
    for (var semTable in widget.semTableList) {
      allSub[semTable] = await _db.readAll(semTable);
    }
    return allSub;
  }

  @override
  Widget build(BuildContext context) {
    var _itemCount = widget.semTableList.length;

    return FutureBuilder(
        future: _loadFromDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 600, // card height
                child: PageView.builder(
                  itemCount: _itemCount,
                  controller: PageController(viewportFraction: 0.9),
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (_, i) {
                    return Opacity(
                      opacity: i == _index ? 1 : 0.5,
                      child: Transform.scale(
                        scale: i == _index ? 1 : 0.95,
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: ListView(
                            children:
                                ((snapshot.data as Map)[widget.semTableList[i]]
                                        as List<Subject>)
                                    .map(
                                      (sub) => ListTile(
                                        title: Text(sub.name),
                                        subtitle: Text(sub.code),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
