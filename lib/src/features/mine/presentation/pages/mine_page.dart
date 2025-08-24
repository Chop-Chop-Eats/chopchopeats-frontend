import 'package:chop_user/src/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/navigate.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mine"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Mine Page"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (mounted) {
                  Navigate.replace(context, Routes.login);
                }
              },
              child: isLoading ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ) : const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}