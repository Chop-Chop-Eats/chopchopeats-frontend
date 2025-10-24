import 'app_localizations.dart';

class AppLocalizationsEn implements AppLocalizations {
  @override
  String get appTitle => 'ChopChop';
  @override
  String get settings => 'Settings';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get themeDark => 'Dark Mode';
  @override
  String get themeLight => 'Light Mode';
  @override
  String get themeSystem => 'System Default';
  
  // ============== 底部导航 ==============
  @override
  String get tabHome => 'Home';
  @override
  String get tabHeart => 'Favorites';
  @override
  String get tabMessage => 'Messages';
  @override
  String get tabOrder => 'Orders';
  @override
  String get tabMine => 'Mine';
  
  // ============== 通用按钮 ==============
  @override
  String get btnConfirm => 'Confirm';
  @override
  String get btnCancel => 'Cancel';
  @override
  String get btnSave => 'Save';
  @override
  String get btnDelete => 'Delete';
  @override
  String get btnEdit => 'Edit';
  @override
  String get btnSearch => 'Search';
  @override
  String get btnClear => 'Clear';
  @override
  String get btnViewAll => 'View All';
  
  // ============== 提示信息 ==============
  @override
  String get loadingText => 'Loading...';
  @override
  String get noDataText => 'No Data';
  @override
  String get networkErrorText => 'Network Error, Please Try Again';
  @override
  String get emptyListText => 'Empty List';
  @override
  String get tryAgainText => 'Try Again';
  
  // ============== 业务文案 - 店铺相关 ==============
  @override
  String get distanceUnit => 'km';
  @override
  String get deliveryFee => 'Delivery Fee';
  @override
  String get operatingHours => 'Operating Hours';
  @override
  String get rating => 'Rating';
  @override
  String get newShop => 'New';
  @override
  String get hotProduct => 'Hot';
  @override
  String get favorite => 'Favorite';
  @override
  String get unfavorite => 'Unfavorite';
  
  // ============== 业务文案 - 分类相关 ==============
  @override
  String get allCategories => 'All Categories';
  @override
  String get selectedChef => 'Selected Chefs';
  
  // ============== 业务文案 - 搜索相关 ==============
  @override
  String get searchPlaceholder => 'Search shops or products';
  @override
  String get searchHistory => 'Search History';
  @override
  String get hotSearchKeywords => 'Hot Search';
  @override
  String get clearHistory => 'Clear History';
  
  // ============== 业务文案 - 详情页相关 ==============
  @override
  String get productDetail => 'Product Detail';
  @override
  String get shopIntroduction => 'Shop Introduction';
  @override
  String get addToCart => 'Add to Cart';
  @override
  String get selectSpec => 'Select Specification';
  @override
  String get stock => 'Stock';
  @override
  String get price => 'Price';
  @override
  String get newShopMark => 'New Shop';
  @override
  String get dailyMenu => 'Daily Menu';
  @override
  String get getCoupon => 'Get Coupon';
  @override
  String get selectSpecification => 'Select Specification';
  @override
  String get estimatedDeliveryFee => 'Estimated Delivery Fee';
  @override
  String get totalPrice => 'Total Price';
  @override
  String get orderNow => 'Order Now';

  // ============== 业务文案 - 语言设置 ==============
  @override
  String get languageSettings => 'Language Settings';
  @override
  String get languageSystem => 'Follow System';
  @override
  String get languageChinese => 'Chinese';
  @override
  String get languageEnglish => 'English';
  
  // ============== Splash 启动页 ==============
  @override
  String get locationPermissionTitle => 'Location Permission Required';
  @override
  String get locationPermissionSubtitle => 'To provide you with better service';
  @override
  String get findNearbyStores => 'Find Nearby Stores';
  @override
  String get findNearbyStoresDesc => 'Discover restaurants and deals around you';
  @override
  String get calculateDeliveryDistance => 'Calculate Delivery Distance';
  @override
  String get calculateDeliveryDistanceDesc => 'Estimate accurate delivery fee and time';
  @override
  String get planBestRoute => 'Plan Best Route';
  @override
  String get planBestRouteDesc => 'Help riders deliver food to you faster';
  @override
  String get goToSettings => 'Go to Settings';
  @override
  String get returnAfterEnable => 'Please return to the app after enabling';
  
  // ============== Home 首页 ==============
  @override
  String get searchHintHome => 'What would you like to eat?';
  @override
  String get noCategoryData => 'No categories available';
  @override
  String get noBannerData => 'No banners available';
  @override
  String get noRestaurantData => 'No restaurants available';
  
  // ============== Search 搜索页 ==============
  @override
  String get searchContentHint => 'Search content';
  @override
  String get guessYouLike => 'You May Like';
  
  // ============== Detail 详情页 ==============
  @override
  String get merchantDetail => 'Merchant Details';
  @override
  String get noShopDescription => 'No shop description';
  @override
  String get unknownDistance => 'Distance unknown';
  @override
  String get comments => 'comments';
  @override
  String get shopNotExist => 'Shop does not exist';
  
  // 星期相关
  @override
  String get today => 'Today';
  @override
  String get monday => 'Mon';
  @override
  String get tuesday => 'Tue';
  @override
  String get wednesday => 'Wed';
  @override
  String get thursday => 'Thu';
  @override
  String get friday => 'Fri';
  @override
  String get saturday => 'Sat';
  @override
  String get sunday => 'Sun';
  
  // ============== Heart 收藏页 ==============
  @override
  String get noFavoriteText => 'No favorite restaurants';
  @override
  String get goToShop => 'Go to shop';
  
  // ============== Mine 我的页面 ==============
  @override
  String get profile => 'Profile';
  @override
  String get deliveryAddress => 'Delivery Address';
  @override
  String get help => 'Help';
  @override
  String get accountSettings => 'Account Settings';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get platformAgreement => 'Platform Agreement';
  @override
  String get logout => 'Logout';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get confirmLogout => 'Confirm Logout';
  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';
  @override
  String get wallet => 'Wallet';
  @override
  String get coupons => 'Coupons';
  @override
  String get recharge => 'Recharge';
  
  // ============== 通用文案 ==============
  @override
  String get loadingFailedWithError => 'Loading failed';
  @override
  String loadingFailedMessage(String error) => 'Loading failed: $error';
}
