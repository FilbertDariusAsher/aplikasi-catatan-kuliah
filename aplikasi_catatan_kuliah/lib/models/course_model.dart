class CourseModel {
  final String? id;
  final String name;
  final String lecturer;

  CourseModel({this.id, required this.name, required this.lecturer});

  factory CourseModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CourseModel(
      id: id,
      name: map['name'] ?? '',
      lecturer: map['lecturer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'lecturer': lecturer};
  }
}
