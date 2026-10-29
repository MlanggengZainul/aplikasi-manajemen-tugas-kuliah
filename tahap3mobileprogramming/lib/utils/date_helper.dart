import 'package:intl/intl.dart';

import '../models/task.dart';

/// Kumpulan fungsi bantu untuk tanggal (locale Indonesia).
///
/// Catatan: `initializeDateFormatting('id_ID')` harus dipanggil di `main()`
/// sebelum fungsi format di bawah dipakai.
class DateHelper {
  DateHelper._();

  /// Membuang komponen jam sehingga hanya tanggal yang dibandingkan.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Contoh: "7 Okt 2026".
  static String formatShort(DateTime date) =>
      DateFormat('d MMM yyyy', 'id_ID').format(date);

  /// Contoh: "Rabu, 7 Oktober 2026".
  static String formatLong(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

  /// Selisih hari antara deadline dan hari ini (negatif = sudah lewat).
  /// Memakai UTC agar tidak terpengaruh perubahan zona waktu/DST.
  static int daysUntil(DateTime deadline) {
    final now = DateTime.now();
    final due = DateTime.utc(deadline.year, deadline.month, deadline.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }

  /// Teks ringkas sisa waktu: "Terlambat 2 hari", "Hari ini", "Besok", "5 hari lagi".
  static String deadlineInfo(Task task) {
    final days = daysUntil(task.deadline);
    if (days < 0) return 'Terlambat ${-days} hari';
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Besok';
    return '$days hari lagi';
  }
}
