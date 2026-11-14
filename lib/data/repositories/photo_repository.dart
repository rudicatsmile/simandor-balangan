import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';

class PhotoStatusResult {
  final bool alreadyUploaded;
  final String? idt;
  final String message;

  PhotoStatusResult({
    required this.alreadyUploaded,
    this.idt,
    required this.message,
  });
}

class PhotoRepository {
  final ApiClient _client;

  PhotoRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResult<PhotoStatusResult>> checkPhotoStatus(String kodeBarang) async {
    final result = await _client.post(
      ApiEndpoints.checkViewKibPhoto,
      body: {'kodeBar': kodeBarang.trim()},
    );

    if (!result.isSuccess) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal memeriksa status foto');
    }

    final data = result.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString();
      if (msg == 'Success') {
        return ApiResult.success(
          PhotoStatusResult(
            alreadyUploaded: true,
            message: 'Foto barang sudah pernah diunggah.',
          ),
        );
      } else if (msg == 'Success2') {
        final val = data['value'];
        final idt = val is Map<String, dynamic> ? (val['idt'] ?? val['IDT'])?.toString() : null;
        if (idt != null && idt.isNotEmpty) {
          return ApiResult.success(
            PhotoStatusResult(
              alreadyUploaded: false,
              idt: idt,
              message: 'Siap untuk unggah foto.',
            ),
          );
        }
      }
      return ApiResult.failure(
        data['message']?.toString() ?? 'Barang belum terdata atau tidak valid.',
      );
    }

    return ApiResult.failure('Format respon server tidak valid.');
  }
}
