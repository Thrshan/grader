class Grade2013 {
  final Grade S = Grade('S', 10);
  final Grade A = Grade('A', 9);
  final Grade B = Grade('B', 8);
  final Grade C = Grade('C', 7);
  final Grade D = Grade('D', 6);
  final Grade E = Grade('E', 5);
  final Grade RA = Grade('RA', 0);
}

Map<String, Grade> grades2013 = {
  'S': Grade2013().S,
  'A': Grade2013().A,
  'B': Grade2013().B,
  'C': Grade2013().C,
  'D': Grade2013().D,
  'E': Grade2013().E,
  'RA': Grade2013().RA,
};

class Grade2021 {
  final Grade O = Grade('O', 10);
  final Grade AA = Grade('A+', 9);
  final Grade A = Grade('A', 8);
  final Grade BB = Grade('B+', 7);
  final Grade B = Grade('B', 6);
  final Grade C = Grade('C', 5);
  final Grade RA = Grade('RA', 0);
}

Map<String, Grade> grades2021 = {
  'O': Grade2021().O,
  'A+': Grade2021().AA,
  'A': Grade2021().A,
  'B+': Grade2021().BB,
  'B': Grade2021().B,
  'C': Grade2021().C,
  'RA': Grade2021().RA,
};

class Grade {
  final int point;
  final String letter;

  Grade(this.letter, this.point);
}
