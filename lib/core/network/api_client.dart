import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_result.dart';

class ApiClient {
  final Duration timeoutDuration;

  ApiClient({this.timeoutDuration = const Duration(seconds: 15)});

  Map<String, String> get _defaultHeaders => {
        'Accept': 'application/json',
      };

  Future<ApiResult<dynamic>> get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _defaultHeaders)
          .timeout(timeoutDuration);

      return _processResponse(response);
    } on SocketException {
      return ApiResult.failure('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on TimeoutException {
      return ApiResult.failure('Koneksi timeout. Server tidak merespons dalam waktu yang ditentukan.');
    } catch (e) {
      return ApiResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ApiResult<dynamic>> post(String url, {Map<String, String>? body}) async {
    try {
      final headers = Map<String, String>.from(_defaultHeaders);
      headers['Content-Type'] = 'application/x-www-form-urlencoded';

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
            encoding: Encoding.getByName('utf-8'),
          )
          .timeout(timeoutDuration);

      return _processResponse(response);
    } on SocketException {
      return ApiResult.failure('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } on TimeoutException {
      return ApiResult.failure('Koneksi timeout. Server tidak merespons.');
    } catch (e) {
      return ApiResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  ApiResult<dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        return ApiResult.success(decoded);
      } catch (e) {
        // If response is plain text like "Success"
        return ApiResult.success(response.body);
      }
    } else {
      return ApiResult.failure('Server merespons dengan status error: ${response.statusCode}');
    }
  }
}

