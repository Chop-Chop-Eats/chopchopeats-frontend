import 'package:flutter/material.dart';
import '../core/widgets/custom_bottom_nav_bar.dart';
import 'home/presentation/pages/home_page.dart';
import 'heart/presentation/pages/heart_page.dart';
import 'message/presentation/pages/message_page.dart';
import 'order/presentation/pages/order_page.dart';
import 'mine/presentation/pages/mine_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HeartPage(),
    const OrderPage(),
    const MessagePage(),
    const MinePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 IndexedStack 来保持每个 Tab 页面的状态
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}