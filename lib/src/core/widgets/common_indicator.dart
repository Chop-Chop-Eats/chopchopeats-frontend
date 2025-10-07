import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommonIndicator extends StatelessWidget {
  final double? strokeWidth;
  final Color? color;
  final double? size; // 圆圈的直径/大小
  final Color? backgroundColor; // 背景轨道的颜色
  
  const CommonIndicator({
    super.key, 
    this.strokeWidth = 2, 
    this.color = AppTheme.primaryOrange,
    this.size,
    this.backgroundColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth ?? 2, 
      color: color,
      backgroundColor: backgroundColor,
    );
    
    return Center(
      child: size != null ? 
      SizedBox(
        width: size,
        height: size,
        child: indicator
      ) : 
      indicator,
    );
  }
}