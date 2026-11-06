import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/task_form_screen.dart';
import '../state/task_store.dart';

/// Membuka form tambah (task == null) atau edit (task != null),
/// lalu menampilkan snackbar konfirmasi setelah form ditutup.
Future<void> openTaskForm(
  BuildContext context,
  TaskStore store, {
  Task? task,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await Navigator.push<String>(
    context,
    MaterialPageRoute(
        builder: (_) => TaskFormScreen(store: store, task: task)),
  );
  if (result == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(result == 'added'
          ? 'Tugas berhasil ditambahkan ✅'
          : 'Perubahan tugas berhasil disimpan ✅'),
      behavior: SnackBarBehavior.floating,
    ));
}