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
  String get btnClose => 'Close';
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
  @override
  String get clearCartConfirmMessage =>
      'Are you sure you want to clear the cart?';
  @override
  String get cartTitle => 'Cart';
  @override
  String get cartEmpty => 'Cart is empty';
  @override
  String get addToCartSuccess => 'Add to Cart Success';
  @override
  String get noCoupon => 'No coupon';
  @override
  String get minSpend => 'Min Spend';
  @override
  String get claimCouponSuccess => 'Claim Coupon Success';
  @override
  String get claimCouponFailed => 'Claim Coupon Failed';
  @override
  String get couponClaimLimitReached => 'You have reached the claim limit';
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
  String get findNearbyStoresDesc =>
      'Discover restaurants and deals around you';
  @override
  String get calculateDeliveryDistance => 'Calculate Delivery Distance';
  @override
  String get calculateDeliveryDistanceDesc =>
      'Estimate accurate delivery fee and time';
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
  @override
  String get selectCurrentLocationHint => 'Select current location';

  // ============== 地图选址 ==============
  @override
  String get mapSelectLocationTitle => 'Choose Location';
  @override
  String get mapConfirmLocation => 'Confirm Location';
  @override
  String get mapSearchHint => 'Search places or address';
  @override
  String get mapResolvingAddress => 'Resolving address...';
  @override
  String get mapNoAddress => 'No detailed address found, please adjust the pin';
  @override
  String get mapUseMyLocation => 'Use current location';
  @override
  String get mapLocationServicesDisabled =>
      'Location services are disabled, please enable them first';
  @override
  String get mapLocationPermissionDenied =>
      'Location permission denied, please enable it in system settings';
  @override
  String get mapLocationFetchFailed =>
      'Failed to get current location, please try again later';
  @override
  String get mapPlaceDetailFailed =>
      'Failed to parse place, please try again later';
  @override
  String get mapSearchFailed => 'Search failed, please check your network';
  @override
  String get mapSelectedLocationLabel => 'Selected Location';
  @override
  String mapCoordinateLabel(double latitude, double longitude) =>
      'Latitude: ${latitude.toStringAsFixed(6)}\nLongitude: ${longitude.toStringAsFixed(6)}';

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
  @override
  String get shopEnter => 'Shop Enter';
  @override
  String get shopEnterDesc => '\$0 Easy Entry';

  // ============== Help Page ==============
  @override
  String get helpShareFeedbackTitle => 'Share Your Feedback';
  @override
  String get helpShareFeedbackDescription =>
      'Thank you for sharing ideas, reporting issues, or expressing appreciation. You can reach our support team using the contact options below.';
  @override
  String get helpSupportEmailLabel => 'Support Email';
  @override
  String get helpSupportPhoneLabel => 'Support Phone';
  @override
  String get helpEmailCopiedToast => 'Support email copied to clipboard';
  @override
  String get helpDialerLaunchFailedToast =>
      'Unable to open dialer. Please try again later.';

  // ============== ShopEnter 商家入驻页面 ==============
  @override
  String get shopEnterTitle => 'Shop Enter';
  @override
  String get shopEnterProcess => 'Shop Enter Process';
  @override
  String get shopEnterDownloadApp => 'Download Shop App';
  @override
  String get shopEnterButtonDescription =>
      'App Store/Google Play download ChopChop Cooks';
  @override
  String get shopEnterRegisterAccount => 'Register Account';
  @override
  String get shopEnterRegisterAccountDescription =>
      'Register with your phone number and fill in basic information';
  @override
  String get shopEnterApplyExam => 'Apply for Exam';
  @override
  String get shopEnterApplyExamDescription =>
      'Apply for food handler\'s certificate, complete the application process after obtaining the certificate';
  @override
  String get shopEnterDownloadButton => 'Download Chopchop Cooks';
  // ============== 业务文案 - 个人资料页 ==============
  @override
  String get avatar => 'Avatar';
  @override
  String get nickname => 'Nickname';
  @override
  String get phone => 'Phone';
  @override
  String get email => 'Email';
  @override
  String get modifyNickname => 'Modify Nickname';
  @override
  String get modifyPhone => 'Modify Phone';
  @override
  String get modifyEmail => 'Modify Email';
  @override
  String get modifyNicknameTips1 => 'Normative Suggestions:';
  @override
  String get modifyNicknameTips2 =>
      'Nickname can only contain up to 15 characters';
  @override
  String get modifyNicknameTips3 =>
      'Nickname can only contain English, numbers, and symbols';
  @override
  String get modifyNicknameEmpty => 'Please enter a nickname';
  @override
  String get modifyEmailEmpty => 'Please enter an email';
  @override
  String get modifyEmailInvalid => 'Please enter a valid email';
  @override
  String get modifyNoChange => 'Nothing changed';
  @override
  String get modifySuccess => 'Updated successfully';
  @override
  String get modifyFailed => 'Update failed, please try again';
  @override
  String get modifyUserInfoMissing => 'Failed to get user info';
  @override
  String get modifyPhoneEmpty => 'Please enter a phone number';
  @override
  String get modifyPhoneCodeEmpty => 'Please enter the verification code';
  @override
  String get modifyPhoneNew => 'New Phone Number';
  @override
  String get modifyPhoneCodeLabel => 'Verification Code';
  @override
  String get modifyPhoneCodeHint => 'Enter the code';
  @override
  String modifyPhoneResend(int seconds) => 'Resend (${seconds}s)';
  @override
  String get modifyPhoneSendCode => 'Send Code';
  @override
  String get modifyPhoneFailed => 'Failed to update phone, please retry';
  @override
  String get smsSendSuccess => 'Code sent';
  @override
  String get smsSendFailed => 'Failed to send code, please retry';
  @override
  String get btnSaving => 'Saving...';
  @override
  String get avatarUploadSuccess => 'Avatar updated';
  @override
  String get avatarUploadFailed => 'Failed to upload avatar, please retry';
  @override
  String get camera => 'Camera';
  @override
  String get gallery => 'Select from gallery or file';

  // ============== 业务文案 - 收货地址页 ==============
  @override
  String get address => 'Delivery Address';
  @override
  String get addAddress => 'Add Delivery Address';
  @override
  String get editAddress => 'Edit Delivery Address';
  @override
  String get defaultAddress => 'Default';
  @override
  String get addressRecipientNameLabel => 'Recipient Name';
  @override
  String get addressPhoneNumberLabel => 'Phone Number';
  @override
  String get addressStreetLabel => 'Street';
  @override
  String get addressStreetFixedValue => '1600 Amphitheatre Pkwy, Mountain View';
  @override
  String get addressDetailLabel =>
      'Building / Apartment / Floor / Unit (Optional)';
  @override
  String get addressCityLabel => 'City';
  @override
  String get addressStateLabel => 'State';
  @override
  String get addressZipCodeLabel => 'Postal Code';
  @override
  String get addressSetDefaultToggle => 'Set as default address';
  @override
  String get addressSelectStateSheetTitle => 'Select City / State';
  @override
  String get addressSelectStateHint => 'Please select a city or state';
  @override
  String get addressSelectStateEmpty => 'No city/state options available';
  @override
  String get addressFormIncomplete => 'Please complete all required fields';
  @override
  String get addressCreateSuccess => 'Address added successfully';
  @override
  String get addressUpdateSuccess => 'Address updated successfully';
  @override
  String get addressDeleteConfirmTitle => 'Delete Address';
  @override
  String get addressDeleteConfirmDescription =>
      'Are you sure you want to delete this delivery address?';
  @override
  String get addressDeleteSuccess => 'Address deleted successfully';

  // ============== 通用文案 ==============
  @override
  String get loadingFailedWithError => 'Loading failed';
  @override
  String loadingFailedMessage(String error) => 'Loading failed: $error';
}
