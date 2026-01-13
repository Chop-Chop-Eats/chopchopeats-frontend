import 'app_localizations.dart';

class AppLocalizationsZh implements AppLocalizations {
  @override
  String get appTitle => 'ChopChop';
  @override
  String get settings => '设置';
  @override
  String get language => '语言';
  @override
  String get theme => '主题';
  @override
  String get themeDark => '暗色模式';
  @override
  String get themeLight => '亮色模式';
  @override
  String get themeSystem => '跟随系统';

  // ============== 底部导航 ==============
  @override
  String get tabHome => '首页';
  @override
  String get tabHeart => '收藏';
  @override
  String get tabMessage => '消息';
  @override
  String get tabOrder => '订单';
  @override
  String get tabMine => '我的';

  // ============== 订单状态标签 ==============
  @override
  String get orderTabAll => '全部';
  @override
  String get orderTabPending => '待支付';
  @override
  String get orderTabInProgress => '进行中';
  @override
  String get orderTabCompleted => '已完成';
  @override
  String get orderTabCancelled => '取消/退款';

  // ============== 通用按钮 ==============
  @override
  String get btnConfirm => '确认';
  @override
  String get btnCancel => '取消';
  @override
  String get btnSave => '保存';
  @override
  String get btnSubmit => '提交';
  @override
  String get btnDelete => '删除';
  @override
  String get btnEdit => '编辑';
  @override
  String get btnSearch => '搜索';
  @override
  String get btnClose => '关闭';
  @override
  String get btnClear => '清除';
  @override
  String get btnViewAll => '查看全部';

  // ============== 提示信息 ==============
  @override
  String get loadingText => '加载中...';
  @override
  String get noDataText => '暂无数据';
  @override
  String get networkErrorText => '网络错误，请稍后重试';
  @override
  String get emptyListText => '列表为空';
  @override
  String get tryAgainText => '重试';

  // ============== 认证相关 ==============
  @override
  String get authLoginTitle => '登录ChopChop';
  @override
  String get authAutoRegisterHint => '未注册手机号我们将自动为您注册';
  @override
  String get authEmailHint => '请输入邮箱';
  @override
  String get authPhoneHint => '请输入手机号';
  @override
  String get authPhoneRequired => '请输入手机号';
  @override
  String get authGetVerificationCode => '获取验证码';
  @override
  String get authSendingCode => '发送中...';
  @override
  String get authPasswordLogin => '密码登录';
  @override
  String get authCodeLogin => '验证码登录';
  @override
  String get authPasswordHint => '请输入密码';
  @override
  String get authPasswordRequired => '请输入密码';
  @override
  String get authForgotPasswordTitle => '找回密码';
  @override
  String get authForgotPasswordQuestion => '忘记密码?';
  @override
  String get authRecoverNow => '立即找回';
  @override
  String get authLogin => '登录';
  @override
  String get authLoggingIn => '登录中...';
  @override
  String get authLoginSuccess => '登录成功';
  @override
  String get authLoginFailedRetry => '登录失败，请重试';
  @override
  String get authEnterVerificationCodeTitle => '输入验证码';
  @override
  String get authVerifyIdentityTitle => '验证身份';
  @override
  String get authCodeSentToPhonePrefix => '已发送至手机号 ';
  @override
  String get authNoCodeReceived => '未收到验证码?';
  @override
  String get authResend => '重新发送';
  @override
  String get authCodeResentSuccess => '验证码已重新发送';
  @override
  String get authProcessing => '处理中...';
  @override
  String get authEnterCompleteCode => '请输入完整的6位验证码';
  @override
  String get authSetNewPassword => '设置新密码';
  @override
  String get authPasswordRequirementHint => '密码至少8位,包含数字/字母';
  @override
  String get authNewPasswordHint => '请输入新密码';
  @override
  String get authSetPasswordSuccess => '设置新密码成功';
  @override
  String get authSetPasswordFailed => '设置新密码失败';
  @override
  String get authSaveAndLogin => '保存并登录';

  // ============== 业务文案 - 店铺相关 ==============
  @override
  String get distanceUnit => 'km';
  @override
  String get deliveryFee => '配送费';
  @override
  String get operatingHours => '营业时间';
  @override
  String get rating => '评分';
  @override
  String get newShop => '新店';
  @override
  String get hotProduct => '热门';
  @override
  String get favorite => '收藏';
  @override
  String get unfavorite => '取消收藏';

  // ============== 业务文案 - 分类相关 ==============
  @override
  String get allCategories => '全部分类';
  @override
  String get selectedChef => '甄选私厨';

  // ============== 业务文案 - 搜索相关 ==============
  @override
  String get searchPlaceholder => '搜索店铺或商品';
  @override
  String get searchHistory => '搜索历史';
  @override
  String get hotSearchKeywords => '热门搜索';
  @override
  String get clearHistory => '清空历史';

  // ============== 业务文案 - 详情页相关 ==============
  @override
  String get productDetail => '商品详情';
  @override
  String get shopIntroduction => '店铺介绍';
  @override
  String get addToCart => '加入购物车';
  @override
  String get selectSpec => '选择规格';
  @override
  String get stock => '库存';
  @override
  String get price => '价格';
  @override
  String get newShopMark => '新店开业';
  @override
  String get dailyMenu => '每日菜单';
  @override
  String get getCoupon => '领券';
  @override
  String get selectSpecification => '选取规格';
  @override
  String get estimatedDeliveryFee => '预估配送费';
  @override
  String get totalPrice => '总价';
  @override
  String get orderNow => '立即下单';
  @override
  String get clearCartConfirmMessage => '确定清空购物车吗？';
  @override
  String get removeItemConfirmMessage => '确定删除该商品吗？';
  @override
  String get cartTitle => '购物车';
  @override
  String get cartEmpty => '购物车为空';
  @override
  String get addToCartSuccess => '加入购物车成功';
  // ============== 业务文案 - 语言设置 ==============
  @override
  String get languageSettings => '语言设置';
  @override
  String get languageSystem => '跟随系统';
  @override
  String get languageChinese => '中文';
  @override
  String get languageEnglish => 'Englist';
  @override
  String get updateLanguageFailed => '更新语言失败';
  @override
  String get updateLanguageSuccess => '更新语言成功';
  // ============== Splash 启动页 ==============
  @override
  String get locationPermissionTitle => '需要位置权限';
  @override
  String get locationPermissionSubtitle => '为了给您提供更好的服务';
  @override
  String get findNearbyStores => '发现附近商家';
  @override
  String get findNearbyStoresDesc => '准确展示您身边的餐厅和优惠';
  @override
  String get calculateDeliveryDistance => '计算配送距离';
  @override
  String get calculateDeliveryDistanceDesc => '为您预估精准的配送费和送达时间';
  @override
  String get planBestRoute => '规划最佳路线';
  @override
  String get planBestRouteDesc => '帮助骑手更快地将美食送到您手中';
  @override
  String get goToSettings => '前往设置开启';
  @override
  String get returnAfterEnable => '开启后请返回应用继续使用';

  // ============== Home 首页 ==============
  @override
  String get searchHintHome => '想吃点什么?';
  @override
  String get noCategoryData => '暂无分类数据';
  @override
  String get noBannerData => '暂无Banner数据';
  @override
  String get noRestaurantData => '暂无甄选私厨数据';
  @override
  String get selectCurrentLocationHint => '选择当前位置';

  // ============== 地图选址 ==============
  @override
  String get mapSelectLocationTitle => '选择位置';
  @override
  String get mapConfirmLocation => '确定位置';
  @override
  String get mapSearchHint => '搜索地点或地址';
  @override
  String get mapResolvingAddress => '正在解析地址...';
  @override
  String get mapNoAddress => '未找到准确地址，请调整图钉位置';
  @override
  String get mapUseMyLocation => '使用当前位置';
  @override
  String get mapLocationServicesDisabled => '定位服务未开启，请先打开设备定位';
  @override
  String get mapLocationPermissionDenied => '定位权限被拒绝，请前往系统设置开启权限';
  @override
  String get mapLocationFetchFailed => '无法获取当前位置，请稍后再试';
  @override
  String get mapPlaceDetailFailed => '解析地点失败，请稍后重试';
  @override
  String get mapSearchFailed => '搜索失败，请检查网络后重试';
  @override
  String get mapSelectedLocationLabel => '选定位置';
  @override
  String mapCoordinateLabel(double latitude, double longitude) =>
      '纬度: ${latitude.toStringAsFixed(6)}\n经度: ${longitude.toStringAsFixed(6)}';

  // ============== Search 搜索页 ==============
  @override
  String get searchContentHint => '搜索内容';
  @override
  String get guessYouLike => '猜你喜欢';

  // ============== Detail 详情页 ==============
  @override
  String get merchantDetail => '商家详情';
  @override
  String get noShopDescription => '暂无店铺描述';
  @override
  String get unknownDistance => '距离未知';
  @override
  String get comments => '条评论';
  @override
  String get shopNotExist => '店铺信息不存在';
  @override
  String get noCoupon => '暂无优惠券';
  @override
  String get minSpend => '最低消费';
  @override
  String get claimCouponSuccess => '领取优惠券成功';
  @override
  String get claimCouponFailed => '领取优惠券失败';
  @override
  String get couponClaimLimitReached => '已经领取到上限';
  @override
  String get couponUse => '使用';
  @override
  String get couponUseNow => '去使用';
  @override
  String get couponUsed => '已使用';
  @override
  String get couponExpired => '已过期';

  // 星期相关
  @override
  String get today => '今天';
  @override
  String get monday => '周一';
  @override
  String get tuesday => '周二';
  @override
  String get wednesday => '周三';
  @override
  String get thursday => '周四';
  @override
  String get friday => '周五';
  @override
  String get saturday => '周六';
  @override
  String get sunday => '周日';
  @override
  String get other => '其他';

  // ============== Confirm Order 确认订单页 ==============
  @override
  String get confirmOrder => '确认订单';
  @override
  String get confirmOrderAddress => '请选择或添加配送地址';
  @override
  String get confirmOrderPrivateChef => '下单私厨';
  @override
  String get confirmOrderDeliveryTime => '选择配送时间';
  @override
  String get confirmOrderTodayNotDelivery => '今日不可配送';
  @override
  String get pleaseEnter0To100 => '请输入0-100之间的数字';
  @override
  String get pleaseEnterValidNumber => '请输入有效的数字';
  @override
  String get confirmOrderDistance => '距离';
  @override
  String get confirmOrderPlan => '计划';
  @override
  String get confirmOrderStartDelivery => '开始配送';
  @override
  String get confirmOrderMealDetail => '餐品详情';
  @override
  String get confirmOrderDeliveryTip => '配送小费';
  @override
  String get confirmOrderAvailableCoupons => '可用优惠券';
  @override
  String get confirmOrderEmptyCart => '购物车为空';
  @override
  String get confirmOrderSelectAddress => '请选择地址';
  @override
  String get confirmOrderSelectDeliveryTime => '请选择配送时间';
  @override
  String get confirmOrderDeliveryFee => '配送费';
  @override
  String get confirmOrderDeliveryFeeTip => '您的小费将全部给配送员';
  @override
  String get confirmOrderOrderAmount => '订单金额';
  @override
  String get confirmOrderMealSubtotal => '餐品小记';
  @override
  String get confirmOrderTaxAndServiceFee => '税费&服务费';
  @override
  String get confirmOrderCouponDiscount => '优惠券折扣';
  @override
  String get confirmOrderRemoveCoupon => '移除优惠券';
  @override
  String confirmOrderCouponThresholdNotMet(String minSpend) =>
      '需消费满 \$$minSpend 才可使用';
  @override
  String get confirmOrderCouponRemovedDueToThreshold => '优惠券因未达到使用门槛已自动移除';
  @override
  String get confirmOrderTotal => '合计';
  @override
  String get confirmOrderPaymentMethod => '支付方式';
  @override
  String get confirmOrderSelectPaymentMethod => '选择支付方式';
  @override
  String get addNewCard => '添加新卡';
  @override
  String get paymentMethodDefaultLabel => '默认';
  @override
  String get confirmOrderRemark => '备注（选填）';
  @override
  String confirmOrderSettlementTip(String value) => '含小费$value后的总价';
  @override
  String get confirmOrderSettlement => '结算';
  @override
  String get confirmOrderSyncCartFailed => '同步购物车失败，请稍后重试';
  @override
  String get confirmOrderInvalidCartItemPrice => '购物车存在无效商品（价格为空），请重新添加';
  @override
  String get confirmOrderInvalidCartItemId => '购物车存在无效商品（商品ID为空），请重新添加';
  @override
  String confirmOrderCreateOrderFailed(String error) => '创建订单失败: $error';
  @override
  String get confirmOrderConfirmPaymentTitle => '确认支付';
  @override
  String confirmOrderConfirmPaymentContent(String orderId) =>
      '确认支付订单 $orderId？';
  @override
  String get confirmOrderPaymentSuccess => '支付成功';
  @override
  String confirmOrderWalletPaymentFailed(String error) => '钱包支付失败: $error';
  @override
  String get confirmOrderPaymentIntentMissing =>
      '订单生成失败：缺少 clientSecret 或 publishableKey';
  @override
  String confirmOrderPaymentTitle(String orderNo) => '订单 $orderNo';
  @override
  String get confirmOrderPaymentCancelled => '取消支付';
  @override
  String confirmOrderPaymentFailed(String error) => '支付失败: $error';
  @override
  String confirmOrderPaymentError(String error) => '发生错误: $error';
  @override
  String confirmOrderCreatePaymentFailed(String error) => '创建支付失败: $error';
  @override
  String get confirmOrderInvalidPaymentMethodTitle => '支付卡片无效';
  @override
  String get confirmOrderInvalidPaymentMethodMessage =>
      '您选择的支付卡片已失效或不可用。\n\n'
      '可能的原因：\n'
      '• 卡片已过期\n'
      '• 卡片信息已变更\n'
      '• 卡片已被银行冻结\n\n'
      '建议您：\n'
      '1. 前往"管理支付方式"删除此卡片\n'
      '2. 重新添加新的银行卡\n'
      '3. 或使用钱包余额支付';
  @override
  String get confirmOrderInvalidPaymentMethodButton => '返回修改';

  // ============== Heart 收藏页 ==============
  @override
  String get noFavoriteText => '暂未收藏任何餐厅';
  @override
  String get goToShop => '去逛逛';

  // ============== Mine 我的页面 ==============
  @override
  String get profile => '个人资料';
  @override
  String get deliveryAddress => '收货地址';
  @override
  String get help => '获取帮助';
  @override
  String get accountSettings => '账号设置';
  @override
  String get privacyPolicy => '隐私政策';
  @override
  String get platformAgreement => '平台协议';
  @override
  String get logout => '退出登录';
  @override
  String get selectLanguage => '选择语言';
  @override
  String get confirmLogout => '确认退出登录';
  @override
  String get logoutConfirmMessage => '确定要退出登录吗？';
  @override
  String get wallet => '钱包';
  @override
  String get coupons => '优惠券';
  @override
  String get recharge => '去充值';
  @override
  String get shopEnter => '商家入驻';
  @override
  String get shopEnterDesc => '0元轻松入驻';

  // ============== 帮助页面 ==============
  @override
  String get helpShareFeedbackTitle => '分享你的反馈';
  @override
  String get helpShareFeedbackDescription =>
      '感谢您分享想法、提出问题或表达谢意。您可以通过以下方式联系到我们的用户支持团队。';
  @override
  String get helpSupportEmailLabel => '客服邮箱';
  @override
  String get helpSupportPhoneLabel => '客服电话';
  @override
  String get helpEmailCopiedToast => '客服邮箱已复制';
  @override
  String get helpDialerLaunchFailedToast => '无法打开拨号键盘，请稍后再试';

  // ============== ShopEnter 商家入驻页面 ==============
  @override
  String get shopEnterTitle => '入驻私厨商家';
  @override
  String get shopEnterProcess => '入驻流程';
  @override
  String get shopEnterDownloadApp => '下载商家端 App';
  @override
  String get shopEnterButtonDescription =>
      'App Store/Google Play下载 ChopChop Cooks';
  @override
  String get shopEnterRegisterAccount => '注册账号';
  @override
  String get shopEnterRegisterAccountDescription => '用手机号注册，填写基本信息';
  @override
  String get shopEnterApplyExam => '考证&申请';
  @override
  String get shopEnterApplyExamDescription =>
      '考取私厨证书，完成申请流程考取 food handler\'s certificate后在App内提交入驻申请';
  @override
  String get shopEnterDownloadButton => '下载 Chopchop Cooks';
  // ============== 业务文案 - 个人资料页 ==============
  @override
  String get avatar => '头像';
  @override
  String get nickname => '昵称';
  @override
  String get phone => '手机号';
  @override
  String get email => '邮箱';
  @override
  String get modifyNickname => '修改昵称';
  @override
  String get modifyPhone => '修改手机号';
  @override
  String get modifyEmail => '修改邮箱';
  @override
  String get modifyNicknameTips1 => '规范建议：';
  @override
  String get modifyNicknameTips2 => '昵称最多15个字符';
  @override
  String get modifyNicknameTips3 => '昵称可由中英文、数字及符号组成';
  @override
  String get modifyNicknameEmpty => '请输入昵称';
  @override
  String get modifyEmailEmpty => '请输入邮箱';
  @override
  String get modifyEmailInvalid => '邮箱格式不正确';
  @override
  String get modifyNoChange => '未做任何修改';
  @override
  String get modifySuccess => '修改成功';
  @override
  String get modifyFailed => '修改失败，请重试';
  @override
  String get modifyUserInfoMissing => '未获取到用户信息';
  @override
  String get modifyPhoneEmpty => '请输入手机号';
  @override
  String get modifyPhoneCodeEmpty => '请输入验证码';
  @override
  String get modifyPhoneNew => '新手机号';
  @override
  String get modifyPhoneCodeLabel => '验证码';
  @override
  String get modifyPhoneCodeHint => '请输入验证码';
  @override
  String modifyPhoneResend(int seconds) => '重新发送(${seconds}s)';
  @override
  String get modifyPhoneSendCode => '发送验证码';
  @override
  String get modifyPhoneFailed => '修改手机号失败，请重试';
  @override
  String get smsSendSuccess => '验证码已发送';
  @override
  String get smsSendFailed => '验证码发送失败，请稍后重试';
  @override
  String get btnSaving => '保存中...';
  @override
  String get avatarUploadSuccess => '头像上传成功';
  @override
  String get avatarUploadFailed => '头像上传失败，请重试';
  @override
  String get camera => '相机';
  @override
  String get gallery => '从相册或文件中选择';

  // ============== 业务文案 - 收货地址页 ==============
  @override
  String get address => '收货地址';
  @override
  String get addAddress => '新增收获地址';
  @override
  String get editAddress => '编辑收货地址';
  @override
  String get defaultAddress => '默认';
  @override
  String get addressRecipientNameLabel => '收货人姓名';
  @override
  String get addressPhoneNumberLabel => '电话号码';
  @override
  String get addressStreetLabel => '街道';
  @override
  String get addressStreetFixedValue => '1600 Amphitheatre Pkwy, Mountain View';
  @override
  String get addressDetailLabel => '建筑/公寓/楼层/单元（选填）';
  @override
  String get addressCityLabel => '城市';
  @override
  String get addressStateLabel => '州/省';
  @override
  String get addressZipCodeLabel => '邮政编码';
  @override
  String get addressSetDefaultToggle => '设置为默认地址';
  @override
  String get addressSelectStateSheetTitle => '选择城市/州';
  @override
  String get addressSelectStateHint => '请选择城市或州';
  @override
  String get addressSelectStateEmpty => '暂无可选城市/州';
  @override
  String get addressFormIncomplete => '请完善必填信息';
  @override
  String get addressCreateSuccess => '地址新增成功';
  @override
  String get addressUpdateSuccess => '地址更新成功';
  @override
  String get addressDeleteConfirmTitle => '删除地址';
  @override
  String get addressDeleteConfirmDescription => '确定要删除该收货地址吗？';
  @override
  String get addressDeleteSuccess => '地址删除成功';

  // ============== 钱包模块 ==============
  @override
  String get walletTitle => '钱包';
  @override
  String get walletBalance => '钱包余额';
  @override
  String get walletRecharge => '钱包充值';
  @override
  String get myWallet => '我的钱包';
  @override
  String get availableBalance => '可用余额';
  @override
  String get selectOrEnterRechargeAmount => '选择或输入充值金额';
  @override
  String get enterRechargeAmount => '请输入充值金额';
  @override
  String get balanceDetail => '余额明细';
  @override
  String get manageBoundCards => '管理绑定卡片';
  @override
  String get rechargeSuccess => '充值成功';
  @override
  String get rechargeFailed => '充值失败';
  @override
  String get complete => '完成';

  // ============== 通用文案 ==============
  @override
  String get loadingFailedWithError => '加载失败';
  @override
  String loadingFailedMessage(String error) => '加载失败: $error';

  // ============== 订单列表和详情 ==============
  @override
  String get orderNoOrders => '暂无订单';
  @override
  String get orderNoOrdersDesc => '去找找家的味道';
  @override
  String get orderExpired => '已过期';
  @override
  String orderExpiresIn(int minutes, int seconds) =>
      '剩余 $minutes 分 $seconds 秒过期';
  @override
  String get orderTotalItems => '共';
  @override
  String orderTotalQuantity(int quantity) => '共 $quantity 件';
  @override
  String get orderPayNow => '立即支付';
  @override
  String get orderCancelOrder => '取消订单';
  @override
  String get orderRequestRefund => '申请退款';
  @override
  String get orderWriteReview => '写评价';
  @override
  String get orderReorder => '再来一单';
  @override
  String get orderDeleteOrder => '删除订单';
  @override
  String get orderDeliveryAddress => '配送地址';
  @override
  String get orderChef => '私厨';
  @override
  String get orderOrderDetails => '订单详情';
  @override
  String get orderSubtotal => '小计';
  @override
  String get orderTaxAndServiceFee => '税费&服务费';
  @override
  String get orderDeliveryFee => '配送费';
  @override
  String get orderCouponDiscount => '优惠券折扣';
  @override
  String get orderActualPayment => '实付款';
  @override
  String orderActualPaymentWithTip(String tip) => '(含小费\$$tip)';
  @override
  String get orderOrderInfo => '订单信息';
  @override
  String get orderOrderNo => '订单编号';
  @override
  String get orderOrderTime => '下单时间';
  @override
  String get orderPaymentMethod => '支付方式';
  @override
  String orderDistance(double distance) => '距离${distance}km';
  @override
  String orderDeliveryTime(String time) => '计划 $time 开始配送';
  @override
  String orderCountdownTime(int minutes, int seconds) =>
      '$minutes分${seconds.toString().padLeft(2, '0')}秒';
  @override
  String get orderCountdownSuffix => ' 后失效';
  @override
  String get orderStatusDescDefault => '私厨已接单，待骑手接单';

  @override
  String get orderCancelReason => '取消原因：';
  @override
  String get orderCancelOrRefundTitle => '取消/退款';
  @override
  String get orderWhyRefund => '您为什么申请退款';
  @override
  String get orderWhyCancel => '您为什么取消订单';
  @override
  String get orderRefundReasonHint => '退款原因私厨不可见，您的选择会促使我们努力改善';
  @override
  String get orderCancelReasonHint => '取消原因私厨不可见，您的选择会促使我们努力改善';
  @override
  String get orderReasonCategoryChefProduct => '私厨/商品的原因';
  @override
  String get orderReasonCategoryPersonal => '我自己的原因';
  @override
  String get orderSelectRefundReason => '请选择退款原因';
  @override
  String get orderSelectCancelReason => '请选择取消原因';
  @override
  String get orderRefundSubmitted => '退款申请已提交';
  @override
  String get orderCancelled => '订单已取消';
  @override
  String orderRefundFailed(String error) => '申请退款失败: $error';
  @override
  String orderCancelFailed(String error) => '取消失败: $error';

  // ============== 消息中心 ==============
  @override
  String get messageCenter => '消息中心';
  @override
  String get messageTabAll => '全部';
  @override
  String get messageTabOrder => '订单消息';
  @override
  String get messageTabSystem => '系统消息';
  @override
  String get messageClearConfirmTitle => '确认清除';
  @override
  String get messageClearConfirmContent => '确定要清除所有消息吗？此操作不可恢复。';
  @override
  String get messageClearConfirmBtn => '确定';
  @override
  String get messageClearCancelBtn => '取消';
  @override
  String get messageNoData => '暂无消息';
  @override
  String get messageLoadFailed => '加载失败';
  @override
  String get messageRetry => '重试';
  @override
  String get messageYesterday => '昨天';

  // ============== 评论模块 ==============
  @override
  String get commentMerchantReply => '商家回复';
  @override
  String get commentRatingSuffix => '分';
  @override
  String get commentCount => '条评价';
  @override
  String get commentViewAll => '显示所有评价';
  @override
  String get commentNoReviews => '暂无评价';
  @override
  String get commentMaxImages => '最多上传4张图片';
  @override
  String get commentSelectRating => '请选择评分';
  @override
  String get commentSuccess => '评价成功';
  @override
  String get commentFailed => '评价失败，请重试';
  @override
  String get commentTitle => '评价';
  @override
  String get commentExperienceTitle => '您的此次用餐体验如何？';
  @override
  String get commentExperienceSubtitle => '喜欢你的食物吗？给私厨商家评分，您的意见很重要。';
  @override
  String get commentShareExperienceHint => '分享多方面的用餐体验，可以帮助更多用户哦';
  @override
  String get commentUploadImages => '上传图片\n(最多4张)';
  @override
  String get commentSubmit => '提交';
  @override
  String commentDaysAgo(int days) => '$days天前';
}
