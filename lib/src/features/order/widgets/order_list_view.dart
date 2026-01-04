import 'package:chop_user/src/core/routing/routes.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:chop_user/src/features/order/pages/cancel_order_page.dart';
import 'package:chop_user/src/features/order/providers/order_provider.dart';
import 'package:chop_user/src/features/order/utils/order_payment_handler.dart';
import 'package:chop_user/src/features/order/widgets/order_card.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chop_user/src/features/detail/pages/detail_page.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';

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
            CommonImage(imagePath: "assets/images/no_order.png", width: 300.w, height: 300.h),
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.statusGroupName ?? order.statusName ?? '',
                      style: TextStyle(
                        fontSize: 20.sp, // Increased from 18
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6.h), // Increased from 4
                    if (order.status == 100) ...[
                      // Pending Payment - Real countdown
                      Builder(
                        builder: (context) {
                          if (order.createTime == null || order.orderPeriod == null) return const SizedBox();
                          final createTime = DateTime.tryParse(order.createTime!);
                          if (createTime == null) return const SizedBox();
                          
                          final expireTime = createTime.add(Duration(minutes: order.orderPeriod!));
                          final now = DateTime.now();
                          final diff = expireTime.difference(now);
                          
                          if (diff.isNegative) {
                             return Text(
                              "已失效",
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                            );
                          }
                          
                          final minutes = diff.inMinutes;
                          final seconds = diff.inSeconds % 60;
                          
                          return Text(
                            "$minutes分 $seconds秒 后失效",
                            style: TextStyle(
                              fontSize: 14.sp, // Increased from 12
                              color: const Color(0xFFFF5722),
                            ),
                          );
                        }
                      ),
                    ] else ...[
                      Text(
                        order.statusDesc ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              OrderCard(
                order: order,
                onTap: () {
                  Navigator.pushNamed(context, Routes.orderDetail, arguments: order.orderNo);
                },
                onPay: () {
                  OrderPaymentHandler.processPayment(
                    orderNo: order.orderNo ?? '',
                    onSuccess: () {
                      ref.read(orderListProvider(widget.statusGroup).notifier).refresh();
                    },
                    onError: (error) {
                      // Error already handled by OrderPaymentHandler
                    },
                  );
                },
                onRefund: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CancelOrderPage(
                        orderNo: order.orderNo ?? '',
                        isRefund: true,
                        onSuccess: () {
                          ref.read(orderListProvider(widget.statusGroup).notifier).refresh();
                        },
                      ),
                    ),
                  );
                },
                onCancel: () {
                  ref.read(orderListProvider(widget.statusGroup).notifier).refresh();
                },
                onReorder: () => _handleReorder(context, order, ref),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 处理重新下单逻辑
  Future<void> _handleReorder(BuildContext context, AppTradeOrderPageRespVO order, WidgetRef ref) async {
    if (order.shopId == null || order.shopId!.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('无法获取店铺信息'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }

    Logger.info('OrderListView', '重新下单: 跳转到店铺详情页 shopId=${order.shopId}');

    if (!context.mounted) return;

    // 直接导航到店铺详情页，让用户重新选择商品
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(id: order.shopId!),
      ),
    );
  }
}
