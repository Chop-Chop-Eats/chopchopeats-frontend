// import 'package:flutter/foundation.dart';
import '../config/app_services.dart';
import '../constants/app_constant.dart';

/// 负责创建网络请求所需的 Headers
class ApiHeader {
  const ApiHeader();

  Future<Map<String, dynamic>> createHeaders() async {
    // 获取认证 Token (异步)
    final token = await _getToken();

    // 获取语言代码
    // final language = _getLanguageCode();


    // 组装 Headers
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      // 'lang': language,
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<String?> _getToken() async {
    return await AppServices.cache.get(AppConstants.accessToken);
  }
  
  // String _getLanguageCode() {
  //   // 使用 PlatformDispatcher 获取当前系统语言环境，更可靠
  //   String language = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
  //   if (language.contains('zh')) {
  //     return 'zh-cn';
  //   } else if (language.contains('ph')) {
  //     return 'en-ph';
  //   } else {
  //     return 'en-us';
  //   }
  // }
}