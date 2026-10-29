# Aplikasi Manajemen Tugas Kuliah Berbasis Local Storage

Aplikasi Manajemen Tugas Kuliah merupakan aplikasi mobile berbasis Android yang dikembangkan menggunakan **Flutter** dan bahasa pemrograman **Dart**. Aplikasi ini dirancang untuk membantu mahasiswa mencatat, mengelola, dan memantau tugas kuliah secara terorganisir dengan memanfaatkan penyimpanan lokal (*local storage*).

Aplikasi menggunakan pendekatan **offline-first**, sehingga pengguna dapat mengelola tugas tanpa memerlukan koneksi internet.

## 📌 Fitur Utama

- **Tambah Tugas** — Menambahkan tugas baru beserta informasi yang diperlukan.
- **Daftar Tugas** — Menampilkan seluruh tugas yang telah disimpan.
- **Detail Tugas** — Melihat informasi lengkap dari setiap tugas.
- **Edit Tugas** — Mengubah informasi tugas yang sudah tersimpan.
- **Hapus Tugas** — Menghapus tugas yang tidak diperlukan dengan konfirmasi.
- **Status Tugas** — Mengelompokkan tugas menjadi:
  - Belum Dikerjakan
  - Sedang Dikerjakan
  - Selesai
- **Deadline Tugas** — Menentukan batas waktu pengumpulan tugas.
- **Pencarian Tugas** — Mencari tugas berdasarkan nama tugas atau mata kuliah.
- **Filter Tugas** — Menyaring daftar tugas berdasarkan status.
- **Penyimpanan Lokal** — Menyimpan data secara lokal agar tetap tersedia ketika aplikasi ditutup dan dibuka kembali.
- **Indikator Visual** — Menggunakan penanda warna untuk membantu pengguna mengenali status tugas dan deadline.

## 🛠️ Teknologi yang Digunakan

- **Flutter** — Framework pengembangan aplikasi mobile.
- **Dart** — Bahasa pemrograman.
- **Provider** — State management untuk mengelola perubahan data dan memperbarui antarmuka.
- **shared_preferences** — Penyimpanan data lokal berbasis key-value.
- **JSON** — Format serialisasi data tugas.

## 🏗️ Arsitektur Aplikasi

Aplikasi menggunakan pemisahan komponen untuk memudahkan pengembangan dan pemeliharaan kode.

```text
lib/
├── models/
│   └── task.dart
├── providers/
│   └── task_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── task_form_screen.dart
│   └── task_detail_screen.dart
├── services/
│   └── task_storage_service.dart
└── widgets/
```

*Catatan: Nama dan susunan file dapat disesuaikan dengan struktur proyek yang sebenarnya.*

### Penjelasan Komponen

- **Models**: Mendefinisikan struktur data tugas.
- **Providers**: Mengelola state dan logika perubahan data tugas.
- **Screens**: Menyediakan halaman antarmuka aplikasi.
- **Services**: Menangani proses penyimpanan dan pembacaan data lokal.
- **Widgets**: Menyimpan komponen antarmuka yang dapat digunakan kembali.

## 🔄 Alur Kerja Aplikasi

1. Pengguna membuka aplikasi.
2. Aplikasi memuat data tugas dari `shared_preferences`.
3. Pengguna dapat menambahkan, melihat, mengubah, menghapus, mencari, atau memfilter tugas.
4. Perubahan data dikelola oleh `TaskProvider`.
5. `TaskStorageService` mengubah data tugas menjadi JSON dan menyimpannya ke penyimpanan lokal.
6. Antarmuka diperbarui untuk menampilkan data terbaru.

## ⚙️ Persyaratan Sistem

Sebelum menjalankan aplikasi, pastikan perangkat pengembangan telah memiliki:

- Flutter SDK.
- Dart SDK (biasanya sudah termasuk dalam Flutter SDK).
- Android Studio atau Visual Studio Code.
- Android Emulator atau perangkat Android fisik.


## 🧪 Pengujian Aplikasi

Pengujian dilakukan menggunakan metode **Black Box Testing** untuk memeriksa fungsi utama aplikasi.

+-------+--------------------------------------+----------------------------------------+
| Kode  | Skenario Pengujian                   | Hasil yang Diharapkan                  |
|-------|--------------------------------------|----------------------------------------|
| TC-01 | Menyimpan tugas dengan nama kosong   | Validasi menampilkan pesan peringatan  |
| TC-02 | Menambahkan tugas baru               | Tugas tersimpan dan muncul pada daftar |
| TC-03 | Menutup dan membuka kembali aplikasi | Data tugas tetap tersedia              |
| TC-04 | Memfilter tugas berdasarkan status   | Daftar menampilkan tugas sesuai filter |
| TC-05 | Menghapus tugas                      | Tugas terhapus setelah konfirmasi      |
| TC-06 | Mengubah data tugas                  | Perubahan tersimpan dan ditampilkan    |
+-------+--------------------------------------+----------------------------------------+

## ✅ Kelebihan Aplikasi

- Dapat digunakan tanpa koneksi internet untuk fungsi utama.
- Memiliki antarmuka yang sederhana dan mudah dipahami.
- Memudahkan mahasiswa mengelola tugas dari berbagai mata kuliah.
- Menyediakan fitur pencarian dan filter untuk membantu pengelolaan tugas.
- Menggunakan pemisahan komponen kode agar lebih mudah dipelihara.

## ⚠️ Keterbatasan

- Data tersimpan pada perangkat pengguna dan belum tersinkronisasi otomatis ke perangkat lain.
- Data lokal berisiko hilang apabila penyimpanan aplikasi dihapus atau perangkat direset.
- `shared_preferences` lebih sesuai untuk penyimpanan data sederhana dan bukan pengganti database untuk data berskala besar.

## 🔮 Pengembangan Selanjutnya

Beberapa pengembangan yang dapat dilakukan antara lain:

- Menambahkan notifikasi pengingat deadline.
- Menambahkan fitur pencadangan data ke cloud.
- Menambahkan kategori dan tingkat prioritas tugas.
- Mengembangkan sinkronisasi data antarperangkat.

## 👥 Anggota Kelompok

1. **Muhammad Farras Mufadhdhal** — 240605110154
2. **Muhammad Langgeng Zainul Irsyad Tsalis** — 240605110174
3. **Muhammad Fachri Hafizh Saleh** — 240605110175

## 🎓 Informasi Proyek

- **Mata Kuliah:** Mobile Programming
- **Program Studi:** Teknik Informatika
- **Fakultas:** Sains dan Teknologi
- **Universitas:** UIN Maulana Malik Ibrahim Malang

---

Dikembangkan sebagai proyek mata kuliah Mobile Programming untuk membantu mahasiswa mengelola tugas kuliah secara lebih terstruktur dan efisien.
