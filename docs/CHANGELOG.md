# CHANGELOG — SIMANDOR Update

## Phase 4: Build System Modernization & Physical Device Deployment (Selesai: 31 Oktober 2026)

### 1. ⚙️ Modernisasi Gradle & Android Toolchain (Java 17 & Declarative Plugins)
- **Migrasi ke Flutter Declarative Plugin DSL**:
  - Mengupdate `android/settings.gradle` dengan `pluginManagement` dan `plugins` block deklaratif (`dev.flutter.flutter-plugin-loader: 1.0.0`).
  - Mengonfigurasi **Android Gradle Plugin (AGP)** versi `8.11.1` dan **Kotlin Gradle Plugin (KGP)** versi `2.2.20`.
  - Mengupdate `android/app/build.gradle` menggunakan plugins deklaratif (`com.android.application`, `dev.flutter.flutter-gradle-plugin`).
  - Menetapkan target kompatibilitas Java 17 (`JavaVersion.VERSION_17`) pada seluruh modul aplikasi.
- **Pembersihan Konfigurasi Build Legacy**:
  - Mengupgrade **Gradle Wrapper** dari `6.7` ke **`8.14-all`** (`android/gradle/wrapper/gradle-wrapper.properties`).
  - Menghapus flag usang `android.enableJetifier=true` yang menyebabkan *Java heap space exhaustion* pada AGP 8+.
  - Mengoptimalkan alokasi memori Gradle Daemon: `org.gradle.jvmargs=-Xmx4096M -XX:MaxMetaspaceSize=1024M`.
  - Menangani kompatibilitas path lintas drive Windows (Drive C: Pub cache vs Drive D: Project root).
- **Resolusi Inkompatibilitas Java 25 (Android Studio JBR)**:
  - Mengunci path JDK Flutter menggunakan `flutter config --jdk-dir="C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"` agar menggunakan JDK 17 LTS stabil alih-alih JDK 25 bundled dari Android Studio.
  - Menyesuaikan `subprojects` build dir di `android/build.gradle` agar output APK dihasilkan langsung ke `build/app/outputs/flutter-apk/app-debug.apk` sesuai ekspektasi Flutter CLI.

### 2. 📦 Resolusi Dependensi & Dart Compatibility
- Mengatasi inkonsistensi signature SDK Dart (`File.createSync(exclusive)`) dengan menambahkan dependensi override **`file: ^7.0.1`** pada `pubspec.yaml`.

### 3. 📱 Pengujian & Deployment ke Perangkat Fisik (Infinix X650C)
- Berhasil meng-compile APK debug `app-debug.apk` (163 MB).
- Berhasil menginstall dan meluncurkan aplikasi via ADB pada smartphone fisik **Infinix X650C** (Android 9 / API 28).
- **Status Aplikasi di HP**: `mResumedActivity: id.go.balangankab.simandorapp/.MainActivity` (**Foreground & Active**).
- Dart VM service tersambung normal tanpa error atau crash.

---

## Phase 3: Polish, UI/UX Design System & Camera Scanner (Selesai: 31 Oktober 2026)

### 1. 📷 Implementasi Modern Camera Scanner (`mobile_scanner`)
- Menggantikan package lama yang sudah ditinggalkan (`flutter_barcode_scanner`) dengan **`mobile_scanner: ^5.2.3`** modern.
- Menambahkan screen kamera khusus: `CameraScannerScreen` (`lib/presentation/scan/screens/camera_scanner_screen.dart`):
  - Viewfinder viewfinder kotak pemindaian dengan cutout transparan dan corner indicator biru modern.
  - Tombol Flashlight / Senter (Torch ON/OFF) yang responsif.
  - Tombol Switch Kamera (Depan / Belakang).
  - Penanganan error izin kamera secara elegan.
- Menambahkan izin kamera resmi di `android/app/src/main/AndroidManifest.xml`:
  - `android.permission.CAMERA`
  - `android.hardware.camera` (opsional)
  - `android.hardware.camera.autofocus` (opsional)

### 2. 🎨 Penerapan Design System Pemerintah Kab. Balangan & Material 3
- `AppColors` (`lib/core/constants/app_colors.dart`):
  - Primary: Deep Blue Balangan (`0xFF0F4C81`)
  - Secondary/Accent: Amber Gold (`0xFFF59E0B`)
  - Semantic: Success (`0xFF10B981`), Error (`0xFFEF4444`), Warning (`0xFFF59E0B`)
  - Neutral & Surface: Soft Slate Background (`0xFFF8FAFC`), Clean White Cards (`0xFFFFFFFF`), Border (`0xFFE2E8F0`)
- `AppTheme` (`lib/core/utils/app_theme.dart`):
  - Material 3 terintegrasi penuh.
  - Konsistensi border radius 12-16px, padding standar 16-24px, dan bayangan lembut.
  - Input fields dengan outline border halus dan state focus jelas.

### 3. ✨ Polish Halaman Utama & User Experience
- **Login Screen (`FormLoginScreen` & `LoginWidget`)**:
  - Hero header dengan gradien resmi Balangan Blue dan logo ikon instansi.
  - Form card mengambang dengan teks bantuan yang jelas.
  - Opsi akses instan "Scan Aset Tanpa Login (Tamu)" untuk inspeksi cepat.
- **Home / Scanner Screen (`ScanBarangScreen`)**:
  - Profil Petugas Card: Menampilkan nama lengkap, unit kerja/UPB, dan badge status ("Admin" / "Petugas").
  - Tombol pemindaian primer: "SCAN DENGAN KAMERA" berukuran besar.
  - Tombol sekunder: "INPUT KODE MANUAL" dengan modal dialog praktis.
  - Tips card praktis pencahayaan barcode.
- **Detail Aset Screen (`DetailPageScreen`)**:
  - Fitur **Pull-to-Refresh** (`RefreshIndicator`) untuk memuat ulang data terkini dari server.
  - Chip status kondisi aset dinamis (Baik / Kurang Baik / Rusak Berat) dengan warna semantik.
  - Card terstruktur:
    1. Header aset & nilai perolehan.
    2. Unit kerja, UPB, dan penempatan ruangan.
    3. Identitas spesifikasi teknis (Register, Nopol, BPKB, Nomor Rangka, Nomor Mesin, dll).
  - Modal pratinjau foto barang dengan `InteractiveViewer` (mendukung pinch-to-zoom).
- **Mapping KIB Screen (`FormKibLiteScreen`)**:
  - Dikelompokkan ke dalam 3 kartu langkah kerja yang logis:
    1. Hierarki Unit Kerja (Unit, Sub Unit, UPB).
    2. Klasifikasi Aset KIB (KIB A s/d F).
    3. Pemilihan Aset & Ringkasan.
  - Modal dialog konfirmasi sebelum menyimpan data pemetaan ke backend.

### 4. 🧪 Hasil Verifikasi Kompilasi & Pengujian
- `flutter analyze`: **No issues found!** (0 error, 0 warning dalam 3.5s).
- `flutter test`: **All tests passed!** (100% lulus pengujian unit).

---

## Phase 2: Restructure & Clean Architecture (Selesai: 31 Oktober 2026)

### 1. 🏗️ Restrukturisasi Modular (Clean Architecture)
Basecode dirombak dari struktur flat/acak menjadi arsitektur layer yang modular dan terisolasi:
- `lib/core/` (constants, network client, api result, utils, theme).
- `lib/data/` (models, repositories).
- `lib/presentation/` (auth, scan, detail, kib).

### 2. 🔌 Pembuatan Repository Layer
- Menghapus semua panggilan langsung `http.get` / `http.post` dari dalam widget UI.
- Terbentuk `AuthRepository`, `BarangRepository`, dan `KibRepository`.

### 3. 🛡️ Network Client & Error Handling Terpusat
- `ApiClient`: Menangani timeout (15 detik), `SocketException`, status error, dan wrapper `ApiResult<T>`.

### 4. 🧹 Standarisasi Naming Conventions
- Menstandarkan seluruh file ke `snake_case` dan menghapus file flat legacy.

### 5. 🧪 Penambahan Unit Tests
- Menambahkan pengujian `CurrencyFormat`, `UserSession`, dan `ApiResult`.

---

## Phase 1: Fix & Stabilize (Selesai: 31 Oktober 2026)

### 1. 🔧 Resolusi Merge Conflicts
- `lib/main.dart` & `lib/controllers/login_controller.dart`.

### 2. 🗑️ Pembersihan Dead Code
- Menghapus 14 file dead code dan direktori test yang tidak terpakai (~1.500+ baris).

### 3. 🔄 Migrasi Null Safety & Dart 3
- Upgrade SDK environment: `sdk: ">=3.0.0 <4.0.0"`.

### 4. 📦 Modernisasi Dependencies
- Menghapus package usang: `flutter_icons`, `flutter_barcode_scanner`, `d_*`, `sqflite`, `get_storage`.
- Mengupgrade: `dropdown_search: ^5.0.6`, `http: ^1.1.0`, `shared_preferences: ^2.2.2`, `intl: ^0.18.1`.

### 5. 🔒 Perbaikan Keamanan & Stabilitas
- Menghapus global SSL bypass `MyHttpOverrides`.
- Menghilangkan `exit(0)`.
- Menghapus hardcoded API key eksternal.
