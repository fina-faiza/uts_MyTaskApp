
import 'dart:async';
import 'package:flutter/material.dart';
import '../state/task_store.dart';

class StatsHeader extends StatefulWidget {
  final TaskStore store;
  const StatsHeader({super.key, required this.store});

  @override
  State<StatsHeader> createState() => _StatsHeaderState();
}

class _StatsHeaderState extends State<StatsHeader> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // Memperbarui jam setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  String get _date {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis',
      'Jumat', 'Sabtu', 'Minggu'
    ];

    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember'
    ];

    return '${days[_now.weekday - 1]}, '
        '${_now.day} ${months[_now.month - 1]} ${_now.year}';
  }

  String get _time {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '${twoDigits(_now.hour)}:'
        '${twoDigits(_now.minute)}:'
        '${twoDigits(_now.second)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final percent = (store.progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _date,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            _time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFeatures: [],
            ),
          ),

          const SizedBox(height: 4),
          const Text(
            'My Task App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _StatCard(
                icon: Icons.assignment_outlined,
                color: const Color(0xFF3B6EF5),
                value: store.total,
                label: 'Total',
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16A34A),
                value: store.done,
                label: 'Selesai',
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: Icons.access_time,
                color: const Color(0xFFF59E0B),
                value: store.pending,
                label: 'Belum',
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: store.progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percent% selesai',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
