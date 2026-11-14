# Analisis Basecode Aplikasi SIMANDOR (Flutter)

**Tanggal:** 31 Oktober 2026  
**Analyst:** AI Code Review  
**Versi Aplikasi:** 1.0.0+1  
**Package ID:** `id.go.balangankab.simandorapp`

---

## 1. Tujuan Aplikasi

**SIMANDOR** (Sistem Manajemen Data Barang Daerah Online) adalah aplikasi pendataan
dan inventarisasi **Barang Milik Daerah (BMD)** untuk Pemerintah Kabupaten Balangan,
Kalimantan Selatan.

Aplikasi ini merupakan companion mobile dari sistem web:
- **SICAPER** (`sicaper.balangankab.go.id`) — backend API
- **SIPANDA BMD** (`sipandabmd.balangankab.go.id`) — image server & admin

### Fungsi Inti
1. **QR Code Scanner** — Scan kode barang daerah
2. **Detail Barang** — Tampilkan info lengkap aset (merk, nopol, BPKB, pemegang, harga, unit, UPB, ruang, foto)
3. **Mapping KIB** — Petakan barang ke kategori KIB A–F (Tanah, Peralatan/Mesin, Gedung, Jalan/Irigasi, Aset Tetap Lainnya, Konstruksi)
4. **Verifikasi Data** — API tersedia tapi belum terhubung ke UI

### Konteks Domain
- **KIB** = Kartu Inventaris Barang
- **UPB** = Unit Pengguna Barang
- **Level user** (0–4) menentukan scope akses

---

## 2. Flow Utama

### Autentikasi
```
App Start → Cek SharedPreferences (isLogin)
  → OK → Home (Scan QR)
  → Tidak → Form Login → POST /login_kib.php
    → Success + Active=Y → Simpan 13 field ke SharedPreferences → Home
    → Active=N → Dialog "Username tidak aktif"
    → Gagal → Dialog "Username/password salah"
```

### Navigasi
```
Login → Home (Scan QR)
  → Scan QR → Detail Barang
    → Barang ditemukan → DetailPage (info + foto)
    → Barang tidak ditemukan + Login → FormKIB (mapping)
    → Barang tidak ditemukan + Guest → "Data tidak ditemukan"
  → Logout → Login
```

---

## 3. Stack Teknologi

| Item | Versi |
|------|-------|
| Dart SDK | `>=2.7.0 <3.0.0` (PRE-NULL SAFETY) |
| State Management | GetX ^4.6.5 |
| Networking | http ^0.13.4 |
| Local Storage | SharedPreferences ^2.0.15 |
| QR Scanner | flutter_barcode_scanner ^2.0.0 |
| Database | sqflite ^2.0.2+1 (tidak dipakai) |
| UI Dropdown | dropdown_search ^3.0.1 |

---

## 4. API Endpoints

| Endpoint | Method | Fungsi |
|----------|--------|--------|
| `/login_kib.php` | POST | Login |
| `/getBarangDetail.php?kode=` | GET | Detail barang |
| `/getObjek.php?tableName=&kode=` | GET | List objek aset |
| `/getUnit.php?tableName=&kode=&kodeUpb=&level=&admin=` | GET | List unit |
| `/getBarang.php?kodeUpb=&kodeAset=` | GET | List barang |
| `/getBarang2.php?kdSubUnit=&kdKib=` | GET | List barang v2 |
| `/getBarang3.php?kdUnit=&kdSubUnit=&kdUpb=&sType=&kdKib=` | GET | List barang v3 |
| `/getUnitDetail.php?kode=` | GET | Detail unit |
| `/getUpbDetail.php?kode=` | GET | Detail UPB |
| `/getRuangDetail.php?kodeUpb=&kodeRuang=` | GET | Detail ruang |
| `/update_tabel_kib.php` | POST | Mapping kode barang ke KIB |
| `/add_verification_data.php` | POST | Verifikasi data |

Base URL: `https://sicaper.balangankab.go.id/api/`  
Images: `https://sipandabmd.balangankab.go.id/`

---

## 5. Temuan Masalah

### CRITICAL
1. **Merge conflict belum resolved** — `main.dart`, `login_controller.dart`
2. **Pre-null-safety** — SDK `>=2.7.0 <3.0.0`, tidak bisa build Flutter modern
3. **SSL certificate bypass global** — `badCertificateCallback => true`
4. **Password plain-text tanpa token/JWT**
5. **6+ packages discontinued/deprecated**
6. **Release build pakai debug signing**

### HIGH
1. Tidak ada arsitektur (API calls di widget)
2. Code duplication masif (formkib.dart ≈ formkib_lite.dart)
3. Dead code ~1500+ baris (copy-paste dari project antrian RS)
4. FutureBuilder infinite loop di detail.dart
5. API key hardcoded
6. exit(0) dipanggil langsung

### MEDIUM
1. Naming convention inkonsisten
2. Tidak ada error handling proper
3. Hard-coded colors & styles
4. print() statements di production
5. Nested ternary 6+ level

---

## 6. Dead Code (Bisa Dihapus)

| File | Alasan |
|------|--------|
| `signup.dart` | Mengarah ke localhost, tidak dipakai |
| `signup_option.dart` | Tidak dipakai |
| `dashboard.dart` | Scaffold kosong |
| `formInputDataBarang.dart` | 1137 baris 100% commented-out |
| `formkib.dart` | Digantikan formkib_lite.dart |
| `entities/dbhelper.dart` | Schema antrian RS, bukan BMD |
| `entities/produk.dart` | Model produk, tidak dipakai |
| `models/city.dart` | Tidak dipakai |
| `models/province.dart` | Tidak dipakai |
| `lib/test/*` | File test salah lokasi |

---

## 7. Rencana Update (4 Fase)

### Phase 1: Fix & Stabilize (1-2 minggu)
- [x] Resolve merge conflicts
- [x] Hapus dead code
- [x] Migrasi null safety (Dart 3)
- [x] Fix security issues (SSL bypass)
- [x] Ganti discontinued packages
- [x] Update pubspec.yaml

### Phase 2: Restructure & Clean Architecture (Selesai)
- [x] Clean Architecture / Modular layer
- [x] Repository layer (Auth, Barang, KIB)
- [x] Eliminasi code duplication & flat files
- [x] Update dropdown_search ke v5+
- [x] Proper error handling & ApiClient timeout
- [x] Fix FutureBuilder infinite loop

### Phase 3: Polish & Modern Camera Scanner (Selesai)
- [x] Design system & theming (Material 3 + Balangan Government theme)
- [x] Integrasi Camera Scanner modern (mobile_scanner)
- [x] Flashlight toggle & Camera switch
- [x] Pull-to-refresh & zoomable photo dialog
- [x] Card grouping & dialog konfirmasi pemetaan KIB
- [x] Unit tests & smoke tests pass 100%

### Phase 4: New Features (ongoing)
- [ ] Dashboard statistik
- [ ] Search barang
- [ ] History scan
- [ ] Export report
- [ ] CI/CD pipeline

