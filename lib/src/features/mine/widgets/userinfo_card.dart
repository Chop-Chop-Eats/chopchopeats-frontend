import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/l10n/app_localizations.dart';

class UserinfoCard extends StatefulWidget {
  const UserinfoCard({super.key});

  @override
  State<UserinfoCard> createState() => _UserinfoCardState();
}

class _UserinfoCardState extends State<UserinfoCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.w),
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 2.w,
            offset: Offset(0, 1.w),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24.w), topRight: Radius.circular(24.w)),
              image: DecorationImage(
                image: AssetImage("assets/images/appbar_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h),
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
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24.w), bottomRight: Radius.circular(24.w)),
              gradient: LinearGradient(colors: [Color(0xFFEAEFF5), Color(0xFFFBFDFF)]),
            ),
            padding: EdgeInsets.all(6.w),
            child: Row(
              children: [
                Expanded(child: _buildItem(title: l10n.wallet, value: "9999元", tip: l10n.recharge, onTap: () {})),
                Container(
                  width: 1.w,
                  height: 48.h,
                  color: Colors.grey.shade400,
                ),
                Expanded(child: _buildItem(title: l10n.coupons, value: "2张", onTap: () {})),
              ],
            ),
          ),
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
