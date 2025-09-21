import 'src/app_bootstrap.dart';
import 'src/core/config/app_environment.dart';

void main() {
  // Dart 内置的 Stopwatch 类来精确计时 创建并启动
  final Stopwatch stopwatch = Stopwatch()..start();
  // 委托所有启动任务给引导程序 默认开启全局错误监听 日志系统自带
  AppBootstrap.run(
    environment: AppEnvironment.development,
    stopwatch:stopwatch
  );
}