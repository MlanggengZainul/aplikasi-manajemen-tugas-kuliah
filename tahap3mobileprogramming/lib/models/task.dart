import 'dart:convert';

/// Status pengerjaan sebuah tugas.
///
/// Setiap nilai membawa [label] yang ditampilkan pada antarmuka.
/// Saat disimpan ke Local Storage, yang disimpan adalah [name]
/// (misalnya "belumDikerjakan"), bukan label, agar data tetap stabil
/// walaupun teks tampilan berubah di kemudian hari.
enum TaskStatus {
  belumDikerjakan('Belum Dikerjakan'),
  sedangDikerjakan('Sedang Dikerjakan'),
  selesai('Selesai');

  const TaskStatus(this.label);

  final String label;

  /// Mengubah string tersimpan menjadi [TaskStatus].
  /// Nilai tidak dikenal/null otomatis menjadi [belumDikerjakan].
  static TaskStatus fromName(String? name) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => TaskStatus.belumDikerjakan,
    );
  }
}

/// Model data satu tugas kuliah (immutable).
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.course,
    required this.description,
    required this.deadline,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String course;
  final String description;
  final DateTime deadline;
  final TaskStatus status;
  final DateTime createdAt;

  /// Membuat tugas baru dengan id unik berbasis waktu.
  factory Task.create({
    required String title,
    required String course,
    required String description,
    required DateTime deadline,
    TaskStatus status = TaskStatus.belumDikerjakan,
  }) {
    final now = DateTime.now();
    return Task(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      course: course,
      description: description,
      deadline: deadline,
      status: status,
      createdAt: now,
    );
  }

  /// Menyalin objek dengan mengganti sebagian field (pola umum untuk model immutable).
  Task copyWith({
    String? title,
    String? course,
    String? description,
    DateTime? deadline,
    TaskStatus? status,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      course: course ?? this.course,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// True jika deadline sudah lewat (dibandingkan per tanggal) dan tugas belum selesai.
  bool get isOverdue {
    if (status == TaskStatus.selesai) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    return due.isBefore(today);
  }

  /// Objek -> Map. Tanggal disimpan sebagai string ISO-8601, status sebagai nama enum.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'course': course,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Map -> objek. Dibuat toleran: tanggal rusak/kosong diganti waktu sekarang
  /// agar satu data yang cacat tidak membuat seluruh daftar gagal dimuat.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      course: (map['course'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      deadline: DateTime.tryParse((map['deadline'] as String?) ?? '') ??
          DateTime.now(),
      status: TaskStatus.fromName(map['status'] as String?),
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  /// Objek -> string JSON.
  String toJson() => jsonEncode(toMap());

  /// String JSON -> objek.
  factory Task.fromJson(String source) =>
      Task.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
