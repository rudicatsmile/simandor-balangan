import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_session.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/photo_repository.dart';
import '../../auth/screens/form_login_screen.dart';
import '../../detail/screens/detail_router_screen.dart';
import '../../message/screens/list_message_screen.dart';
import '../../photo/screens/upload_photo_screen.dart';
import 'camera_scanner_screen.dart';

class ScanBarangScreen extends StatefulWidget {
  const ScanBarangScreen({super.key});

  @override
  State<ScanBarangScreen> createState() => _ScanBarangScreenState();
}

class _ScanBarangScreenState extends State<ScanBarangScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final PhotoRepository _photoRepository = PhotoRepository();
  final MessageRepository _messageRepository = MessageRepository();
  final TextEditingController _codeController = TextEditingController();

  UserSession? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSession() async {
    final session = await _authRepository.getSession();
    if (mounted) {
      setState(() {
        _session = session;
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(String code) {
    final cleanCode = code.trim();
    if (cleanCode.isNotEmpty && cleanCode != '-1') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailRouterScreen(code: cleanCode),
        ),
      );
    }
  }

  Future<void> _openCameraScanner() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CameraScannerScreen()),
    );

    if (scannedCode != null && scannedCode.isNotEmpty) {
      _navigateToDetail(scannedCode);
    }
  }

  void _showManualInputDialog() {
    _codeController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Input Kode Manual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan nomor kode barang / register aset:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: KIB-B-0000000004',
                  prefixIcon: Icon(Icons.qr_code, size: 20),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _codeController.text.trim();
                Navigator.pop(context);
                if (code.isNotEmpty) {
                  _navigateToDetail(code);
                }
              },
              child: const Text('Cari Aset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUploadPhoto() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CameraScannerScreen()),
    );

    if (scannedCode != null && scannedCode.isNotEmpty && scannedCode != '-1') {
      _processPhotoUploadForCode(scannedCode);
    }
  }

  Future<void> _processPhotoUploadForCode(String code) async {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Memeriksa status foto...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final result = await _photoRepository.checkPhotoStatus(code);

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    if (!result.isSuccess) {
      Get.defaultDialog(
        title: 'Perhatian',
        middleText: result.errorMessage ?? 'Gagal memeriksa status foto barang.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primary,
        onConfirm: () => Get.back(),
      );
      return;
    }

    final data = result.data;
    if (data != null && data.alreadyUploaded) {
      Get.snackbar(
        'Perhatian',
        'Photo barang sudah ter upload',
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } else if (data != null && data.idt != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadPhotoScreen(
              idt: data.idt!,
              kodeBarang: code,
            ),
          ),
        );
      }
    }
  }

  void _showInputMessageDialog() {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.mail_outline_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Input Pesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tuliskan pesan atau laporan di bawah ini:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Isi pesan di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final message = messageController.text.trim();
                if (message.isEmpty) return;

                Navigator.pop(context);
                final userName = _session?.userName ?? 'Petugas';
                final res = await _messageRepository.insertMessage(userName, message);

                if (res.isSuccess) {
                  Get.snackbar(
                    'Berhasil',
                    'Berhasil kirim pesan',
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade900,
                    snackPosition: SnackPosition.TOP,
                  );
                } else {
                  Get.snackbar(
                    'Gagal',
                    res.errorMessage ?? 'Gagal mengirim pesan',
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              },
              child: const Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun SIMANDOR?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepository.logout();
      Get.offAll(() => const FormLoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _session != null;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SIMANDOR ONLINE'),
            Text(
              'Kabupaten Balangan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Menu Utama',
              onSelected: (value) {
                switch (value) {
                  case 'upload_photo':
                    _handleUploadPhoto();
                    break;
                  case 'daftar_pesan':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListMessageScreen()),
                    );
                    break;
                  case 'input_pesan':
                    _showInputMessageDialog();
                    break;
                  case 'logout':
                    _confirmLogout();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'upload_photo',
                  child: Row(
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Text('Upload photo barang'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'daftar_pesan',
                  child: Row(
                    children: [
                      Icon(Icons.mark_chat_unread_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Text('Daftar Isi Pesan'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'input_pesan',
                  child: Row(
                    children: [
                      Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Text('Input Pesan'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            )
          else
            IconButton(
              tooltip: 'Masuk',
              icon: const Icon(Icons.login),
              onPressed: () => Get.offAll(() => const FormLoginScreen()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Profile Card
                  if (isLoggedIn) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _session!.fullName.isNotEmpty
                                        ? _session!.fullName
                                        : _session!.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _session!.nmUnit.isNotEmpty
                                        ? _session!.nmUnit
                                        : 'Operator BMD',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_session!.nmUpb.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _session!.nmUpb,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _session!.isAdmin ? 'Admin' : 'Petugas',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Main Scanner Action Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 56,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'PENDATAAN ASET BMD',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scan barcode/QR code pada stiker aset daerah untuk melihat data atau memetakan KIB.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('SCAN DENGAN KAMERA'),
                              onPressed: _openCameraScanner,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.border, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.keyboard_outlined),
                              label: const Text(
                                'INPUT KODE MANUAL',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: _showManualInputDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tips Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pastikan stiker barcode dalam pencahayaan yang cukup dan lensa kamera bersih agar pemindaian optimal.',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
