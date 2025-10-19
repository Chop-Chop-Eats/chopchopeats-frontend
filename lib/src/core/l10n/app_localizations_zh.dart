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
  
  // ============== 通用按钮 ==============
  @override
  String get btnConfirm => '确认';
  @override
  String get btnCancel => '取消';
  @override
  String get btnSave => '保存';
  @override
  String get btnDelete => '删除';
  @override
  String get btnEdit => '编辑';
  @override
  String get btnSearch => '搜索';
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
  
  // ============== 业务文案 - 语言设置 ==============
  @override
  String get languageSettings => '语言设置';
  @override
  String get languageSystem => '跟随系统';
  @override
  String get languageChinese => '中文';
  @override
  String get languageEnglish => 'English';
  
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
  
  // ============== 通用文案 ==============
  @override
  String get loadingFailedWithError => '加载失败';
  @override
  String loadingFailedMessage(String error) => '加载失败: $error';
}
