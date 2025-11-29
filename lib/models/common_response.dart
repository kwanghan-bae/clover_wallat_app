class CommonResponse<T> {
  final String result;
  final T? data;
  final String? errorCode;
  final String? message;

  CommonResponse({
    required this.result,
    this.data,
    this.errorCode,
    this.message,
  });

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return CommonResponse<T>(
      result: json['result'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errorCode: json['errorCode'] as String?,
      message: json['message'] as String?,
    );
  }

  bool get isSuccess => result == 'SUCCESS';
}
