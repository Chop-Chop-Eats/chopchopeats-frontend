import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/base_page.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../providers/mine_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userInfo = ref.watch(userInfoDataProvider);
    final isLoading = ref.watch(userInfoLoadingProvider);
    final error = ref.watch(userInfoErrorProvider);

       // 显示加载状态
    if (isLoading && userInfo == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.w),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: const CommonIndicator(color: Colors.white,),
        ),
      );
    }

    // 显示错误状态
    if (error != null && userInfo == null) {
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
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red),
              SizedBox(height: 16.h),
              Text('加载失败', style: TextStyle(fontSize: 16.sp, color: Colors.red)),
              SizedBox(height: 8.h),
              Text(error, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ],
          ),
        ),
      );
    }


    return  Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppBar(title: l10n.profile, backgroundColor: Colors.transparent,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _buildRowItem(title: l10n.avatar, value: userInfo?.avatar ?? '', isImage: true, onTap: () {}),
                  _buildRowItem(title: l10n.nickname, value: userInfo?.nickname ?? '', onTap: () {}),
                  _buildRowItem(title: l10n.phone, value: userInfo?.mobile ?? '', onTap: () {}),
                  _buildRowItem(title: l10n.email, value: userInfo?.email ?? '', isArrow: false, onTap: () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildRowItem({
    bool? isImage = false,
    bool? isArrow = true,
    required String title,
    required String value,
    required VoidCallback onTap,
  }){
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,color: Colors.black),),
            Row(
              children: [
                if(isImage != null && isImage)
                  CommonImage(
                    imagePath: value.isNotEmpty ? value : "assets/images/avatar.png", 
                    width: 48.w, 
                    height: 48.h, 
                    borderRadius: 24.w
                  )
                else
                  Text(value, style: TextStyle(fontSize: 14.sp,color: Colors.grey.shade600),),
                if(isArrow != null && isArrow)...[
                  CommonSpacing.width(8.w),
                  Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.grey.shade600),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
