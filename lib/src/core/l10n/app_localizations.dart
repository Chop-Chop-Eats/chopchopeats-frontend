import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// 定义所有需要国际化的文本
abstract class AppLocalizations {
  // 用于从 Widget 树中获取实例
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // 定义一个 Delegate
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // ============== App 文本 ==============
  String get appTitle;
  String get settings;
  String get language;
  String get theme;
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  
  // ============== 底部导航 ==============
  String get tabHome;
  String get tabHeart;
  String get tabMessage;
  String get tabOrder;
  String get tabMine;
  
  // ============== 通用按钮 ==============
  String get btnConfirm;
  String get btnCancel;
  String get btnSave;
  String get btnDelete;
  String get btnEdit;
  String get btnSearch;
  String get btnClear;
  String get btnViewAll;
  
  // ============== 提示信息 ==============
  String get loadingText;
  String get noDataText;
  String get networkErrorText;
  String get emptyListText;
  String get tryAgainText;
  
  // ============== 业务文案 - 店铺相关 ==============
  String get distanceUnit; // km
  String get deliveryFee;
  String get operatingHours;
  String get rating;
  String get newShop;
  String get hotProduct;
  String get favorite;
  String get unfavorite;
  
  // ============== 业务文案 - 分类相关 ==============
  String get allCategories;
  String get selectedChef;
  
  // ============== 业务文案 - 搜索相关 ==============
  String get searchPlaceholder;
  String get searchHistory;
  String get hotSearchKeywords;
  String get clearHistory;
  
  // ============== 业务文案 - 详情页相关 ==============
  String get productDetail;
  String get shopIntroduction;
  String get addToCart;
  String get selectSpec;
  String get stock;
  String get price;
  String get newShopMark;
  String get dailyMenu;
  String get getCoupon;
  String get selectSpecification;
  String get estimatedDeliveryFee;
  String get totalPrice;
  String get orderNow;
  
  // ============== 业务文案 - 语言设置 ==============
  String get languageSettings;
  String get languageSystem;
  String get languageChinese;
  String get languageEnglish;
  
  // ============== Splash 启动页 ==============
  String get locationPermissionTitle;
  String get locationPermissionSubtitle;
  String get findNearbyStores;
  String get findNearbyStoresDesc;
  String get calculateDeliveryDistance;
  String get calculateDeliveryDistanceDesc;
  String get planBestRoute;
  String get planBestRouteDesc;
  String get goToSettings;
  String get returnAfterEnable;
  
  // ============== Home 首页 ==============
  String get searchHintHome;
  String get noCategoryData;
  String get noBannerData;
  String get noRestaurantData;
  
  // ============== Search 搜索页 ==============
  String get searchContentHint;
  String get guessYouLike;
  
  // ============== Detail 详情页 ==============
  String get merchantDetail;
  String get noShopDescription;
  String get unknownDistance;
  String get comments;
  String get shopNotExist;
  
  
  // 星期相关
  String get today;
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // ============== Heart 收藏页 ==============
  String get noFavoriteText;
  String get goToShop;
  
  // ============== Mine 我的页面 ==============
  String get profile; // 个人资料
  String get deliveryAddress; // 收货地址
  String get help; // 获取帮助
  String get accountSettings; // 账号设置
  String get privacyPolicy; // 隐私政策
  String get platformAgreement; // 平台协议
  String get logout; // 退出登录
  String get selectLanguage; // 选择语言
  String get confirmLogout; // 确认退出登录
  String get logoutConfirmMessage; // 确定要退出登录吗？
  String get wallet; // 钱包
  String get coupons; // 优惠券
  String get recharge; // 去充值
  String get shopEnter; // 商家入驻
  String get shopEnterDesc; // 0元轻松入驻


  // ============== 业务文案 - 个人资料页 ==============
  String get avatar; // 头像
  String get nickname; // 昵称
  String get phone; // 手机号
  String get email; // 邮箱
  String get modifyNickname; // 修改昵称
  String get modifyPhone; // 修改手机号
  String get modifyNicknameTips1; // 修改昵称提示1
  String get modifyNicknameTips2; // 修改昵称提示2
  String get modifyNicknameTips3; // 修改昵称提示3
  

  
  // ============== 通用文案 ==============
  String get loadingFailedWithError;
  String loadingFailedMessage(String error);
}

// Delegate 类，Flutter 会用它来加载对应的语言类
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  // 判断该 Delegate 是否支持给定的 Locale
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  // 根据当前的 Locale，加载并返回一个 AppLocalizations 的实例
  @override
  Future<AppLocalizations> load(Locale locale) {
    // 使用 SynchronousFuture 是一个优化，因为我们的加载是同步的，不需要异步操作
    return SynchronousFuture<AppLocalizations>(
      locale.languageCode == 'zh' ? AppLocalizationsZh() : AppLocalizationsEn(),
    );
  }

  // 是否需要重新加载，通常返回 false
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
