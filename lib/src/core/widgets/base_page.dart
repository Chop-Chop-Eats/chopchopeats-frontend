import 'package:flutter/material.dart';
import 'common_spacing.dart';
import 'tabbar_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? rightWidget;
  const BasePage({
    super.key, 
    required this.title, 
    required this.content,
    this.rightWidget
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          color: Colors.white,
          child: Column(
            children: [
              CommonSpacing.large,
              TabbarAppBar(title: title, rightWidget: rightWidget),
              CommonSpacing.large,
              Expanded(child: content)
            ],
          ),
        ),
      ),
    );
  }
}