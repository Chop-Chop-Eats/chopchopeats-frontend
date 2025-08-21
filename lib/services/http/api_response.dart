import '../../app/app_config.dart';

/// 标准化的后端响应数据模型
/// 假设后端返回的数据结构都是类似 {"code": 0, "message": "success", "data": ...}
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {

    // 动态从 AppConfig.messageKeys 列表中查找消息字段
    String foundMessage = "未知错误"; // 默认消息
    for (final key in AppConfig.messageKeys) {
      if (json.containsKey(key) && json[key] != null) {
        foundMessage = json[key];
        break;
      }
    }

    return ApiResponse<T>(
      code: json[AppConfig.codeKey],
      message: foundMessage,
      // 只有当 data 不为 null 且提供了转换函数时才进行转换
      data: json[AppConfig.dataKey] != null && fromJsonT != null ? fromJsonT(json[AppConfig.dataKey]) : json[AppConfig.dataKey],
    );
  }

  /// 业务是否成功
  bool get isSuccessful => AppConfig.successCodes.contains(code); // 成功的业务代码
}
