import 'package:flutter/material.dart';

enum Priority { low, medium, high }

enum TaskStatus { pending, inProgress, done }

const List<String> kCourses = [
  'Penulisan Karya Ilmiah',
  'Implementasi Proyek Terintegrasi (Capstone)',
  'Pengujian dan Pemeliharaan Sistem',
  'Keamanan Sistem Informasi',
  'Pemrograman Mobile Lanjut',
  'English Conversation',
  'Metodologi Penelitian',
];

const List<Color> _coursePalette = [
  Color(0xFF3B6EF5),
  Color(0xFF8B5CF6),
  Color(0xFF0EA5A4),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF16A34A),
  Color(0xFF64748B),
];

Color courseColor(String course) {
  final i = kCourses.indexOf(course);
  return _coursePalette[(i < 0 ? kCourses.length - 1 : i) % _coursePalette.length];
}

extension PriorityX on Priority {
  String get label => const {
        Priority.low: 'Rendah',
        Priority.medium: 'Sedang',
        Priority.high: 'Tinggi',
      }[this]!;

  Color get color => const {
        Priority.low: Color(0xFF16A34A),
        Priority.medium: Color(0xFFF59E0B),
        Priority.high: Color(0xFFEF4444),
      }[this]!;
}

extension TaskStatusX on TaskStatus {
  String get label => const {
        TaskStatus.pending: 'Belum Dikerjakan',
        TaskStatus.inProgress: 'Sedang Dikerjakan',
        TaskStatus.done: 'Selesai',
      }[this]!;

  Color get color => const {
        TaskStatus.pending: Color(0xFFF59E0B),
        TaskStatus.inProgress: Color(0xFF3B6EF5),
        TaskStatus.done: Color(0xFF16A34A),
      }[this]!;
}

class Task {
  final String id;
  String title;
  String course;
  DateTime deadline;
  Priority priority;
  String notes;
  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    this.priority = Priority.medium,
    this.notes = '',
    this.status = TaskStatus.pending,
  });

  bool get isDone => status == TaskStatus.done;
  bool get isOverdue => !isDone && deadline.isBefore(DateTime.now());
}
