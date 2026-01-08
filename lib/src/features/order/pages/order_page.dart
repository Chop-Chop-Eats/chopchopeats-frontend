import 'package:chop_user/src/core/l10n/app_localizations.dart';
import 'package:chop_user/src/features/order/widgets/order_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const int _tabCount = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.orderTabAll,
      l10n.orderTabPending,
      l10n.orderTabInProgress,
      l10n.orderTabCompleted,
      l10n.orderTabCancelled,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l10n.tabOrder,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
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
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFFF5722),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 13.sp),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            labelPadding: EdgeInsets.zero,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
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
