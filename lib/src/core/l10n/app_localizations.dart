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
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  // ============== 订单状态标签 ==============
  String get orderTabAll;
  String get orderTabPending;
  String get orderTabInProgress;
  String get orderTabCompleted;
  String get orderTabCancelled;

  // ============== 通用按钮 ==============
  String get btnConfirm;
  String get btnCancel;
  String get btnSave;
  String get btnSubmit;
  String get btnDelete;
  String get btnEdit;
  String get btnSearch;
  String get btnClose;
  String get btnClear;
  String get btnViewAll;

  // ============== 提示信息 ==============
  String get loadingText;
  String get noDataText;
  String get noProductsText;
  String get networkErrorText;
  String get emptyListText;
  String get tryAgainText;

  // ============== 认证相关 ==============
  String get authLoginTitle;
  String get authAutoRegisterHint;
  String get authEmailHint;
  String get authPhoneHint;
  String get authPhoneRequired;
  String get authGetVerificationCode;
  String get authSendingCode;
  String get authPasswordLogin;
  String get authCodeLogin;
  String get authPasswordHint;
  String get authPasswordRequired;
  String get authForgotPasswordTitle;
  String get authForgotPasswordQuestion;
  String get authRecoverNow;
  String get authLogin;
  String get authLoggingIn;
  String get authLoginSuccess;
  String get authLoginFailedRetry;
  String get authEnterVerificationCodeTitle;
  String get authVerifyIdentityTitle;
  String get authCodeSentToPhonePrefix;
  String get authNoCodeReceived;
  String get authResend;
  String get authCodeResentSuccess;
  String get authProcessing;
  String get authEnterCompleteCode;
  String get authSetNewPassword;
  String get authPasswordRequirementHint;
  String get authNewPasswordHint;
  String get authSetPasswordSuccess;
  String get authSetPasswordFailed;
  String get authSaveAndLogin;

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
  String get clearCartConfirmMessage;
  String get removeItemConfirmMessage;
  String get cartTitle;
  String get cartEmpty;
  String get addToCartSuccess;
  String get other;
  String get pleaseEnter0To100;
  String get pleaseEnterValidNumber;
  // ============== 业务文案 - 语言设置 ==============
  String get languageSettings;
  String get languageSystem;
  String get languageChinese;
  String get languageEnglish;
  String get updateLanguageFailed;
  String get updateLanguageSuccess;
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
  String get selectCurrentLocationHint;

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
  String get merchantDetail; // 商家详情
  String get noShopDescription; // 暂无店铺描述
  String get unknownDistance; // 距离未知
  String get comments; // 条评论
  String get shopNotExist; // 店铺信息不存在
  String get noCoupon; // 暂无优惠券
  String get minSpend; // 最低消费
  String get claimCouponSuccess; // 领取优惠券成功
  String get claimCouponFailed; // 领取优惠券失败
  String get couponClaimLimitReached; // 已领取到上限
  String get couponUse; // 使用
  String get couponUseNow; // 去使用
  String get couponUsed; // 已使用
  String get couponExpired; // 已过期

  // 星期相关
  String get today;
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // ============== Confirm Order 确认订单页 ==============
  String get confirmOrder; // 确认订单
  String get confirmOrderAddress; // 选择地址
  String get confirmOrderPrivateChef; // 下单私厨
  String get confirmOrderDeliveryTime; // 配送时间
  String get confirmOrderDistance; // 距离
  String get confirmOrderPlan; // 计划
  String get confirmOrderStartDelivery; // 开始配送
  String get confirmOrderMealDetail; // 餐品详情
  String get confirmOrderDeliveryTip; // 配送小费提示
  String get confirmOrderDeliveryFeeTip; // 配送小费提示
  String get confirmOrderOrderAmount; // 订单金额
  String get confirmOrderMealSubtotal; // 餐品小记
  String get confirmOrderTaxAndServiceFee; // 税费&服务费
  String get confirmOrderDeliveryFee; // 配送费
  String get confirmOrderCouponDiscount; // 优惠券折扣
  String get confirmOrderAvailableCoupons; // 可用优惠券
  String get confirmOrderRemoveCoupon; // 移除优惠券
  String confirmOrderCouponThresholdNotMet(String minSpend); // 优惠券使用门槛未达到
  String get confirmOrderCouponRemovedDueToThreshold; // 优惠券因未达门槛已自动移除
  String get confirmOrderTotal; // 合计
  String get confirmOrderPaymentMethod; // 支付方式
  String get confirmOrderSelectPaymentMethod; // 选择支付方式
  String get addNewCard; // 添加新卡
  String get paymentMethodDefaultLabel; // 默认
  String get confirmOrderRemark; // 备注
  String confirmOrderSettlementTip(String value); // 结算小费
  String get confirmOrderSettlement; // 结算
  String get confirmOrderEmptyCart; // 购物车为空
  String get confirmOrderSelectAddress; // 请选择地址
  String get confirmOrderSelectDeliveryTime; // 请选择配送时间
  String get confirmOrderTodayNotDelivery; // 今日不可配送
  String get confirmOrderSyncCartFailed; // 同步购物车失败，请稍后重试
  String get confirmOrderInvalidCartItemPrice; // 购物车存在无效商品（价格为空），请重新添加
  String get confirmOrderInvalidCartItemId; // 购物车存在无效商品（商品ID为空），请重新添加
  String confirmOrderCreateOrderFailed(String error); // 创建订单失败
  String get confirmOrderConfirmPaymentTitle; // 确认支付
  String confirmOrderConfirmPaymentContent(String orderId); // 确认支付订单？
  String get confirmOrderPaymentSuccess; // 支付成功
  String confirmOrderWalletPaymentFailed(String error); // 钱包支付失败
  String
  get confirmOrderPaymentIntentMissing; // 订单生成失败：缺少 clientSecret 或 publishableKey
  String confirmOrderPaymentTitle(String orderNo); // 订单 X
  String get confirmOrderPaymentCancelled; // 取消支付
  String confirmOrderPaymentFailed(String error); // 支付失败
  String confirmOrderPaymentError(String error); // 发生错误
  String confirmOrderCreatePaymentFailed(String error); // 创建支付失败
  String get confirmOrderInvalidPaymentMethodTitle; // 支付卡片无效
  String get confirmOrderInvalidPaymentMethodMessage; // 支付卡片无效提示内容
  String get confirmOrderInvalidPaymentMethodButton; // 返回修改

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

  // ============== ShopEnter 商家入驻页面 ==============
  String get shopEnterTitle; // 商家入驻
  String get shopEnterProcess; // 入驻流程
  String get shopEnterDownloadApp; // 下载商家端 App
  String get shopEnterButtonDescription; // 描述1
  String get shopEnterRegisterAccount; // 注册账号
  String get shopEnterRegisterAccountDescription; // 注册账号描述
  String get shopEnterApplyExam; // 考证&申请
  String get shopEnterApplyExamDescription; // 考证&申请描述
  String get shopEnterDownloadButton; // 下载按钮

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
  String get addressCityLabel; // 城市
  String get addressStateLabel; // 州/省
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

  // ============== 钱包模块 ==============
  String get walletTitle; // 钱包
  String get walletBalance; // 钱包余额
  String get walletRecharge; // 钱包充值
  String get myWallet; // 我的钱包（支付方式显示）
  String get availableBalance; // 可用余额（支付方式显示）
  String get selectOrEnterRechargeAmount; // 选择或输入充值金额
  String get enterRechargeAmount; // 请输入充值金额
  String get balanceDetail; // 余额明细
  String get manageBoundCards; // 管理绑定卡片
  String get rechargeSuccess; // 充值成功
  String get rechargeFailed; // 充值失败
  String get complete; // 完成

  // ============== 通用文案 ==============
  String get loadingFailedWithError;
  String loadingFailedMessage(String error);

  // ============== 订单列表和详情 ==============
  String get orderNoOrders; // 暂无订单
  String get orderNoOrdersDesc; // 去找找家的味道
  String get orderExpired; // 已过期
  String orderExpiresIn(int minutes, int seconds); // 剩余XX分XX秒过期
  String get orderTotalItems; // 总共X件商品
  String orderTotalQuantity(int quantity); // 总共X件
  String get orderPayNow; // 立即支付
  String get orderCancelOrder; // 取消订单
  String get orderRequestRefund; // 申请退款
  String get orderWriteReview; // 写评价
  String get orderReorder; // 再来一单
  String get orderDeleteOrder; // 删除订单
  String get orderDeliveryAddress; // 配送地址
  String get orderChef; // 私厨
  String get orderOrderDetails; // 订单详情
  String get orderSubtotal; // 小计
  String get orderTaxAndServiceFee; // 税费&服务费
  String get orderDeliveryFee; // 配送费
  String get orderCouponDiscount; // 优惠券折扣
  String get orderActualPayment; // 实付款
  String orderActualPaymentWithTip(String tip); // 实付款(含小费)
  String get orderOrderInfo; // 订单信息
  String get orderOrderNo; // 订单编号
  String get orderOrderTime; // 下单时间
  String get orderPaymentMethod; // 支付方式
  String orderDistance(double distance); // 距离X km
  String orderDeliveryTime(String time); // 计划 XX 开始配送
  String orderCountdownTime(int minutes, int seconds); // 倒计时时间
  String get orderCountdownSuffix; // 后失效
  String get orderStatusDescDefault; // 默认状态描述
  String get orderCancelReason; // 取消原因
  String get orderCancelOrRefundTitle; // 取消/退款标题
  String get orderWhyRefund; // 退款原因询问
  String get orderWhyCancel; // 取消原因询问
  String get orderRefundReasonHint; // 退款提示文案
  String get orderCancelReasonHint; // 取消提示文案
  String get orderReasonCategoryChefProduct; // 私厨/商品原因分类
  String get orderReasonCategoryPersonal; // 个人原因分类
  String get orderSelectRefundReason; // 请选择退款原因
  String get orderSelectCancelReason; // 请选择取消原因
  String get orderRefundSubmitted; // 退款申请已提交
  String get orderCancelled; // 订单已取消
  String orderRefundFailed(String error); // 退款失败提示
  String orderCancelFailed(String error); // 取消失败提示

  // ============== 消息中心 ==============
  String get messageCenter; // 消息中心
  String get messageTabAll; // 全部
  String get messageTabOrder; // 订单消息
  String get messageTabSystem; // 系统消息
  String get messageClearConfirmTitle; // 确认清除
  String get messageClearConfirmContent; // 确定要清除所有消息吗？此操作不可恢复。
  String get messageClearConfirmBtn; // 确定
  String get messageClearCancelBtn; // 取消
  String get messageNoData; // 暂无消息
  String get messageLoadFailed; // 加载失败
  String get messageRetry; // 重试
  String get messageYesterday; // 昨天

  // ============== 评论模块 ==============
  String get commentMerchantReply; // 商家回复
  String get commentRatingSuffix; // 分（评分单位）
  String get commentCount; // 条评价
  String get commentViewAll; // 显示所有评价
  String get commentNoReviews; // 暂无评价
  String get commentMaxImages; // 最多上传4张图片
  String get commentSelectRating; // 请选择评分
  String get commentSuccess; // 评价成功
  String get commentFailed; // 评价失败，请重试
  String get commentTitle; // 评价
  String get commentExperienceTitle; // 您的此次用餐体验如何？
  String get commentExperienceSubtitle; // 喜欢你的食物吗？给私厨商家评分，您的意见很重要。
  String get commentShareExperienceHint; // 分享多方面的用餐体验，可以帮助更多用户哦
  String get commentUploadImages; // 上传图片\n(最多4张)
  String get commentSubmit; // 提交
  String commentDaysAgo(int days); // X天前
}

// Delegate 类，Flutter 会用它来加载对应的语言类
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
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
