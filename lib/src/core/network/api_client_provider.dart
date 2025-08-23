import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../../data/datasources/remote/user_api_service.dart';
import '../../data/datasources/local/cache_service.dart';
import '../../data/repositories/user_repository.dart';

/// ApiClient 的 Provider
/// 
/// 这个文件展示了如何使用 Riverpod 进行依赖注入
/// 替代了原来的静态服务定位器模式
final apiClientProvider = Provider<ApiClient>((ref) {
  // ApiClient 的创建依赖于环境配置
  // 你可以通过 ref.watch() 来获取其他 provider 的值
  return ApiClient();
});

/// 用户 API 服务的 Provider
final userApiServiceProvider = Provider<UserApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserApiService(apiClient);
});

/// 缓存服务的 Provider
/// 假设 CacheService 的初始化是异步的
final cacheServiceProvider = FutureProvider<CacheService>((ref) async {
  // 这里可以注入 SharedPreferences 的 Provider
  // final prefs = await ref.watch(sharedPreferencesProvider.future);
  // return CacheService(prefs: prefs);
  
  // 暂时返回一个模拟的 CacheService
  throw UnimplementedError('需要实现 SharedPreferences 的 Provider');
});

/// 用户仓库的 Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userApiService = ref.watch(userApiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider).value;
  
  if (cacheService == null) {
    throw StateError('CacheService 尚未初始化');
  }
  
  return UserRepository(
    userApiService: userApiService,
    cacheService: cacheService,
  );
});
