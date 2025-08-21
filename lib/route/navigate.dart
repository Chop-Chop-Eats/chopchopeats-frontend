import 'package:flutter/material.dart';

class Navigate {
  Navigate._(); // 单例模式
  /// 导航到新页面 (push)
  ///
  /// [context]: 当前 BuildContext
  /// [routeName]: 来自 Routes 的路由名称
  /// [arguments]: (可选) 传递给目标页面的参数
  /// 返回一个 Future，可以接收从目标页面 pop 返回的结果
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// 替换当前页面 (replace)
  /// [context]: 当前 BuildContext
  /// [routeName]: 来自 AppRoutes 的路由名称
  /// [arguments]: (可选) 传递给目标页面的参数
  /// 返回一个 Future，但通常在替换场景下不太关心其结果
  static Future<T?> replace<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      context,
    ).pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  /// 导航到新页面，并移除栈中所有之前的页面 (常用语登录后跳转首页)
  ///
  /// [context]: 当前 BuildContext
  /// [routeName]: 来自 AppRoutes 的路由名称
  /// [arguments]: (可选) 传递给目标页面的参数
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    // RoutePredicate? predicate, // 如果需要更复杂的移除逻辑，可以暴露 predicate
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (Route<dynamic> route) => false, // 移除所有之前的路由
      arguments: arguments,
    );
  }

  /// 导航到新页面，并移除栈中直到某个条件满足的页面
  static Future<T?> pushAndRemoveUntilPredicate<T extends Object?>(
    BuildContext context,
    String newRouteName, {
    required RoutePredicate predicate,
    Object? arguments,
  }) {
    return Navigator.of(
      context,
    ).pushNamedAndRemoveUntil<T>(newRouteName, predicate, arguments: arguments);
  }

  /// 返回上一页 (pop)
  /// [context]: 当前 BuildContext
  /// [result]: (可选) 返回给上一个页面的数据
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    // 检查是否可以 pop，避免在根路由上 pop 导致应用崩溃
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<T>(result);
    } else {
      // 可以选择在这里执行其他操作，比如退出应用 (但不推荐直接退出)
      // SystemNavigator.pop();
    }
  }

  /// 返回到指定名称的路由
  /// 例如，从 D 返回到 A (如果 A 在栈中)
  /// 注意：这会 pop 掉目标路由之上的所有页面
  /// [context]: 当前 BuildContext
  /// [routeName]: 目标路由的名称 (来自 AppRoutes)
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// 检查当前路由是否是栈顶路由
  /// [context]: 当前 BuildContext
  /// [routeName]: 要检查的路由名称
  static bool isRoutesTop(BuildContext context, String routeName) {
    bool isCurrent = false;
    // 使用 popUntil 来检查，但并不实际 pop
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = route.isCurrent;
      }
      // 始终返回 false，这样 popUntil 不会移除任何路由
      // 或者返回 true 来停止遍历 (如果只需要检查栈顶)
      return true; // Stop iterating once found or not
    });
    // A more robust way might involve directly inspecting the navigator stack if possible,
    // but ModalRoute.of(context)?.settings.name == routeName is simpler for just the top route.
    // For simplicity, let's just check the top route:
    return ModalRoute.of(context)?.settings.name == routeName;
  }

  static bool isCurrent(BuildContext context , String routeName) {
    bool isCurrent = false;
    // 使用 popUntil 来检查，但并不实际 pop
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = route.isCurrent;
      }
      return true; // 停止遍历
    });
    return isCurrent;
  }
}
