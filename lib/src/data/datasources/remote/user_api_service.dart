import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

/// 用户 API 服务
/// 专门负责用户相关的 API 调用
class UserApiService {
  final ApiClient _apiClient;
  const UserApiService(this._apiClient);

}
