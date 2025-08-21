/// 自定义网络异常
class ApiException implements Exception {
  final int? code;
  final String message;

  ApiException(this.message, {this.code});

  @override
  String toString() {
    return "ApiException: [$code] $message";
  }
}

/// 认证异常
///
/// 当监听到这个异常时，UI层可以做特殊处理，比如跳转到登录页
class AuthException extends ApiException {
  AuthException(super.message, {super.code});

  @override
  String toString() => "AuthException: [$code] $message";
}
