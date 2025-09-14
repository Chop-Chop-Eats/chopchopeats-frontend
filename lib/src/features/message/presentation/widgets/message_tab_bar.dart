import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/common_spacing.dart';

class MessageTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final List<Widget> tabViews;
  
  const MessageTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.tabViews,
    this.onTap,
  });

  @override
  State<MessageTabBar> createState() => _MessageTabBarState();
}

class _MessageTabBarState extends State<MessageTabBar> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(MessageTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _currentIndex) {
      _currentIndex = widget.selectedIndex;
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: widget.tabs.asMap().entries.map((entry) {
            int index = entry.key;
            String tabText = entry.value;
            bool isSelected = index == _currentIndex;
            
            return GestureDetector(
              onTap: () => _onTabTapped(index),
              child: Container(
                margin: EdgeInsets.only(right: index < widget.tabs.length - 1 ? 8.w : 0),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    tabText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        CommonSpacing.extraLarge,
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: widget.tabViews,
          ),
        ),
      ],
    );
  }
}
