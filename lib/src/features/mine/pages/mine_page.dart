import 'package:chop_user/src/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routing/navigate.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../auth/providers/auth_provider.dart';

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mine"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示用户信息
            if (authState.isAuthenticated && authState.user != null) ...[
              Text("欢迎回来！"),
              SizedBox(height: 8.h),
              Text("用户ID: ${authState.user!.userId}"),
              SizedBox(height: 20.h),
            ],
            
            const Text("Mine Page"),
            SizedBox(height: 20.h),
            
            // 登出按钮
            ElevatedButton(
              onPressed: authState.isLoading ? null : () async {
                Logger.info("MinePage", "开始登出流程");
                
                try {
                  await ref.read(authNotifierProvider.notifier).logout();
                  
                  if (!mounted) return;
                  
                  // 登出成功，跳转到登录页面
                  Logger.info("MinePage", "登出成功，跳转到登录页面");
                  Navigate.replace(context, Routes.login);
                } catch (e) {
                  Logger.error("MinePage", "登出失败", error: e);
                  if (!mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('登出失败: ${e.toString()}')),
                  );
                }
              },
              child: authState.isLoading ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CommonIndicator(),
              ) : const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}