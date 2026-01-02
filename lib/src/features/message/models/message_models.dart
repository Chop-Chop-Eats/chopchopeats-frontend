import '../../../core/l10n/locale_service.dart';
import '../../../core/utils/json_utils.dart';

/// 注册推送token params
class RegisterPushTokenParams {
  ///应用版本
  final String? appVersion;

  ///设备 ID (36位UUID)
  final String deviceId;

  ///设备型号
  final String? deviceModel;

  ///平台类型 (android/ios/web)
  final String platform;

  ///FCM Token
  final String token;

  RegisterPushTokenParams({
    this.appVersion,
    required this.deviceId,
    this.deviceModel,
    required this.platform,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      if (appVersion != null) 'appVersion': appVersion,
      'deviceId': deviceId,
      if (deviceModel != null) 'deviceModel': deviceModel,
      'platform': platform,
      'token': token,
    };
  }
}

/// 消息列表
class MessageListModel {
  ///数据
  final List<MessageItem> list;

  ///总量
  final int total;

  MessageListModel({required this.list, required this.total});

  factory MessageListModel.fromJson(Map<String, dynamic> json) {
    return MessageListModel(
      list: JsonUtils.parseList<MessageItem>(
        json,
        'list',
        (e) => MessageItem.fromJson(e),
      ) ?? [],
      total: json['total'] ?? 0,
    );
  }
}


class MessageItem {
  ///消息内容
  final String? body;

  ///英文消息内容
  final String? englishBody;

  ///英文消息标题
  final String? englishTitle;

  ///扩展字段
  final String? extension;

  ///消息ID
  final String? id;

  ///消息内容类型
  final String? messageContentType;

  ///消息类型ID
  final int? messageTypeId;

  ///消息类型名称
  final String? messageTypeName;

  ///消息被阅读的时间
  final DateTime? readTime;

  ///消息发送时间
  final DateTime? sentTime;

  ///消息状态: 0=未读, 1=已读
  final int? status;

  ///消息标题
  final String? title;

  MessageItem({
    this.body,
    this.englishBody,
    this.englishTitle,
    this.extension,
    this.id,
    this.messageContentType,
    this.messageTypeId,
    this.messageTypeName,
    this.readTime,
    this.sentTime,
    this.status,
    this.title,
  });
  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      body: json['body'],
      englishBody: json['englishBody'],
      englishTitle: json['englishTitle'],
      extension: json['extension'],
      id: json['id'],
      messageContentType: json['messageContentType'],
      messageTypeId: json['messageTypeId'],
      messageTypeName: json['messageTypeName'], 
      readTime: JsonUtils.parseDateTime(json, 'readTime'),
      sentTime: JsonUtils.parseDateTime(json, 'sentTime'),
      status: json['status'],
      title: json['title'],
    );
  }

 
  String get localizedTitle {
    return LocaleService.getLocalizedText(title, englishTitle);
  }

  String get localizedBody {
    return LocaleService.getLocalizedText(body, englishBody);
  }
}
