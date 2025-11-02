import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CommonAppBar(title: l10n.address , backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            // 可以滚动的地址列表
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  // 模拟10条数据
                  final name = "张三${index + 1}";
                  final phone = "13800138000${index + 1}";
                  final address = "北京市房山区${index + 1}";
                  if (index <= 10) {
                    return _buildAddressItem(name: name, phone: phone, address: address, isDefault: (index == 0));
                  }
                },
              ),
            ),
    
            // 居于屏幕底部 避开安全区域
            GestureDetector(
              onTap: () {
                Logger.info("AddressPage", "添加地址");
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(l10n.addAddress , style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold,),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem({
    required String name,
    required String phone,
    required String address,
    bool isDefault = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonImage(
            imagePath: "assets/images/location.png",
            width: 48.w,
            height: 36.h,
          ),
          CommonSpacing.width(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (isDefault) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 4.w,
                            ),
                            margin: EdgeInsets.only(left: 6.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              "默认",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Logger.info("AddressPage", "编辑地址");
                      },
                      child: Icon(
                        Icons.edit,
                        size: 16.w,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                CommonSpacing.small,
                // 电话
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
                CommonSpacing.small,
                // 详细地址
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
