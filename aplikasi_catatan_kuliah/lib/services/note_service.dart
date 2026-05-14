import 'package:firebase_database/firebase_database.dart';
import '../models/note_model.dart';

class NoteService {
  final DatabaseReference _notesRef = FirebaseDatabase.instance.ref('notes');

  Future<void> addNote(NoteModel note) async {
    await _notesRef.push().set(note.toMap());
  }

  Stream<List<NoteModel>> streamNotes() {
    return _notesRef.orderByChild('timestamp').onValue.map((event) {
      List<NoteModel> notes = [];

      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          notes.add(
            NoteModel.fromMap(key.toString(), value as Map<dynamic, dynamic>),
          );
        });

        notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      return notes;
    });
  }

  Future<void> updateNote(String noteId, NoteModel note) async {
    await _notesRef.child(noteId).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _notesRef.child(noteId).remove();
  }
}
