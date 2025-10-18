import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabbarAppBar extends StatelessWidget {
  final String title;
  final Widget? rightWidget;
  const TabbarAppBar({super.key, required this.title, this.rightWidget});
  

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title , style: titleTextStyle, textAlign: TextAlign.left,),
          if(rightWidget != null) rightWidget!,
        ],
      ),
    );
  }
}