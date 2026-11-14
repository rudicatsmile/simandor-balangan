import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../data/models/barang.dart';
import '../../../data/models/unit.dart';
import '../../../data/repositories/kib_repository.dart';
import '../../scan/screens/scan_barang_screen.dart';
import '../controllers/formkib_controller.dart';

class FormKibLiteScreen extends StatefulWidget {
  final String gCode;

  const FormKibLiteScreen({super.key, required this.gCode});

  @override
  State<FormKibLiteScreen> createState() => _FormKibLiteScreenState();
}

class _FormKibLiteScreenState extends State<FormKibLiteScreen> {
  final FormKibController formkibC = Get.put(FormKibController());
  final KibRepository _kibRepository = KibRepository();

  final List<Map<String, dynamic>> dataKib = [
    {'kib': 'KIB A (Tanah)', 'kode': '1.3.1'},
    {'kib': 'KIB B (Peralatan & Mesin)', 'kode': '1.3.2'},
    {'kib': 'KIB C (Gedung & Bangunan)', 'kode': '1.3.3'},
    {'kib': 'KIB D (Jalan, Irigasi & Jaringan)', 'kode': '1.3.4'},
    {'kib': 'KIB E (Aset Tetap Lainnya)', 'kode': '1.3.5'},
    {'kib': 'KIB F (Konstruksi dlm Pengerjaan)', 'kode': '1.3.6'},
  ];

  String kdAset = '';
  String kdKib = '1.3.2';
  String kdSubUnit = '';
  String kdUpb = '';
  String idt = '';
  String parKdUnit = '';
  String parKdSubUnit = '';
  String parKdUpb = '';
  String sType = '';

  Barang? _selectedBarang;
  bool _isSaving = false;

  Future<List<Unit>> _fetchUnits(String tableName, String kode) async {
    final s = formkibC.session.value;
    return _kibRepository.getUnits(
      tableName: tableName,
      kode: kode,
      kodeUpb: s.kodeUpb,
      level: s.level,
      admin: s.admin,
    );
  }

  Future<List<Barang>> _fetchBarang() async {
    return _kibRepository.getBarangList(
      kdUnit: parKdUnit,
      kdSubUnit: parKdSubUnit,
      kdUpb: parKdUpb,
      sType: sType,
      kdKib: kdKib,
    );
  }

  Future<void> _onSimpanPressed() async {
    if (idt.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Silakan pilih barang yang akan dipetakan terlebih dahulu',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pemetaan KIB', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Petakan kode QR "${widget.gCode}" ke barang:\n\n'
          'Nama: ${_selectedBarang?.nmAset ?? '-'}\n'
          'Register: ${_selectedBarang?.noRegister ?? '-'}\n'
          'Merk: ${_selectedBarang?.merk ?? '-'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Simpan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _executeSimpan();
    }
  }

  Future<void> _executeSimpan() async {
    setState(() => _isSaving = true);
    final s = formkibC.session.value;

    final result = await _kibRepository.mappingKib(
      idt: idt,
      kdUpb: kdUpb,
      kdAset: kdAset,
      kodeBar: widget.gCode,
      userName: s.userName,
    );

    setState(() => _isSaving = false);

    if (result.isSuccess) {
      Get.snackbar(
        'Sukses',
        'Data KIB berhasil dipetakan ke kode barang',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAll(() => const ScanBarangScreen());
    } else {
      Get.snackbar(
        'Gagal Menyimpan',
        result.errorMessage ?? 'Gagal memperbarui data',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemetaan Data KIB'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Code Target Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Kode QR Baru:',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          widget.gCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 1: Hierarki Unit Kerja
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '1. Hierarki Unit Kerja',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Unit
                    Obx(() {
                      if (formkibC.isTampilUnit.isTrue) {
                        return DropdownSearch<Unit>(
                          asyncItems: (text) => _fetchUnits('ref_unit', '0.0.0'),
                          itemAsString: (item) => item.namaUnit ?? '',
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Unit Kerja',
                              hintText: 'Pilih Unit',
                            ),
                          ),
                          popupProps: const PopupProps.menu(showSearchBox: true),
                          onChanged: (value) {
                            kdSubUnit = value?.kodeUnit ?? '';
                            parKdUnit = value?.kodeUnit ?? '';
                            parKdSubUnit = '';
                            parKdUpb = '';
                            sType = '1';
                          },
                        );
                      } else if (formkibC.isTampilStringUnit.isTrue) {
                        return _buildReadOnlyField('Unit:', formkibC.session.value.nmUnit);
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 12),

                    // Sub Unit
                    Obx(() {
                      if (formkibC.isTampilSubUnit.isTrue) {
                        final defaultUnit = formkibC.session.value.kdUnit;
                        return DropdownSearch<Unit>(
                          asyncItems: (text) => _fetchUnits(
                            'ref_sub_unit',
                            kdSubUnit.isNotEmpty ? kdSubUnit : defaultUnit,
                          ),
                          itemAsString: (item) => item.namaUnit ?? '',
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Sub Unit',
                              hintText: 'Pilih Sub Unit',
                            ),
                          ),
                          popupProps: const PopupProps.menu(showSearchBox: true),
                          onChanged: (value) {
                            kdUpb = value?.kodeUnit ?? '';
                            parKdUnit = kdSubUnit.isNotEmpty ? kdSubUnit : formkibC.session.value.kdUnit;
                            parKdSubUnit = value?.kodeUnit ?? '';
                            parKdUpb = '';
                            sType = '2';
                          },
                        );
                      } else if (formkibC.isTampilStringSubUnit.isTrue) {
                        return _buildReadOnlyField('Sub Unit:', formkibC.session.value.nmSub);
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 12),

                    // UPB
                    Obx(() {
                      if (formkibC.isTampilUpb.isTrue) {
                        final defaultSubUnit = formkibC.session.value.kdSubUnit;
                        return DropdownSearch<Unit>(
                          asyncItems: (text) => _fetchUnits(
                            'ref_upb',
                            kdUpb.isNotEmpty ? kdUpb : defaultSubUnit,
                          ),
                          itemAsString: (item) => item.namaUnit ?? '',
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Unit Pengguna Barang (UPB)',
                              hintText: 'Pilih UPB',
                            ),
                          ),
                          popupProps: const PopupProps.menu(showSearchBox: true),
                          onChanged: (value) {
                            parKdUnit = kdSubUnit.isNotEmpty ? kdSubUnit : formkibC.session.value.kdUnit;
                            parKdSubUnit = kdUpb.isNotEmpty ? kdUpb : formkibC.session.value.kdSubUnit;
                            parKdUpb = value?.kodeUnit ?? '';
                            sType = '3';
                          },
                        );
                      } else if (formkibC.isTampilStringUpb.isTrue) {
                        return _buildReadOnlyField('UPB:', formkibC.session.value.nmUpb);
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Klasifikasi Aset
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '2. Klasifikasi KIB',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    DropdownSearch<Map<String, dynamic>>(
                      items: dataKib,
                      itemAsString: (item) => item['kib']?.toString() ?? '',
                      selectedItem: dataKib[1], // Default KIB B
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Kategori KIB',
                          hintText: 'Pilih Kategori',
                        ),
                      ),
                      popupProps: const PopupProps.menu(showSearchBox: false),
                      onChanged: (value) {
                        setState(() {
                          kdKib = value?['kode'] ?? '1.3.2';
                          _selectedBarang = null;
                          idt = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card 3: Pilih Barang
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '3. Pilih Aset yang Cocok',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    DropdownSearch<Barang>(
                      asyncItems: (text) => _fetchBarang(),
                      itemAsString: (item) =>
                          '${item.nmAset ?? ''} (Reg: ${item.noRegister ?? '-'})',
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Cari & Pilih Barang',
                          hintText: 'Ketik nama aset atau register...',
                        ),
                      ),
                      popupProps: PopupProps.dialog(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Ketik pencarian...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) => ListTile(
                          title: Text(item.nmAset ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Reg: ${item.noRegister ?? '-'} | Merk: ${item.merk ?? '-'} | Nopol: ${item.nomorPolisi ?? '-'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            CurrencyFormat.convertToIdr(item.harga, 0),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedBarang = value;
                          idt = value?.idt ?? '';
                          kdUpb = value?.kdUpb ?? '';
                          kdAset = value?.kdAset108 ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'SIMPAN PEMETAAN',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _isSaving ? null : _onSimpanPressed,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
