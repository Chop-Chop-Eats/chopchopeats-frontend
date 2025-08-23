import '../datasources/local/cache_service.dart';
import '../datasources/remote/user_api_service.dart';
import '../models/user_model.dart';

/// 用户仓库
/// 
/// 这个文件展示了新的分层架构中的仓库层
/// 负责协调本地和远程数据源，为上层提供统一的数据访问接口
class UserRepository {
  final UserApiService _userApiService;
  final CacheService _cacheService;

  const UserRepository({
    required UserApiService userApiService,
    required CacheService cacheService,
  })  : _userApiService = userApiService,
        _cacheService = cacheService;



  /// 更新用户信息
  /// 先更新网络，成功后再更新缓存
  // Future<UserModel> updateUser(String userId, Map<String, dynamic> userData) async {
  //   try {
  //     // 1. 更新网络数据
  //     final updatedUser = await _userApiService.updateUser(userId, userData);
  //
  //     // 2. 更新本地缓存
  //     await _cacheService.set('user_$userId', updatedUser);
  //
  //     return updatedUser;
  //   } catch (e) {
  //     // 更新失败，重新抛出异常
  //     rethrow;
  //   }
  // }



  /// 清除用户缓存
  Future<void> clearUserCache(String userId) async {
    await _cacheService.remove('user_$userId');
  }

  /// 清除所有用户相关缓存
  Future<void> clearAllUserCache() async {
    // 这里可以实现批量清除逻辑
    // 或者使用缓存服务的批量操作功能
  }
}
