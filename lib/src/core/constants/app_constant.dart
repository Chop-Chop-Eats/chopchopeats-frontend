// lib/config/app_constants.dart
class AppConstants {
  AppConstants._(); // 私有构造
  // 记录api请求时间  
  static const String apiStartTime = "API_START_TIME";  
  // 设备信息
  static const String deviceUuid = "DEVICE_UUID";
  // 主题模式
  static const String themeMode = "THEME_MODE";
  // 语言模式
  static const String languageMode = "LANGUAGE_MODE";
  // 用户token
  static const String accessToken = "ACCESS_TOKEN";
  // 用户刷新token
  static const String refreshToken = "REFRESH_TOKEN";
  // 用户openid
  static const String openid = "OPENID";
  // 用户shopId
  static const String shopId = "SHOP_ID";
  // 用户userId
  static const String userId = "USER_ID";
  // 搜索历史
  static const String searchHistory = "SEARCH_HISTORY";
  // 全局经度
  static const String longitude = "APP_LONGITUDE";
  // 全局纬度
  static const String latitude = "APP_LATITUDE";
  // 全局位置名称
  static const String locationLabel = "APP_LOCATION_LABEL";

}
