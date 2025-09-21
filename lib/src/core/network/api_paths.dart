/// 管理所有的 API 路径
class ApiPaths {
  ApiPaths._();

  // 发送验证码
  static const String sendSmsApi = "/app-api/member/auth/send-sms-code";

  // 使用手机 + 验证码登录
  static const String loginApi = "/app-api/member/auth/sms-login";

  // 使用手机 + 密码 + 用户平台类型登录
  static const String loginByPhoneAndPasswordApi = "/app-api/member/auth/platform-login";

  // 重置密码
  static const String resetPasswordApi = "/app-api/member/user/reset-password";

  // 登出系统
  static const String logoutApi = "/app-api/member/auth/logout";

}
