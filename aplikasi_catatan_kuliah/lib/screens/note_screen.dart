import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../models/note_model.dart';
import '../services/course_service.dart';
import '../services/note_service.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final NoteService _noteService = NoteService();
  final CourseService _courseService = CourseService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'terbaru';
  NoteModel? _editingNote;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final courses = await _courseService.getCourses();
    setState(() {
      _courses = courses;
    });
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih mata kuliah terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool isEditing = _editingNote != null;
    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        final updatedNote = NoteModel(
          id: _editingNote!.id,
          courseId: _selectedCourse!.id ?? '',
          courseName: _selectedCourse!.name,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          timestamp: _editingNote!.timestamp,
        );
        await _noteService.updateNote(_editingNote!.id!, updatedNote);
      } else {
        final note = NoteModel(
          courseId: _selectedCourse!.id ?? '',
          courseName: _selectedCourse!.name,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await _noteService.addNote(note);
      }

      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedCourse = null;
        _editingNote = null;
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Catatan diperbarui' : 'Catatan disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan catatan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddNoteSheet({NoteModel? note}) async {
    final sheetContext = context;
    _editingNote = note;
    _titleController.text = note?.title ?? '';
    _contentController.text = note?.content ?? '';

    await _loadCourses();

    if (note != null) {
      CourseModel? selectedCourse;
      for (final course in _courses) {
        if (course.id == note.courseId) {
          selectedCourse = course;
          break;
        }
      }
      _selectedCourse = selectedCourse;
    } else {
      _selectedCourse = null;
    }

    showModalBottomSheet(
      context: sheetContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note != null
                        ? 'Edit Catatan Kuliah'
                        : 'Tambah Catatan Kuliah',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<CourseModel>(
                    initialValue: _selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'Mata Kuliah',
                      prefixIcon: Icon(Icons.school),
                    ),
                    hint: const Text('Pilih mata kuliah'),
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih mata kuliah';
                      }
                      return null;
                    },
                    items: _courses.map((course) {
                      return DropdownMenuItem<CourseModel>(
                        value: course,
                        child: Text(course.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() => _selectedCourse = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Catatan',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      if (value.trim().length < 3) {
                        return 'Judul minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Catatan',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Isi catatan tidak boleh kosong';
                      }
                      if (value.trim().length < 5) {
                        return 'Isi catatan minimal 5 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveNote,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              _editingNote != null ? Icons.edit : Icons.save,
                            ),
                      label: Text(
                        _editingNote != null
                            ? 'Perbarui Catatan'
                            : 'Simpan Catatan',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNoteDetail(NoteModel note) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Text(
                  note.courseName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                note.content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(note.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddNoteSheet(note: note);
            },
            icon: const Icon(Icons.edit, color: Colors.blue),
            label: const Text('Edit', style: TextStyle(color: Colors.blue)),
          ),
          TextButton.icon(
            onPressed: () async {
              final dialogContext = context;
              await _noteService.deleteNote(note.id!);
              if (!mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Catatan dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Cari catatan...',
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<NoteModel>>(
            stream: _noteService.streamNotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<NoteModel> notes = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                notes = notes.where((note) {
                  return note.title.toLowerCase().contains(_searchQuery) ||
                      note.content.toLowerCase().contains(_searchQuery) ||
                      note.courseName.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              notes.sort((a, b) {
                switch (_sortBy) {
                  case 'terlama':
                    return a.timestamp.compareTo(b.timestamp);
                  case 'a-z':
                    return a.title.compareTo(b.title);
                  case 'z-a':
                    return b.title.compareTo(a.title);
                  default:
                    return b.timestamp.compareTo(a.timestamp);
                }
              });

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${notes.length} catatan',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'terbaru',
                              child: Text('Terbaru'),
                            ),
                            DropdownMenuItem(
                              value: 'terlama',
                              child: Text('Terlama'),
                            ),
                            DropdownMenuItem(
                              value: 'a-z',
                              child: Text('A - Z'),
                            ),
                            DropdownMenuItem(
                              value: 'z-a',
                              child: Text('Z - A'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortBy = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: notes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_outlined,
                                  size: 88,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Belum ada catatan kuliah'
                                      : 'Catatan tidak ditemukan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Tambah catatan untuk menyimpan ringkasan materi kuliah'
                                      : 'Coba kata kunci lain atau tambahkan catatan baru',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: theme.dividerColor.withOpacity(0.8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withOpacity(
                                        0.04,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => _showNoteDetail(note),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              note.courseName,
                                              style: TextStyle(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            note.title,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            note.content,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                              height: 1.45,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.5),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _formatTimestamp(
                                                  note.timestamp,
                                                ),
                                                style: TextStyle(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _showAddNoteSheet,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Catatan'),
            ),
          ),
        ),
      ],
    );
  }
}
