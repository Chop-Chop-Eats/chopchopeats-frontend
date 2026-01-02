import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/message/models/message_models.dart';
import '../../features/message/services/message_services.dart';
import '../config/app_services.dart';
import '../utils/logger/logger.dart';

// 1. 定义后台消息处理函数（必须是顶层函数）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger.info("PushService", "后台消息收到: ${message.messageId}");
  // 注意：此处无法直接更新 UI，但可以保存数据到本地存储
}


class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  // 初始化
  Future<void> init() async {
    // 1. 请求权限
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info("PushService", '用户已授权通知');
      
      // 2. 获取 Token 并上传给后端
      String? token = await _fcm.getToken();
      if (token != null) {
        Logger.info("PushService", "FCM Token: $token");
        _uploadTokenToBackend(token);
      }

      // 3. 监听 Token 刷新（防止 Token 过期）
      _fcm.onTokenRefresh.listen((newToken) {
        _uploadTokenToBackend(newToken);
      });

      // 4. 注册后台处理器
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. 监听前台消息
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Logger.info("PushService", '前台收到消息: ${message.notification?.title}');
        // 可以在这里调用 "获取未读消息数" 接口刷新 TabBar 的红点
        // _refreshUnreadCount(); 
        
        // 如果需要在前台弹出横幅，需要配合 flutter_local_notifications 插件
      });

      // 6. 处理点击通知打开 App (从后台或关闭状态)
      _setupInteractedMessage();
    }
  }

  // --- 业务逻辑：对接你的 API ---
  
  // 调用接口：1. 注册推送 Token
  void _uploadTokenToBackend(String token) async {
    try {
      // 这里调用你的 API 封装方法
      // 对应文档接口：/message/用户 APP - 站内消息/registerPushToken
      final deviceInfo = AppServices.deviceInfo;
      await MessageServices.registerPushToken(
        RegisterPushTokenParams(
          token: token,
          deviceId: deviceInfo.deviceId,
          deviceModel: deviceInfo.deviceModel,
          platform: deviceInfo.platform,
          appVersion: deviceInfo.appVersion,
        ),
      );
      Logger.info("PushService", "Token 上报成功");
    } catch (e) {
      Logger.error("PushService", "Token 上报失败: $e");
    }
  }

  // 处理消息点击跳转逻辑
  Future<void> _setupInteractedMessage() async {
    // A. App 被终止时点击通知启动
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }

    // B. App 在后台时点击通知
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);
  }

  // 解析数据并跳转
  void _handleMessageClick(RemoteMessage message) {
    // 获取 message.data 中的自定义字段
    final data = message.data;
    if (data.isNotEmpty) {
      // 解析后端传来的 extension 字段 (JSON 字符串)
      String? extensionStr = data['extension'];
      Map<String, dynamic>? extensionMap;
      if (extensionStr != null) {
        extensionMap = jsonDecode(extensionStr);
      }
      
      String? messageType = data['messageType']; // "1"-订单, "2"-系统

      Logger.info("PushService", "点击跳转: type=$messageType, orderId=${extensionMap?['orderId']}");

      // TODO: 根据 messageType 进行路由跳转
      // 例如：Navigator.pushNamed(context, '/order_detail', arguments: extensionMap?['orderId']);
    }
  }
}