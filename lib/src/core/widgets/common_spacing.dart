import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用间距组件
class CommonSpacing {
  /// 小间距 - 8
  static Widget get small => SizedBox(height: 8.h);
  
  /// 中等间距 - 12
  static Widget get medium => SizedBox(height: 12.h);
  
  /// 标准间距 - 16
  static Widget get standard => SizedBox(height: 16.h);
  
  /// 大间距 - 20
  static Widget get large => SizedBox(height: 20.h);
  
  /// 超大间距 - 24
  static Widget get extraLarge => SizedBox(height: 24.h);
  
  /// 超大间距 - 40
  static Widget get huge => SizedBox(height: 40.h);
  
  /// 自定义高度间距
  static Widget height(double height) => SizedBox(height: height.h);
  
  /// 自定义宽度间距
  static Widget width(double width) => SizedBox(width: width.w);
}

/// 带padding的容器组件
class PaddedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;

  const PaddedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

/// 表单容器组件
class FormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const FormContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return PaddedContainer(
      padding: padding ?? EdgeInsets.all(24.w),
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }
}
