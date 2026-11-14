import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/utils/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/auth/screens/form_login_screen.dart';
import 'presentation/scan/screens/scan_barang_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SimandorApp());
}

class SimandorApp extends StatefulWidget {
  const SimandorApp({super.key});

  @override
  State<SimandorApp> createState() => _SimandorAppState();
}

class _SimandorAppState extends State<SimandorApp> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIMANDOR',
      theme: AppTheme.lightTheme,
      home: _isLoggedIn ? const ScanBarangScreen() : const FormLoginScreen(),
    );
  }
}
