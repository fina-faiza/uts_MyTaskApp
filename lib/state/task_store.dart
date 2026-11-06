
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStore extends ChangeNotifier {
  final List<Task> _tasks = _seed();

  String profileName = 'Mahasiswa';

  late final Future<void> ready;

  TaskStore() {
    ready = _load();
  }

  // Memuat data dari penyimpanan HP
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    profileName = prefs.getString('profileName') ?? 'Mahasiswa';

    final savedTasks = prefs.getString('savedTasks');

    if (savedTasks != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedTasks);

        _tasks
          ..clear()
          ..addAll(
            decoded.map(
              (item) => _taskFromMap(
                Map<String, dynamic>.from(item),
              ),
            ),
          );
      } catch (e) {
        debugPrint('Gagal membaca data tugas: $e');
      }
    } else {
      // Simpan data awal hanya saat pertama kali aplikasi digunakan
      await _save();
    }

    notifyListeners();
  }

  // Mengubah objek Task menjadi JSON
  Map<String, dynamic> _taskToMap(Task t) {
    return {
      'id': t.id,
      'title': t.title,
      'course': t.course,
      'deadline': t.deadline.toIso8601String(),
      'priority': t.priority.name,
      'notes': t.notes,
      'status': t.status.name,
    };
  }

  // Mengubah JSON menjadi objek Task
  Task _taskFromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      course: map['course'],
      deadline: DateTime.parse(map['deadline']),
      priority: Priority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => Priority.medium,
      ),
      notes: map['notes'] ?? '',
      status: TaskStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
    );
  }

  // Menyimpan tugas dan profil
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _tasks.map((t) => _taskToMap(t)).toList(),
    );

    await prefs.setString('savedTasks', encoded);
    await prefs.setString('profileName', profileName);
  }

  void updateProfileName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return;

    profileName = trimmed;
    notifyListeners();
    _save();
  }

  List<Task> get tasks {
    final list = List<Task>.from(_tasks);

    list.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }

      return a.deadline.compareTo(b.deadline);
    });

    return list;
  }

  int get total => _tasks.length;

  int get done => _tasks.where((t) => t.isDone).length;

  int get pending => total - done;

  int get overdue => _tasks.where((t) => t.isOverdue).length;

  double get progress => total == 0 ? 0 : done / total;

  Task? byId(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }

    return null;
  }

  // Tambah tugas
  void add(Task t) {
    _tasks.add(t);
    notifyListeners();
    _save();
  }

  // Edit tugas
  void update(
    Task t, {
    required String title,
    required String course,
    required DateTime deadline,
    required Priority priority,
    required String notes,
  }) {
    t.title = title;
    t.course = course;
    t.deadline = deadline;
    t.priority = priority;
    t.notes = notes;

    notifyListeners();
    _save();
  }

  // Tandai selesai atau belum selesai
  void toggleDone(Task t) {
    t.status = t.isDone
        ? TaskStatus.pending
        : TaskStatus.done;

    notifyListeners();
    _save();
  }

  // Mengubah status tugas
  void setStatus(Task t, TaskStatus s) {
    t.status = s;

    notifyListeners();
    _save();
  }

  // Hapus tugas
  void remove(Task t) {
    _tasks.remove(t);

    notifyListeners();
    _save();
  }

  // Mengembalikan tugas yang dihapus (Undo)
  void restore(Task t) {
    if (_tasks.any((item) => item.id == t.id)) return;

    _tasks.add(t);

    notifyListeners();
    _save();
  }

  static List<Task> _seed() {
    final now = DateTime.now();

    return [
      Task(
        id: '1',
        title: 'Selesaikan Aplikasi Flutter UTS',
        course: 'Pemrograman Mobile Lanjut',
        deadline: now.add(const Duration(days: 2)),
        priority: Priority.high,
        notes: 'Implementasi CRUD tugas dan dokumentasi.',
        status: TaskStatus.inProgress,
      ),
      Task(
        id: '2',
        title: 'Baca Bab 4: Data Preprocessing',
        course: 'Analitika Data',
        deadline: now.add(const Duration(days: 5)),
        priority: Priority.low,
        status: TaskStatus.done,
      ),
      Task(
        id: '3',
        title: 'Siapkan Kuis Basis Data',
        course: 'Basis Data',
        deadline: now.add(const Duration(days: 1, hours: 4)),
        priority: Priority.medium,
      ),
      Task(
        id: '4',
        title: 'Kumpulkan Dokumen SRS',
        course: 'Rekayasa Perangkat Lunak',
        deadline: now.subtract(const Duration(hours: 6)),
        priority: Priority.high,
        notes: 'Revisi use case diagram.',
      ),
    ];
  }
}
