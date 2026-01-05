import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:chop_user/src/core/network/api_client.dart';
import 'package:chop_user/src/core/network/api_paths.dart';
import 'package:chop_user/src/features/comment/models/comment_model.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';

class CommentService {
  static Future<void> createComment(AppMerchantShopCommentCreateReqVO req) async {
    await ApiClient().post(
      ApiPaths.shopCommentCreateApi,
      data: req.toJson(),
    );
  }

  static Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'review_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });
      // Using avatar upload for now as no other upload endpoint is visible
      final response = await ApiClient().post(
        ApiPaths.uploadAvatarApi,
        data: formData,
        encryptBody: false,
      );
      // ApiInterceptor unwraps the response data if code is 0
      return response.data as String;
    } catch (e) {
      Logger.error('CommentService', 'Upload image failed: $e');
      return null;
    }
  }
}
