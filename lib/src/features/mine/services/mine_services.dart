import 'dart:typed_data';

import 'package:dio/dio.dart';

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

  // 修改基本信息
  Future<void> updateUserInfo(UpdateUserInfoParams params) async {
    final response = await ApiClient().put(
      ApiPaths.updateUserInfoApi,
      data: params.toJson(),
    );
    Logger.info('MineServices', 'updateUserInfo response: ${response.data}');
    return response.data;
  }

  // 上传头像
  Future<String> uploadAvatar(
    Uint8List avatarBytes, {
    String? fileName,
    String fieldName = 'file',
  }) async {
    final formData = FormData.fromMap({
      fieldName: MultipartFile.fromBytes(
        avatarBytes,
        filename: fileName ?? 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
      ),
    });
    final response = await ApiClient().post(
      ApiPaths.uploadAvatarApi,
      data: formData,
      encryptBody: false,
    );
    Logger.info('MineServices', 'uploadAvatar response: ${response.data}');
    return response.data as String;
  }

  // 修改语言设置 1:中文 2:英文 
  Future<bool> updateLanguage(int language) async {
    final response = await ApiClient().put(
      ApiPaths.updateLanguageApi,
      data: {'languageSetting': language},
    );
    Logger.info('MineServices', 'updateLanguage response: ${response.data}');
    return response.data;
  }
}
