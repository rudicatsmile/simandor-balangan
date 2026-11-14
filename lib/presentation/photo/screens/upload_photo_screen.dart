import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';

enum _UploadStage {
  idle,
  pickingImage,
  preparingRequest,
  connecting,
  uploading,
  waitingResponse,
  done,
}

extension on _UploadStage {
  String get label {
    switch (this) {
      case _UploadStage.idle:
        return 'Siap';
      case _UploadStage.pickingImage:
        return 'Memilih foto...';
      case _UploadStage.preparingRequest:
        return 'Menyiapkan berkas...';
      case _UploadStage.connecting:
        return 'Menghubungkan ke server...';
      case _UploadStage.uploading:
        return 'Mengunggah foto...';
      case _UploadStage.waitingResponse:
        return 'Menunggu konfirmasi server...';
      case _UploadStage.done:
        return 'Selesai';
    }
  }
}

class UploadPhotoScreen extends StatefulWidget {
  final String idt;
  final String? kodeBarang;

  const UploadPhotoScreen({
    super.key,
    required this.idt,
    this.kodeBarang,
  });

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingLocation = true;
  String _address = 'Mengambil lokasi perangkat...';
  String _latitude = '';
  String _longitude = '';

  _UploadStage _uploadStage = _UploadStage.idle;
  int _bytesSent = 0;
  int _totalBytes = 0;
  double _speed = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _address = 'Mengambil lokasi perangkat...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _address = 'GPS / Layanan lokasi tidak aktif.';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _address = 'Izin lokasi ditolak.';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _address = 'Izin lokasi ditolak permanen.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _latitude = '${position.latitude}';
      _longitude = '${position.longitude}';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          _address = parts.isNotEmpty ? parts : 'Lat: $_latitude, Long: $_longitude';
        } else {
          _address = 'Lat: $_latitude, Long: $_longitude';
        }
      } catch (_) {
        _address = 'Lat: $_latitude, Long: $_longitude';
      }
    } catch (e) {
      _address = 'Gagal mendeteksi lokasi: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ambil foto aset langsung dari kamera atau pilih dari galeri perangkat.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary),
                  ),
                  title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Ambil foto baru menggunakan kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.info),
                  ),
                  title: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pilih foto dari penyimpanan galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      setState(() {
        _uploadStage = _UploadStage.pickingImage;
      });

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        setState(() {
          _uploadStage = _UploadStage.idle;
        });
        return;
      }

      _showUploadProgressDialog();
      await _executeUpload(File(pickedFile.path));
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadStage = _UploadStage.idle;
        });
      }
      Get.snackbar(
        'Terjadi Kesalahan',
        e.toString(),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  void _showUploadProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final percent = _totalBytes > 0
                ? (_bytesSent / _totalBytes).clamp(0.0, 1.0)
                : 0.0;
            final percentText = '${(percent * 100).toStringAsFixed(0)}%';
            final speedText = _speed > 0
                ? '${(_speed / 1024).toStringAsFixed(1)} KB/s'
                : '-';

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    _uploadStage.label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _totalBytes > 0 ? percent : null,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress: $percentText', style: const TextStyle(fontSize: 13)),
                      Text('Kecepatan: $speedText', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  if (_totalBytes > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${(_bytesSent / 1024).toStringAsFixed(0)} KB / ${(_totalBytes / 1024).toStringAsFixed(0)} KB',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _executeUpload(File imageFile) async {
    final primaryUri = Uri.parse(
      '${ApiEndpoints.uploadPhotoV2}?idt=${widget.idt}&lat=$_latitude&lng=$_longitude',
    );
    final fallbackUri = Uri.parse(
      '${ApiEndpoints.uploadPhoto}?idt=${widget.idt}&lat=$_latitude&lng=$_longitude',
    );

    final fileSize = await imageFile.length();
    final stopwatch = Stopwatch()..start();
    int lastBytes = 0;
    int lastMs = 0;

    void onProgress(int sent, int total) {
      final elapsedMs = stopwatch.elapsedMilliseconds;
      final deltaBytes = sent - lastBytes;
      final deltaMs = elapsedMs - lastMs;
      final speed = (deltaMs > 0) ? (deltaBytes * 1000 / deltaMs) : 0.0;
      lastBytes = sent;
      lastMs = elapsedMs;

      if (mounted) {
        setState(() {
          _bytesSent = sent;
          _totalBytes = total;
          _speed = speed;
          _uploadStage = (total > 0 && sent >= total)
              ? _UploadStage.waitingResponse
              : _UploadStage.uploading;
        });
      }
    }

    Future<http.Response> sendMultipart(Uri uri) async {
      final request = http.MultipartRequest('POST', uri);
      final fileStream = http.ByteStream(imageFile.openRead());
      
      var bytes = 0;
      final streamed = fileStream.transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (List<int> data, EventSink<List<int>> sink) {
            bytes += data.length;
            onProgress(bytes, fileSize);
            sink.add(data);
          },
        ),
      );

      final multipartFile = http.MultipartFile(
        'image',
        streamed,
        fileSize,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      );
      request.files.add(multipartFile);

      final client = http.Client();
      try {
        final streamedResponse = await client.send(request).timeout(const Duration(seconds: 90));
        return await http.Response.fromStream(streamedResponse);
      } finally {
        client.close();
      }
    }

    try {
      setState(() {
        _uploadStage = _UploadStage.connecting;
        _bytesSent = 0;
        _totalBytes = fileSize;
      });

      http.Response response = await sendMultipart(primaryUri);

      if (response.statusCode == 404) {
        response = await sendMultipart(fallbackUri);
      }

      // Close progress dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      setState(() {
        _uploadStage = _UploadStage.done;
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
          'Gagal mengunggah foto',
          'Status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _uploadStage = _UploadStage.idle;
        });
      }
      _showErrorDialog('Terjadi Kesalahan', e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 10),
            Text('Upload Berhasil'),
          ],
        ),
        content: const Text('Foto barang berhasil diunggah ke server.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, true); // back from screen with success flag
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photo Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.kodeBarang != null && widget.kodeBarang!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, color: AppColors.primary, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kode Aset / Register',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.kodeBarang!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Lokasi Pengambilan Foto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          InkWell(
                            onTap: _fetchCurrentLocation,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Perbarui',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _address,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ),
                    if (_latitude.isNotEmpty && _longitude.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Koordinat: $_latitude, $_longitude',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Upload Button Center Area
            Center(
              child: InkWell(
                onTap: _uploadStage == _UploadStage.idle || _uploadStage == _UploadStage.done
                    ? _showImageSourceDialog
                    : null,
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ketuk tombol di atas untuk memilih atau memotret aset',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('PILIH / AMBIL FOTO'),
                onPressed: _showImageSourceDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
