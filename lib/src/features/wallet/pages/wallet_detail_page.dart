import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../widgets/balance_item.dart';

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({super.key});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(title: "钱包" , backgroundColor: Colors.transparent),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 20,
                itemBuilder: (context, index) {
                  if(index == 0) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text("2025-07" ,style:  AppValues.labelValue,),
                    );
                  }
                  return BalanceItem(
                    title: "钱包余额" ,
                    value: "1000" ,
                    time: "2025-01-01" ,
                    balance: "1000" ,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}