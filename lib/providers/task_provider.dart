import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';

/// State management aplikasi (Provider + ChangeNotifier).
///
/// Menyimpan daftar tugas di memori, filter status, dan kata kunci pencarian.
/// Setiap perubahan data ditulis ke Local Storage lewat [TaskStorageService],
/// lalu UI diberi tahu melalui [notifyListeners].
class TaskProvider extends ChangeNotifier {
  TaskProvider(this._service);

  final TaskStorageService _service;

  List<Task> _tasks = [];
  TaskStatus? _statusFilter; // null = tampilkan semua status
  String _searchQuery = '';
  String? _errorMessage;

  TaskStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  int get totalCount => _tasks.length;

  /// Daftar tugas setelah filter status + pencarian diterapkan.
  /// Urutan: tugas aktif lebih dulu (deadline terdekat di atas), tugas selesai di bawah.
  List<Task> get filteredTasks {
    final query = _searchQuery.trim().toLowerCase();

    final result = _tasks.where((task) {
      final matchStatus = _statusFilter == null || task.status == _statusFilter;
      final matchQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.course.toLowerCase().contains(query);
      return matchStatus && matchQuery;
    }).toList();

    result.sort((a, b) {
      final aDone = a.status == TaskStatus.selesai;
      final bDone = b.status == TaskStatus.selesai;
      if (aDone != bDone) return aDone ? 1 : -1;
      return a.deadline.compareTo(b.deadline);
    });

    return result;
  }

  /// Jumlah tugas pada status tertentu (untuk badge pada filter).
  int countByStatus(TaskStatus status) =>
      _tasks.where((task) => task.status == status).length;

  /// Mencari tugas berdasarkan id; null bila tidak ada.
  Task? findById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// Memuat data dari Local Storage (dipanggil sekali saat aplikasi dimulai).
  Future<void> loadTasks() async {
    _tasks = _service.loadTasks();
    _errorMessage = null;
    notifyListeners();
  }

  /// Mengembalikan true bila berhasil disimpan.
  Future<bool> addTask(Task task) => _mutate(() => _service.addTask(task));

  Future<bool> updateTask(Task task) =>
      _mutate(() => _service.updateTask(task));

  Future<bool> deleteTask(String id) => _mutate(() => _service.deleteTask(id));

  /// Mengubah status saja (dipakai pada halaman detail).
  Future<bool> updateStatus(String id, TaskStatus status) {
    final task = findById(id);
    if (task == null) return Future.value(false);
    return updateTask(task.copyWith(status: status));
  }

  void setStatusFilter(TaskStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Pola umum: jalankan operasi storage, simpan hasilnya, tangani error di satu tempat.
  Future<bool> _mutate(Future<List<Task>> Function() action) async {
    try {
      _tasks = await action();
      _errorMessage = null;
      notifyListeners();
      return true;
    } on TaskStorageException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
