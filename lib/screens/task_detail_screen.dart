import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../utils/status_style.dart';
import '../utils/task_actions.dart';
import '../widgets/status_chip.dart';
import 'task_form_screen.dart';

/// Screen 3: informasi lengkap satu tugas.
///
/// Menerima [taskId] (bukan objek Task) lalu mengambil data terbaru dari provider,
/// sehingga tampilan otomatis ikut berubah ketika tugas diedit atau status diganti.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    // select: hanya membangun ulang bila task dengan id ini berubah.
    final task = context.select<TaskProvider, Task?>((p) => p.findById(taskId));

    // Terjadi sesaat setelah tugas dihapus, sebelum halaman ditutup.
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(child: Text('Tugas tidak ditemukan')),
      );
    }

    final done = task.status == TaskStatus.selesai;
    final deadlineColor = task.isOverdue ? AppTheme.danger : AppTheme.textDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            tooltip: 'Ubah',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEdit(context, task),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
            onPressed: () => _delete(context, task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // Kartu ringkasan: judul + status.
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 12),
                StatusChip(status: task.status),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kartu informasi: mata kuliah, deadline, tanggal dibuat.
          _SectionCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.menu_book_outlined,
                  label: 'Mata Kuliah',
                  value: task.course,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.event,
                  label: 'Deadline',
                  value: done
                      ? DateHelper.formatLong(task.deadline)
                      : '${DateHelper.formatLong(task.deadline)}\n${DateHelper.deadlineInfo(task)}',
                  valueColor: deadlineColor,
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.history,
                  label: 'Dibuat pada',
                  value: DateHelper.formatLong(task.createdAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kartu deskripsi.
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kartu ubah status cepat.
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final status in TaskStatus.values)
                      ChoiceChip(
                        avatar: Icon(
                          status.style.icon,
                          size: 18,
                          color: status.style.foreground,
                        ),
                        label: Text(status.label),
                        selected: task.status == status,
                        onSelected: (_) => context
                            .read<TaskProvider>()
                            .updateStatus(task.id, status),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol aksi di bagian bawah.
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _delete(context, task),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppTheme.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openEdit(context, task),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Ubah'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _delete(BuildContext context, Task task) async {
    final navigator = Navigator.of(context);
    final deleted = await confirmAndDeleteTask(context, task);
    // Setelah tugas terhapus, tutup halaman detail dan kembali ke daftar.
    if (deleted) navigator.pop();
  }
}

/// Kartu putih berborder yang membungkus setiap bagian pada halaman detail.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

/// Satu baris informasi: ikon, label kecil, dan nilai.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppTheme.textDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
