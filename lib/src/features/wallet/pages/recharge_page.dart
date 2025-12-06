
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_spacing.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(title: "钱包充值" , backgroundColor: Colors.transparent),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonSpacing.standard,
                Text("选择或输入充值金额" , style: AppValues.labelTitle,),
                CommonSpacing.standard,
                Row(
                  children: [
                    Expanded(
                      child: _buildAmountItem(
                        tip: "送\$100",
                        amount: "100",
                        onTap: () {},
                        isSelected: true,
                      ),    
                    ),
                    Expanded(
                      child: _buildAmountItem(
                        tip: "送\$100",
                        amount: "100",
                        onTap: () {},
                        isSelected: false,
                      ),
                    ),
                    Expanded(
                      child: _buildAmountItem(
                        tip: "送\$100",
                        amount: "100",
                        onTap: () {},
                        isSelected: false,
                      ),
                    )
                  ],
                ),
                CommonSpacing.standard,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("\$", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
                    CommonSpacing.width(4.w),
                    Expanded( 
                      child: TextField(
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "请输入充值金额",
                          hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal, color: Colors.grey.shade500),
                          border: null,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                        ),
                      ),
                    )
                  ],
                ),
                CommonSpacing.standard,
                CommonButton(
                  text: "充值",
                  onPressed: () {
                    Logger.info("RechargePage", "充值");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAmountItem({
    required String tip,
    required String amount,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : AppTheme.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color:  AppTheme.primaryOrange ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(6.r) , bottomLeft: Radius.circular(0.r), bottomRight: Radius.circular(6.r) ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Text(tip, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.normal, color: Colors.white),),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric( vertical: 12.h),
              child: Text(amount, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
            )
          ],
        ),
      ),
    );
  }
}