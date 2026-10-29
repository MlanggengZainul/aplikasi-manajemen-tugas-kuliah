import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'services/task_storage_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin (shared_preferences) pada main() yang async.
  WidgetsFlutterBinding.ensureInitialized();

  // Menyiapkan data format tanggal bahasa Indonesia (nama hari dan bulan).
  await initializeDateFormatting('id_ID');

  // Membuka Local Storage sekali, lalu menyuntikkannya ke service -> provider.
  final prefs = await SharedPreferences.getInstance();
  final provider = TaskProvider(TaskStorageService(prefs));

  // Memuat data tersimpan SEBELUM UI tampil, sehingga daftar langsung terisi.
  await provider.loadTasks();

  runApp(TaskManagerApp(provider: provider));
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key, required this.provider});

  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider menyediakan TaskProvider ke seluruh widget di bawahnya.
    return ChangeNotifierProvider<TaskProvider>(
      create: (_) => provider,
      child: MaterialApp(
        title: 'Tugas Kuliah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // Lokalisasi Indonesia agar DatePicker dan teks bawaan Material berbahasa Indonesia.
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
