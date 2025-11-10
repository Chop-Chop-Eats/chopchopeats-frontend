import 'package:chop_user/src/features/auth/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import '../../features/address/pages/address_page.dart';
import '../../features/address/pages/add_address_page.dart';
import '../../features/address/models/address_models.dart';
import '../../features/auth/pages/password_login_page.dart';
import '../../features/auth/pages/set_new_password_page.dart';
import '../../features/auth/pages/verification_code_page.dart';
import '../../features/category/pages/category_detail_page.dart';
import '../../features/detail/pages/detail_page.dart';
import '../../features/error_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/main_screen.dart';
import '../../features/mine/pages/profile_page.dart';
import '../../features/search/pages/search_page.dart';
import '../../features/splash/pages/splash_page.dart';
import '../maps/map_picker_page.dart';
import 'routes.dart';

class AppRouter {
  static final Map<String, Widget Function(RouteSettings)> _routeHandlers = {
    Routes.home: (settings) => const MainScreen(),
    Routes.login: (settings) => const LoginPage(),
    Routes.passwordLogin: (settings) => PasswordLoginPage(phoneNumber: settings.arguments as String),
    Routes.forgotPassword: (settings) => ForgotPasswordPage(phoneNumber: settings.arguments as String),
    Routes.setNewPasswordPage: (settings) {
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        final code = args["code"] as String;
        final phoneNumber = args["phoneNumber"] as String;
        return SetNewPasswordPage(code: code, phoneNumber: phoneNumber);
      }
      return const ErrorPage(message: "参数错误或缺失");
    },
    Routes.search: (settings) => const SearchPage(),
    Routes.verificationCode: (settings) {
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        final phoneNumber = args["phoneNumber"] as String;
        final type = args["type"] as VerificationCodeType;
        final email = args["email"] as String?; // 可选参数
        return VerificationCodePage(phoneNumber: phoneNumber, type: type, email: email);
      }
      return const ErrorPage(message: "参数错误或缺失");
     },

    Routes.categoryDetail: (settings) {
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        final categoryId = args["categoryId"];
        final categoryName = args["categoryName"];
        if (categoryId is int && categoryName is String) {
          return CategoryDetailPage(categoryId: categoryId, categoryName: categoryName);
        }
      }
      return const ErrorPage(message: "分类ID参数错误或缺失");
    },

    Routes.detail: (settings) {
      if (settings.arguments is Map<String, dynamic>) {
        final args = settings.arguments as Map<String, dynamic>;
        final id = args["id"];
        return DetailPage(id: id);
      }
      return const ErrorPage(message: "参数错误或缺失");
    },
    Routes.profile: (settings) => const ProfilePage(),
    Routes.address: (settings) => const AddressPage(),
    Routes.addAddress: (settings) {
      final arguments = settings.arguments;
      if (arguments is AddressFormArguments) {
        return AddAddressPage(arguments: arguments);
      }
      return const AddAddressPage();
    },
    Routes.mapPicker: (settings) {
      final arguments = settings.arguments;
      if (arguments is MapPickerArguments) {
        return MapPickerPage(arguments: arguments);
      }
      return const ErrorPage(message: "地图参数错误或缺失");
    },
  };

  /// 创建路由方法
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // 查找与路由名称匹配的处理程序
    final handler = _routeHandlers[settings.name];

    if (settings.name == Routes.mapPicker) {
      final widget = handler?.call(settings) ?? const ErrorPage(message: "地图参数错误或缺失");
      return MaterialPageRoute<MapPickerResult?>(
        builder: (_) => widget,
        settings: settings,
      );
    }

    Widget page;
    if (handler != null) {
      // 如果找到，就用它来构建页面
      page = handler(settings);
    } else {
      // 如果没找到，默认显示错误页面
      page = const ErrorPage(message: "路由处理程序未定义");
    }

    // 根据路由名称决定使用哪种转场动画
    if (settings.name == Routes.splash) {
      return MaterialPageRoute<dynamic>(
        builder: (_) => const SplashPage(),
        settings: settings,
      );
    }

    // 使用优化的跨平台滑动动画
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }

  // unknownRoute 保持不变，作为最终的兜底
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const ErrorPage(message: "未知路由"),
      settings: settings,
    );
  }
}

/// 优化的跨平台滑动路由组件
/// 确保在 Android 和 iOS 上表现完全一致
class OptimizedSlideRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  @override
  final RouteSettings settings;

  OptimizedSlideRoute({
    required this.builder,
    required this.settings,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) : super(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 使用 RepaintBoundary 优化性能
      return RepaintBoundary(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // 从右侧开始
            end: Offset.zero, // 滑动到中央
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // 缓入缓出曲线
          )),
          child: child,
        ),
      );
    },
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
    reverseTransitionDuration: reverseTransitionDuration ?? const Duration(milliseconds: 300),
    // 确保跨平台一致性
    opaque: true,
    barrierDismissible: false,
    maintainState: true,
  );
}

/// 淡入淡出动画（用于 Splash 页面）
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  FadePageRoute({
    required this.builder,
    required super.settings,
    Duration? transitionDuration,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return RepaintBoundary(
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
    opaque: true,
    barrierDismissible: false,
    maintainState: true,
  );
}

// 保留原来的自定义路由类代码，以备将来需要时使用
/*
/// 自定义路由类 实现滑动动画 替换默认的MaterialPageRoute
class CustomPagePeterRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  @override
  final RouteSettings settings;

  CustomPagePeterRoute({required this.builder, required this.settings})
    : super(
        settings: settings,
        pageBuilder:
            (context, animation, secondaryAnimation) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 新页面从右侧开始
          const end = Offset.zero; // 滑动到屏幕中央
          const curve = Curves.easeInOut; // 缓入缓出曲线

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // 使用 RepaintBoundary 优化性能，减少不必要的重绘
          return RepaintBoundary(
            child: SlideTransition(
              position: offsetAnimation, 
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300), // 动画时长 300ms
      );
}
*/
