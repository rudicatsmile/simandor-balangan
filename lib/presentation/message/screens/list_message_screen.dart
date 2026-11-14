import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/pesan.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/message_repository.dart';

class ListMessageScreen extends StatefulWidget {
  const ListMessageScreen({super.key});

  @override
  State<ListMessageScreen> createState() => _ListMessageScreenState();
}

class _ListMessageScreenState extends State<ListMessageScreen> {
  final MessageRepository _messageRepository = MessageRepository();
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController _textController = TextEditingController();

  List<Pesan> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final session = await _authRepository.getSession();
    if (session != null) {
      _currentUserName = session.userName;
    }

    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _messageRepository.getMessages();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _messages = result.data ?? [];
        } else {
          _errorMessage = result.errorMessage ?? 'Gagal memuat daftar pesan.';
        }
      });
    }
  }

  Future<void> _toggleTampil(Pesan pesan) async {
    final idt = pesan.idt;
    if (idt == null || idt.isEmpty) return;

    final result = await _messageRepository.toggleTampil(idt);
    if (result.isSuccess) {
      Get.snackbar(
        'Sukses',
        'Status pesan berhasil diperbarui',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      _fetchMessages();
    } else {
      Get.snackbar(
        'Gagal',
        result.errorMessage ?? 'Gagal memperbarui status pesan',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showAddMessageDialog() {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Kirim Pesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tuliskan pesan atau catatan sistem:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan Anda di sini...',
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
                final message = _textController.text.trim();
                if (message.isEmpty) return;

                Navigator.pop(context);
                final res = await _messageRepository.insertMessage(
                  _currentUserName.isNotEmpty ? _currentUserName : 'User',
                  message,
                );

                if (res.isSuccess) {
                  Get.snackbar(
                    'Berhasil',
                    'Pesan berhasil dikirim',
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green.shade900,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  _fetchMessages();
                } else {
                  Get.snackbar(
                    'Gagal',
                    res.errorMessage ?? 'Gagal mengirim pesan',
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                    snackPosition: SnackPosition.BOTTOM,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Isi Pesan'),
        actions: [
          IconButton(
            tooltip: 'Perbarui',
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMessages,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Input Pesan', style: TextStyle(color: Colors.white)),
        onPressed: _showAddMessageDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchMessages,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mark_chat_unread_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada pesan tercatat',
                            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMessages,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _messages.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pesan = _messages[index];
                          final isTampil = pesan.tampil == '1';

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isTampil
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.account_circle, size: 18, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            pesan.userName ?? pesan.pencatat ?? 'Anonim',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (pesan.recorded != null && pesan.recorded!.isNotEmpty)
                                        Text(
                                          pesan.recorded!,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    pesan.pesan ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isTampil
                                              ? AppColors.success.withValues(alpha: 0.1)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isTampil ? 'Aktif / Tampil' : 'Nonaktif',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isTampil ? AppColors.success : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: Icon(
                                          isTampil ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        label: Text(
                                          isTampil ? 'Sembunyikan' : 'Tampilkan',
                                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                                        ),
                                        onPressed: () => _toggleTampil(pesan),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
