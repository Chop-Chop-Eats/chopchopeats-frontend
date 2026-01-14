# Firebase Cloud Messaging (FCM) 完整实现文档

本文档基于 Flutter FCM Demo 项目整理，详细说明了如何在 Flutter 项目中实现 Firebase 消息推送功能（包含站内和站外推送）。

## 目录

1. [环境要求与依赖版本](#环境要求与依赖版本)
2. [Firebase 项目配置](#firebase-项目配置)
3. [Android 平台配置](#android-平台配置)
4. [iOS 平台配置](#ios-平台配置)
5. [Flutter 代码实现](#flutter-代码实现)
6. [消息推送流程说明](#消息推送流程说明)
7. [测试与验证](#测试与验证)
8. [常见问题排查](#常见问题排查)

---

## 环境要求与依赖版本

### Flutter SDK 要求
- Flutter SDK: `>=3.0.0 <4.0.0`
- Dart SDK: `>=3.0.0 <4.0.0`

### 依赖包版本（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP 请求
  http: ^1.1.0
  
  # Firebase 核心
  firebase_core: ^2.24.2
  
  # Firebase Cloud Messaging
  firebase_messaging: ^14.7.9
  
  # 本地通知（用于前台消息显示）
  flutter_local_notifications: ^17.0.0
  
  # 权限处理
  permission_handler: ^11.3.0
  
  # 状态管理
  provider: ^6.1.1
  
  # 本地存储
  shared_preferences: ^2.2.2
  
  # 设备信息
  device_info_plus: ^9.1.1
  
  # UUID 生成器
  uuid: ^4.2.2
```

### Android 配置版本

- **Gradle**: 8.1.0
- **Kotlin**: 1.9.0
- **Google Services Plugin**: 4.4.0
- **compileSdkVersion**: 34
- **minSdkVersion**: 21
- **targetSdkVersion**: 34

---

## Firebase 项目配置

### 步骤 1: 创建 Firebase 项目

1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 点击"创建项目"或选择现有项目
3. 按照向导完成项目创建
4. 启用 **Cloud Messaging** 服务

### 步骤 2: 获取 SHA-1 证书指纹（Android 必需）

在项目根目录运行：

```bash
# macOS/Linux
cd android
./gradlew signingReport

# Windows (PowerShell)
cd android
.\gradlew signingReport
```

或者使用 keytool：

```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

找到 **SHA-1** 指纹，后续需要在 Firebase 控制台添加。

---

## Android 平台配置

### 步骤 1: 在 Firebase 控制台添加 Android 应用

1. 在 Firebase 项目概览页面，点击"添加应用"，选择 **Android** 图标
2. 填写应用信息：
   - **Android 包名**: 你的应用包名（如 `com.chopchop.chopuser`）
   - **应用昵称（可选）**: 应用显示名称
   - **调试签名证书 SHA-1**: 粘贴步骤 2 获取的 SHA-1 指纹
3. 点击"注册应用"

### 步骤 2: 下载并配置 google-services.json

1. 下载 `google-services.json` 文件
2. 将文件放置到以下位置：
   ```
   android/app/google-services.json
   ```
3. **重要**: 确保文件路径正确，文件名必须是 `google-services.json`

### 步骤 3: 配置项目级 build.gradle

文件路径: `android/build.gradle`

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // 添加 Google Services 插件
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 步骤 4: 配置应用级 build.gradle

文件路径: `android/app/build.gradle`

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    // 添加 Google Services 插件
    id "com.google.gms.google-services"
}

android {
    namespace "com.chopchop.chopuser"  // 替换为你的包名
    compileSdk 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.chopchop.chopuser"  // 替换为你的包名
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true  // 如果使用 multidex
    }
}
```

### 步骤 5: 配置 AndroidManifest.xml

文件路径: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.chopchop.chopuser">  <!-- 替换为你的包名 -->
    
    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <!-- Android 13+ 通知权限（必需） -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application
        android:label="你的应用名称"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"  <!-- 重要：singleTop 模式 -->
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- FCM 通知配置 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="@string/default_notification_channel_id" />
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 步骤 6: 创建通知图标资源

文件路径: `android/app/src/main/res/drawable/ic_notification.xml`

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#FFFFFF">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,22c1.1,0 2,-0.9 2,-2h-4c0,1.1 0.89,2 2,2zM18,16v-5c0,-3.07 -1.64,-5.64 -4.5,-6.32L13.5,4c0,-0.83 -0.67,-1.5 -1.5,-1.5s-1.5,0.67 -1.5,1.5v0.68C7.63,5.36 6,7.92 6,11v5l-2,2v1h16v-1l-2,-2z"/>
</vector>
```

### 步骤 7: 配置通知颜色和渠道

文件路径: `android/app/src/main/res/values/colors.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#2196F3</color>
</resources>
```

文件路径: `android/app/src/main/res/values/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_notification_channel_id">default_channel</string>
    <string name="default_notification_channel_name">Default Notifications</string>
</resources>
```

---

## iOS 平台配置

### 步骤 1: 在 Firebase 控制台添加 iOS 应用

1. 在 Firebase 项目中，点击"添加应用"，选择 **iOS** 图标
2. 填写应用信息：
   - **iOS 捆绑包 ID**: 你的应用 Bundle ID（如 `com.example.chopFcm`）
   - **应用昵称（可选）**: 应用显示名称
   - **App Store ID（可选）**: 留空
3. 点击"注册应用"

### 步骤 2: 下载并配置 GoogleService-Info.plist

1. 下载 `GoogleService-Info.plist` 文件
2. 使用 Xcode 将文件添加到项目：
   ```bash
   open ios/Runner.xcworkspace
   ```
3. 在 Xcode 中：
   - 右键点击 `Runner` 目录
   - 选择 "Add Files to Runner..."
   - 选择下载的 `GoogleService-Info.plist` 文件
   - **重要**: 确保勾选 "Copy items if needed" 和 "Runner" target
   - 文件应位于: `ios/Runner/GoogleService-Info.plist`

### 步骤 3: 配置推送通知能力

1. 在 Xcode 中选择 **Runner** target
2. 点击 **Signing & Capabilities** 标签
3. 点击 **+ Capability**
4. 添加以下能力：
   - **Push Notifications**
   - **Background Modes**（勾选 **Remote notifications**）

### 步骤 4: 上传 APNs 密钥（生产环境必需）

1. 访问 [Apple Developer](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 在 **Keys** 中创建新的 APNs 密钥
4. 下载密钥文件（.p8 格式）
5. 在 Firebase 控制台：
   - 进入项目设置
   - 选择 **Cloud Messaging** 标签
   - 上传 APNs 认证密钥

---

## Flutter 代码实现

### 步骤 1: 创建消息模型

文件路径: `lib/models/fcm_message.dart`

```dart
class FcmMessage {
  final String? messageId;
  final DateTime? sentTime;
  final String? title;
  final String? body;
  final String? fcmMessageId;
  final String? messageTypeId;
  final String? messageTypeName;
  final String? contentType;
  final int? status;
  final DateTime? readTime;
  final Map<String, dynamic>? customData;

  FcmMessage({
    this.messageId,
    this.sentTime,
    this.title,
    this.body,
    this.fcmMessageId,
    this.messageTypeId,
    this.messageTypeName,
    this.contentType,
    this.status,
    this.readTime,
    this.customData,
  });

  // 从 FCM 推送消息创建
  factory FcmMessage.fromRemoteMessage(
      Map<String, dynamic> data, String? fcmMsgId, DateTime? time) {
    // 提取自定义数据（排除已知的标准字段）
    final customData = <String, dynamic>{};
    final standardKeys = {
      'title',
      'body',
      'messageId',
      'messageTypeId',
      'contentType'
    };

    data.forEach((key, value) {
      if (!standardKeys.contains(key)) {
        customData[key] = value;
      }
    });

    return FcmMessage(
      messageId: data['messageId'],
      sentTime: time,
      title: data['title'],
      body: data['body'],
      fcmMessageId: fcmMsgId,
      messageTypeId: data['messageTypeId'],
      contentType: data['contentType'],
      customData: customData.isNotEmpty ? customData : null,
    );
  }

  // 从服务器 API 数据创建
  factory FcmMessage.fromJson(Map<String, dynamic> json) {
    DateTime? sentTime;
    if (json['sentTime'] != null) {
      sentTime = DateTime.fromMillisecondsSinceEpoch(json['sentTime']);
    }

    DateTime? readTime;
    if (json['readTime'] != null) {
      readTime = DateTime.fromMillisecondsSinceEpoch(json['readTime']);
    }

    final customData = <String, dynamic>{};
    if (json['extension'] != null) {
      customData['extension'] = json['extension'];
    }

    return FcmMessage(
      messageId: json['id'],
      sentTime: sentTime,
      title: json['title'],
      body: json['body'],
      messageTypeId: json['messageTypeId']?.toString(),
      messageTypeName: json['messageTypeName'],
      contentType: json['messageContentType'],
      status: json['status'],
      readTime: readTime,
      customData: customData.isNotEmpty ? customData : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'sentTime': sentTime?.toIso8601String(),
      'title': title,
      'body': body,
      'fcmMessageId': fcmMessageId,
      'messageTypeId': messageTypeId,
      'contentType': contentType,
      'customData': customData,
    };
  }

  @override
  String toString() {
    return 'FcmMessage(messageId: $messageId, title: $title, body: $body, contentType: $contentType)';
  }
}
```

### 步骤 2: 创建 FCM 服务

文件路径: `lib/services/fcm_service.dart`

```dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fcm_message.dart';
import '../screens/message_detail_screen.dart';
import '../main.dart';
import 'api_service.dart';

// 后台消息处理函数（必须是顶层函数）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('处理后台消息: ${message.messageId}');
  debugPrint('消息数据: ${message.data}');
}

class FcmService extends ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();
  final List<FcmMessage> _messages = [];
  String? _fcmToken;

  List<FcmMessage> get messages => List.unmodifiable(_messages);
  String? get fcmToken => _fcmToken;

  // 初始化FCM
  Future<void> initialize() async {
    try {
      // 初始化本地通知
      await _initializeLocalNotifications();

      // Android 13+ 请求通知权限
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        debugPrint('通知权限状态: $status');

        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.notification.request();
          debugPrint('请求通知权限结果: $result');

          if (result.isDenied || result.isPermanentlyDenied) {
            debugPrint('⚠️ 用户拒绝了通知权限');
          }
        }
      }

      // 请求通知权限
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('用户授予了通知权限');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('用户授予了临时通知权限');
      } else {
        debugPrint('用户拒绝了通知权限');
        return;
      }

      // 获取FCM Token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // 监听Token刷新
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token已刷新: $newToken');
        // Token刷新后重新注册
        registerToken();
      });

      // 设置前台消息处理选项（仅iOS）
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 监听前台消息
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 监听消息点击（应用在后台时）
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 检查是否从通知启动应用
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      debugPrint('FCM初始化完成');
    } catch (e) {
      debugPrint('FCM初始化失败: $e');
    }
  }

  // 处理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('收到前台消息: ${message.messageId}');
    debugPrint('消息数据: ${message.data}');

    final fcmMessage = FcmMessage.fromRemoteMessage(
      message.data,
      message.messageId,
      message.sentTime,
    );

    _messages.insert(0, fcmMessage);
    notifyListeners();

    // 在前台显示本地通知
    // 优先使用 notification 字段，如果没有则使用 data 字段
    final title = message.notification?.title ?? message.data['title'] ?? '新消息';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    _showLocalNotification(
      title: title,
      body: body,
      payload: message.messageId,
    );
  }

  // 处理消息点击
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('用户点击了消息: ${message.messageId}');
    debugPrint('消息数据: ${message.data}');

    final fcmMessage = FcmMessage.fromRemoteMessage(
      message.data,
      message.messageId,
      message.sentTime,
    );

    // 检查是否已存在
    bool exists =
        _messages.any((msg) => msg.fcmMessageId == fcmMessage.fcmMessageId);
    if (!exists) {
      _messages.insert(0, fcmMessage);
      notifyListeners();
    }

    // 跳转到消息详情页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => MessageDetailScreen(message: fcmMessage),
          ),
        );
      }
    });
  }

  // 注册FCM Token到服务器
  Future<bool> registerToken() async {
    try {
      if (_fcmToken == null) {
        debugPrint('FCM Token为空，无法注册');
        return false;
      }

      // 获取设备信息
      final deviceInfo = await _getDeviceInfo();

      await _apiService.registerFcmToken(
        deviceId: deviceInfo['deviceId']!,
        token: _fcmToken!,
        platform: deviceInfo['platform']!,
        appVersion: deviceInfo['appVersion']!,
        deviceModel: deviceInfo['deviceModel']!,
      );

      debugPrint('FCM Token注册成功');
      return true;
    } catch (e) {
      debugPrint('FCM Token注册失败: $e');
      return false;
    }
  }

  // 获取设备信息
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final prefs = await SharedPreferences.getInstance();

    // 获取或生成设备ID
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }

    String platform;
    String deviceModel;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      platform = 'android';
      deviceModel = '${androidInfo.brand} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      platform = 'ios';
      deviceModel = iosInfo.model;
    } else {
      platform = 'unknown';
      deviceModel = 'unknown';
    }

    return {
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': '1.0.0',
      'deviceModel': deviceModel,
    };
  }

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('本地通知初始化完成');
  }

  // 显示本地通知
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      debugPrint('========================================');
      debugPrint('准备显示通知:');
      debugPrint('标题: $title');
      debugPrint('内容: $body');
      debugPrint('========================================');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'order_channel',
        '订单通知',
        channelDescription: '订单相关的重要通知',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _localNotifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✅ 通知已发送，ID: $notificationId');

      // 检查通知权限状态
      if (Platform.isAndroid) {
        final hasPermission = await Permission.notification.isGranted;
        debugPrint('当前通知权限状态: $hasPermission');
      }
    } catch (e) {
      debugPrint('❌ 显示通知失败: $e');
    }
  }

  // 处理通知点击
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('通知被点击: ${response.payload}');
    // 可以根据 payload 跳转到对应页面
  }

  // 清空消息列表
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // 删除单条消息
  void removeMessage(FcmMessage message) {
    _messages.remove(message);
    notifyListeners();
  }

  // 从服务器加载消息列表
  Future<void> loadMessagesFromServer() async {
    try {
      final messages = await _apiService.getMessageList();
      _messages.clear();
      _messages.addAll(messages);
      notifyListeners();
      debugPrint('从服务器加载了 ${messages.length} 条消息');
    } catch (e) {
      debugPrint('加载消息列表失败: $e');
      rethrow;
    }
  }
}
```

### 步骤 3: 创建 FCM Provider

文件路径: `lib/providers/fcm_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../services/fcm_service.dart';

/// 全局 FCM 服务单例
class FcmProvider with ChangeNotifier {
  static final FcmProvider _instance = FcmProvider._internal();
  factory FcmProvider() => _instance;
  FcmProvider._internal();

  FcmService? _fcmService;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  FcmService? get fcmService => _fcmService;

  /// 初始化 FCM 服务（应用启动时调用一次）
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('FCM 已经初始化');
      return;
    }

    try {
      _fcmService = FcmService();
      await _fcmService!.initialize();
      _isInitialized = true;
      notifyListeners();
      debugPrint('FCM 初始化成功');
    } catch (e) {
      debugPrint('FCM 初始化失败: $e');
      rethrow;
    }
  }

  /// 注册 FCM Token 到服务器（登录成功后调用）
  Future<bool> registerToken() async {
    if (!_isInitialized || _fcmService == null) {
      debugPrint('FCM 未初始化，无法注册 Token');
      return false;
    }

    try {
      final success = await _fcmService!.registerToken();
      if (success) {
        debugPrint('FCM Token 注册成功');
      } else {
        debugPrint('FCM Token 注册失败');
      }
      return success;
    } catch (e) {
      debugPrint('注册 FCM Token 时出错: $e');
      return false;
    }
  }

  /// 获取当前 FCM Token
  String? get fcmToken => _fcmService?.fcmToken;
}
```

### 步骤 4: 配置 main.dart

文件路径: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'services/fcm_service.dart';
import 'providers/fcm_provider.dart';

// 全局导航键（用于从通知跳转）
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 后台消息处理器（必须在顶层）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp();

  // 设置后台消息处理器
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 初始化 FCM 服务
  try {
    await FcmProvider().initialize();
  } catch (e) {
    debugPrint('FCM 初始化失败: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM Demo',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 全局导航键
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
```

### 步骤 5: 在登录成功后注册 Token

在登录成功后的回调中调用：

```dart
// 登录成功后
if (response['code'] == 0 || response['code'] == 200) {
  // 注册 FCM Token 到服务器
  try {
    final success = await FcmProvider().registerToken();
    if (success) {
      debugPrint('FCM Token 已注册到服务器');
    }
  } catch (e) {
    debugPrint('注册 FCM Token 时出错: $e');
  }
  
  // 跳转到主页面
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const MessageListScreen(),
    ),
  );
}
```

### 步骤 6: 创建 API 服务（用于 Token 注册）

文件路径: `lib/services/api_service.dart`

需要实现 `registerFcmToken` 方法，将 FCM Token 发送到服务器：

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  // 获取存储的token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 注册FCM token
  Future<Map<String, dynamic>> registerFcmToken({
    required String deviceId,
    required String token,
    required String platform,
    required String appVersion,
    required String deviceModel,
  }) async {
    try {
      final authToken = await getToken();
      final url =
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerToken}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'deviceId': deviceId,
          'token': token,
          'platform': platform,
          'appVersion': appVersion,
          'deviceModel': deviceModel,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('注册Token失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('注册Token失败: $e');
    }
  }
}
```

文件路径: `lib/utils/constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'https://dev-api.chopchopeats.org';

  // Message endpoints
  static const String registerToken = '/app-api/message/register-token';
  static const String messageInbox = '/app-api/message/inbox/page';
}
```

---

## 消息推送流程说明

### 消息类型

FCM 支持两种消息格式：

1. **通知消息（Notification Message）**: 包含 `notification` 字段，系统会自动显示通知
2. **数据消息（Data Message）**: 只包含 `data` 字段，需要应用自行处理

### 推送场景

#### 场景 1: 应用在前台（Foreground）

1. 消息通过 `FirebaseMessaging.onMessage` 监听接收
2. 应用使用 `flutter_local_notifications` 显示本地通知
3. 用户点击通知后，通过 `onDidReceiveNotificationResponse` 处理跳转

**代码流程**:
```dart
FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
// → _handleForegroundMessage() 处理消息
// → _showLocalNotification() 显示本地通知
// → 用户点击通知 → _onNotificationTapped() 处理点击
```

#### 场景 2: 应用在后台（Background）

1. 系统自动显示通知（如果包含 `notification` 字段）
2. 用户点击通知后，应用启动或切换到前台
3. 通过 `FirebaseMessaging.onMessageOpenedApp` 监听处理跳转

**代码流程**:
```dart
FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
// → _handleMessageOpenedApp() 处理消息点击
// → 跳转到消息详情页面
```

#### 场景 3: 应用已终止（Terminated）

1. 系统自动显示通知（如果包含 `notification` 字段）
2. 用户点击通知后，应用启动
3. 通过 `FirebaseMessaging.getInitialMessage()` 获取初始消息
4. 处理消息跳转

**代码流程**:
```dart
RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
if (initialMessage != null) {
  _handleMessageOpenedApp(initialMessage);
}
```

### 消息数据格式

服务器推送的消息应包含以下字段：

```json
{
  "notification": {
    "title": "消息标题",
    "body": "消息内容"
  },
  "data": {
    "title": "消息标题",
    "body": "消息内容",
    "messageId": "消息ID",
    "messageTypeId": "消息类型ID",
    "contentType": "内容类型",
    "orderId": "订单ID",
    "shopId": "店铺ID"
  }
}
```

**重要说明**: 
- `notification` 字段用于系统显示通知（应用在后台或终止时）
- `data` 字段用于应用处理业务逻辑（所有场景）
- **建议同时包含两个字段**，以确保所有场景下都能正常工作
- `data` 字段中的值必须是字符串类型

### 站内推送 vs 站外推送

**站内推送（应用在前台）**:
- 通过 `FirebaseMessaging.onMessage` 接收
- 使用 `flutter_local_notifications` 显示本地通知
- 可以立即更新应用内的消息列表

**站外推送（应用在后台或终止）**:
- 系统自动显示通知（如果包含 `notification` 字段）
- 用户点击后通过 `onMessageOpenedApp` 或 `getInitialMessage` 处理
- 可以跳转到指定页面

---

## 测试与验证

### 步骤 1: 安装依赖

```bash
flutter pub get
```

### 步骤 2: 运行应用

```bash
# Android
flutter run

# iOS
flutter run
```

### 步骤 3: 获取 FCM Token

1. 应用启动后，在日志中查找 FCM Token
2. 或者在应用中显示 Token（用于测试）
3. Token 格式类似: `cXyZ123...`

**查看日志方法**:
```bash
# Android
adb logcat | grep "FCM Token"

# iOS
# 在 Xcode 控制台查看
```

### 步骤 4: 在 Firebase Console 发送测试消息

1. 进入 [Firebase Console](https://console.firebase.google.com/)
2. 选择你的项目
3. 在左侧菜单选择 **Cloud Messaging**（或 **Engage** > **Cloud Messaging**）
4. 点击 **发送第一条消息** 或 **新建通知**
5. 填写通知内容：
   - **通知标题**: 测试标题
   - **通知文本**: 测试内容
6. 点击 **下一步**
7. 选择 **发送测试消息**
8. 输入 FCM Token（从步骤 3 获取）
9. 点击 **测试**

### 步骤 5: 添加自定义数据（可选）

在 Firebase Console 中发送测试消息时，可以添加自定义数据：

1. 在消息编辑页面，展开 **其他选项**
2. 在 **自定义数据** 中添加键值对：
   ```
   key: title, value: 新订单通知
   key: body, value: 您有一笔新订单
   key: messageId, value: test123
   key: messageTypeId, value: 1
   key: contentType, value: 订单消息
   key: orderId, value: ORDER123
   key: shopId, value: SHOP456
   ```
3. 点击 **测试**

### 步骤 6: 验证不同场景

#### 前台测试
1. 保持应用在前台运行
2. 发送测试消息
3. **预期结果**: 
   - 应用应显示本地通知
   - 消息应添加到消息列表
   - 控制台应输出 "收到前台消息"

#### 后台测试
1. 将应用切换到后台（按 Home 键）
2. 发送测试消息
3. **预期结果**: 
   - 系统应显示通知
   - 点击通知后，应用应启动并跳转到消息详情页面

#### 终止测试
1. 完全关闭应用（从任务管理器移除）
2. 发送测试消息
3. **预期结果**: 
   - 系统应显示通知
   - 点击通知后，应用应启动
   - 应用应处理初始消息并跳转到相应页面

---

## 常见问题排查

### 问题 1: Android 无法接收消息

**检查清单**:
- [ ] `google-services.json` 文件是否正确放置在 `android/app/` 目录
- [ ] `build.gradle` 文件是否正确配置 Google Services 插件
- [ ] AndroidManifest.xml 中是否添加了通知权限
- [ ] 应用是否已授予通知权限（Android 13+）
- [ ] Firebase 项目中的包名是否与 `applicationId` 一致
- [ ] SHA-1 证书指纹是否已添加到 Firebase 项目
- [ ] 是否重新构建了应用（`flutter clean && flutter build apk`）

**调试方法**:
```bash
# 查看日志
flutter logs

# 检查 FCM Token 是否获取成功
# 在应用日志中查找 "FCM Token:"

# 检查 Google Services 配置
# 查看 android/app/google-services.json 文件是否存在且正确
```

**常见错误**:
- `MissingPluginException`: 需要运行 `flutter clean && flutter pub get`
- `Default FirebaseApp is not initialized`: 检查 `google-services.json` 是否正确配置
- `Token is null`: 检查网络连接和权限

### 问题 2: iOS 无法接收消息

**检查清单**:
- [ ] `GoogleService-Info.plist` 是否正确添加到 Xcode 项目
- [ ] 是否在 Xcode 中配置了 Push Notifications 能力
- [ ] 是否在 Xcode 中配置了 Background Modes（Remote notifications）
- [ ] 是否已上传 APNs 认证密钥到 Firebase（生产环境必需）
- [ ] iOS 设备上的通知权限是否已授予
- [ ] Bundle ID 是否与 Firebase 项目中的一致
- [ ] 是否使用真机测试（模拟器不支持推送）

**调试方法**:
```bash
# 查看日志
flutter logs

# 在 Xcode 中查看控制台输出
# 确保在真机上测试，模拟器不支持推送通知
```

**常见错误**:
- `No valid 'aps-environment' entitlement`: 需要在 Xcode 中配置 Push Notifications 能力
- `APNs token not retrieved`: 检查 APNs 密钥是否已上传到 Firebase

### 问题 3: Token 为 null

**可能原因**:
- Firebase 初始化未完成
- 网络连接问题
- 权限未授予
- Google Services 配置错误

**解决方法**:
1. 确保在 `main()` 中正确初始化 Firebase
2. 等待初始化完成后再获取 Token（添加延迟或使用 Future）
3. 检查网络连接
4. 确保已授予通知权限
5. 检查 `google-services.json` 或 `GoogleService-Info.plist` 是否正确

**调试代码**:
```dart
// 在 initialize() 方法中添加延迟
await Future.delayed(Duration(seconds: 2));
_fcmToken = await _firebaseMessaging.getToken();
```

### 问题 4: 前台消息不显示通知

**可能原因**:
- 本地通知未正确初始化
- 通知权限未授予
- 通知渠道配置错误（Android）
- 通知 ID 冲突

**解决方法**:
1. 检查 `_initializeLocalNotifications()` 是否已调用
2. 确保已授予通知权限
3. 检查 Android 通知渠道配置
4. 确保通知 ID 唯一（使用时间戳）

**调试代码**:
```dart
// 检查通知权限
if (Platform.isAndroid) {
  final hasPermission = await Permission.notification.isGranted;
  debugPrint('通知权限状态: $hasPermission');
}
```

### 问题 5: 点击通知无法跳转

**可能原因**:
- 全局导航键未设置
- 消息处理逻辑错误
- 应用未正确处理 `onMessageOpenedApp`
- 应用启动时未检查 `getInitialMessage()`

**解决方法**:
1. 确保在 `MaterialApp` 中设置了 `navigatorKey`
2. 检查 `_handleMessageOpenedApp` 方法实现
3. 确保在应用启动时检查 `getInitialMessage()`
4. 使用 `WidgetsBinding.instance.addPostFrameCallback` 确保导航在框架准备好后执行

**调试代码**:
```dart
void _handleMessageOpenedApp(RemoteMessage message) {
  debugPrint('用户点击了消息: ${message.messageId}');
  debugPrint('消息数据: ${message.data}');
  
  // 添加延迟确保导航键已准备好
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigatorKey.currentContext != null) {
      // 执行导航
    }
  });
}
```

### 问题 6: 后台消息处理失败

**检查清单**:
- [ ] 后台消息处理函数必须是顶层函数（不在类内部）
- [ ] 函数必须使用 `@pragma('vm:entry-point')` 注解
- [ ] 在函数中必须重新初始化 Firebase
- [ ] 函数必须在 `main()` 中注册（在 `runApp()` 之前）

**正确示例**:
```dart
// 在文件顶层定义（不在类内部）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('处理后台消息: ${message.messageId}');
  debugPrint('消息数据: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // 必须在 runApp() 之前注册
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}
```

### 问题 7: Token 刷新后未重新注册

**解决方法**:
确保在 `onTokenRefresh` 监听器中调用 `registerToken()`:

```dart
_firebaseMessaging.onTokenRefresh.listen((newToken) {
  _fcmToken = newToken;
  debugPrint('FCM Token已刷新: $newToken');
  // Token刷新后重新注册
  registerToken();
});
```

### 问题 8: Android 通知渠道配置问题

**解决方法**:
1. 确保在 `AndroidManifest.xml` 中配置了通知渠道 ID
2. 确保本地通知使用的渠道 ID 与配置一致
3. Android 8.0+ 必须使用通知渠道

**检查代码**:
```dart
// 确保渠道 ID 一致
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'order_channel',  // 渠道 ID
  '订单通知',
  channelDescription: '订单相关的重要通知',
  // ...
);
```

---

## 版本兼容性说明

### Flutter 版本
- **最低支持**: Flutter 3.0.0
- **推荐使用**: Flutter 3.x 最新稳定版
- **测试版本**: Flutter 3.19.0

### Dart 版本
- **最低支持**: Dart 3.0.0
- **推荐使用**: Dart 3.x 最新稳定版

### Android 版本
- **最低支持**: Android 5.0 (API 21)
- **推荐目标**: Android 14 (API 34)
- **测试版本**: Android 13 (API 33)

### iOS 版本
- **最低支持**: iOS 12.0
- **推荐目标**: iOS 17.0+
- **测试版本**: iOS 16.0

### 依赖包版本锁定

为确保稳定性，建议锁定以下关键依赖版本：

```yaml
dependencies:
  firebase_core: 2.24.2
  firebase_messaging: 14.7.9
  flutter_local_notifications: 17.0.0
  permission_handler: 11.3.0
  device_info_plus: 9.1.1
  shared_preferences: 2.2.2
  uuid: 4.2.2
  http: 1.1.0
  provider: 6.1.1
```

### Android 构建工具版本

- **Gradle**: 8.1.0
- **Kotlin**: 1.9.0
- **Google Services Plugin**: 4.4.0
- **Android Gradle Plugin**: 8.1.0

---

## 服务器端推送示例

### 使用 Firebase Admin SDK (Node.js)

#### 安装依赖

```bash
npm install firebase-admin
```

#### 初始化 Firebase Admin

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

// 初始化 Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
```

#### 发送通知消息

```javascript
// 发送通知消息
async function sendNotification(token, data) {
  const message = {
    token: token,
    notification: {
      title: data.title,
      body: data.body,
    },
    data: {
      title: data.title,
      body: data.body,
      messageId: data.messageId || '',
      messageTypeId: data.messageTypeId || '',
      contentType: data.contentType || '',
      orderId: data.orderId || '',
      shopId: data.shopId || '',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'order_channel',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('成功发送消息:', response);
    return response;
  } catch (error) {
    console.error('发送消息失败:', error);
    throw error;
  }
}

// 使用示例
sendNotification('FCM_TOKEN_HERE', {
  title: '新订单通知',
  body: '您有一笔新订单',
  messageId: 'MSG123',
  messageTypeId: '1',
  contentType: '订单消息',
  orderId: 'ORDER123',
  shopId: 'SHOP456',
});
```

#### 批量发送消息

```javascript
// 批量发送消息
async function sendMulticast(tokens, data) {
  const message = {
    notification: {
      title: data.title,
      body: data.body,
    },
    data: {
      title: data.title,
      body: data.body,
      messageId: data.messageId || '',
      messageTypeId: data.messageTypeId || '',
      contentType: data.contentType || '',
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'order_channel',
        sound: 'default',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
        },
      },
    },
    tokens: tokens, // 最多 500 个 token
  };

  try {
    const response = await admin.messaging().sendMulticast(message);
    console.log(`成功发送 ${response.successCount} 条消息`);
    console.log(`失败 ${response.failureCount} 条消息`);
    return response;
  } catch (error) {
    console.error('批量发送失败:', error);
    throw error;
  }
}
```

### 使用 HTTP v1 API

#### 获取访问令牌

```bash
# 使用 gcloud CLI 获取访问令牌
gcloud auth print-access-token

# 或使用服务账号密钥
gcloud auth activate-service-account --key-file=serviceAccountKey.json
gcloud auth print-access-token
```

#### 发送消息

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "FCM_TOKEN",
      "notification": {
        "title": "测试标题",
        "body": "测试内容"
      },
      "data": {
        "title": "测试标题",
        "body": "测试内容",
        "messageId": "123",
        "messageTypeId": "1",
        "contentType": "测试消息"
      },
      "android": {
        "priority": "high",
        "notification": {
          "channelId": "order_channel",
          "sound": "default"
        }
      },
      "apns": {
        "payload": {
          "aps": {
            "sound": "default"
          }
        }
      }
    }
  }'
```

### 使用 Python

```python
from firebase_admin import credentials, messaging, initialize_app

# 初始化
cred = credentials.Certificate('path/to/serviceAccountKey.json')
initialize_app(cred)

# 发送消息
def send_notification(token, data):
    message = messaging.Message(
        token=token,
        notification=messaging.Notification(
            title=data['title'],
            body=data['body'],
        ),
        data={
            'title': data['title'],
            'body': data['body'],
            'messageId': data.get('messageId', ''),
            'messageTypeId': data.get('messageTypeId', ''),
            'contentType': data.get('contentType', ''),
        },
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                channel_id='order_channel',
                sound='default',
            ),
        ),
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(sound='default'),
            ),
        ),
    )
    
    try:
        response = messaging.send(message)
        print(f'成功发送消息: {response}')
        return response
    except Exception as e:
        print(f'发送消息失败: {e}')
        raise
```

---

## 总结

本文档详细说明了 Flutter 项目中 Firebase Cloud Messaging 的完整实现流程，包括：

1. ✅ **环境配置和依赖版本** - 详细的版本信息和依赖配置
2. ✅ **Firebase 项目配置** - 从创建项目到获取证书指纹的完整步骤
3. ✅ **Android 平台完整配置** - 7 个详细步骤，包含所有必要的配置文件
4. ✅ **iOS 平台完整配置** - 4 个详细步骤，包含 Xcode 配置和 APNs 设置
5. ✅ **Flutter 代码实现细节** - 6 个步骤，包含完整的代码示例
6. ✅ **消息推送流程说明** - 详细解释三种推送场景和消息格式
7. ✅ **测试验证方法** - 6 个步骤的完整测试流程
8. ✅ **常见问题排查** - 8 个常见问题的详细解决方案
9. ✅ **版本兼容性说明** - 完整的版本要求和兼容性信息
10. ✅ **服务器端推送示例** - Node.js、HTTP API 和 Python 的完整示例

### 关键要点

1. **权限配置**: Android 13+ 和 iOS 都需要正确配置通知权限
2. **后台消息处理**: 必须是顶层函数，使用 `@pragma('vm:entry-point')` 注解
3. **消息格式**: 建议同时包含 `notification` 和 `data` 字段
4. **Token 管理**: 需要在登录成功后注册 Token，并监听 Token 刷新
5. **导航处理**: 使用全局导航键处理从通知跳转的场景

### 实施建议

1. **按步骤实施**: 严格按照文档顺序进行配置，不要跳过任何步骤
2. **测试验证**: 每个步骤完成后进行测试，确保功能正常
3. **错误处理**: 添加完善的错误处理和日志记录
4. **版本锁定**: 使用文档中指定的版本，避免兼容性问题

按照本文档步骤操作，即可在其他项目中成功集成 Firebase 消息推送功能。

---

**文档版本**: 1.0  
**最后更新**: 2024年  
**基于项目**: Flutter FCM Demo  
**适用 Flutter 版本**: >=3.0.0 <4.0.0