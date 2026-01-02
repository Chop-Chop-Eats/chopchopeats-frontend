import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/widgets/base_page.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/custom_refresh_footer.dart';
import '../../../core/providers/tab_index_provider.dart';
import '../widgets/message_tab_bar.dart';
import '../widgets/message_item.dart';
import '../providers/message_provider.dart';
import '../models/message_models.dart' as models;

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["全部", "订单消息", "系统消息"];
  
  // 为每个 Tab 创建独立的 RefreshController
  final RefreshController _allMessagesController = RefreshController(initialRefresh: false);
  final RefreshController _orderMessagesController = RefreshController(initialRefresh: false);
  final RefreshController _systemMessagesController = RefreshController(initialRefresh: false);
  
  // 记录已经初始化加载过的消息类型，避免重复加载
  final Set<int?> _initializedTypes = {};

  @override
  void initState() {
    super.initState();
    // 加载未读消息数量和初始消息列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unreadCountProvider.notifier).loadUnreadCount();
      // 初始化加载全部消息列表（默认显示第一个 Tab）
      ref.read(messageProvider(null).notifier).loadMessages(null);
    });
  }

  @override
  void dispose() {
    _allMessagesController.dispose();
    _orderMessagesController.dispose();
    _systemMessagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听 Tab 切换，当切换到消息页时刷新未读消息数量
    ref.listen<int>(currentTabIndexProvider, (previous, next) {
      if (next == 3 && previous != 3 && mounted) {
        Logger.info('MessagePage', '检测到切换到消息页，刷新未读消息数量');
        ref.read(unreadCountProvider.notifier).refresh();
      }
    });

    return BasePage(
      title: "消息中心",
      rightWidget: _buildRightWidget(),
      content: MessageTabBar(
        tabs: _tabs,
        selectedIndex: _selectedTabIndex,
        tabViews: _buildTabViews(),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          // 切换 Tab 时加载对应类型的消息
          _loadMessagesForTab(index);
        },
      ),
    );
  }

  /// 根据 Tab 索引加载对应类型的消息
  void _loadMessagesForTab(int tabIndex) {
    int? messageTypeId;
    switch (tabIndex) {
      case 0:
        messageTypeId = null; // 全部
        break;
      case 1:
        messageTypeId = 1; // 订单消息
        break;
      case 2:
        messageTypeId = 2; // 系统消息
        break;
    }
    
    final messageState = ref.read(messageProvider(messageTypeId));
    final messages = ref.read(messageListProvider(messageTypeId));
    final isLoading = ref.read(messageLoadingProvider(messageTypeId));
    
    // 只有在消息列表为空、未在加载中、且未加载过的情况下才加载
    // 检查 messageTypeId 是否匹配来判断是否已经加载过
    final hasLoaded = messageState.messageTypeId == messageTypeId && !isLoading;
    
    if (messages.isEmpty && !hasLoaded) {
      ref.read(messageProvider(messageTypeId).notifier).loadMessages(messageTypeId);
    }
  }

  Widget _buildRightWidget() {
    final unreadCount = ref.watch(unreadCountDataProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 未读消息数量红点
        if (unreadCount > 0)
          Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        // 清除按钮
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showClearMessagesDialog(),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: CommonImage(imagePath: "assets/images/clear.png", width: 16.w, height: 16.h),
          ),
        ),
      ],
    );
  }

  /// 显示清除消息确认对话框
  Future<void> _showClearMessagesDialog() async {
    await Pop.confirm(
      title: '确认清除',
      content: '确定要清除所有消息吗？此操作不可恢复。',
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: () async {
        await ref.read(messageProvider(null).notifier).clearAllMessages();
        // 刷新未读消息数量
        ref.read(unreadCountProvider.notifier).refresh();
      },
    );
        
  }

  List<Widget> _buildTabViews() {
    return [
      _buildMessageList(null, _allMessagesController), // 全部消息
      _buildMessageList(1, _orderMessagesController), // 订单消息
      _buildMessageList(2, _systemMessagesController), // 系统消息
    ];
  }

  Widget _buildMessageList(int? messageTypeId, RefreshController controller) {
    final messages = ref.watch(messageListProvider(messageTypeId));
    final isLoading = ref.watch(messageLoadingProvider(messageTypeId));
    final error = ref.watch(messageErrorProvider(messageTypeId));
    final hasMore = ref.watch(messageHasMoreProvider(messageTypeId));
    final messageState = ref.watch(messageProvider(messageTypeId));

    // 判断是否已经加载过：检查 messageTypeId 是否匹配且不在加载中
    // 如果 messageTypeId 匹配且不在加载中，说明已经请求过（即使 total 为 0 也表示已请求过）
    final hasLoaded = messageState.messageTypeId == messageTypeId && 
                      !isLoading && 
                      (messageState.total >= 0 || _initializedTypes.contains(messageTypeId));
    
    // 如果消息列表为空且未在加载中，且未初始化过，则自动加载数据
    if (messages.isEmpty && !isLoading && error == null && !hasLoaded) {
      _initializedTypes.add(messageTypeId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(messageProvider(messageTypeId).notifier).loadMessages(messageTypeId);
        }
      });
    }

    // 初始加载
    if (isLoading && messages.isEmpty) {
      return const Center(child: CommonIndicator());
    }

    // 错误状态
    if (error != null && messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.read(messageProvider(messageTypeId).notifier).loadMessages(messageTypeId);
              },
              child: Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage(
              imagePath: "assets/images/empty_heart.png",
              width: 160.w,
              height: 120.h,
            ),
            CommonSpacing.large,
            Text(
              '暂无消息',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    // 消息列表
    return SmartRefresher(
      controller: controller,
      enablePullDown: true,
      enablePullUp: hasMore,
      onRefresh: () => _onRefresh(messageTypeId, controller),
      onLoading: () => _onLoading(messageTypeId, controller),
      header: CustomHeader(
        builder: (context, mode) => Padding(
          padding: EdgeInsets.symmetric(vertical: 16.w),
          child: CommonIndicator(size: 16.w),
        ),
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          if (mode == LoadStatus.loading) {
            return const CustomRefreshFooter();
          } else if (mode == LoadStatus.noMore) {
            return const CustomNoMoreIndicator();
          }
          return const SizedBox.shrink();
        },
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return MessageItemWidget(
            message: message,
            onTap: () => _onMessageTap(message),
          );
        },
      ),
    );
  }

  /// 下拉刷新
  Future<void> _onRefresh(int? messageTypeId, RefreshController controller) async {
    await ref.read(messageProvider(messageTypeId).notifier).refresh(messageTypeId);
    // 刷新未读消息数量
    ref.read(unreadCountProvider.notifier).refresh();
    controller.refreshCompleted();
  }

  /// 上拉加载更多
  Future<void> _onLoading(int? messageTypeId, RefreshController controller) async {
    await ref.read(messageProvider(messageTypeId).notifier).loadMore(messageTypeId);
    controller.loadComplete();
  }

  /// 点击消息项
  Future<void> _onMessageTap(models.MessageItem message) async {
    // 如果消息未读，标记为已读
    if (message.status == 0 && message.id != null) {
      // 等待标记已读完成后再刷新未读消息数量
      await ref.read(messageProvider(message.messageTypeId).notifier).markAsRead(message.id!);
      // 刷新未读消息数量
      ref.read(unreadCountProvider.notifier).refresh();
    }
    
    // TODO: 根据 messageTypeId 和 extension 进行路由跳转
    // 例如：如果是订单消息，跳转到订单详情页
    Logger.info('MessagePage', '点击消息: id=${message.id}, type=${message.messageTypeId}');
  }
}