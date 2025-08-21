import 'package:flutter/material.dart';
import '../app/app_services.dart';
import '../app/environment_config.dart';
import '../common/constant/cache_constant.dart';
import '../common/widgets/logo.dart';
import '../route/navigate.dart';
import '../route/routes.dart';
import '../services/apis/api_paths.dart';
import '../services/http/http.dart';
import '../utils/logger/logger.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _initializeApplication();
  }

  Future<void> _initializeApplication() async {
    // 1. 检查本地缓存中是否有环境后缀
    final cachedSuffix = await AppServices.cache.get<String>(CacheConstant.enable);

    // 如果没有缓存的后缀，必须去登录页选择
    if (cachedSuffix == null || cachedSuffix.isEmpty) {
      Logger.info("Splash", "No cached suffix, navigating to Login.");
      if (mounted) Navigate.replace(context, Routes.login);
      return;
    }

    // 2. 如果有，则更新全局配置
    Logger.info("Splash", "Found suffix in cache: $cachedSuffix. Updating config.");
    EnvironmentConfig.updateApiSuffix(cachedSuffix);

    // 3. 检查Token
    final String? token = await AppServices.cache.get(CacheConstant.token);
    if (mounted) {
      token != null && token.isNotEmpty ? Navigate.replace(context, Routes.home) : Navigate.replace(context, Routes.login);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Logo(),
    );
  }
}
