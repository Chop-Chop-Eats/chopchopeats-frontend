import 'dart:async';
import 'package:flutter/material.dart';
import 'logger/logger.dart';

/// 性能监控工具
/// 用于监控页面性能、内存使用和操作耗时
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  static PerformanceMonitor get instance => _instance;

  final Map<String, Stopwatch> _timers = {};
  final Map<String, int> _operationCounts = {};
  final Map<String, List<int>> _operationDurations = {};

  /// 开始监控某个操作
  void startOperation(String operationName) {
    _timers[operationName] = Stopwatch()..start();
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
    
    Logger.debug('Performance', '开始操作: $operationName (第${_operationCounts[operationName]}次)');
  }

  /// 结束监控某个操作
  void endOperation(String operationName) {
    final timer = _timers[operationName];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;
      
      _operationDurations[operationName] ??= [];
      _operationDurations[operationName]!.add(duration);
      
      Logger.info('Performance', '操作完成: $operationName - 耗时: ${duration}ms');
      
      // 清理定时器
      _timers.remove(operationName);
    }
  }

  /// 获取操作统计信息
  Map<String, dynamic> getOperationStats(String operationName) {
    final counts = _operationCounts[operationName] ?? 0;
    final durations = _operationDurations[operationName] ?? [];
    
    if (durations.isEmpty) {
      return {
        'operation': operationName,
        'count': counts,
        'average_duration': 0,
        'min_duration': 0,
        'max_duration': 0,
        'total_duration': 0,
      };
    }
    
    final total = durations.reduce((a, b) => a + b);
    final average = total / durations.length;
    final min = durations.reduce((a, b) => a < b ? a : b);
    final max = durations.reduce((a, b) => a > b ? a : b);
    
    return {
      'operation': operationName,
      'count': counts,
      'average_duration': average.round(),
      'min_duration': min,
      'max_duration': max,
      'total_duration': total,
    };
  }

  /// 获取所有操作统计信息
  Map<String, Map<String, dynamic>> getAllStats() {
    final stats = <String, Map<String, dynamic>>{};
    final allOperations = <String>{};
    allOperations.addAll(_operationCounts.keys);
    allOperations.addAll(_operationDurations.keys);
    
    for (final operation in allOperations) {
      stats[operation] = getOperationStats(operation);
    }
    
    return stats;
  }

  /// 打印性能报告
  void printPerformanceReport() {
    final stats = getAllStats();
    Logger.info('Performance', '=== 性能报告 ===');
    
    for (final entry in stats.entries) {
      final stat = entry.value;
      Logger.info('Performance', 
        '${stat['operation']}: 执行${stat['count']}次, '
        '平均耗时${stat['average_duration']}ms, '
        '总耗时${stat['total_duration']}ms'
      );
    }
    
    Logger.info('Performance', '=== 报告结束 ===');
  }

  /// 清理统计数据
  void clearStats() {
    _operationCounts.clear();
    _operationDurations.clear();
    Logger.info('Performance', '性能统计数据已清理');
  }

  /// 监控 Widget 构建性能
  Widget monitorWidgetBuild(String widgetName, Widget Function() builder) {
    return Builder(
      builder: (context) {
        startOperation('${widgetName}_build');
        final widget = builder();
        endOperation('${widgetName}_build');
        return widget;
      },
    );
  }

  /// 监控异步操作性能
  Future<T> monitorAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startOperation(operationName);
    try {
      final result = await operation();
      endOperation(operationName);
      return result;
    } catch (e) {
      endOperation(operationName);
      rethrow;
    }
  }
}

/// 性能监控 Mixin
mixin PerformanceMonitoringMixin<T extends StatefulWidget> on State<T> {
  final PerformanceMonitor _monitor = PerformanceMonitor.instance;

  @override
  void initState() {
    super.initState();
    _monitor.startOperation('${widget.runtimeType}_initState');
  }

  @override
  void dispose() {
    _monitor.endOperation('${widget.runtimeType}_dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _monitor.monitorWidgetBuild(
      widget.runtimeType.toString(),
      () => super.build(context),
    );
  }

  /// 监控异步操作
  Future<T> monitorAsync<T>(String operationName, Future<T> Function() operation) {
    return _monitor.monitorAsyncOperation(operationName, operation);
  }
}
