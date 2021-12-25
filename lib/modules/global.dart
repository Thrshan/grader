import 'dart:math' as math;

int _noOfGrades = 6;

class Global {
  int noOfGrades = _noOfGrades;
  List<Map<String, Object>> grades = [
    {"letter": "O", "angle": (1 * (2 * math.pi / _noOfGrades))},
    {"letter": "A+", "angle": (2 * (2 * math.pi / _noOfGrades))},
    {"letter": "A", "angle": (3 * (2 * math.pi / _noOfGrades))},
    {"letter": "B+", "angle": (4 * (2 * math.pi / _noOfGrades))},
    {"letter": "B", "angle": (5 * (2 * math.pi / _noOfGrades))},
    {"letter": "RA", "angle": (6 * (2 * math.pi / _noOfGrades))}
  ];
}
