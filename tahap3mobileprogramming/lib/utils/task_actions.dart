import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import 'app_theme.dart';

/// Menampilkan dialog konfirmasi. Mengembalikan true bila pengguna menekan "Hapus".
Future<bool> showDeleteConfirmDialog(BuildContext context, Task task) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hapus tugas?'),
      content: Text('Tugas "${task.title}" akan dihapus permanen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Alur lengkap hapus: konfirmasi -> hapus dari storage -> SnackBar dengan tombol "URUNGKAN".
/// Dipakai bersama oleh Home Screen dan Detail Screen. Mengembalikan true bila terhapus.
Future<bool> confirmAndDeleteTask(BuildContext context, Task task) async {
  // Referensi diambil SEBELUM operasi async agar aman dari masalah BuildContext.
  final provider = context.read<TaskProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDeleteConfirmDialog(context, task);
  if (!confirmed) return false;

  final success = await provider.deleteTask(task.id);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          success
              ? 'Tugas berhasil dihapus'
              : (provider.errorMessage ?? 'Gagal menghapus tugas'),
        ),
        action: success
            ? SnackBarAction(
                label: 'URUNGKAN',
                onPressed: () => provider.addTask(task),
              )
            : null,
      ),
    );

  return success;
}
