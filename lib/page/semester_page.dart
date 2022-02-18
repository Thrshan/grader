import 'package:flutter/material.dart';
import 'package:grader/models/subject.dart';
import 'package:grader/page/dashboard_page.dart';

import '../db/database_manager.dart';
import 'edit_grade_page.dart';
import '../models/grade.dart';

class SemesterPage extends StatefulWidget {
  final List<String> semTableList;
  const SemesterPage({required this.semTableList, Key? key}) : super(key: key);

  @override
  _SemesterSlideState createState() => _SemesterSlideState();
}

class _SemesterSlideState extends State<SemesterPage> {
  int _index = 0;

  final _db = DatabaseManager.instance;

  Future<Map<String, List<Subject>>> _loadFromDB() async {
    Map<String, List<Subject>> allSub = {};
    for (var semTable in widget.semTableList) {
      allSub[semTable] = await _db.readAll(semTable);
    }
    return allSub;
  }

  void _openEditGradePage(
      context, List<Subject> subOfSem, String tableName, int semNo) {
    Navigator.of(context)
        .push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => EditGradePage(
            semNo: semNo,
            subjectsOfSem: subOfSem,
            tableName: tableName,
          ),
        )

            // MaterialPageRoute(
            //   builder: (_) => EditGradePage(
            //     subjectsOfSem: subOfSem,
            //     tableName: tableName,
            //   ),
            // )
            )
        .then(_onGoBack);
  }

  double _calculateGpa(List<Subject> subjectsOfSem) {
    // This code need to be more sophisticated to handle more regulations
    double totalCredit = 0;
    double securedCredit = 0;
    for (var subject in subjectsOfSem) {
      // print(subject.grade);

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
    var _itemCount = widget.semTableList.length;

    return FutureBuilder(
        future: _loadFromDB(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: SizedBox(
                //! Change the card size variable
                height: 690, // card height
                child: PageView.builder(
                  itemCount: _itemCount,
                  controller: PageController(viewportFraction: 1),
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemBuilder: (_, i) {
                    return Card(
                      color: Color.fromRGBO(239, 237, 227, 1),
                      // color: Color(0xFFEFEDE3),
                      // margin: EdgeInsets.fromLTRB(25, 10, 10, 10),
                      margin: const EdgeInsets.only(
                        top: 25,
                        bottom: 10,
                        right: 20,
                        left: 20,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 15, top: 10),
                                  child: Hero(
                                    tag: 'sem${i}_no',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        'Semester ${i + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                    ),
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
                                        (snapshot.data
                                                as Map)[widget.semTableList[i]]
                                            as List<Subject>,
                                        widget.semTableList[i],
                                        i,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                physics: NeverScrollableScrollPhysics(),
                                children: ((snapshot.data
                                            as Map)[widget.semTableList[i]]
                                        as List<Subject>)
                                    .map(
                                      (sub) => ListTile(
                                        title: Hero(
                                          tag: 'sem${i}_subName_${sub.code}',
                                          child: Text(
                                            sub.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                        ),
                                        subtitle: Hero(
                                          tag: 'sem${i}_subCode_${sub.code}',
                                          child: Text(
                                            sub.code,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                          ),
                                        ),
                                        trailing: Hero(
                                          tag: 'sem${i}_subGrade_${sub.code}',
                                          child: Text(
                                            sub.grade,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                          ),
                                        ),
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
                                            as Map)[widget.semTableList[i]]
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
