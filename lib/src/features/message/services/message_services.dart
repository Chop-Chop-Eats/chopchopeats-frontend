import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/message_models.dart';

class MessageServices {
  // 注册推送token
  static Future<void> registerPushToken(RegisterPushTokenParams params) async {
    final response = await ApiClient().post(
      ApiPaths.registerPushTokenApi,
      data: params.toJson(),
    );
    Logger.info('MessageServices', '注册推送token: ${response.data}');
    return response.data;
  }

  // 标记消息已读
  static Future<void> markMessageRead(String id) async {
    final response = await ApiClient().post(
      ApiPaths.markMessageReadApi,
      data: {
        'id': id,
      },
    );
    Logger.info('MessageServices', '标记消息已读: ${response.data}');
    return response.data;
  }

  // 分页查询用户消息 messageTypeId = 1 订单消息 messageTypeId = 2 系统消息 不传或者为空是所有数据
  static Future<MessageListModel> getMessageList(int? messageTypeId, int page, int pageSize) async {
    final response = await ApiClient().get(
      ApiPaths.getMessageListApi,
      queryParameters: {
        if (messageTypeId != null) 'messageTypeId': messageTypeId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    Logger.info('MessageServices', '分页查询用户消息: ${response.data}');
    return MessageListModel.fromJson(response.data);
  }

  /// 获取未读消息数量
  static Future<int> getUnreadMessageCount() async {
    final response = await ApiClient().get(
      ApiPaths.getUnreadMessageCountApi,
    );
    Logger.info('MessageServices', '获取未读消息数量: ${response.data}');
    return response.data;
  }

  /// 清除站内消息
  static Future<void> clearMessage() async {
    final response = await ApiClient().delete(
      ApiPaths.clearMessageApi,
    );
    Logger.info('MessageServices', '清除站内消息: ${response.data}');
    return response.data;
  }
  /// 删除站内消息
  static Future<void> deleteMessage(String id) async {
    final response = await ApiClient().delete(
      ApiPaths.deleteMessageApi,
      data: {
        'id': id,
      },
    );
    Logger.info('MessageServices', '删除站内消息: ${response.data}');
    return response.data;
  }
}

