import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前 Tab 索引 Provider
/// 用于追踪底部导航栏的当前选中页面
/// 
/// Tab 索引说明：
/// - 0: 首页 (HomePage)
/// - 1: 收藏 (HeartPage)
/// - 2: 订单 (OrderPage)
/// - 3: 消息 (MessagePage)
/// - 4: 我的 (MinePage)
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

