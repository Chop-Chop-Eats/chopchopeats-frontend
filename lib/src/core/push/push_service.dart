import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/message/models/message_models.dart';
import '../../features/message/services/message_services.dart';
import '../config/app_services.dart';
import '../routing/routes.dart';
import '../utils/logger/logger.dart';

// 后台消息处理函数（必须是顶层函数）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger.info("PushService", "🔔 后台消息收到: ${message.messageId}");
  Logger.info("PushService", "消息通知字段: title=${message.notification?.title}, body=${message.notification?.body}");
  Logger.info("PushService", "消息数据字段: ${message.data}");
  // 注意：此处无法直接更新 UI，但可以保存数据到本地存储
  // 系统会自动显示通知（如果包含 notification 字段）
}

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 初始化
  Future<void> init() async {
    try {
      // 检查 Firebase 是否已初始化
      try {
        Firebase.app(); // 如果 Firebase 未初始化，这里会抛出异常
        _fcm = FirebaseMessaging.instance;
      } catch (e) {
        Logger.warn("PushService", "Firebase 未初始化，跳过推送服务初始化: $e");
        return; // Firebase 未初始化，直接返回
      }
      // 1. 初始化本地通知
      await _initializeLocalNotifications();

      // 2. Android 13+ 请求通知权限
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        Logger.info("PushService", '通知权限状态: $status');

        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.notification.request();
          Logger.info("PushService", '请求通知权限结果: $result');

          if (result.isDenied || result.isPermanentlyDenied) {
            Logger.warn("PushService", '用户拒绝了通知权限');
          }
        }
      }

      // 3. 请求 Firebase 通知权限（添加超时保护）
      NotificationSettings settings;
      try {
        settings = await _fcm!.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        ).timeout(
          const Duration(seconds: 10),
        );
      } on TimeoutException {
        Logger.warn("PushService", "请求通知权限超时，跳过推送服务初始化");
        return; // 超时后直接返回，不继续初始化
      } catch (e) {
        Logger.warn("PushService", "请求通知权限失败: $e");
        return; // 失败后直接返回，不继续初始化
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.info("PushService", '用户已授权通知');

        // 4. iOS 前台通知配置
        await _fcm!.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 5. 获取 Token 并上传给后端（添加超时保护）
        String? token;
        try {
          token = await _fcm!.getToken().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              Logger.warn("PushService", "获取 Token 超时");
              return null;
            },
          );
        } catch (e) {
          Logger.warn("PushService", "获取 Token 失败: $e");
          token = null;
        }
        
        if (token != null) {
          Logger.info("PushService", "FCM Token: $token");
          _uploadTokenToBackend(token);
        } else {
          Logger.warn("PushService", "未能获取 FCM Token，推送功能可能不可用");
        }

        // 6. 监听 Token 刷新（防止 Token 过期）
        _fcm!.onTokenRefresh.listen((newToken) {
          Logger.info("PushService", "FCM Token已刷新: $newToken");
          _uploadTokenToBackend(newToken);
        });

        // 7. 监听前台消息
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // 8. 处理点击通知打开 App (从后台或关闭状态)
        _setupInteractedMessage();
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        Logger.info("PushService", '用户授予了临时通知权限');
      } else {
        Logger.warn("PushService", '用户拒绝了通知权限');
      }
    } catch (e) {
      Logger.error("PushService", "初始化失败: $e", error: e);
    }
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

    // 创建 Android 通知渠道（Android 8.0+ 必需）
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'order_channel', // id - 必须与 _showLocalNotification 中使用的ID一致
        '订单通知', // name
        description: '订单相关的重要通知', // description
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      final androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
        Logger.info("PushService", 'Android 通知渠道创建成功: order_channel');
      } else {
        Logger.warn("PushService", '无法获取 Android 通知插件实现');
      }
    }

    Logger.info("PushService", '本地通知初始化完成');
  }

  // 处理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    Logger.info("PushService", '🔔 前台收到消息: ${message.messageId}');
    Logger.info("PushService", "消息通知字段: title=${message.notification?.title}, body=${message.notification?.body}");
    Logger.info("PushService", "消息数据字段: ${message.data}");

    // 显示本地通知
    final title = message.notification?.title ?? message.data['title'] ?? '新消息';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    Logger.info("PushService", "准备显示通知: title=$title, body=$body");
    _showLocalNotification(
      title: title,
      body: body,
      payload: message.messageId,
    );
  }

  // 显示本地通知
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      Logger.info("PushService", '准备显示通知: 标题=$title, 内容=$body');

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

      Logger.info("PushService", '✅ 通知已发送，ID: $notificationId');
    } catch (e) {
      Logger.error("PushService", '❌ 显示通知失败: $e', error: e);
    }
  }

  // 处理通知点击
  void _onNotificationTapped(NotificationResponse response) {
    Logger.info("PushService", '通知被点击: ${response.payload}');
    // 通知点击会通过 _handleMessageClick 处理，这里不需要额外处理
  }

  // 处理消息点击跳转逻辑
  Future<void> _setupInteractedMessage() async {
    if (_fcm == null) return; // 如果 Firebase 未初始化，直接返回
    
    // A. App 被终止时点击通知启动
    RemoteMessage? initialMessage = await _fcm!.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }

    // B. App 在后台时点击通知
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);
  }

  // 解析数据并跳转
  void _handleMessageClick(RemoteMessage message) {
    Logger.info("PushService", "用户点击了消息: ${message.messageId}");
    Logger.info("PushService", "消息数据: ${message.data}");

    final data = message.data;
    if (data.isEmpty) {
      Logger.warn("PushService", "消息数据为空，无法跳转");
      return;
    }

    // 解析后端传来的 extension 字段 (JSON 字符串)
    String? extensionStr = data['extension'];
    Map<String, dynamic>? extensionMap;
    if (extensionStr != null && extensionStr.isNotEmpty) {
      try {
        extensionMap = jsonDecode(extensionStr);
      } catch (e) {
        Logger.error("PushService", "解析 extension 字段失败: $e", error: e);
      }
    }

    // 获取消息类型（可能是 messageType 或 messageTypeId）
    String? messageTypeStr = data['messageType'] ?? data['messageTypeId']?.toString();
    int? messageTypeId;
    if (messageTypeStr != null) {
      messageTypeId = int.tryParse(messageTypeStr);
    }

    Logger.info("PushService",
        "点击跳转: messageTypeId=$messageTypeId, orderId=${extensionMap?['orderId']}");

    // 使用 WidgetsBinding.instance.addPostFrameCallback 确保导航在框架准备好后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = AppServices.navigatorKey.currentContext;
      if (context == null) {
        Logger.warn("PushService", "Navigator context 未准备好，延迟跳转");
        // 延迟重试
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleMessageClick(message);
        });
        return;
      }

      try {
        // 根据 messageTypeId 跳转
        if (messageTypeId == 1) {
          // 订单消息：跳转到订单详情页
          final orderId = extensionMap?['orderId'] as String?;
          if (orderId != null && orderId.isNotEmpty) {
            Navigator.of(context).pushNamed(
              Routes.orderDetail,
              arguments: orderId,
            );
            Logger.info("PushService", "跳转到订单详情页: orderId=$orderId");
          } else {
            Logger.warn("PushService", "订单ID为空，跳转到消息页");
            _navigateToMessagePage(context);
          }
        } else {
          // 系统消息或其他：跳转到消息页
          _navigateToMessagePage(context);
        }
      } catch (e) {
        Logger.error("PushService", "跳转失败: $e", error: e);
      }
    });
  }

  // 跳转到消息页
  void _navigateToMessagePage(BuildContext context) {
    try {
      // 先导航到首页
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.home,
        (route) => false,
      );
      Logger.info("PushService", "跳转到消息页");
    } catch (e) {
      Logger.error("PushService", "跳转到消息页失败: $e", error: e);
    }
  }

  // 调用接口：注册推送 Token
  void _uploadTokenToBackend(String token) async {
    try {
      Logger.info("PushService", "开始上报 Token 到后端...");
      final deviceInfo = AppServices.deviceInfo;
      Logger.info("PushService", "设备信息: deviceId=${deviceInfo.deviceId}, platform=${deviceInfo.platform}");
      await MessageServices.registerPushToken(
        RegisterPushTokenParams(
          token: token,
          deviceId: deviceInfo.deviceId,
          deviceModel: deviceInfo.deviceModel,
          platform: deviceInfo.platform,
          appVersion: deviceInfo.appVersion,
        ),
      );
      Logger.info("PushService", "✅ Token 上报成功");
    } catch (e, stackTrace) {
      Logger.error("PushService", "❌ Token 上报失败: $e", error: e);
      Logger.error("PushService", "堆栈信息: $stackTrace");
    }
  }
}
