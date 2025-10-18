import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/custom_bottom_nav_bar.dart';
import '../core/utils/logger/logger.dart';
import '../core/providers/tab_index_provider.dart';
import 'home/pages/home_page.dart';
import 'heart/pages/heart_page.dart';
import 'message/pages/message_page.dart';
import 'order/pages/order_page.dart';
import 'mine/pages/mine_page.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  
  /// 延迟加载：缓存已创建的页面
  final Map<int, Widget> _pageCache = {};

  @override
  void initState() {
    super.initState();
    // 首屏只创建首页
    _pageCache[0] = const HomePage();
    Logger.info('MainScreen', '首屏初始化完成，只加载首页');
  }

  /// 构建页面（延迟加载）
  Widget _buildPage(int index) {
    // 如果页面还未创建，则创建并缓存
    if (!_pageCache.containsKey(index)) {
      Logger.info('MainScreen', '延迟加载页面: index=$index');
      switch (index) {
        case 0:
          _pageCache[index] = const HomePage();
          break;
        case 1:
          _pageCache[index] = const HeartPage();
          break;
        case 2:
          _pageCache[index] = const OrderPage();
          break;
        case 3:
          _pageCache[index] = const MessagePage();
          break;
        case 4:
          _pageCache[index] = const MinePage();
          break;
        default:
          _pageCache[index] = const SizedBox.shrink();
      }
    }
    return _pageCache[index]!;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // 更新全局 Tab 索引 Provider，用于通知各页面
    ref.read(currentTabIndexProvider.notifier).state = index;
    Logger.info('MainScreen', '切换到 Tab: $index');
  }

  @override
  Widget build(BuildContext context) {
    // 使用 IndexedStack 来保持每个 Tab 页面的状态
    // 延迟加载：只创建已访问过的页面
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, (index) {
          // 如果是当前页面或已缓存的页面，显示真实页面
          // 否则显示空占位
          return index == _currentIndex || _pageCache.containsKey(index)
              ? _buildPage(index)
              : const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}