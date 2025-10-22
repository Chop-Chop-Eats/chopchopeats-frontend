import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';

class ShopEnter extends StatelessWidget {
  const ShopEnter({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Logger.info('ShopEnter', '商家入驻');
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("商家入驻", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            Row(
              children: [
                Text("0元轻松入驻", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                CommonSpacing.width(4.w),
                Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey.shade600),
              ],
            )
          ],
        ),
      ),
    );
  }
}