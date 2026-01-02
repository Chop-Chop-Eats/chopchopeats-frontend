import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_services.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/message_models.dart';
import '../services/message_services.dart';

/// 消息列表数据状态
class MessageState {
  final List<MessageItem> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int total;
  final bool hasMore;
  final int? messageTypeId; // null=全部, 1=订单消息, 2=系统消息

  MessageState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
    this.messageTypeId,
  });

  MessageState copyWith({
    List<MessageItem>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? total,
    bool? hasMore,
    int? messageTypeId,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      messageTypeId: messageTypeId ?? this.messageTypeId,
    );
  }
}

/// 消息列表数据状态管理
class MessageNotifier extends StateNotifier<MessageState> {
  final _pageSize = AppServices.appSettings.pageSize;

  MessageNotifier() : super(MessageState());

  /// 加载消息列表
  Future<void> loadMessages(int? messageTypeId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      hasMore: true,
      messageTypeId: messageTypeId,
    );

    try {
      final response = await MessageServices.getMessageList(
        messageTypeId,
        1,
        _pageSize,
      );

      state = state.copyWith(
        messages: response.list,
        total: response.total,
        isLoading: false,
        currentPage: 1,
        hasMore: response.list.length < response.total,
        messageTypeId: messageTypeId,
      );

      Logger.info(
        'MessageNotifier',
        '消息列表加载成功: messageTypeId=$messageTypeId, total=${response.total}, 当前${response.list.length}条',
      );
    } catch (e) {
      Logger.error('MessageNotifier', '消息列表加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        messageTypeId: messageTypeId,
      );
    }
  }

  /// 刷新消息列表
  Future<void> refresh(int? messageTypeId) async {
    await loadMessages(messageTypeId);
  }

  /// 加载更多数据
  Future<void> loadMore(int? messageTypeId) async {
    if (!state.hasMore || state.isLoadingMore) return;
    if (state.messageTypeId != messageTypeId) {
      // 如果消息类型不匹配，先加载对应类型的消息
      await loadMessages(messageTypeId);
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await MessageServices.getMessageList(
        messageTypeId,
        nextPage,
        _pageSize,
      );

      state = state.copyWith(
        messages: [...state.messages, ...response.list],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: state.messages.length + response.list.length < response.total,
      );

      Logger.info(
        'MessageNotifier',
        '加载更多成功: messageTypeId=$messageTypeId, 当前页: $nextPage',
      );
    } catch (e) {
      Logger.error('MessageNotifier', '加载更多失败: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// 标记消息已读
  Future<void> markAsRead(String id) async {
    try {
      await MessageServices.markMessageRead(id);
      
      // 更新本地状态：将对应消息的 status 改为 1（已读）
      final updatedMessages = state.messages.map((message) {
        if (message.id == id) {
          return MessageItem(
            body: message.body,
            englishBody: message.englishBody,
            englishTitle: message.englishTitle,
            extension: message.extension,
            id: message.id,
            messageContentType: message.messageContentType,
            messageTypeId: message.messageTypeId,
            messageTypeName: message.messageTypeName,
            readTime: DateTime.now(),
            sentTime: message.sentTime,
            status: 1, // 标记为已读
            title: message.title,
          );
        }
        return message;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
      
      Logger.info('MessageNotifier', '消息已标记为已读: $id');
    } catch (e) {
      Logger.error('MessageNotifier', '标记消息已读失败: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String id) async {
    try {
      await MessageServices.deleteMessage(id);
      
      // 从列表中移除该消息
      final updatedMessages = state.messages.where((message) => message.id != id).toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        total: state.total - 1,
      );
      
      Logger.info('MessageNotifier', '消息已删除: $id');
    } catch (e) {
      Logger.error('MessageNotifier', '删除消息失败: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 清除所有消息
  Future<void> clearAllMessages() async {
    try {
      await MessageServices.clearMessage();
      
      // 清空列表
      state = state.copyWith(
        messages: [],
        total: 0,
        hasMore: false,
        currentPage: 1,
      );
      
      Logger.info('MessageNotifier', '所有消息已清除');
    } catch (e) {
      Logger.error('MessageNotifier', '清除消息失败: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 未读消息数量状态
class UnreadCountState {
  final int count;
  final bool isLoading;
  final String? error;

  UnreadCountState({
    this.count = 0,
    this.isLoading = false,
    this.error,
  });

  UnreadCountState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) {
    return UnreadCountState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 未读消息数量状态管理
class UnreadCountNotifier extends StateNotifier<UnreadCountState> {
  UnreadCountNotifier() : super(UnreadCountState());

  /// 加载未读消息数量
  Future<void> loadUnreadCount() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final count = await MessageServices.getUnreadMessageCount();
      state = state.copyWith(
        count: count,
        isLoading: false,
      );
      Logger.info('UnreadCountNotifier', '未读消息数量: $count');
    } catch (e) {
      Logger.error('UnreadCountNotifier', '获取未读消息数量失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新未读消息数量
  Future<void> refresh() async {
    await loadUnreadCount();
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 消息列表数据 Provider（使用 family 支持多个消息类型）
final messageProvider = StateNotifierProvider.family<MessageNotifier, MessageState, int?>((ref, messageTypeId) {
  return MessageNotifier();
});

/// 消息列表数据选择器
final messageListProvider = Provider.family<List<MessageItem>, int?>((ref, messageTypeId) {
  return ref.watch(messageProvider(messageTypeId)).messages;
});

/// 消息列表加载状态选择器
final messageLoadingProvider = Provider.family<bool, int?>((ref, messageTypeId) {
  return ref.watch(messageProvider(messageTypeId)).isLoading;
});

/// 消息列表加载更多状态选择器
final messageLoadingMoreProvider = Provider.family<bool, int?>((ref, messageTypeId) {
  return ref.watch(messageProvider(messageTypeId)).isLoadingMore;
});

/// 消息列表错误状态选择器
final messageErrorProvider = Provider.family<String?, int?>((ref, messageTypeId) {
  return ref.watch(messageProvider(messageTypeId)).error;
});

/// 消息列表是否有更多数据选择器
final messageHasMoreProvider = Provider.family<bool, int?>((ref, messageTypeId) {
  return ref.watch(messageProvider(messageTypeId)).hasMore;
});

/// 未读消息数量 Provider
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, UnreadCountState>((ref) {
  return UnreadCountNotifier();
});

/// 未读消息数量选择器
final unreadCountDataProvider = Provider<int>((ref) {
  return ref.watch(unreadCountProvider).count;
});

/// 未读消息数量加载状态选择器
final unreadCountLoadingProvider = Provider<bool>((ref) {
  return ref.watch(unreadCountProvider).isLoading;
});

