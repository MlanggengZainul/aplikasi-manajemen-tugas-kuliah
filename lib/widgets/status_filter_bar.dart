import 'package:flutter/material.dart';

import '../models/task.dart';

/// Baris chip horizontal untuk memfilter tugas berdasarkan status.
/// [selected] bernilai null berarti "Semua".
class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.totalCount,
    required this.countOf,
  });

  final TaskStatus? selected;
  final ValueChanged<TaskStatus?> onSelected;
  final int totalCount;
  final int Function(TaskStatus status) countOf;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip('Semua ($totalCount)', selected == null, () {
            onSelected(null);
          }),
          for (final status in TaskStatus.values)
            _buildChip(
              '${status.label} (${countOf(status)})',
              selected == status,
              () => onSelected(status),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
