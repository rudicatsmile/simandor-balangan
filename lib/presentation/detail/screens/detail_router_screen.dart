import 'package:flutter/material.dart';
import '../../../data/models/barang.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/barang_repository.dart';
import '../../kib/screens/formkib_lite_screen.dart';
import 'detail_page_screen.dart';

class DetailRouterScreen extends StatefulWidget {
  final String code;

  const DetailRouterScreen({super.key, required this.code});

  @override
  State<DetailRouterScreen> createState() => _DetailRouterScreenState();
}

class _DetailRouterScreenState extends State<DetailRouterScreen> {
  final BarangRepository _barangRepository = BarangRepository();
  final AuthRepository _authRepository = AuthRepository();

  late Future<Barang?> _barangFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _barangFuture = _fetchBarang();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (mounted) {
      setState(() => _isLoggedIn = loggedIn);
    }
  }

  Future<Barang?> _fetchBarang() async {
    final result = await _barangRepository.getBarangDetail(widget.code);
    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Barang?>(
        future: _barangFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final barang = snapshot.data;
          if (barang != null && barang.idt != null) {
            return DetailPageScreen(code: widget.code);
          } else {
            if (_isLoggedIn) {
              return FormKibLiteScreen(gCode: widget.code);
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Data Barang Tidak Ditemukan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kode: ${widget.code}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

