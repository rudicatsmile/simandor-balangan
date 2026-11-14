class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  ApiResult._({required this.isSuccess, this.data, this.errorMessage});

  factory ApiResult.success(T data) {
    return ApiResult._(isSuccess: true, data: data);
  }

  factory ApiResult.failure(String message) {
    return ApiResult._(isSuccess: false, errorMessage: message);
  }
}

