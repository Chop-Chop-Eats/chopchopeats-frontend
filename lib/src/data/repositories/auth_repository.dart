import '../datasources/local/cache_service.dart';
import '../datasources/remote/auth_api_service.dart';
import '../../core/utils/logger/logger.dart';

/// 认证仓库
/// 
/// 负责协调认证相关的数据操作，包括登录、登出、token 管理等
class AuthRepository {
  final AuthApiService _authApiService;
  final CacheService _cacheService;

  const AuthRepository({
    required AuthApiService authApiService,
    required CacheService cacheService,
  })  : _authApiService = authApiService,
        _cacheService = cacheService;

  /// 用户登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    Logger.info('AuthRepo', '开始登录流程: username=$username');
    
    try {
      // 调用 API 服务进行登录
      final response = await _authApiService.login(username, password);
      
      // handleStandardResponse 已经处理了成功/失败判断，这里直接处理成功的情况
      Logger.info('AuthRepo', '登录成功，准备缓存用户数据');
      
      // 保存用户信息到本地缓存
      await _saveUserData(response);
      
      Logger.info('AuthRepo', '登录成功，用户数据已缓存');
      return response;
    } catch (e) {
      Logger.error('AuthRepo', '登录异常', error: e);
      rethrow;
    }
  }

  /// 用户登出
  Future<Map<String, dynamic>> logout() async {
    Logger.info('AuthRepo', '开始登出流程');
    
    try {
      // 调用 API 服务进行登出
      final response = await _authApiService.logout();
      
      // handleStandardResponse 已经处理了成功/失败判断
      Logger.info('AuthRepo', '登出成功，准备清除本地数据');
      
      // 清除本地缓存的用户数据
      await _clearUserData();
      
      Logger.info('AuthRepo', '登出成功，本地数据已清除');
      return response;
    } catch (e) {
      Logger.error('AuthRepo', '登出异常', error: e);
      // 即使 API 调用失败，也要清除本地数据
      await _clearUserData();
      rethrow;
    }
  }

  /// 刷新 Token
  Future<Map<String, dynamic>> refreshToken() async {
    Logger.info('AuthRepo', '开始刷新 Token');
    
    try {
      // 从缓存获取 refresh token
      final refreshToken = await _cacheService.get<String>('refresh_token');
      
      if (refreshToken == null || refreshToken.isEmpty) {
        Logger.warn('AuthRepo', 'Refresh token 不存在，需要重新登录');
        throw Exception('Refresh token 不存在');
      }
      
      // 调用 API 服务刷新 token
      final response = await _authApiService.refreshToken(refreshToken);
      
      // handleStandardResponse 已经处理了成功/失败判断
      Logger.info('AuthRepo', 'Token 刷新成功，准备更新本地数据');
      
      // 更新本地缓存的 token 信息
      await _updateTokenData(response);
      
      Logger.info('AuthRepo', 'Token 刷新成功');
      return response;
    } catch (e) {
      Logger.error('AuthRepo', 'Token 刷新异常', error: e);
      rethrow;
    }
  }

  /// 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    try {
      Logger.debug('AuthRepo', '开始检查登录状态');
      
      // 检查 access_token
      final token = await _cacheService.get<String>('access_token');
      Logger.debug('AuthRepo', '读取 access_token: $token');
      
      // 检查 user_data
      final userData = await _cacheService.get<Map<String, dynamic>>('user_data');
      Logger.debug('AuthRepo', '读取 user_data: $userData');
      
      final isLoggedIn = token != null && token.isNotEmpty;
      Logger.info('AuthRepo', '登录状态检查结果: $isLoggedIn (token: ${token?.substring(0, 20)}...)');
      
      return isLoggedIn;
    } catch (e) {
      Logger.error('AuthRepo', '检查登录状态异常', error: e);
      return false;
    }
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userData = await _cacheService.get<Map<String, dynamic>>(
        'user_data',
        fromJson: (json) => json,
      );
      return userData;
    } catch (e) {
      Logger.error('AuthRepo', '获取用户信息异常', error: e);
      return null;
    }
  }

  /// 保存用户数据到本地缓存
  Future<void> _saveUserData(Map<String, dynamic> response) async {
    try {
      Logger.debug('AuthRepo', '开始保存用户数据，完整响应: $response');
      
      // 从 response 的 data 字段中提取数据
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('响应中缺少 data 字段');
      }
      
      // 安全地提取数据，添加类型检查
      final user = data['user'];
      final token = data['token'];
      final refreshToken = data['refresh_token'];
      
      // 验证数据类型
      if (user == null || user is! Map<String, dynamic>) {
        throw Exception('用户数据格式错误: user = $user');
      }
      
      if (token == null || token is! String) {
        throw Exception('Token 格式错误: token = $token');
      }
      
      if (refreshToken == null || refreshToken is! String) {
        throw Exception('Refresh token 格式错误: refresh_token = $refreshToken');
      }
      
      // 保存用户信息
      await _cacheService.set('user_data', user);
      await _cacheService.set('access_token', token);
      await _cacheService.set('refresh_token', refreshToken);
      
      Logger.info('AuthRepo', '用户数据已保存到本地缓存: user=${user['username']}, token=${token.substring(0, 20)}...');
    } catch (e) {
      Logger.error('AuthRepo', '保存用户数据异常', error: e);
      rethrow;
    }
  }

  /// 更新 Token 数据
  Future<void> _updateTokenData(Map<String, dynamic> response) async {
    try {
      Logger.debug('AuthRepo', '开始更新 Token 数据，完整响应: $response');
      
      // 从 response 的 data 字段中提取数据
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('响应中缺少 data 字段');
      }
      
      // 安全地提取数据
      final token = data['token'];
      final refreshToken = data['refresh_token'];
      
      // 验证数据类型
      if (token == null || token is! String) {
        throw Exception('Token 格式错误: token = $token');
      }
      
      if (refreshToken == null || refreshToken is! String) {
        throw Exception('Refresh token 格式错误: refresh_token = $refreshToken');
      }
      
      await _cacheService.set('access_token', token);
      await _cacheService.set('refresh_token', refreshToken);
      
      Logger.info('AuthRepo', 'Token 数据已更新: token=${token.substring(0, 20)}...');
    } catch (e) {
      Logger.error('AuthRepo', '更新 Token 数据异常', error: e);
      rethrow;
    }
  }

  /// 清除用户数据
  Future<void> _clearUserData() async {
    try {
      await _cacheService.remove('user_data');
      await _cacheService.remove('access_token');
      await _cacheService.remove('refresh_token');
      
      Logger.debug('AuthRepo', '用户数据已清除');
    } catch (e) {
      Logger.error('AuthRepo', '清除用户数据异常', error: e);
      rethrow;
    }
  }
}
