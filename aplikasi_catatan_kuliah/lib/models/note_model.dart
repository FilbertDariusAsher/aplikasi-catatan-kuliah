class NoteModel {
  final String? id;
  final String courseId;
  final String courseName;
  final String title;
  final String content;
  final int timestamp;

  NoteModel({
    this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory NoteModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return NoteModel(
      id: id,
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
