import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chop_user/src/core/widgets/common_spacing.dart';
import 'package:chop_user/src/features/comment/providers/shop_comment_provider.dart';
import 'package:chop_user/src/features/comment/widgets/shop_comment_item.dart';
import 'package:chop_user/src/features/comment/widgets/shop_comment_sheet.dart';
import 'package:chop_user/src/core/l10n/app_localizations.dart';

class ShopCommentSection extends ConsumerStatefulWidget {
  final String shopId;

  const ShopCommentSection({super.key, required this.shopId});

  @override
  ConsumerState<ShopCommentSection> createState() => _ShopCommentSectionState();
}

class _ShopCommentSectionState extends ConsumerState<ShopCommentSection> {
  @override
  void initState() {
    super.initState();
    // Load comments when the section is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopCommentProvider(widget.shopId).notifier)
          .loadComments(refresh: true);
    });
  }

  void _showAllComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShopCommentSheet(shopId: widget.shopId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopCommentProvider(widget.shopId));
    final l10n = AppLocalizations.of(context)!;

    if (state.list.isEmpty && !state.isLoading) {
      return const SizedBox(); // Hide if no comments
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFF333333),
                  size: 20.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${state.averageRate}${l10n.commentRatingSuffix}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '· ${state.total}${l10n.commentCount}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          CommonSpacing.small,
          SizedBox(
            height: 208.w, // Fixed height for horizontal list
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: state.list.length > 3 ? 3 : state.list.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return ShopCommentItem(
                  comment: state.list[index],
                  isPreview: true,
                );
              },
            ),
          ),
          CommonSpacing.small,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () => _showAllComments(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.commentViewAll,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
