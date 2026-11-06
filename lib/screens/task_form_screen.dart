import 'package:flutter/material.dart';
import '../models/task.dart';
import '../state/task_store.dart';
import '../utils/format.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskStore store;
  final Task? task; // null = tambah, tidak null = edit
  const TaskFormScreen({super.key, required this.store, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleC;
  late final TextEditingController _notesC;
  String? _course;
  DateTime? _deadline;
  Priority _priority = Priority.medium;
  bool _submitted = false;
  List<String> _missing = [];

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleC = TextEditingController(text: t?.title ?? '');
    _notesC = TextEditingController(text: t?.notes ?? '');
    _course = t?.course;
    _deadline = t?.deadline;
    _priority = t?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(days: 1));
    final current = _deadline ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: current.isBefore(earliest) ? current : earliest,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    setState(() {
      _deadline =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final title = _titleC.text.trim();
    final missing = <String>[];
    if (title.length < 3) missing.add('Judul tugas');
    if (_course == null) missing.add('Mata kuliah');
    if (_deadline == null) missing.add('Deadline');

    setState(() {
      _submitted = true;
      _missing = missing;
    });
    _formKey.currentState!.validate();

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Data belum lengkap: ${missing.join(', ')}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }

    if (_isEdit) {
      widget.store.update(
        widget.task!,
        title: title,
        course: _course!,
        deadline: _deadline!,
        priority: _priority,
        notes: _notesC.text.trim(),
      );
      Navigator.pop(context, 'edited');
    } else {
      widget.store.add(Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        course: _course!,
        deadline: _deadline!,
        priority: _priority,
        notes: _notesC.text.trim(),
      ));
      Navigator.pop(context, 'added');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineError = _submitted && _deadline == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Tugas' : 'Tambah Tugas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Tugas'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_missing.isNotEmpty) _ErrorBanner(fields: _missing),
            const _Label('Judul Tugas *'),
            TextFormField(
              controller: _titleC,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(hintText: 'Masukkan judul tugas'),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return 'Judul tugas tidak boleh kosong';
                if (s.length < 3) return 'Judul tugas minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 18),
            const _Label('Mata Kuliah *'),
            DropdownButtonFormField<String>(
              value: _course,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Pilih mata kuliah'),
              items: [
                for (final c in kCourses)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _course = v),
              validator: (v) => v == null ? 'Mata kuliah harus dipilih' : null,
            ),
            const SizedBox(height: 18),
            const _Label('Deadline *'),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickDeadline,
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.event_outlined),
                  suffixIcon: const Icon(Icons.chevron_right),
                  errorText: deadlineError ? 'Deadline harus diisi' : null,
                ),
                child: Text(
                  _deadline == null
                      ? 'Pilih tanggal & jam'
                      : formatDeadline(_deadline!),
                  style: TextStyle(
                      color: _deadline == null
                          ? Colors.grey.shade600
                          : Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const _Label('Prioritas'),
            Row(
              children: [
                for (final p in Priority.values)
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: p == Priority.high ? 0 : 8),
                      child: ChoiceChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text(p.label, textAlign: TextAlign.center),
                        ),
                        selected: _priority == p,
                        selectedColor: p.color.withOpacity(0.18),
                        side: BorderSide(
                            color: _priority == p
                                ? p.color
                                : Colors.grey.shade300),
                        labelStyle: TextStyle(
                            color: _priority == p ? p.color : Colors.black87,
                            fontWeight: FontWeight.w600),
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _priority = p),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const _Label('Catatan (opsional)'),
            TextFormField(
              controller: _notesC,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan atau deskripsi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final List<String> fields;
  const _ErrorBanner({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Data belum lengkap. Mohon periksa: ${fields.join(', ')}.',
              style: TextStyle(
                  color: Colors.red.shade800, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );
}