import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';
import '../models/message_models.dart' as models;

class MessageItemWidget extends StatelessWidget {
  final models.MessageItem message;
  final VoidCallback? onTap;

  const MessageItemWidget({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contentTextStyle = TextStyle(
      fontSize: 12.sp,
      color: Color(0xFF86909C),
      fontWeight: FontWeight.w400,
    );
    final titleTextStyle = TextStyle(
      fontSize: 16.sp,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    );

    // 判断是否未读：status == 0 表示未读
    final isUnread = message.status == 0;

    // 格式化时间
    final timeText = _formatTime(message.sentTime);

    // 获取图标路径
    final imagePath = _getIconPath(message.messageTypeId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIcon(imagePath),
                      CommonSpacing.width(16.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.localizedTitle,
                            style: titleTextStyle,
                          ),
                          Text(
                            timeText,
                            style: contentTextStyle,
                          ),
                        ],
                      )
                    ],
                  ),
                  if (isUnread)
                    Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    )
                ],
              ),
              CommonSpacing.medium,
              Text(
                message.localizedBody,
                style: contentTextStyle,
              ),
              CommonSpacing.extraLarge,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String imagePath) {
    return CommonImage(imagePath: imagePath, width: 48.w, height: 48.h);
  }

  /// 格式化时间显示
  String _formatTime(DateTime? sentTime) {
    if (sentTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(sentTime);

    // 如果是今天，显示时间
    if (sentTime.year == now.year &&
        sentTime.month == now.month &&
        sentTime.day == now.day) {
      return DateFormat('HH:mm').format(sentTime);
    }

    // 如果是昨天
    if (difference.inDays == 1) {
      return '昨天 ${DateFormat('HH:mm').format(sentTime)}';
    }

    // 如果是一周内
    if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm', 'zh_CN').format(sentTime);
    }

    // 其他情况显示完整日期时间
    return DateFormat('MMM dd, yyyy HH:mm', 'en_US').format(sentTime);
  }

  /// 根据消息类型获取图标路径
  String _getIconPath(int? messageTypeId) {
    if (messageTypeId == 1) {
      return 'assets/images/message_1.png';
    } else if (messageTypeId == 2) {
      return 'assets/images/message_2.png';
    } else {
      return 'assets/images/message_3.png';
    }
  }
}
