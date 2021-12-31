import 'package:flutter/material.dart';
import 'package:grader/models/subject.dart';
import 'package:grader/page/dashboard_page.dart';

import '../db/database_manager.dart';
import '../page/edit_grade_page.dart';
import '../models/grade.dart';

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

  void _openEditGradePage(context, List<Subject> subOfSem, String tableName) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => EditGradePage(
            subjectsOfSem: subOfSem,
            tableName: tableName,
          ),
        ))
        .then(_onGoBack);
  }

  double _calculateGpa(List<Subject> subjectsOfSem) {
    // This code need to be more sophisticated to handle more regulations
    double totalCredit = 0;
    double securedCredit = 0;
    for (var subject in subjectsOfSem) {
      print(subject.grade);

      //To GPA as 0 when any of the firld is X aka new
      if (subject.grade == 'X') {
        return 0;
      }

      if (subject.grade != (grades2021['RA'] as Grade).letter &&
          subject.grade != 'X') {
        totalCredit += subject.credit;
        securedCredit +=
            (subject.credit) * (grades2021[subject.grade] as Grade).point;
      }
    }

    return securedCredit / totalCredit;
  }

  Future _onGoBack(dynamic value) async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _itemCount = widget.semTableList.length + 1;

    return FutureBuilder(
        future: _loadFromDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 670, // card height
                child: PageView.builder(
                  itemCount: _itemCount,
                  controller: PageController(viewportFraction: 0.9),
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return const DashboardPage();
                    } else {
                      var j = i - 1;
                      return Opacity(
                        opacity: i == _index ? 1 : 0.5,
                        child: Transform.scale(
                          scale: i == _index ? 1 : 0.95,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 15, top: 10),
                                      child: Text(
                                        'Semester ${j + 1}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: 10, right: 10),
                                          height: 28,
                                          width: 28,
                                          decoration: const BoxDecoration(
                                            // borderRadius: BorderRadius.circular(14),
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 17,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        onTap: () {
                                          _openEditGradePage(
                                              context,
                                              (snapshot.data as Map)[
                                                      widget.semTableList[j]]
                                                  as List<Subject>,
                                              widget.semTableList[j]);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: ListView(
                                    children: ((snapshot.data
                                                as Map)[widget.semTableList[j]]
                                            as List<Subject>)
                                        .map(
                                          (sub) => ListTile(
                                            title: Text(sub.name),
                                            subtitle: Text(sub.code),
                                            trailing: Text(sub.grade),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    child: Text(
                                      'GPA ${_calculateGpa(
                                        (snapshot.data
                                                as Map)[widget.semTableList[j]]
                                            as List<Subject>,
                                      ).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
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
