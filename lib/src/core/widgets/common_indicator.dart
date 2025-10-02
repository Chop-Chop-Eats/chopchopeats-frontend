import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommonIndicator extends StatelessWidget {
  final double? strokeWidth;
  final Color? color;
  const CommonIndicator({super.key, this.strokeWidth = 2, this.color = AppTheme.primaryOrange});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth, 
        color: color,
      ),
    );
  }
}