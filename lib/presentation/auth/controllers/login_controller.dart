import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../scan/screens/scan_barang_screen.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository;

  LoginController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  final RxBool isHidden = true.obs;
  final RxBool isLoading = false.obs;

  Future<void> login() async {
    final username = usernameC.text.trim();
    final password = passwordC.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Username dan Password wajib diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final result = await _authRepository.login(username, password);
    isLoading.value = false;

    if (result.isSuccess) {
      Get.offAll(() => const ScanBarangScreen());
    } else {
      Get.snackbar(
        'Login Gagal',
        result.errorMessage ?? 'Terjadi kesalahan saat login',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    usernameC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}

