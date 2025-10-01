import 'package:unified_popups/unified_popups.dart';

/// Toast工具类，提供简化的Toast调用方式
class Toast {
  /// 显示普通Toast
  static void show(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Pop.toast(
      message,
      duration: duration,
      position: position,
      toastType: ToastType.none,
    );
  }

  /// 显示成功Toast
  static void success(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Pop.toast(
      message,
      duration: duration,
      position: position,
      toastType: ToastType.success,
    );
  }

  /// 显示错误Toast
  static void error(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Pop.toast(
      message,
      duration: duration,
      position: position,
      toastType: ToastType.error,
    );
  }

  /// 显示警告Toast
  static void warn(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Pop.toast(
      message,
      duration: duration,
      position: position,
      toastType: ToastType.warn, // 使用error类型显示警告
    );
  }

}

/// 全局Toast实例，提供更简洁的调用方式
final toast = _Toast();

/// Toast实例类
class _Toast {
  /// 显示普通Toast
  void call(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Toast.show(message, duration: duration, position: position);
  }

  /// 显示成功Toast
  void success(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Toast.success(message, duration: duration, position: position);
  }

  /// 显示错误Toast
  void error(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Toast.error(message, duration: duration, position: position);
  }

  /// 显示警告Toast
  void warn(String message, {
    Duration duration = const Duration(milliseconds: 1200),
    PopupPosition position = PopupPosition.center,
  }) {
    Toast.warn(message, duration: duration, position: position);
  }
}