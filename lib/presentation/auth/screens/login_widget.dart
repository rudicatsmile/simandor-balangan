import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../scan/screens/scan_barang_screen.dart';
import '../controllers/login_controller.dart';

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginC = Get.put(LoginController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Masuk Petugas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gunakan kredensial akun SIPANDA-BMD Anda',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Username Field
        TextField(
          controller: loginC.usernameC,
          decoration: const InputDecoration(
            labelText: 'Username',
            hintText: 'Ketik username...',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 16),

        // Password Field
        Obx(() => TextField(
              controller: loginC.passwordC,
              obscureText: loginC.isHidden.value,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Ketik password...',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => loginC.isHidden.toggle(),
                  icon: Icon(
                    loginC.isHidden.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => loginC.login(),
            )),

        const SizedBox(height: 24),

        // Login Button
        SizedBox(
          height: 48,
          child: Obx(() => ElevatedButton(
                onPressed: loginC.isLoading.isFalse ? loginC.login : null,
                child: loginC.isLoading.isTrue
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'MASUK SEKARANG',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              )),
        ),

        const SizedBox(height: 20),

        // Divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('ATAU', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        // Public Viewer option
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            label: const Text(
              'Scan Aset Tanpa Login (Tamu)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Get.to(() => const ScanBarangScreen()),
          ),
        ),
      ],
    );
  }
}
