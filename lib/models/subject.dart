class Subject {
  final String name;
  final String code;
  final int credit;
  final int elective;
  final int? id;
  String grade;

  Subject({
    required this.name,
    required this.code,
    required this.credit,
    required this.elective,
    this.id,
    required this.grade,
  });

  Map<String, Object?> toMap() => {
        SubjectFields.id: id,
        SubjectFields.name: name,
        SubjectFields.code: code,
        SubjectFields.credit: credit,
        SubjectFields.elective: elective,
        SubjectFields.grade: grade,
      };

  static Subject fromMap(Map<String, Object?> map) => Subject(
        id: map[SubjectFields.id] as int,
        name: map[SubjectFields.name] as String,
        code: map[SubjectFields.code] as String,
        elective: map[SubjectFields.elective] as int,
        credit: map[SubjectFields.credit] as int,
        grade: map[SubjectFields.grade] as String,
      );

  Subject copy({
    int? id,
    String? name,
    String? code,
    int? credit,
    String? grade,
    int? elective,
  }) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        credit: credit ?? this.credit,
        grade: grade ?? this.grade,
        elective: elective ?? this.elective,
      );

  void setGrade(String newGrade) {
    this.grade = newGrade;
  }
}

class SubjectFields {
  static const String id = "_id";
  static const String name = "name";
  static const String code = "code";
  static const String credit = "credit";
  static const String elective = "elective";
  static const String grade = "grade";

  static const List<String> values = [id, name, code, credit, elective, grade];
}
