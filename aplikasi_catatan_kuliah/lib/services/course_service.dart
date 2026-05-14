import 'package:firebase_database/firebase_database.dart';
import '../models/course_model.dart';

class CourseService {
  final DatabaseReference _coursesRef = FirebaseDatabase.instance.ref(
    'courses',
  );

  Future<void> addCourse(CourseModel course) async {
    await _coursesRef.push().set(course.toMap());
  }

  Future<List<CourseModel>> getCourses() async {
    final snapshot = await _coursesRef.get();
    List<CourseModel> courses = [];

    if (snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        courses.add(
          CourseModel.fromMap(key.toString(), value as Map<dynamic, dynamic>),
        );
      });
    }

    return courses;
  }

  Stream<List<CourseModel>> streamCourses() {
    return _coursesRef.onValue.map((event) {
      List<CourseModel> courses = [];

      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          courses.add(
            CourseModel.fromMap(key.toString(), value as Map<dynamic, dynamic>),
          );
        });
      }

      return courses;
    });
  }
}
