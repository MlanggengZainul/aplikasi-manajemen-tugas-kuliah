import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Dilempar ketika operasi penyimpanan lokal gagal.
class TaskStorageException implements Exception {
  const TaskStorageException(this.message);

  final String message;

  @override
  String toString() => 'TaskStorageException: $message';
}

/// Lapisan akses data (Local Storage) menggunakan `shared_preferences`.
///
/// Seluruh daftar tugas disimpan sebagai SATU string JSON pada key [storageKey].
/// Untuk skala MVP (puluhan sampai ratusan tugas) pendekatan ini sederhana dan cukup cepat.
class TaskStorageService {
  TaskStorageService(this._prefs);

  /// Versi pada nama key memudahkan migrasi skema di masa depan.
  static const String storageKey = 'tasks_v1';

  final SharedPreferences _prefs;

  /// READ: membaca semua tugas. Data cacat dilewati, bukan menggagalkan seluruh pembacaan.
  List<Task> loadTasks() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final tasks = <Task>[];
      for (final item in decoded) {
        try {
          tasks.add(Task.fromMap(Map<String, dynamic>.from(item as Map)));
        } catch (_) {
          // Lewati item yang strukturnya rusak.
        }
      }
      return tasks;
    } catch (_) {
      return [];
    }
  }

  /// Menulis ulang seluruh daftar tugas ke penyimpanan lokal.
  Future<void> saveTasks(List<Task> tasks) async {
    final encoded = jsonEncode(tasks.map((t) => t.toMap()).toList());
    final success = await _prefs.setString(storageKey, encoded);
    if (!success) {
      throw const TaskStorageException(
        'Gagal menyimpan data ke penyimpanan lokal.',
      );
    }
  }

  /// CREATE: menambah tugas, mengembalikan daftar terbaru.
  Future<List<Task>> addTask(Task task) async {
    final tasks = loadTasks()..add(task);
    await saveTasks(tasks);
    return tasks;
  }

  /// UPDATE: mengganti tugas dengan id yang sama, mengembalikan daftar terbaru.
  Future<List<Task>> updateTask(Task task) async {
    final tasks = loadTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw const TaskStorageException('Tugas tidak ditemukan.');
    }
    tasks[index] = task;
    await saveTasks(tasks);
    return tasks;
  }

  /// DELETE: menghapus tugas berdasarkan id, mengembalikan daftar terbaru.
  Future<List<Task>> deleteTask(String id) async {
    final tasks = loadTasks()..removeWhere((t) => t.id == id);
    await saveTasks(tasks);
    return tasks;
  }

  /// Menghapus seluruh data tugas (berguna untuk reset/pengujian).
  Future<void> clearAll() async {
    await _prefs.remove(storageKey);
  }
}
