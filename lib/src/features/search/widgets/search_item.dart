import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';

class SearchItem extends StatelessWidget {
  final String title;
  final bool? isHot;
  const SearchItem({super.key, required this.title, this.isHot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:  Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(isHot == true)...[
            CommonImage(imagePath: 'assets/images/search_fire.png', width: 16.w, height: 16.h),
            CommonSpacing.width(8.w),
          ],
          Text(title , style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black),),
        ],
      ),
    );
  }
}