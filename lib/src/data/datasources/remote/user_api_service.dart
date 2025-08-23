import '../../../core/network/base_api_service.dart';
import '../../models/user_model.dart';

/// 用户 API 服务
/// 
/// 继承 BaseApiService，减少样板代码
/// 专门负责用户相关的 API 调用
class UserApiService extends BaseApiService {
  const UserApiService(super.apiClient);

  /// 获取用户信息
  Future<UserModel> getUser(String userId) async {
    return get<UserModel>(
      '/users/$userId',
      fromJson: UserModel.fromJson,
      tag: 'UserAPI',
    );
  }

  /// 更新用户信息
  Future<UserModel> updateUser(String userId, Map<String, dynamic> userData) async {
    return put<UserModel>(
      '/users/$userId',
      data: userData,
      fromJson: UserModel.fromJson,
      tag: 'UserAPI',
    );
  }

  /// 获取用户列表
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20}) async {
    return get<List<UserModel>>(
      '/users',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final data = json['data'] as List<dynamic>;
        return data.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
      },
      tag: 'UserAPI',
    );
  }
}
