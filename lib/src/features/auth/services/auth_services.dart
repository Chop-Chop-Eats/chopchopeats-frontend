import '../../../core/config/app_services.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/auth_models.dart';

class AuthServices {

  // 检查是否登录
  Future<bool> isLoggedIn() async {
    final token = await AppServices.cache.get(AppConstants.accessToken);
    return token != null && token.isNotEmpty;
  }

  // 发送验证码
  Future<void> sendSms(AppAuthSmsSendParams params) async {
    final response = await ApiClient().post(ApiPaths.sendSmsApi, data: params.toJson());
    Logger.info('AuthServices', '发送验证码: ${response.data}');
    return response.data;
  }

  /// 手机号验证码登录
  Future<AppAuthLoginResponse> login(AppAuthLoginParams params) async {
    final response = await ApiClient().post(ApiPaths.loginApi, data: params.toJson());
    Logger.info('AuthServices', '手机号验证码登录: ${response.data}');
    return AppAuthLoginResponse.fromJson(response.data);
  }

  // 手机号密码登录
  Future<AppAuthLoginResponse> loginByPhoneAndPassword(AppAuthPlatformLoginParams params) async {
    final response = await ApiClient().post(ApiPaths.loginByPhoneAndPasswordApi, data: params.toJson());
    Logger.info('AuthServices', '手机号密码登录: ${response.data}');
    return AppAuthLoginResponse.fromJson(response.data);
  }

  // 重置密码
  Future<void> resetPassword(AppAuthResetPasswordParams params) async {
    final response = await ApiClient().put(ApiPaths.resetPasswordApi, data: params.toJson());
    Logger.info('AuthServices', '重置密码: ${response.data}');
    return response.data;
  }

  // 登出系统
  Future<void> logout() async {
    final response = await ApiClient().post(ApiPaths.logoutApi, data: {});
    Logger.info('AuthServices', '登出系统: ${response.data}');
    return response.data;
  }

  // 修改手机号
  Future<void> updatePhone(AppAuthUpdatePhoneParams params) async {
    final response = await ApiClient().put(
      ApiPaths.updatePhoneApi, 
      data: params.toJson()
    );
    Logger.info('AuthServices', '修改手机号: ${response.data}');
    return response.data;
  }

}