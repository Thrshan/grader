import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import './home_page.dart';
import '../modules/drop_down_list.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  final _lastCarouselNo = 2;
  var _activeCarouselNo = 0;
  late String _selectRevision;
  late String _selectCourse;
  Map _courseNameAndKey = {};
  String dropdownValue = '2021';

  Future<Map> _loadJson(String jsonFileName) async {
    final String response =
        await rootBundle.loadString('assets/jsons/$jsonFileName');
    return await json.decode(response);
  }

  void _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstOpen', false);
    prefs.setString('selectedRevision', _selectRevision);
    prefs.setString('selectedCourse', _courseNameAndKey[_selectCourse]);
    prefs.setString('userName', nameTextFieldController.text);
    prefs.setBool('loadDBwithDefault', true);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const HomePage(),
    ));
  }

  var nameTextFieldController = TextEditingController();
  void _nextCarousel() {
    introKey.currentState?.next();
    // int nextPageIndex = ((introKey.currentState?.controller.page ?? 0) +
    //         (_isLastCarousel ? 0 : 1))
    //     .round();
    // introKey.currentState?.animateScroll(nextPageIndex);
  }

  void _previousCarousel() {
    introKey.currentState?.previous();
  }

  Widget _buildFullscrenImage(assetName) {
    return Image.asset(
      'assets/images/$assetName',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  bool get _isLastCarousel {
    return _activeCarouselNo == _lastCarouselNo;
  }

  bool get _isFirstCarousel {
    return _activeCarouselNo == 0;
  }

  Future<List<String>> _getRevisions() async {
    Map coursesData = await _loadJson('courses.json');
    List<String> revisionsList = (coursesData['revisions'])
        .map<String>((value) => value.toString())
        .toList();
    revisionsList.insert(0, 'Choose Revision');
    return revisionsList;
  }

  Future<List<String>> _getCourses() async {
    Map coursesData = await _loadJson('courses.json');
    _courseNameAndKey = {};
    List<String> coursessList = [];
    coursesData[_selectRevision].forEach((k, v) {
      coursessList.add(v['name']);
      _courseNameAndKey[v['name']] = k;
    });
    coursessList.insert(0, 'Choose Course');
    return coursessList;
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color.fromRGBO(225, 225, 255, 0.5),
      imagePadding: EdgeInsets.zero,
      contentMargin: EdgeInsets.symmetric(horizontal: 16),
      fullScreen: true,
      bodyFlex: 2,
      imageFlex: 3,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      globalFooter: SizedBox(
        width: double.infinity,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _activeCarouselNo != 0
                ? Flexible(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 15,
                        bottom: 10,
                      ),
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _previousCarousel,
                        child: const Text('Previous'),
                      ),
                    ),
                  )
                : Container(),
            Flexible(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.only(
                  right: 15,
                  left: 15,
                  bottom: 10,
                ),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isLastCarousel) {
                      _onIntroEnd(context);
                    } else {
                      _nextCarousel();
                    }
                  },
                  child: _isLastCarousel ? Text("Done") : Text('Next'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      pages: [
        PageViewModel(
          title: 'How should I call you',
          image: _buildFullscrenImage('onboarding-1.jpg'),
          bodyWidget: TextField(
            autocorrect: false,
            controller: nameTextFieldController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Revision year',
          image: _buildFullscrenImage('onboarding-2.jpg'),
          bodyWidget: FutureBuilder(
            future: _getRevisions(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropDownList(
                  items: snapshot.data as List<String>,
                  onChange: (value) => _selectRevision = value,
                );
              } else {
                return DropDownList(
                  items: ['Loading...'],
                  onChange: (_) {},
                );
              }
            },
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Your discipline?',
          image: _buildFullscrenImage('onboarding-3.jpg'),
          bodyWidget: FutureBuilder(
            future: _getCourses(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropDownList(
                  items: snapshot.data as List<String>,
                  onChange: (value) => _selectCourse = value,
                );
              } else {
                return DropDownList(
                  items: ['Select Revision'],
                  onChange: (_) {},
                );
              }
            },
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      onChange: (value) => setState(() {
        _activeCarouselNo = value;
      }),
      isProgress: false,
      showNextButton: false,
      showDoneButton: false,
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}
