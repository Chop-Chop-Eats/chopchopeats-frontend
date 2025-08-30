import 'package:chop_user/src/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class HeartPage extends ConsumerStatefulWidget {
  const HeartPage({super.key});

  @override
  ConsumerState<HeartPage> createState() => _HeartPageState();
}

class _HeartPageState extends ConsumerState<HeartPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Heart"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Heart Page"),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}