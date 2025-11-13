import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_spacing.dart';

class ShopEnterPage extends StatelessWidget {
  const ShopEnterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CommonAppBar(title: l10n.shopEnterTitle),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            Text(l10n.shopEnterTitle , style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            CommonSpacing.medium,
            CommonImage(imagePath: 'assets/images/cook.png' , height: 192.h,),
            Text(l10n.shopEnterProcess , style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Colors.black)),
            CommonSpacing.medium,
            _buildItem(imagePath: 'assets/images/download.png', title: l10n.shopEnterDownloadApp, description: l10n.shopEnterButtonDescription),
            _buildItem(imagePath: 'assets/images/add_user.png', title: l10n.shopEnterRegisterAccount, description: l10n.shopEnterRegisterAccountDescription),
            _buildItem(imagePath: 'assets/images/apply.png', title: l10n.shopEnterApplyExam, description: l10n.shopEnterApplyExamDescription),
            GestureDetector(
              onTap: () {
                // launchUrl(Uri.parse('https://www.google.com'));
                // 打开app store 或者 google play
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(l10n.shopEnterDownloadButton, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Colors.white)),
              ),
            )            
          ],
        ),
      )
    );
  }

  Widget _buildItem({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        CommonImage(imagePath: imagePath, height: 20.h,),
        CommonSpacing.width(12.w),
        Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Colors.black)),
            Text(description, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.black)),
          ],
        ),
      ],
    );
  }
}
