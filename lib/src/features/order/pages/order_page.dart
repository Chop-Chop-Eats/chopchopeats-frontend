import 'package:chop_user/src/features/order/widgets/order_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["全部", "待支付", "进行中", "已完成", "取消/退款"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "订单", 
          style: TextStyle(
            color: Colors.black, 
            fontSize: 20.sp, 
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF5722),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 14.sp),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrderListView(statusGroup: null), // All
          OrderListView(statusGroup: 1), // Pending
          OrderListView(statusGroup: 2), // In Progress
          OrderListView(statusGroup: 3), // Completed
          OrderListView(statusGroup: 4), // Cancel/Refund
        ],
      ),
    );
  }
}