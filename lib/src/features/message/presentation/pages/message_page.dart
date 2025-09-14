import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/base_page.dart';
import '../widgets/message_tab_bar.dart';
import '../widgets/message_item.dart';


class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["全部", "订单消息", "系统消息"];

  @override
  Widget build(BuildContext context) {
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
        },
      ),
    );
  }

  Widget _buildRightWidget(){
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Logger.info("MessagePage", "清除消息");
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Image.asset("assets/images/clear.png" , width: 16.w, height: 16.h,),
      ),
    );
  }

  List<Widget> _buildTabViews() {
    return [
      _buildAllMessages(),
      _buildOrderMessages(),
      _buildSystemMessages(),
    ];
  }

  Widget _buildAllMessages() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return MessageItem(
          title: "全部消息 $index", 
          time: "2021-01-01", 
          content: "全部消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容 $index", 
          isRead: index % 2 == 0, 
          imagePath: "assets/images/message_${index + 1}.png"
        );
      },
    );
  }

  Widget _buildOrderMessages() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return MessageItem(
          title: "订单消息 $index", 
          time: "2021-01-02", 
          content: "订单消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容 $index", 
          isRead: index % 2 == 1, 
          imagePath: "assets/images/message_${index + 1}.png"
        );
      },
    );
  }

  Widget _buildSystemMessages() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return MessageItem(
          title: "系统消息 $index", 
          time: "2021-01-03", 
          content: "系统消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容消息内容 $index", 
          isRead: index % 3 == 0, 
          imagePath: "assets/images/message_${(index % 3) + 1}.png"
        );
      },
    );
  }
}