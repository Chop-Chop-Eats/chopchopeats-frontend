import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:chop_user/src/core/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(title: "钱包" , backgroundColor: Colors.transparent),
          Expanded(child: 
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  CommonSpacing.large,
                  // 钱包信息
                  _buildWalletInfo(),
                  // 支付方式
                  _buildPaymentMethod(),
                  // 余额明细
                  Expanded(
                    child: _buildBalanceDetail(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      margin: EdgeInsets.only(bottom: 24.h),
      child: child,
    );
  }

  Widget _buildWalletInfo() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("钱包余额" , style: AppValues.labelValue,),
          CommonSpacing.medium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1000" , style: AppValues.labelTitle.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w500),),
              CommonButton(
                text: "充值", 
                padding: EdgeInsets.symmetric(horizontal:  24.w, vertical: 8.h),
                borderRadius: BorderRadius.circular(8.r),
                onPressed:(){
                  Logger.info("WalletPage", "充值");
                }
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Logger.info("WalletPage", "管理绑定卡片");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.confirmOrderPaymentMethod , style: AppValues.labelTitle,),
            Row(
              children: [
                Text("管理绑定卡片" , style: AppValues.labelValue,),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDetail() {
    return _buildCard(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Logger.info("WalletPage", "查看全部");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("余额明细" , style: AppValues.labelTitle,),
                Row(
                  children: [
                    Text("查看全部" , style: AppValues.labelValue,),
                    CommonSpacing.width(4.w),
                    Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade600),
                  ],
                ),
              ],
            ),
          ),
          
          CommonSpacing.medium,
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildBalanceDetailItem(
                  title: "余额明细$index",
                  value: "1000",
                  time: "2021-01-01",
                  balance: "1000",
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceDetailItem({
    required String title,
    required String value,
    required String time,
    required String balance,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title , style: AppValues.labelTitle.copyWith(fontWeight: FontWeight.w500),),
            Text(value , style: AppValues.labelTitle.copyWith(fontWeight: FontWeight.w500),),
          ],
        ),
        CommonSpacing.small,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time , style: AppValues.labelValue,),
            Text(balance , style: AppValues.labelValue,),
          ],
        ),
        CommonSpacing.medium,
      ],
    );
  }
}