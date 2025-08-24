import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/performance_monitor.dart';
import '../../core/utils/logger/logger.dart';

class PerformanceDebugPage extends StatefulWidget {
  const PerformanceDebugPage({super.key});

  @override
  State<PerformanceDebugPage> createState() => _PerformanceDebugPageState();
}

class _PerformanceDebugPageState extends State<PerformanceDebugPage> {
  final PerformanceMonitor _monitor = PerformanceMonitor.instance;
  Map<String, Map<String, dynamic>> _stats = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshStats();
    // 每5秒刷新一次统计数据
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _refreshStats();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshStats() {
    setState(() {
      _stats = _monitor.getAllStats();
    });
  }

  void _clearStats() {
    _monitor.clearStats();
    _refreshStats();
    Logger.info('PerformanceDebugPage', '统计数据已清理');
  }

  void _printReport() {
    _monitor.printPerformanceReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('性能调试'),
        actions: [
          IconButton(
            onPressed: _clearStats,
            icon: const Icon(Icons.clear),
            tooltip: '清理统计',
          ),
          IconButton(
            onPressed: _printReport,
            icon: const Icon(Icons.print),
            tooltip: '打印报告',
          ),
        ],
      ),
      body: Column(
        children: [
          // 操作按钮
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _refreshStats,
                    child: const Text('刷新统计'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 模拟一些操作来测试性能监控
                      _monitor.startOperation('test_operation');
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _monitor.endOperation('test_operation');
                        _refreshStats();
                      });
                    },
                    child: const Text('测试监控'),
                  ),
                ),
              ],
            ),
          ),
          
          // 统计数据
          Expanded(
            child: _stats.isEmpty
                ? const Center(
                    child: Text('暂无性能数据，请先进行一些操作'),
                  )
                : ListView.builder(
                    itemCount: _stats.length,
                    itemBuilder: (context, index) {
                      final entry = _stats.entries.elementAt(index);
                      final operationName = entry.key;
                      final stat = entry.value;
                      
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                operationName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildStatRow('执行次数', '${stat['count']}'),
                              _buildStatRow('平均耗时', '${stat['average_duration']}ms'),
                              _buildStatRow('最小耗时', '${stat['min_duration']}ms'),
                              _buildStatRow('最大耗时', '${stat['max_duration']}ms'),
                              _buildStatRow('总耗时', '${stat['total_duration']}ms'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
