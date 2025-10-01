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

  // 获取甄选私厨店铺
  static const String getSelectedChefApi = "/app-api/merchant/shop/selected-chef"; 

  // 获取分类浏览私厨店铺
  static const String getDiamondAreaApi = "/app-api/merchant/shop/diamond-area";

  // 店铺分类列表
  static const String getCategoryListApi = "/app-api/merchant/shop/catsegory/list";

  // 搜索私厨店铺
  static const String searchShopApi = "/app-api/merchant/shop/page";

  // 获取商户店铺 (详情)
  static const String getShopApi = "/app-api/merchant/shop/get";

}
