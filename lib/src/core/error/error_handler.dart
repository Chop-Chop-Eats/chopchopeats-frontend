import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unified_popups/unified_popups.dart';
import '../../app_services.dart';
import '../network/api_exception.dart';
import '../utils/logger/logger.dart';
import '../routing/navigate.dart';
import '../routing/routes.dart';
import '../constants/cache_constant.dart';

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  static ErrorHandler get instance => _instance;

  /// 处理认证错误
  static void handleAuthError(AuthException authException) {

    final BuildContext? context = AppServices.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    if (Navigate.isCurrent(context, '/login')) {
      _showErrorSnackBar(context, authException.message);
      return;
    }
    _clearUserSession();
    Navigate.pushAndRemoveUntil(
      context,
      Routes.login,
      arguments: {
        'error_message': authException.message,
        'error_code': authException.code,
      },
    );
  }

  static Future<void> _clearUserSession() async {
    await AppServices.cache.remove(CacheConstant.token);
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    UnifiedPopups.showToast(
      message,
      position: PopupPosition.bottom,
      duration: const Duration(milliseconds: 1200)
    );
  }
}


