import 'package:flutter/material.dart';

import '../models/task.dart';
import '../state/task_store.dart';

class ProfileScreen extends StatelessWidget {
  final TaskStore store;
  const ProfileScreen({super.key, required this.store});

  Future<void> _showEditNameDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _EditNameDialog(
        initialName: store.profileName,
        onSave: store.updateProfileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final percent = (store.progress * 100).round();
        final tasks = store.tasks;

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 24,
                  20,
                  28,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B6EF5), Color(0xFF6C8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF3B6EF5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          store.profileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit nama',
                          onPressed: () => _showEditNameDialog(context),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ringkasan tugas kuliah kamu',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 96,
                            height: 96,
                            child: CircularProgressIndicator(
                              value: store.progress,
                              strokeWidth: 9,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'selesai',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _MiniStat(
                          'Total',
                          store.total,
                          const Color(0xFF3B6EF5),
                        ),
                        const SizedBox(width: 10),
                        _MiniStat(
                          'Selesai',
                          store.done,
                          const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 10),
                        _MiniStat('Terlambat', store.overdue, Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Per Mata Kuliah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final course in kCourses)
                      Builder(
                        builder: (_) {
                          final list = tasks
                              .where((t) => t.course == course)
                              .toList();
                          if (list.isEmpty) return const SizedBox.shrink();
                          final done = list.where((t) => t.isDone).length;
                          final color = courseColor(course);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        course,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$done/${list.length} selesai',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: done / list.length,
                                    minHeight: 7,
                                    backgroundColor: color.withOpacity(0.12),
                                    valueColor: AlwaysStoppedAnimation(color),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (store.total == 0)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Belum ada data tugas.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onSave;

  const _EditNameDialog({required this.initialName, required this.onSave});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(_controller.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Nama'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
