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

  // 修改手机号
  static const String updatePhoneApi = "/app-api/member/user/update-mobile";


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

  // 上传头像
  static const String uploadAvatarApi = "/app-api/infra/file/upload/avatar";

  // 修改基本信息
  static const String updateUserInfoApi = "/app-api/member/user/update";

  // 获得用户配送地址列表
  static const String getUserAddressListApi = "/app-api/member/address/list";

  // 获得用户配送地址
  static const String getUserAddressApi = "/app-api/member/address/get";

  // 获得默认的用户配送地址
  static const String getDefaultUserAddressApi = "/app-api/member/address/get-default";
  
  // 添加用户配送地址
  static const String createUserAddressApi = "/app-api/member/address/create";

  // 更新用户配送地址
  static const String updateUserAddressApi = "/app-api/member/address/update";
  
  // 删除用户配送地址
  static const String deleteUserAddressApi = "/app-api/member/address/delete";

  // 获取州市列表
  static const String getStateListApi = "/app-api/merchant/state-list";

  // [优惠券模块]
  // 获取我的优惠券列表
  static const String getMyCouponListApi = "/app-api/market/user-coupon/my";

  // 领取优惠券
  static const String claimCouponApi = "/app-api/market/user-coupon/claim";

  // [订单模块]
  // 创建交易订单
  static const String createOrderApi = "/app-api/trade/app-order/create";

  // 添加购物车
  static const String addCartApi = "/app-api/trade/cart/add";

  // 获取购物车列表
  static const String getCartListApi = "/app-api/trade/cart/list";

  // 清空购物车
  static const String clearCartApi = "/app-api/trade/cart/clear";

  // 更新购物车商品数量
  static const String updateCartQuantityApi = "/app-api/trade/cart/update-quantity";

  // 创建 Stripe PaymentIntent
  static const String createSPIApi = "/app-api/trade/stripe-payment-intent/create";

}
