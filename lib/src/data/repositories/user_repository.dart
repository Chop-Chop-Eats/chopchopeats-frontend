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

  /// 获取用户信息
  /// 优先从缓存获取，如果没有则从网络获取并缓存
  Future<UserModel?> getUser(String userId) async {
    try {
      // 1. 尝试从缓存获取
      final cachedUser = await _cacheService.get<UserModel>(
        'user_$userId',
        fromJson: UserModel.fromJson,
      );

      if (cachedUser != null) {
        return cachedUser;
      }

      // 2. 从网络获取
      final user = await _userApiService.getUser(userId);
      
      // 3. 缓存到本地
      await _cacheService.set('user_$userId', user);
      
      return user;
    } catch (e) {
      // 如果网络请求失败，尝试返回缓存数据（即使可能过期）
      final cachedUser = await _cacheService.get<UserModel>(
        'user_$userId',
        fromJson: UserModel.fromJson,
      );
      
      if (cachedUser != null) {
        // 记录日志：使用缓存数据
        print('使用缓存用户数据: $userId');
        return cachedUser;
      }
      
      // 重新抛出异常
      rethrow;
    }
  }

  /// 更新用户信息
  /// 先更新网络，成功后再更新缓存
  Future<UserModel> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      // 1. 更新网络数据
      final updatedUser = await _userApiService.updateUser(userId, userData);
      
      // 2. 更新本地缓存
      await _cacheService.set('user_$userId', updatedUser);
      
      return updatedUser;
    } catch (e) {
      // 更新失败，重新抛出异常
      rethrow;
    }
  }

  /// 获取用户列表
  /// 用户列表通常不需要缓存，直接返回网络数据
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20}) async {
    try {
      return await _userApiService.getUsers(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

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
