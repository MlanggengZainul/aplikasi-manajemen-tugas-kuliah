import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../utils/status_style.dart';

/// Screen 2: form untuk menambah tugas baru, atau mengubah tugas jika [task] diisi.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  /// null = mode Tambah, non-null = mode Ubah.
  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController(); // hanya untuk tampilan

  DateTime? _deadline;
  TaskStatus _status = TaskStatus.belumDikerjakan;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      // Mode ubah: isi form dengan data yang sudah ada.
      _titleController.text = task.title;
      _courseController.text = task.course;
      _descriptionController.text = task.description;
      _deadline = DateHelper.dateOnly(task.deadline);
      _deadlineController.text = DateHelper.formatLong(_deadline!);
      _status = task.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  /// Membuka DatePicker. Memilih tanggal lewat picker menghindari kesalahan format input manual.
  Future<void> _pickDeadline() async {
    final today = DateHelper.dateOnly(DateTime.now());
    final current = _deadline;

    // Jika deadline lama sudah lewat (mode ubah), picker harus tetap bisa menampilkannya.
    final firstDate = (current != null && current.isBefore(today)) ? current : today;
    final initialDate = current ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 5, 12, 31),
      helpText: 'Pilih deadline',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked == null) return;

    // Mengubah teks controller membuat kolom deadline divalidasi ulang otomatis
    // (autovalidateMode: onUserInteraction), sehingga pesan error lama hilang.
    setState(() {
      _deadline = DateHelper.dateOnly(picked);
      _deadlineController.text = DateHelper.formatLong(_deadline!);
    });
  }

  // ---------- Validator ----------

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama tugas wajib diisi';
    if (text.length < 3) return 'Nama tugas minimal 3 karakter';
    return null;
  }

  String? _validateCourse(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Mata kuliah wajib diisi';
    return null;
  }

  String? _validateDescription(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Deskripsi wajib diisi';
    return null;
  }

  String? _validateDeadline(String? _) {
    final deadline = _deadline;
    if (deadline == null) return 'Deadline wajib dipilih';

    final today = DateHelper.dateOnly(DateTime.now());
    // Tanggal lampau hanya diizinkan bila itu adalah deadline asli tugas yang sedang diubah.
    final unchangedOriginal = _isEditing &&
        deadline == DateHelper.dateOnly(widget.task!.deadline);
    if (deadline.isBefore(today) && !unchangedOriginal) {
      return 'Deadline tidak boleh sebelum hari ini';
    }
    return null;
  }

  // ---------- Simpan ----------

  Future<void> _save() async {
    // Hentikan jika ada kolom yang belum valid.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final title = _titleController.text.trim();
    final course = _courseController.text.trim();
    final description = _descriptionController.text.trim();

    final bool success;
    if (_isEditing) {
      success = await provider.updateTask(
        widget.task!.copyWith(
          title: title,
          course: course,
          description: description,
          deadline: _deadline,
          status: _status,
        ),
      );
    } else {
      success = await provider.addTask(
        Task.create(
          title: title,
          course: course,
          description: description,
          deadline: _deadline!,
          status: _status,
        ),
      );
    }

    if (!mounted) return;

    if (success) {
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              _isEditing ? 'Tugas berhasil diperbarui' : 'Tugas berhasil ditambahkan',
            ),
          ),
        );
    } else {
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(provider.errorMessage ?? 'Gagal menyimpan tugas'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Ubah Tugas' : 'Tambah Tugas')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: appInputDecoration(
                label: 'Nama Tugas',
                hint: 'Contoh: Laporan Praktikum Modul 10',
                prefixIcon: Icons.title,
              ),
              validator: _validateTitle,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _courseController,
              maxLength: 60,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: appInputDecoration(
                label: 'Mata Kuliah',
                hint: 'Contoh: Pemrograman Mobile',
                prefixIcon: Icons.menu_book_outlined,
              ),
              validator: _validateCourse,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLength: 500,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: appInputDecoration(
                label: 'Deskripsi',
                hint: 'Tuliskan rincian tugas',
                prefixIcon: Icons.notes,
              ),
              validator: _validateDescription,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _deadlineController,
              readOnly: true,
              onTap: _pickDeadline,
              decoration: appInputDecoration(
                label: 'Deadline',
                hint: 'Pilih tanggal deadline',
                prefixIcon: Icons.event,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              validator: _validateDeadline,
            ),
            const SizedBox(height: 20),
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in TaskStatus.values)
                  ChoiceChip(
                    avatar: Icon(status.style.icon, size: 18, color: status.style.foreground),
                    label: Text(status.label),
                    selected: _status == status,
                    onSelected: (_) => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Tugas'),
            ),
          ],
        ),
      ),
    );
  }
}
