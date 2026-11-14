import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/barang.dart';
import '../models/unit.dart';

class KibRepository {
  final ApiClient _client;

  KibRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Unit>> getUnits({
    required String tableName,
    required String kode,
    required String kodeUpb,
    required String level,
    required String admin,
  }) async {
    final url =
        '${ApiEndpoints.getUnit}?tableName=$tableName&kode=$kode&kodeUpb=$kodeUpb&level=$level&admin=$admin';
    final result = await _client.get(url);

    if (result.isSuccess && result.data is Map<String, dynamic>) {
      final val = result.data['value'];
      if (val is List) {
        return val.map((e) => Unit.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<List<Barang>> getBarangList({
    required String kdUnit,
    required String kdSubUnit,
    required String kdUpb,
    required String sType,
    required String kdKib,
  }) async {
    final url =
        '${ApiEndpoints.getBarang3}?kdUnit=$kdUnit&kdSubUnit=$kdSubUnit&kdUpb=$kdUpb&sType=$sType&kdKib=$kdKib';
    final result = await _client.get(url);

    if (result.isSuccess && result.data is Map<String, dynamic>) {
      final val = result.data['value'];
      if (val is List) {
        return val.map((e) => Barang.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<ApiResult<bool>> mappingKib({
    required String idt,
    required String kdUpb,
    required String kdAset,
    required String kodeBar,
    required String userName,
  }) async {
    final result = await _client.post(
      ApiEndpoints.updateTabelKib,
      body: {
        'idt': idt,
        'Kd_UPB': kdUpb,
        'Kd_Aset_108': kdAset,
        'kode_bar': kodeBar,
        'userName': userName,
      },
    );

    if (!result.isSuccess || result.data == null) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal menyimpan mapping KIB.');
    }

    final data = result.data.toString();
    if (data.contains('Success')) {
      return ApiResult.success(true);
    } else {
      return ApiResult.failure(data);
    }
  }
}

