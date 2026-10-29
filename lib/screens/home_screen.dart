import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/task_actions.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_filter_bar.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

/// Screen 1: daftar tugas + pencarian + filter status + tombol tambah.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm({Task? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  void _openDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch: widget dibangun ulang setiap kali TaskProvider memanggil notifyListeners().
    final provider = context.watch<TaskProvider>();
    final tasks = provider.filteredTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Kuliah')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              textInputAction: TextInputAction.search,
              decoration: appInputDecoration(
                hint: 'Cari nama tugas atau mata kuliah',
                prefixIcon: Icons.search,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Bersihkan',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      ),
              ),
            ),
          ),
          StatusFilterBar(
            selected: provider.statusFilter,
            onSelected: provider.setStatusFilter,
            totalCount: provider.totalCount,
            countOf: provider.countByStatus,
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody(provider, tasks)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider, List<Task> tasks) {
    if (provider.totalCount == 0) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Belum ada tugas',
        message: 'Tekan tombol "Tambah Tugas" untuk mencatat tugas kuliah pertama Anda.',
      );
    }

    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Tugas tidak ditemukan',
        message: 'Coba ubah filter status atau kata kunci pencarian.',
      );
    }

    return ListView.builder(
      // Padding bawah besar agar item terakhir tidak tertutup tombol FAB.
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => _openDetail(task),
          onEdit: () => _openForm(task: task),
          onDelete: () => confirmAndDeleteTask(context, task),
        );
      },
    );
  }
}
