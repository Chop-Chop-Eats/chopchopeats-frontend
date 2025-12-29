import 'package:flutter/material.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/widgets/common_spacing.dart';

class BalanceItem extends StatelessWidget {
  final String title;
  final String value;
  final String time;
  final String balance;
  const BalanceItem({
    super.key,
    required this.title,
    required this.value,
    required this.time,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppValues.labelTitle.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: AppValues.labelTitle.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        CommonSpacing.small,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time, style: AppValues.labelValue),
            Text("余额：$balance", style: AppValues.labelValue),
          ],
        ),
        CommonSpacing.medium,
      ],
    );
  }
}
