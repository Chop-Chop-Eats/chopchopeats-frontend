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
  String get btnClose;
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
  
  // ============== 地图选址 ==============
  String get mapSelectLocationTitle;
  String get mapConfirmLocation;
  String get mapSearchHint;
  String get mapResolvingAddress;
  String get mapNoAddress;
  String get mapUseMyLocation;
  String get mapLocationServicesDisabled;
  String get mapLocationPermissionDenied;
  String get mapLocationFetchFailed;
  String get mapPlaceDetailFailed;
  String get mapSearchFailed;
  String get mapSelectedLocationLabel;
  String mapCoordinateLabel(double latitude, double longitude);

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

  // ============== Help 帮助页面 ==============
  String get helpShareFeedbackTitle; // 分享你的反馈
  String get helpShareFeedbackDescription; // 感谢文案
  String get helpSupportEmailLabel; // 客服邮箱
  String get helpSupportPhoneLabel; // 客服电话
  String get helpEmailCopiedToast; // 邮箱复制提示
  String get helpDialerLaunchFailedToast; // 拨号失败提示


  // ============== 业务文案 - 个人资料页 ==============
  String get avatar; // 头像
  String get nickname; // 昵称
  String get phone; // 手机号
  String get email; // 邮箱
  String get modifyNickname; // 修改昵称
  String get modifyPhone; // 修改手机号
  String get modifyEmail; // 修改邮箱
  String get modifyNicknameTips1; // 修改昵称提示1
  String get modifyNicknameTips2; // 修改昵称提示2
  String get modifyNicknameTips3; // 修改昵称提示3
  String get modifyNicknameEmpty; // 昵称为空提示
  String get modifyEmailEmpty; // 邮箱为空提示
  String get modifyEmailInvalid; // 邮箱格式错误提示
  String get modifyNoChange; // 未修改提示
  String get modifySuccess; // 修改成功提示
  String get modifyFailed; // 修改失败提示
  String get modifyUserInfoMissing; // 用户信息缺失提示
  String get modifyPhoneEmpty; // 手机号为空提示
  String get modifyPhoneCodeEmpty; // 验证码为空提示
  String get modifyPhoneNew; // 新手机号标签
  String get modifyPhoneCodeLabel; // 验证码标签
  String get modifyPhoneCodeHint; // 验证码提示
  String modifyPhoneResend(int seconds); // 重新发送提示
  String get modifyPhoneSendCode; // 发送验证码按钮
  String get modifyPhoneFailed; // 修改手机号失败提示
  String get smsSendSuccess; // 短信发送成功
  String get smsSendFailed; // 短信发送失败
  String get btnSaving; // 保存中按钮文本
  String get avatarUploadSuccess; // 头像上传成功
  String get avatarUploadFailed; // 头像上传失败
  String get camera; // 相机
  String get gallery; // 相册

  // ============== 业务文案 - 收货地址页 ==============
  String get address; // 收货地址
  String get addAddress; // 添加地址
  String get editAddress; // 编辑地址
  String get defaultAddress; // 默认地址标记
  String get addressRecipientNameLabel; // 收货人姓名
  String get addressPhoneNumberLabel; // 电话号码
  String get addressStreetLabel; // 街道
  String get addressStreetFixedValue; // 固定街道值
  String get addressDetailLabel; // 建筑/公寓/楼层/单元
  String get addressStateLabel; // 城市/州
  String get addressZipCodeLabel; // 邮政编码
  String get addressSetDefaultToggle; // 设置默认地址文案
  String get addressSelectStateSheetTitle; // 选择城市/州标题
  String get addressSelectStateHint; // 选择城市提示
  String get addressSelectStateEmpty; // 无城市提示
  String get addressFormIncomplete; // 表单未完成提示
  String get addressCreateSuccess; // 新增成功提示
  String get addressUpdateSuccess; // 更新成功提示
  String get addressDeleteConfirmTitle; // 删除确认标题
  String get addressDeleteConfirmDescription; // 删除确认描述
  String get addressDeleteSuccess; // 删除成功提示

  
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
