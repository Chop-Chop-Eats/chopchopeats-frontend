/// 管理所有的 API 路径
class ApiPaths {
  ApiPaths._();

  // [认证模块]
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


  // [首页模块]
  // 获取甄选私厨店铺
  static const String getSelectedChefApi = "/app-api/merchant/shop/selected-chef"; 

  // 店铺分类列表
  static const String getCategoryListApi = "/app-api/merchant/shop/category/list";

  // 获取分类浏览私厨店铺 金刚区二级页
  static const String getDiamondAreaApi = "/app-api/merchant/shop/diamond-area";

  // 获取banner列表
  static const String getBannerListApi = "/app-api/market/banner/list";

  // [搜索模块]
  // 搜索私厨店铺
  static const String searchShopApi = "/app-api/merchant/shop/page";

  // 获取关键词列表
  static const String getKeywordListApi = "/app-api/merchant/keyword/list";

  // 获取历史记录列表
  static const String getHistoryListApi = "/app-api/merchant/search-history/list";

  // 清除搜索记录
  static const String clearSearchHistoryApi = "/app-api/merchant/search-history/clear";

  // [详情模块]
  // 获取商户店铺 (店铺详情)
  static const String getShopApi = "/app-api/merchant/shop/get";

  // 获得可售商品列表
  static const String getSaleProductListApi = "/app-api/merchant/shop-product/available";

  // 获得可领取优惠券列表
  static const String getAvailableCouponListApi = "/app-api/market/user-coupon/available";

  // [收藏模块]
  // 添加收藏
  static const String addFavoriteApi = "/app-api/merchant/shop-favorite/add";

  // 取消收藏
  static const String cancelFavoriteApi = "/app-api/merchant/shop-favorite/remove";

  // 获取我的收藏
  static const String getFavoriteApi = "/app-api/merchant/shop-favorite/page";

  // [我的模块]
  // 获取用户基本信息
  static const String getUserInfoApi = "/app-api/member/user/get";

  // 修改基本信息
  static const String updateUserInfoApi = "/app-api/member/user/update";
}
