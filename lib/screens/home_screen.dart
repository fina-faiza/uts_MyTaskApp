
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../state/task_store.dart';
import '../utils/navigation.dart';
import '../widgets/stats_header.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final TaskStore store;

  const HomeScreen({
    super.key,
    required this.store,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filter = 0; // 0 = Semua, 1 = Belum, 2 = Selesai
  String _query = '';

  TaskStore get store => widget.store;

  List<Task> _visible() {
    return store.tasks.where((t) {
      if (_filter == 1 && t.isDone) return false;
      if (_filter == 2 && !t.isDone) return false;

      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();

        return t.title.toLowerCase().contains(q) ||
            t.course.toLowerCase().contains(q);
      }

      return true;
    }).toList();
  }

  // Membuka halaman detail tugas
  void _openDetail(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          store: store,
          taskId: task.id,
        ),
      ),
    );
  }

  // Membuka form edit tugas
  Future<void> _editTask(Task task) async {
    await openTaskForm(
      context,
      store,
      task: task,
    );
  }

  // Konfirmasi hapus tugas
  Future<void> _confirmDelete(Task task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text(
          '"${task.title}" akan dihapus dari daftar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    store.remove(task);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Tugas dihapus'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'URUNGKAN',
            onPressed: () => store.restore(task),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const filters = [
      'Semua',
      'Belum',
      'Selesai',
    ];

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = _visible();

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header dan statistik
                StatsHeader(store: store),

                // Pencarian tugas
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari tugas atau mata kuliah...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                      ),
                    ),
                  ),
                ),

                // Filter tugas
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    children: [
                      for (int i = 0; i < filters.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: ChoiceChip(
                            label: Text(filters[i]),
                            selected: _filter == i,
                            onSelected: (_) {
                              setState(() {
                                _filter = i;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Daftar tugas
                Expanded(
                  child: items.isEmpty
                      ? _EmptyState(
                          searching:
                              _query.isNotEmpty || _filter != 0,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final task = items[index];

                            return TaskCard(
                              key: ValueKey(task.id),
                              task: task,

                              // Buka detail tugas
                              onTap: () {
                                _openDetail(task);
                              },

                              // Ubah status tugas
                              onToggle: () {
                                store.toggleDone(task);
                              },

                              // Edit tugas
                              onEdit: () {
                                _editTask(task);
                              },

                              // Hapus tugas
                              onDelete: () {
                                _confirmDelete(task);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Tampilan ketika daftar tugas kosong
class _EmptyState extends StatelessWidget {
  final bool searching;

  const _EmptyState({
    required this.searching,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            searching ? Icons.search_off : Icons.task_alt,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            searching
                ? 'Tidak ada tugas yang cocok'
                : 'Belum ada tugas',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            searching
                ? 'Coba ubah filter atau kata kunci.'
                : 'Tekan "Tambah" di menu bawah untuk memulai.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
