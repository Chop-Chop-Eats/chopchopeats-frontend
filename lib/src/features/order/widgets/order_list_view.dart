import 'package:chop_user/src/core/routing/routes.dart';
import 'package:chop_user/src/features/order/providers/order_provider.dart';
import 'package:chop_user/src/features/order/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderListView extends ConsumerStatefulWidget {
  final int? statusGroup;

  const OrderListView({super.key, this.statusGroup});

  @override
  ConsumerState<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends ConsumerState<OrderListView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListProvider(widget.statusGroup).notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(orderListProvider(widget.statusGroup).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(orderListProvider(widget.statusGroup));

    if (state.isLoading && state.list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use a placeholder image if available, otherwise icon
             Icon(Icons.receipt_long, size: 64.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              "暂无美食订单",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              "快去寻找家的味道吧",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(orderListProvider(widget.statusGroup).notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
        itemCount: state.list.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.list.length) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ));
          }
          final order = state.list[index];
          return OrderCard(
            order: order,
            onTap: () {
              Navigator.pushNamed(context, Routes.orderDetail, arguments: order.orderNo);
            },
            onPay: () {
              // Handle pay
            },
            // ... other callbacks
          );
        },
      ),
    );
  }
}
