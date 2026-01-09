import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:chop_user/src/core/widgets/common_empty.dart';
import 'package:chop_user/src/core/widgets/common_indicator.dart';
import 'package:chop_user/src/core/widgets/custom_refresh_footer.dart';
import 'package:chop_user/src/features/comment/providers/shop_comment_provider.dart';
import 'package:chop_user/src/features/comment/widgets/shop_comment_item.dart';

class ShopCommentSheet extends ConsumerStatefulWidget {
  final String shopId;

  const ShopCommentSheet({super.key, required this.shopId});

  @override
  ConsumerState<ShopCommentSheet> createState() => _ShopCommentSheetState();
}

class _ShopCommentSheetState extends ConsumerState<ShopCommentSheet> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    // Initial load if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(shopCommentProvider(widget.shopId));
      if (state.list.isEmpty && !state.isLoading) {
        ref.read(shopCommentProvider(widget.shopId).notifier).loadComments(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onLoading() async {
    await ref.read(shopCommentProvider(widget.shopId).notifier).loadComments();
    final state = ref.read(shopCommentProvider(widget.shopId));
    if (state.hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopCommentProvider(widget.shopId));

    return Container(
      height: 0.8.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          _buildHeader(state.total, state.averageRate),
          Expanded(
            child: state.isLoading && state.list.isEmpty
                ? const Center(child: CommonIndicator())
                : state.list.isEmpty
                    ? const CommonEmpty(message: '暂无评价')
                    : SmartRefresher(
                        controller: _refreshController,
                        enablePullDown: false,
                        enablePullUp: true,
                        onLoading: _onLoading,
                        footer: CustomFooter(
                          builder: (context, mode) {
                            if (mode == LoadStatus.loading) {
                              return const CustomRefreshFooter();
                            } else if (mode == LoadStatus.noMore) {
                              return const CustomNoMoreIndicator();
                            }
                            return const SizedBox();
                          },
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: state.list.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            return ShopCommentItem(comment: state.list[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int total, double averageRate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: const Color(0xFFFFB800), size: 24.w),
              SizedBox(width: 4.w),
              Text(
                '$averageRate分',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '· $total条评价',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, size: 24.w, color: const Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
