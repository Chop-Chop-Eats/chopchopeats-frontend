import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// 通用的键盘避让页面组件
/// 
/// 自动处理键盘弹出时的页面调整，支持滚动和布局优化
/// 适用于所有包含输入框的页面
class KeyboardAwarePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomSheet;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const KeyboardAwarePage({
    super.key,
    required this.child,
    this.padding,
    this.physics,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomSheet,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomSheet: bottomSheet,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: physics ?? const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 认证页面专用的键盘避让组件
/// 
/// 专门为认证相关页面设计，包含常用的认证页面配置
class AuthKeyboardAwarePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final ScrollPhysics? physics;

  const AuthKeyboardAwarePage({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardAwarePage(
      backgroundColor: backgroundColor ?? Colors.white,
      padding: padding,
      physics: physics,
      child: child,
    );
  }
}

/// 带渐变背景的认证页面键盘避让组件
/// 
/// 专门为有装饰性背景的认证页面设计
class AuthGradientKeyboardAwarePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final ScrollPhysics? physics;

  const AuthGradientKeyboardAwarePage({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardAwarePage(
      backgroundColor: backgroundColor ?? const Color(0xFFF3F4F6),
      padding: padding,
      physics: physics,
      child: child,
    );
  }
}

/// 带滚动条的键盘避让页面组件
/// 
/// 当需要显示滚动条指示器时使用
class ScrollableKeyboardAwarePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final ScrollPhysics? physics;
  final Color? scrollbarColor;
  final double? scrollbarThickness;
  final Radius? scrollbarRadius;

  const ScrollableKeyboardAwarePage({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.physics,
    this.scrollbarColor,
    this.scrollbarThickness,
    this.scrollbarRadius,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardAwarePage(
      backgroundColor: backgroundColor,
      padding: padding,
      physics: physics,
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: scrollbarThickness ?? 6.0,
        radius: scrollbarRadius ?? const Radius.circular(3.0),
        child: child,
      ),
    );
  }
}
