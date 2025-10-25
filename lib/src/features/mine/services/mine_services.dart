import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/mine_model.dart';

class MineServices {
  // 获取用户基本信息
  Future<UserInfoModel> getUserInfo() async {
    final response = await ApiClient().get(ApiPaths.getUserInfoApi);
    Logger.info('MineServices', 'getUserInfo response: ${response.data}');
    return UserInfoModel.fromJson(response.data);
  }
}
