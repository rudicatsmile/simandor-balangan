import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../data/models/barang.dart';
import '../../../data/models/ruang_detail.dart';
import '../../../data/models/unit_detail.dart';
import '../../../data/models/upb_detail.dart';
import '../../../data/repositories/barang_repository.dart';
import '../../photo/screens/upload_photo_screen.dart';

class DetailPageScreen extends StatefulWidget {
  final String code;

  const DetailPageScreen({super.key, required this.code});

  @override
  State<DetailPageScreen> createState() => _DetailPageScreenState();
}

class _DetailPageScreenState extends State<DetailPageScreen> {
  final BarangRepository _repository = BarangRepository();

  bool _isLiked = false;
  bool _isLoading = true;
  String? _errorMessage;

  Barang? _barang;
  UnitDetail? _unit;
  UpbDetail? _upb;
  RuangDetail? _ruang;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final result = await _repository.getBarangDetail(widget.code);
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final barang = result.data!;
      setState(() {
        _barang = barang;
        _isLoading = false;
        _errorMessage = null;
      });

      final kdUpb = barang.kdUpb ?? '';
      final kdRuang = barang.kdRuang ?? '';
      final kdUnit = kdUpb.length >= 11 ? kdUpb.substring(0, 11) : kdUpb;

      if (kdUnit.isNotEmpty) {
        _repository.getUnitDetail(kdUnit).then((res) {
          if (res.isSuccess && mounted) setState(() => _unit = res.data);
        });
      }
      if (kdUpb.isNotEmpty) {
        _repository.getUpbDetail(kdUpb).then((res) {
          if (res.isSuccess && mounted) setState(() => _upb = res.data);
        });
      }
      if (kdUpb.isNotEmpty && kdRuang.isNotEmpty) {
        _repository.getRuangDetail(kdUpb, kdRuang).then((res) {
          if (res.isSuccess && mounted) setState(() => _ruang = res.data);
        });
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Gagal memuat detail barang.';
        _isLoading = false;
      });
    }
  }

  bool get _hasPhoto {
    final fn = _barang?.fileName?.trim();
    return fn != null &&
        fn.isNotEmpty &&
        fn.toLowerCase() != 'null' &&
        fn != '-' &&
        fn != 'noimage.jpg';
  }

  String? _getPhotoUrl({bool fallback = false}) {
    if (!_hasPhoto) return null;

    final rawName = _barang!.fileName!.trim();
    final idt = (_barang?.idt ?? '').trim();

    final String fullFileName;
    if (rawName.contains('xyz')) {
      fullFileName = rawName;
    } else {
      fullFileName = idt.isNotEmpty ? '${idt}xyz$rawName' : rawName;
    }

    final base = fallback
        ? ApiEndpoints.baseUrlImages
        : ApiEndpoints.baseUrlImagesSimandor;

    return '$base/$fullFileName';
  }

  Widget _buildBrokenImagePlaceholder() {
    return Container(
      height: 220,
      color: Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 56, color: Colors.grey),
            SizedBox(height: 8),
            Text('Foto tidak dapat dimuat dari server', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showImageDialog() {
    if (!_hasPhoto) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library_outlined, size: 38, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _barang?.nmAset ?? 'Foto Barang',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kode: ${_barang?.kdAset108 ?? widget.code}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Foto belum diunggah untuk aset ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ),
                      if ((_barang?.idt ?? '').isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: () async {
                              Navigator.pop(context);
                              final uploaded = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UploadPhotoScreen(
                                    idt: _barang!.idt!,
                                    kodeBarang: widget.code,
                                  ),
                                ),
                              );
                              if (uploaded == true) {
                                _fetchDetails();
                              }
                            },
                            icon: const Icon(Icons.camera_alt, size: 16),
                            label: const Text('Unggah Foto', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    final photoUrl = _getPhotoUrl()!;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(_barang?.nmAset ?? 'Foto Barang', style: const TextStyle(fontSize: 16)),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                    maxWidth: double.infinity,
                  ),
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 3.5,
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        final total = loadingProgress.expectedTotalBytes;
                        final loaded = loadingProgress.cumulativeBytesLoaded;
                        final progress = total != null && total > 0 ? loaded / total : null;

                        return Container(
                          height: 220,
                          color: Colors.grey[50],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(value: progress),
                                const SizedBox(height: 12),
                                Text(
                                  progress != null
                                      ? 'Memuat foto ${(progress * 100).toStringAsFixed(0)}%...'
                                      : 'Memuat foto...',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        final fallbackUrl = _getPhotoUrl(fallback: true);
                        if (fallbackUrl != null) {
                          return Image.network(
                            fallbackUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(),
                          );
                        }
                        return _buildBrokenImagePlaceholder();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kode: ${_barang?.kdAset108 ?? widget.code}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((_barang?.idt ?? '').isNotEmpty)
                        TextButton.icon(
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          onPressed: () async {
                            Navigator.pop(context);
                            final uploaded = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadPhotoScreen(
                                  idt: _barang!.idt!,
                                  kodeBarang: widget.code,
                                ),
                              ),
                            );
                            if (uploaded == true) {
                              _fetchDetails();
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Ganti Foto', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getKondisiLabel(String? kode) {
    switch (kode?.toUpperCase()) {
      case 'B':
        return 'Baik';
      case 'KB':
        return 'Kurang Baik';
      case 'RB':
        return 'Rusak Berat';
      default:
        return kode ?? 'Normal';
    }
  }

  Color _getKondisiColor(String? kode) {
    switch (kode?.toUpperCase()) {
      case 'B':
        return AppColors.success;
      case 'KB':
        return AppColors.warning;
      case 'RB':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _barang == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Barang')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Data tidak tersedia',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final b = _barang!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aset BMD'),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => setState(() => _isLiked = !_isLiked),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Asset Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              (b.nmAset ?? '-').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getKondisiColor(b.kondisi).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getKondisiLabel(b.kondisi),
                              style: TextStyle(
                                color: _getKondisiColor(b.kondisi),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kode Rekening: ${b.kdAset108 ?? widget.code}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nilai Perolehan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormat.convertToIdr(b.harga, 0),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              backgroundColor: _hasPhoto ? AppColors.primary : Colors.blueGrey,
                            ),
                            onPressed: _showImageDialog,
                            icon: Icon(_hasPhoto ? Icons.photo_library : Icons.add_a_photo_outlined, size: 18),
                            label: Text(_hasPhoto ? 'Lihat Foto' : 'Foto Aset', style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Location & Hierarchy Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.apartment, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Unit Kerja & Lokasi',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildDetailRow('Unit', _unit?.nmUnit ?? '-'),
                      _buildDetailRow('UPB', _upb?.nmUpb ?? '-'),
                      _buildDetailRow('Ruang', _ruang?.nmRuang?.isNotEmpty == true ? _ruang!.nmRuang : '-'),
                      _buildDetailRow('Alamat', b.alamat?.isNotEmpty == true ? b.alamat : null),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Specification & Identity Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Identitas & Spesifikasi Aset',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildDetailRow('Nomor Register', b.noRegister),
                      _buildDetailRow('Merk', b.merk != '-' ? b.merk : null),
                      _buildDetailRow('Tipe', b.type != '-' ? b.type : null),
                      _buildDetailRow('Nomor Polisi', b.nomorPolisi != '-' ? b.nomorPolisi : null),
                      _buildDetailRow('Nomor Rangka', b.nomorRangka != '-' ? b.nomorRangka : null),
                      _buildDetailRow('Nomor Mesin', b.nomorMesin != '-' ? b.nomorMesin : null),
                      _buildDetailRow('Nomor BPKB', b.nomorBpkb != '-' ? b.nomorBpkb : null),
                      _buildDetailRow('Pemegang Barang', b.pemegang != '-' ? b.pemegang : null),
                      _buildDetailRow('Tahun Perolehan', b.tahun != '0' ? b.tahun : null),
                      _buildDetailRow('Asal Usul', b.asalUsul?.isNotEmpty == true ? b.asalUsul : null),
                      _buildDetailRow('Keterangan', b.keterangan?.isNotEmpty == true ? b.keterangan : null),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: AppColors.primary, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aset ini tercatat resmi di Sistem Pengelolaan Barang Milik Daerah (BMD) Kabupaten Balangan.',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
