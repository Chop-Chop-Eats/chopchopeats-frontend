import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_spacing.dart';
import '../widgets/bottom_arc_container.dart';

class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          CommonAppBar(title: "确定订单"),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: _buildApplyContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyContainer() {
    return BottomArcContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 价格区域
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    // 现价
                    TextSpan(
                      text: "\$100.00",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    TextSpan(text: " "),
                    // 原价
                    TextSpan(
                      text: "\$120.00",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF86909C),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFF86909C),
                        decorationThickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text("含小费\$8.17后的总价", style: TextStyle(fontSize: 12.sp, color: Color(0xFF86909C))),
            ],
          ),
          // 按钮区域
          CommonButton(
            text: "结算",
            padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
            onPressed: () {}
          ),
        ],
      ),
    );
  }
}

