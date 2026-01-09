import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:chop_user/src/core/widgets/common_spacing.dart';
import 'package:chop_user/src/features/comment/models/comment_model.dart';
import 'package:intl/intl.dart';
import 'package:chop_user/src/core/widgets/image_preview_page.dart';

class ShopCommentItem extends StatelessWidget {
  final AppMerchantShopCommentRespVO comment;
  final bool isPreview;

  const ShopCommentItem({
    super.key,
    required this.comment,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isPreview ? 300.w : double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: isPreview
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          CommonSpacing.small,
          _buildRatingAndDate(),
          CommonSpacing.small,
          Text(
            comment.comment,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF333333),
              height: 1.4,
            ),
            maxLines: isPreview ? 2 : null,
            overflow: isPreview ? TextOverflow.ellipsis : null,
          ),
          if (comment.image.isNotEmpty) ...[
            CommonSpacing.small,
            _buildImages(context),
          ],
          if (comment.reply != null && !isPreview) ...[
            CommonSpacing.medium,
            _buildReply(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        ClipOval(
          child: CommonImage(
            imagePath: comment.userAvatar,
            width: 32.w,
            height: 32.w,
            fit: BoxFit.cover,
            placeholder: Container(
              color: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[400], size: 20.w),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            comment.userNickname,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndDate() {
    return Row(
      children: [
        _buildStars(comment.rate),
        SizedBox(width: 8.w),
        Text(
          _formatDate(comment.createTime),
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  Widget _buildStars(int rate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rate ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFFFB800),
          size: 16.w,
        );
      }),
    );
  }

  Widget _buildImages(BuildContext context) {
    if (comment.image.isEmpty) return const SizedBox();
    
    // For preview, maybe show fewer images or smaller
    final imageCount = comment.image.length;
    final displayCount = isPreview ? (imageCount > 4 ? 4 : imageCount) : imageCount;

    return SizedBox(
      height: 80.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayCount,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewPage(
                    images: comment.image,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CommonImage(
                imagePath: comment.image[index],
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReply() {
    final reply = comment.reply!;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '商家回复',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              Text(
                _formatDate(reply.replyTime),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            reply.replyContent,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF666666),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 1) {
        return '今天';
      } else if (difference.inDays < 2) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return DateFormat('yyyy-MM-dd').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }
}
