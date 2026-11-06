import 'package:flutter/material.dart';
import '../models/task.dart';
import '../state/task_store.dart';
import '../utils/format.dart';
import '../utils/navigation.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskStore store;
  final String taskId;
  const TaskDetailScreen(
      {super.key, required this.store, required this.taskId});

  Future<void> _delete(BuildContext context, Task t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('"${t.title}" akan dihapus dari daftar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      store.remove(t);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final t = store.byId(taskId);
        if (t == null) return const Scaffold(body: SizedBox());
        final cColor = courseColor(t.course);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Tugas'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => openTaskForm(context, store, task: t),
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _delete(context, t),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: () => store.toggleDone(t),
                icon: Icon(t.isDone ? Icons.undo : Icons.check_circle_outline),
                label:
                    Text(t.isDone ? 'Tandai Belum Selesai' : 'Tandai Selesai'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor:
                      t.isDone ? Colors.blueGrey : const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(t.course),
                  backgroundColor: cColor.withOpacity(0.12),
                  labelStyle:
                      TextStyle(color: cColor, fontWeight: FontWeight.w700),
                  side: BorderSide.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(t.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    decoration: t.isDone ? TextDecoration.lineThrough : null,
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _InfoRow(Icons.event_outlined, 'Deadline',
                        formatDeadline(t.deadline),
                        valueColor: t.isOverdue ? Colors.red : null),
                    if (!t.isDone) ...[
                      const Divider(height: 24),
                      _InfoRow(Icons.timer_outlined, 'Sisa waktu',
                          sisaWaktu(t.deadline),
                          valueColor: t.isOverdue ? Colors.red : null),
                    ],
                    const Divider(height: 24),
                    _InfoRow(Icons.flag_outlined, 'Prioritas', t.priority.label,
                        valueColor: t.priority.color),
                    const Divider(height: 24),
                    _InfoRow(Icons.info_outline, 'Status', t.status.label,
                        valueColor: t.status.color),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Ubah Status Pengerjaan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TaskStatus>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: TaskStatus.pending, label: Text('Belum')),
                    ButtonSegment(
                        value: TaskStatus.inProgress, label: Text('Proses')),
                    ButtonSegment(
                        value: TaskStatus.done, label: Text('Selesai')),
                  ],
                  selected: {t.status},
                  onSelectionChanged: (s) => store.setStatus(t, s.first),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Catatan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  t.notes.isEmpty ? 'Tidak ada catatan.' : t.notes,
                  style: TextStyle(
                      color: t.notes.isEmpty ? Colors.grey : Colors.black87,
                      height: 1.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.icon, this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }
}