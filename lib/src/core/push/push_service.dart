import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chop_user/src/core/constants/app_constant.dart';
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
  Logger.info("PushService", "========================================");
  Logger.info("PushService", "🔔 后台消息收到: ${message.messageId}");
  Logger.info("PushService", "收到时间: ${DateTime.now()}");
  
  // 检查 notification 字段
  if (message.notification != null) {
    Logger.info("PushService", "✅ 包含 notification 字段:");
    Logger.info("PushService", "   - title: ${message.notification!.title}");
    Logger.info("PushService", "   - body: ${message.notification!.body}");
    Logger.info("PushService", "   - android: ${message.notification!.android}");
    Logger.info("PushService", "   - apple: ${message.notification!.apple}");
  } else {
    Logger.warn("PushService", "❌ 缺少 notification 字段！这会导致后台/终止状态下不显示通知");
  }
  
  // 检查 data 字段
  if (message.data.isNotEmpty) {
    Logger.info("PushService", "✅ 包含 data 字段: ${message.data}");
  } else {
    Logger.warn("PushService", "⚠️ 没有 data 字段");
  }
  
  Logger.info("PushService", "========================================");
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
  
  // 缓存 FCM Token，等待用户登录后上报
  String? _cachedFcmToken;

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
        Logger.info("PushService", '通知权限详情: alert=${settings.alert}, badge=${settings.badge}, sound=${settings.sound}');

        // 4. iOS 前台通知配置
        await _fcm!.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        Logger.info("PushService", 'iOS 前台通知配置完成');

        // 5. 获取 Token 并上传给后端
        // iOS 平台：APNS Token 获取需要时间，使用延迟重试 + onTokenRefresh 监听
        if (Platform.isIOS) {
          Logger.info("PushService", "iOS 平台：启动后台 Token 获取任务...");
          Logger.warn("PushService", "⚠️ 个人开发者账号不支持推送，如需使用请升级到付费账号");
          Logger.info("PushService", "提示：APNS Token 可能需要几秒到几十秒，请耐心等待");
          
          // 延迟后台获取，不阻塞初始化流程
          _retryGetTokenInBackground();
        } else {
          // Android 平台：直接获取
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
            _cachedFcmToken = token;
            _uploadTokenIfLoggedIn(token);
          } else {
            Logger.warn("PushService", "未能获取 FCM Token，推送功能可能不可用");
          }
        }

        // 6. 监听 Token 刷新（防止 Token 过期）
        _fcm!.onTokenRefresh.listen((newToken) {
          Logger.info("PushService", "FCM Token已刷新: $newToken");
          _cachedFcmToken = newToken;
          _uploadTokenIfLoggedIn(newToken);
        });

        // 7. 监听前台消息
        Logger.info("PushService", '正在注册前台消息监听器...');
        FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
            Logger.info("PushService", '✅✅✅ 监听器被触发！收到消息: ${message.messageId}');
            _handleForegroundMessage(message);
          },
          onError: (error) {
            Logger.error("PushService", '❌ 前台消息监听器错误: $error', error: error);
          },
          onDone: () {
            Logger.warn("PushService", '⚠️ 前台消息监听器已关闭');
          },
          cancelOnError: false,
        );
        Logger.info("PushService", '✅ 前台消息监听器已注册');

        // 8. 处理点击通知打开 App (从后台或关闭状态)
        _setupInteractedMessage();
        Logger.info("PushService", '✅ 消息点击处理已设置');
        
        Logger.info("PushService", '========================================');
        Logger.info("PushService", '🎉 推送服务初始化完成！');
        Logger.info("PushService", '📱 当前 Token: $_cachedFcmToken');
        Logger.info("PushService", '🔔 前台消息监听: 已启用');
        Logger.info("PushService", '🔔 后台消息监听: 已启用（通过 firebaseMessagingBackgroundHandler）');
        Logger.info("PushService", '🔔 点击通知跳转: 已启用');
        Logger.info("PushService", '⚠️ 请确保后端使用此 Token 发送消息！');
        Logger.info("PushService", '========================================');
        
        // 自动打印调试信息
        Future.delayed(const Duration(seconds: 1), () {
          printDebugInfo();
        });
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
    Logger.info("PushService", '========================================');
    Logger.info("PushService", '🔔 前台收到消息: ${message.messageId}');
    Logger.info("PushService", '收到时间: ${DateTime.now()}');
    
    // 检查 notification 字段
    if (message.notification != null) {
      Logger.info("PushService", "✅ 包含 notification 字段:");
      Logger.info("PushService", "   - title: ${message.notification!.title}");
      Logger.info("PushService", "   - body: ${message.notification!.body}");
      Logger.info("PushService", "   - android: ${message.notification!.android}");
      Logger.info("PushService", "   - apple: ${message.notification!.apple}");
    } else {
      Logger.warn("PushService", "❌ 缺少 notification 字段！");
    }
    
    // 检查 data 字段
    if (message.data.isNotEmpty) {
      Logger.info("PushService", "✅ 包含 data 字段: ${message.data}");
    } else {
      Logger.warn("PushService", "⚠️ 没有 data 字段");
    }
    
    Logger.info("PushService", '========================================');

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

  /// 供外部调用：用户登录后主动上报 Token
  /// 应该在用户登录成功后调用此方法
  Future<void> uploadTokenWhenLoggedIn() async {
    if (_cachedFcmToken == null) {
      Logger.info("PushService", "没有缓存的 FCM Token");
      
      if (_fcm == null) {
        Logger.warn("PushService", "Firebase 未初始化，无法获取 Token");
        return;
      }
      
      if (Platform.isIOS) {
        Logger.info("PushService", "iOS 平台：Token 将通过后台任务和 onTokenRefresh 监听自动获取并上报");
        Logger.info("PushService", "提示：APNS Token 需要时间获取，请耐心等待几秒");
      } else {
        // Android：尝试立即获取
        try {
          final token = await _fcm!.getToken().timeout(
            const Duration(seconds: 10),
            onTimeout: () => null,
          );
          
          if (token != null) {
            Logger.info("PushService", "✅ 获取 Token 成功: $token");
            _cachedFcmToken = token;
            await _uploadTokenToBackend(token);
          } else {
            Logger.warn("PushService", "获取 Token 失败，Token 为空");
          }
        } catch (e) {
          Logger.error("PushService", "获取 Token 异常: $e", error: e);
        }
      }
      return;
    }
    
    Logger.info("PushService", "用户已登录，开始上报缓存的 FCM Token");
    await _uploadTokenToBackend(_cachedFcmToken!);
  }
  
  // iOS 后台重试获取 Token
  Future<void> _retryGetTokenInBackground() async {
    if (_fcm == null || !Platform.isIOS) return;
    
    // 重试策略：2秒、5秒、10秒后重试
    final delays = [2, 5, 10];
    
    for (int i = 0; i < delays.length; i++) {
      await Future.delayed(Duration(seconds: delays[i]));
      
      // 如果已经有 Token 了，停止重试
      if (_cachedFcmToken != null) {
        Logger.info("PushService", "Token 已通过其他途径获取，停止后台重试");
        return;
      }
      
      Logger.info("PushService", "后台重试 ${i + 1}/${delays.length}：尝试获取 Token...");
      
      try {
        // 先检查 APNS Token
        final apnsToken = await _fcm!.getAPNSToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        
        if (apnsToken == null) {
          Logger.info("PushService", "APNS Token 仍未就绪，继续等待...");
          continue;
        }
        
        Logger.info("PushService", "✅ APNS Token 已就绪！");
        
        // 获取 FCM Token
        final token = await _fcm!.getToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        
        if (token != null) {
          Logger.info("PushService", "🎉 成功获取 FCM Token: $token");
          _cachedFcmToken = token;
          _uploadTokenIfLoggedIn(token);
          return; // 成功获取，结束重试
        }
      } catch (e) {
        if (!e.toString().contains('apns-token-not-set')) {
          Logger.warn("PushService", "重试 ${i + 1} 失败: $e");
        }
      }
    }
    
    // 所有重试都失败，给出详细的诊断建议
    Logger.warn("PushService", "========================================");
    Logger.warn("PushService", "⚠️ iOS 推送配置问题诊断");
    Logger.warn("PushService", "========================================");
    Logger.warn("PushService", "APNS Token 无法获取，请检查以下配置：");
    Logger.warn("PushService", "");
    Logger.warn("PushService", "❌ 最可能的原因：使用了个人开发者账号");
    Logger.warn("PushService", "   → 个人账号（Free/Personal Team）不支持推送功能");
    Logger.warn("PushService", "   → 需要升级到付费的 Apple Developer Program（\$99/年）");
    Logger.warn("PushService", "   → 检查 ios/Runner/Runner.entitlements 是否缺少 aps-environment");
    Logger.warn("PushService", "");
    Logger.warn("PushService", "如果已是付费账号，请检查：");
    Logger.warn("PushService", "   1. Xcode → Runner → Signing & Capabilities");
    Logger.warn("PushService", "      → 是否添加了 \"Push Notifications\" Capability");
    Logger.warn("PushService", "");
    Logger.warn("PushService", "   2. Bundle ID 是否匹配");
    Logger.warn("PushService", "      → 当前: com.chopchop.chopuser");
    Logger.warn("PushService", "      → Firebase Console 中是否一致？");
    Logger.warn("PushService", "");
    Logger.warn("PushService", "   3. Firebase Console → Project Settings → Cloud Messaging");
    Logger.warn("PushService", "      → iOS 是否上传了 APNS 认证密钥（.p8）或证书（.p12）？");
    Logger.warn("PushService", "");
    Logger.warn("PushService", "   4. 设备网络");
    Logger.warn("PushService", "      → 能否访问 Apple 推送服务器？");
    Logger.warn("PushService", "      → 尝试切换网络或使用 VPN");
    Logger.warn("PushService", "========================================");
  }
  
  /// 调试方法：打印当前推送服务状态
  Future<void> printDebugInfo() async {
    Logger.info("PushService", "========== 推送服务调试信息 ==========");
    Logger.info("PushService", "1. Firebase 初始化状态: ${_fcm != null ? '✅ 已初始化' : '❌ 未初始化'}");
    Logger.info("PushService", "2. 缓存的 FCM Token: ${_cachedFcmToken ?? '❌ 无'}");
    
    if (_fcm != null) {
      try {
        final settings = await _fcm!.getNotificationSettings();
        Logger.info("PushService", "3. 通知权限状态: ${settings.authorizationStatus}");
        Logger.info("PushService", "   - Alert: ${settings.alert}");
        Logger.info("PushService", "   - Badge: ${settings.badge}");
        Logger.info("PushService", "   - Sound: ${settings.sound}");
      } catch (e) {
        Logger.warn("PushService", "无法获取通知权限状态: $e");
      }
      
      if (Platform.isIOS) {
        try {
          final apnsToken = await _fcm!.getAPNSToken();
          Logger.info("PushService", "4. APNS Token: ${apnsToken ?? '❌ 未获取'}");
          if (apnsToken == null) {
            Logger.warn("PushService", "   ⚠️ 可能使用了个人开发者账号（不支持推送）");
            Logger.warn("PushService", "   ⚠️ 或者未在 Xcode 中添加 Push Notifications Capability");
          }
        } catch (e) {
          Logger.warn("PushService", "4. APNS Token: ❌ 获取失败");
          Logger.warn("PushService", "   错误: $e");
        }
      }
      
      try {
        final token = await _fcm!.getToken();
        Logger.info("PushService", "${Platform.isIOS ? '5' : '4'}. 当前 FCM Token: $token");
      } catch (e) {
        Logger.warn("PushService", "${Platform.isIOS ? '5' : '4'}. 无法获取 FCM Token: $e");
      }
    }
    
    final accessToken = await AppServices.cache.get<String>(AppConstants.accessToken);
    final loginIndex = Platform.isIOS ? '6' : '5';
    Logger.info("PushService", "$loginIndex. 用户登录状态: ${accessToken != null && accessToken.isNotEmpty ? '✅ 已登录' : '❌ 未登录'}");
    
    final platformIndex = Platform.isIOS ? '7' : '6';
    Logger.info("PushService", "$platformIndex. 平台: ${Platform.operatingSystem}");
    
    if (Platform.isIOS) {
      Logger.info("PushService", "");
      Logger.info("PushService", "iOS 推送配置提示：");
      Logger.info("PushService", "  • Bundle ID: com.chopchop.chopuser");
      Logger.info("PushService", "  • 需要付费 Apple Developer Program 账号");
      Logger.info("PushService", "  • 需要在 Xcode 中添加 Push Notifications Capability");
      Logger.info("PushService", "  • 需要在 Firebase Console 上传 APNS 密钥");
    }
    
    Logger.info("PushService", "=====================================");
  }
  
  // 检查登录状态后再上报 Token
  Future<void> _uploadTokenIfLoggedIn(String token) async {
    // 检查用户是否已登录（通过检查是否有 accessToken）
    final accessToken = await AppServices.cache.get<String>(AppConstants.accessToken);
    
    if (accessToken != null && accessToken.isNotEmpty) {
      Logger.info("PushService", "用户已登录，开始上报 Token");
      await _uploadTokenToBackend(token);
    } else {
      Logger.info("PushService", "用户未登录，Token 已缓存，等待登录后上报");
      Logger.info("PushService", "提示：请在用户登录成功后调用 PushService().uploadTokenWhenLoggedIn()");
    }
  }

  // 调用接口：注册推送 Token
  Future<void> _uploadTokenToBackend(String token) async {
    try {
      Logger.info("PushService", "开始上报 Token 到后端...");
      final deviceInfo = AppServices.deviceInfo;
      
      final params = RegisterPushTokenParams(
        token: token,
        deviceId: deviceInfo.deviceId,
        deviceModel: deviceInfo.deviceModel,
        platform: deviceInfo.platform,
        appVersion: deviceInfo.appVersion,
      );
      
      Logger.info("PushService", "完整请求参数: ${params.toJson()}");
      Logger.info("PushService", "设备信息明细:");
      Logger.info("PushService", "  - deviceId: ${deviceInfo.deviceId}");
      Logger.info("PushService", "  - platform: ${deviceInfo.platform}");
      Logger.info("PushService", "  - deviceModel: ${deviceInfo.deviceModel}");
      Logger.info("PushService", "  - appVersion: ${deviceInfo.appVersion}");
      Logger.info("PushService", "  - token: $token");
      
      await MessageServices.registerPushToken(params);
      Logger.info("PushService", "✅ Token 上报成功");
      Logger.info("PushService", "📌 提示：现在可以从其他设备或 Firebase Console 发送测试消息了");
      Logger.info("PushService", "📌 使用此 Token 进行测试: $token");
    } catch (e) {
      Logger.error("PushService", "❌ Token 上报失败: $e", error: e);
      Logger.warn("PushService", "可能的原因:");
      Logger.warn("PushService", "  1. 后端接口验证失败（检查参数格式）");
      Logger.warn("PushService", "  2. 用户未登录或 Token 已过期");
      Logger.warn("PushService", "  3. 后端数据库连接问题");
      Logger.warn("PushService", "  4. deviceId 格式不符合后端要求（应为36位UUID）");
    }
  }
}
