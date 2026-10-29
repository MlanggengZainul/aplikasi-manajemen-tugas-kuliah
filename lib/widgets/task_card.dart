import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../utils/status_style.dart';
import 'status_chip.dart';

/// Kartu satu tugas pada Home Screen: judul, mata kuliah, deadline, status,
/// serta tombol Ubah dan Hapus. Mengetuk kartu membuka halaman detail.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.selesai;
    final deadlineColor = task.isOverdue ? AppTheme.danger : AppTheme.textMuted;
    final deadlineText = done
        ? DateHelper.formatShort(task.deadline)
        : '${DateHelper.formatShort(task.deadline)}  \u2022  ${DateHelper.deadlineInfo(task)}';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis warna di sisi kiri sebagai penanda status.
              Container(width: 5, color: task.status.style.foreground),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: done
                                    ? AppTheme.textMuted
                                    : AppTheme.textDark,
                                decoration:
                                    done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ubah',
                            visualDensity: VisualDensity.compact,
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            visualDensity: VisualDensity.compact,
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.danger,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        task.course,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: deadlineColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              deadlineText,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: task.isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: deadlineColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StatusChip(status: task.status),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
