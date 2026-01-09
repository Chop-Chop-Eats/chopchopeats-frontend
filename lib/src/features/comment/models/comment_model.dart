import 'dart:convert';
import 'package:chop_user/src/core/utils/json_utils.dart';

class AppMerchantShopCommentCreateReqVO {
  final String shopId;
  final String orderId;
  final String? comment;
  final int rate;
  final List<String>? image;

  AppMerchantShopCommentCreateReqVO({
    required this.shopId,
    required this.orderId,
    this.comment,
    required this.rate,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'orderId': orderId,
      'comment': comment,
      'rate': rate,
      'image': image,
    };
  }
}

class AppMerchantShopCommentPageRespVO {
  final List<AppMerchantShopCommentRespVO> list;
  final int total;
  final double averageRate;
  final String shopId;

  AppMerchantShopCommentPageRespVO({
    required this.list,
    required this.total,
    required this.averageRate,
    required this.shopId,
  });

  factory AppMerchantShopCommentPageRespVO.fromJson(Map<String, dynamic> json) {
    return AppMerchantShopCommentPageRespVO(
      list: JsonUtils.parseList<AppMerchantShopCommentRespVO>(
            json,
            'list',
            (e) => AppMerchantShopCommentRespVO.fromJson(e),
          ) ??
          [],
      total: JsonUtils.parseInt(json, 'total') ?? 0,
      averageRate: JsonUtils.parseDouble(json, 'averageRate') ?? 0.0,
      shopId: JsonUtils.parseString(json, 'shopId') ?? '',
    );
  }
}

class AppMerchantShopCommentRespVO {
  final String id;
  final String shopId;
  final String shopName;
  final String userId;
  final String userNickname;
  final String userAvatar;
  final String orderId;
  final String comment;
  final int rate;
  final List<String> image;
  final int hasImage;
  final int reviewType;
  final String createTime;
  final AppMerchantShopCommentReplyVO? reply;

  AppMerchantShopCommentRespVO({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.userId,
    required this.userNickname,
    required this.userAvatar,
    required this.orderId,
    required this.comment,
    required this.rate,
    required this.image,
    required this.hasImage,
    required this.reviewType,
    required this.createTime,
    this.reply,
  });

  factory AppMerchantShopCommentRespVO.fromJson(Map<String, dynamic> json) {
    return AppMerchantShopCommentRespVO(
      id: JsonUtils.parseString(json, 'id') ?? '',
      shopId: JsonUtils.parseString(json, 'shopId') ?? '',
      shopName: JsonUtils.parseString(json, 'shopName') ?? '',
      userId: JsonUtils.parseString(json, 'userId') ?? '',
      userNickname: JsonUtils.parseString(json, 'userNickname') ?? '',
      userAvatar: JsonUtils.parseString(json, 'userAvatar') ?? '',
      orderId: JsonUtils.parseString(json, 'orderId') ?? '',
      comment: JsonUtils.parseString(json, 'comment') ?? '',
      rate: JsonUtils.parseInt(json, 'rate') ?? 0,
      image: _parseImages(json['image']),
      hasImage: JsonUtils.parseInt(json, 'hasImage') ?? 0,
      reviewType: JsonUtils.parseInt(json, 'reviewType') ?? 0,
      createTime: JsonUtils.parseString(json, 'createTime') ?? '',
      reply: json['reply'] != null
          ? AppMerchantShopCommentReplyVO.fromJson(json['reply'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}

class AppMerchantShopCommentReplyVO {
  final String replyId;
  final String replyContent;
  final List<String> replyImage;
  final String replyTime;

  AppMerchantShopCommentReplyVO({
    required this.replyId,
    required this.replyContent,
    required this.replyImage,
    required this.replyTime,
  });

  factory AppMerchantShopCommentReplyVO.fromJson(Map<String, dynamic> json) {
    return AppMerchantShopCommentReplyVO(
      replyId: JsonUtils.parseString(json, 'replyId') ?? '',
      replyContent: JsonUtils.parseString(json, 'replyContent') ?? '',
      replyImage: AppMerchantShopCommentRespVO._parseImages(json['replyImage']),
      replyTime: JsonUtils.parseString(json, 'replyTime') ?? '',
    );
  }
}
