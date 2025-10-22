import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';

class UserinfoCard extends StatefulWidget {
  const UserinfoCard({super.key});

  @override
  State<UserinfoCard> createState() => _UserinfoCardState();
}

class _UserinfoCardState extends State<UserinfoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.w),
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.w),
              image: DecorationImage(
                image: AssetImage("assets/images/appbar_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonSpacing.medium,
                CommonImage(imagePath: "assets/images/user_avatar.png", width: 64.w, height: 64.h , borderRadius: 32.w),
                CommonSpacing.medium,
                Text("1234567890", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                CommonSpacing.small,
                Text("163@email", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildItem(title: "钱包", value: "9999元", tip: "去充值", onTap: () {})),
              Container(
                width: 1.w,
                height: 32.h,
                color: Colors.grey.shade400,
              ),
              Expanded(child: _buildItem(title: "优惠券", value: "2张", onTap: () {})),
            ],
          )
          
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title, 
    required String value,
    String? tip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Colors.grey.shade700)),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(tip != null) ...[
                      CommonSpacing.width(12.w),
                      Text(tip, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    ],
                    CommonSpacing.width(4.w),
                    Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.grey.shade600),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
