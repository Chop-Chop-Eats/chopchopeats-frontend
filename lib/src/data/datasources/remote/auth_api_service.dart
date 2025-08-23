import '../../../core/network/api_client.dart';
import '../../../core/utils/logger/logger.dart';

/// 认证 API 服务
///
/// 模拟后端认证接口，用于演示登录流程
class AuthApiService {
  final ApiClient _apiClient;

   const AuthApiService( this._apiClient);

  /// 模拟用户登录
  /// 延迟 1 秒模拟网络请求
  Future<Map<String, dynamic>> login(String username, String password) async {
    Logger.info('AuthAPI', '开始登录请求: username=$username');
    
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟验证逻辑
      if (username.isEmpty || password.isEmpty) {
        Logger.warn('AuthAPI', '用户名或密码为空');
        throw Exception('用户名和密码不能为空');
      }
      
      if (username == 'admin' && password == '123456') {
        Logger.info('AuthAPI', '登录成功: username=$username');
        
        // 模拟返回的用户信息和 token
        final response = {
          'success': true,
          'message': '登录成功',
          'data': {
            'user': {
              'id': '1',
              'username': username,
              'email': '$username@example.com',
              'avatar': null,
              'created_at': DateTime.now().toIso8601String(),
              'is_active': true,
            },
            'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
            'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
            'expires_in': 3600, // 1小时
          }
        };
        
        // 直接返回模拟数据，不使用 handleStandardResponse
        return response;
      } else {
        Logger.warn('AuthAPI', '用户名或密码错误: username=$username');
        throw Exception('用户名或密码错误');
      }
    } catch (e) {
      Logger.error('AuthAPI', '登录请求异常', error: e);
      rethrow;
    }
  }

  /// 模拟用户登出
  Future<Map<String, dynamic>> logout() async {
    Logger.info('AuthAPI', '开始登出请求');
    
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      Logger.info('AuthAPI', '登出成功');
      final response = {
        'success': true,
        'message': '登出成功',
      };
      
      // 直接返回模拟数据，不使用 handleStandardResponse
      return response;
    } catch (e) {
      Logger.error('AuthAPI', '登出请求异常', error: e);
      rethrow;
    }
  }

  /// 模拟刷新 token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    Logger.info('AuthAPI', '开始刷新 token');
    
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (refreshToken.isEmpty) {
        throw Exception('刷新 token 无效');
      }
      
      Logger.info('AuthAPI', 'Token 刷新成功');
      final response = {
        'success': true,
        'message': 'Token 刷新成功',
        'data': {
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'expires_in': 3600,
        }
      };
      
      // 直接返回模拟数据，不使用 handleStandardResponse
      return response;
    } catch (e) {
      Logger.error('AuthAPI', '刷新 token 异常', error: e);
      rethrow;
    }
  }
}
