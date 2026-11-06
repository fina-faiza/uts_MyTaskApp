import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/format.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cColor = courseColor(task.course);
    final overdue = task.isOverdue;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
            color: overdue ? Colors.red.shade200 : Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 0, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                activeColor: const Color(0xFF16A34A),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: task.priority.color,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isDone
                                  ? Colors.grey
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(task.course,
                        style: TextStyle(
                            color: cColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 13,
                            color: overdue ? Colors.red : Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatDeadline(task.deadline),
                            style: TextStyle(
                                fontSize: 12,
                                color: overdue
                                    ? Colors.red
                                    : Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Pill(task.status.label, task.status.color),
                        if (!task.isDone)
                          _Pill(sisaWaktu(task.deadline),
                              overdue ? Colors.red : Colors.blueGrey),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Menu tugas',
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 20, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}