import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../models/pesan.dart';

class MessageRepository {
  final ApiClient _client;

  MessageRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ApiResult<bool>> insertMessage(String userName, String message) async {
    final result = await _client.post(
      ApiEndpoints.insertMessage,
      body: {
        'userName': userName,
        'message': message,
      },
    );

    if (!result.isSuccess) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal mengirim pesan');
    }

    final data = result.data;
    if (data is Map<String, dynamic> && data['message'] == 'Success') {
      return ApiResult.success(true);
    }

    final errorMsg = data is Map<String, dynamic> ? data['message']?.toString() : null;
    return ApiResult.failure(errorMsg ?? 'Gagal mengirim pesan');
  }

  Future<ApiResult<List<Pesan>>> getMessages() async {
    final result = await _client.get(ApiEndpoints.pesanGetAll);
    if (!result.isSuccess) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal memuat pesan');
    }

    final data = result.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      final list = data['data'] as List?;
      if (list != null) {
        final messages = list
            .map((e) => Pesan.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(messages);
      }
      return ApiResult.success([]);
    }

    return ApiResult.success([]);
  }

  Future<ApiResult<bool>> toggleTampil(String code) async {
    final result = await _client.post(
      ApiEndpoints.pesanTampil,
      body: {'code': code},
    );

    if (!result.isSuccess) {
      return ApiResult.failure(result.errorMessage ?? 'Gagal mengubah status pesan');
    }

    final data = result.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return ApiResult.success(true);
    }

    return ApiResult.failure('Gagal mengubah status pesan');
  }
}
