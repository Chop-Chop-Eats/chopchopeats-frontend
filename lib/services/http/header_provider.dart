import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../app/app_services.dart';
import '../../common/constant/cache_constant.dart';

/// 负责创建网络请求所需的 Headers
class HeaderProvider {
  const HeaderProvider();

  Future<Map<String, dynamic>> createHeaders() async {
    // 1. 获取认证 Token (异步)
    final token = await _getToken();

    // 2. 获取语言代码
    final language = _getLanguageCode();

    // 3. 加密设备 ID
    // final encryptedUuid = AppServices.cryptoService.encryptData(AppServices.uuid);

    // 4. 组装 Headers
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'debt-c-lang': language,
      'debt-c-os': kIsWeb ? 1 : Platform.isAndroid ? '1' : '2',
      // 'debt-c-ek': encryptedUuid,
    };

    if (token != null && token.isNotEmpty) {
      headers['debt-c-token'] = 'Bearer $token';
    }

    return headers;
  }

  Future<String?> _getToken() async {
    // 从缓存服务中异步获取 token
    return await AppServices.cache.get<String>(CacheConstant.token);
  }

  String _getLanguageCode() {
    // 使用 PlatformDispatcher 获取当前系统语言环境，更可靠
    String language = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (language.contains('zh')) {
      return 'zh-cn';
    } else if (language.contains('ph')) {
      return 'en-ph';
    } else {
      return 'en-us';
    }
  }
}