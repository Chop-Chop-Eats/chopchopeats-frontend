/// 应用配置模型
class AppConfig {
  /// 基地址
  final String baseApi;

  AppConfig({required this.baseApi});

  /// 测试环境基地址
  static const String devApi = 'https://dev-api.chopchopeats.org';

  /// 正式环境基地址
  static const String proApi = 'https://dev-api.chopchopeats.org';

  /// pagesize
  static const int pageSize = 10;

  /// API 响应中代表业务『成功』的 code 码集合
  static const List<int> successCodes = [0, 200];

  /// API 响应中代表业务『用户认证无效』的 code 码集合
  /// 用于触发特殊的业务逻辑，例如：跳转到登录页
  static const List<int> authErrorCodes = [403];

  /// API 响应中代表业务『code』的字段 key
  static const String codeKey = 'code';

  /// API 响应中代表业务『消息』的字段 key (按顺序查找，找到第一个就用)
  /// 兼容后端可能返回 'message' 或 'msg' 的情况
  static const List<String> messageKeys = ['message', 'msg'];

  /// API 响应中代表业务『数据』的字段 key
  static const String dataKey = 'data';

  // 未来可以继续扩展...
  // static const String devCdnUrl = '...';
  // static const String proCdnUrl = '...';
}
