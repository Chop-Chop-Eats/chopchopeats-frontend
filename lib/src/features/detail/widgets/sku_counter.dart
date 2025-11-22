import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';

class SkuCounter extends StatefulWidget {
  const SkuCounter({super.key});

  @override
  State<SkuCounter> createState() => _SkuCounterState();
}

class _SkuCounterState extends State<SkuCounter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            // 数量必须 > 1
            onTap: () {
              // TODO: 实现减少数量逻辑
              Logger.info("ProductList", "点击减少数量");
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Icon(Icons.remove, size: 16.w, color: Colors.black),
            ),
          ),
          Text(
            '1', // TODO: 从购物车状态获取实际数量
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          GestureDetector(
            // 数量必须小于 sku.stock
            onTap: () {
              Logger.info("ProductList", "点击增加数量");
              // TODO: 实现增加数量逻辑
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              child: Icon(Icons.add, size: 16.w, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
