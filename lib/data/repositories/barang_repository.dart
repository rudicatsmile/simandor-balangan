import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/barang.dart';
import '../models/ruang_detail.dart';
import '../models/unit_detail.dart';
import '../models/upb_detail.dart';
import '../models/verify_data_response.dart';

class BarangRepository {
  final ApiClient _client;

  BarangRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResult<Barang>> getBarangDetail(String kode) async {
    final result = await _client.get('${ApiEndpoints.getBarangDetail}?kode=$kode');
    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal memuat detail barang');
    }

    try {
      final data = result.data;
      if (data is Map<String, dynamic> && data['IDT'] != null) {
        return ApiResult.success(Barang.fromJson(data));
      } else {
        return ApiResult.failure('Data barang tidak ditemukan');
      }
    } catch (e) {
      return ApiResult.failure('Gagal memproses data barang');
    }
  }

  Future<ApiResult<UnitDetail>> getUnitDetail(String kode) async {
    final result = await _client.get('${ApiEndpoints.getUnitDetail}?kode=$kode');
    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal memuat detail unit');
    }

    try {
      final data = result.data;
      if (data is Map<String, dynamic>) {
        return ApiResult.success(UnitDetail.fromJson(data));
      }
      return ApiResult.failure('Unit tidak ditemukan');
    } catch (e) {
      return ApiResult.failure('Gagal memproses data unit');
    }
  }

  Future<ApiResult<UpbDetail>> getUpbDetail(String kode) async {
    final result = await _client.get('${ApiEndpoints.getUpbDetail}?kode=$kode');
    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal memuat detail UPB');
    }

    try {
      final data = result.data;
      if (data is Map<String, dynamic>) {
        return ApiResult.success(UpbDetail.fromJson(data));
      }
      return ApiResult.failure('UPB tidak ditemukan');
    } catch (e) {
      return ApiResult.failure('Gagal memproses data UPB');
    }
  }

  Future<ApiResult<RuangDetail>> getRuangDetail(String kodeUpb, String kodeRuang) async {
    final result = await _client.get('${ApiEndpoints.getRuangDetail}?kodeUpb=$kodeUpb&kodeRuang=$kodeRuang');
    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal memuat detail ruang');
    }

    try {
      final data = result.data;
      if (data is Map<String, dynamic>) {
        return ApiResult.success(RuangDetail.fromJson(data));
      }
      return ApiResult.failure('Ruang tidak ditemukan');
    } catch (e) {
      return ApiResult.failure('Gagal memproses data ruang');
    }
  }

  Future<ApiResult<VerifyDataResponse>> verifyBarang(
      String kodeBarang, String verifikasiTanggal, String otorisator) async {
    final result = await _client.post(
      ApiEndpoints.addVerificationData,
      body: {
        'kode_barang': kodeBarang,
        'verifikasi_status': '1',
        'verifikasi_tanggal': verifikasiTanggal,
        'otorisator': otorisator,
      },
    );

    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal verifikasi barang');
    }

    try {
      final data = result.data;
      if (data is Map<String, dynamic>) {
        return ApiResult.success(VerifyDataResponse.fromJson(data));
      }
      return ApiResult.failure('Format respons tidak valid');
    } catch (e) {
      return ApiResult.failure('Gagal memproses verifikasi');
    }
  }
}

