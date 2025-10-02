import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';

class MessageItem extends StatelessWidget {
  final String title;
  final String time;
  final String content;
  final bool isRead;
  final String imagePath;
  const MessageItem({
    super.key, 
    required this.title, 
    required this.time, 
    required this.content, 
    required this.isRead,
    required this.imagePath
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
    return Column(
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
                    Text(title , style: titleTextStyle,),
                    Text(time , style: contentTextStyle,),
                  ],
                )
              ],
            ),
            if(isRead)
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
        Text(content , style: contentTextStyle,),
        CommonSpacing.extraLarge,
      ],
    );
  }

  Widget _buildIcon(String imagePath){
    return CommonImage(imagePath: imagePath, width: 48.w, height: 48.h);
  }
}