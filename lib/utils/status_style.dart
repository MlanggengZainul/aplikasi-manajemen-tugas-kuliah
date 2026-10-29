import 'package:flutter/material.dart';

import '../models/task.dart';

/// Warna latar, warna teks/ikon, dan ikon untuk satu status.
class StatusStyle {
  const StatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final IconData icon;
}

/// Extension agar gaya bisa diakses langsung: `task.status.style`.
extension TaskStatusStyle on TaskStatus {
  StatusStyle get style {
    switch (this) {
      case TaskStatus.belumDikerjakan:
        return const StatusStyle(
          foreground: Color(0xFFC62828),
          background: Color(0xFFFDECEA),
          icon: Icons.radio_button_unchecked,
        );
      case TaskStatus.sedangDikerjakan:
        return const StatusStyle(
          foreground: Color(0xFF8D6100),
          background: Color(0xFFFFF4D6),
          icon: Icons.timelapse,
        );
      case TaskStatus.selesai:
        return const StatusStyle(
          foreground: Color(0xFF2E7D32),
          background: Color(0xFFE6F4EA),
          icon: Icons.check_circle,
        );
    }
  }
}
