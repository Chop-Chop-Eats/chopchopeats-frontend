import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_values.dart';
import '../l10n/app_localizations.dart';
import 'common_image.dart';
import 'common_spacing.dart';

class CommonEmpty extends StatelessWidget {
  final String? message;
  const CommonEmpty({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonImage(imagePath: 'assets/images/empty_heart.png' , height: 140.h),
          CommonSpacing.medium,
          Text(message ?? l10n.noDataText, style: AppValues.labelTitle,),
        ],
      ),
    );
  }
}