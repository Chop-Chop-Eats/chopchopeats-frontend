import 'package:flutter/material.dart';

import '../route/navigate.dart';


class ErrorPage extends StatefulWidget {
  final String? message;
  const ErrorPage({super.key , this.message});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  // 定义要返回的固定结果
  static const String _popResult = "callback is errorPage";

  @override
  Widget build(BuildContext context) {
    String? displayMessage = widget.message ?? "error message" ;

    // 使用 PopScope 包裹页面主体
    return PopScope(
      // 设置为 false 表示阻止由系统触发的默认弹出行为（例如安卓返回按钮、iOS 右滑手势）
      // 我们需要阻止默认行为，以便能在 onPopInvoked 中手动弹出并携带结果。
      canPop: false,
      // 当尝试弹出此路由时调用。
      // didPop 参数表示弹出是否 已经 成功执行（基于 canPop 的值）。
      // result 参数是触发此回调的 Navigator.pop(result) 调用中传递的值（如果提供了）。
      onPopInvokedWithResult: (bool didPop, String? result) {
        // 因为 canPop 设置为 false，所以 didPop 总是 false。
        // 这意味着无论是系统手势/按钮还是程序化的 pop 调用，
        // 默认的弹出行为都被阻止了。
        if (!didPop) {
          // 检查 context 是否仍然有效，这是一个好习惯
          if (context.mounted) {
            // 手动调用 pop 并传递我们预设的固定结果 _popResult。
            Navigate.pop(context , _popResult);
          }
        }
        // 此处不需要 else 分支，因为 didPop 在 canPop 为 false 时总是 false。
      },
      child: Scaffold(
        appBar: null,
          body: Center(
              child: Column( // 使用 Column 添加一个返回按钮示例
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("error page : $displayMessage"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // 点击按钮尝试弹出页面。
                      // 这个 Navigator.pop() 调用也会被 PopScope 拦截。
                      // 因为 canPop 是 false，这个直接调用也会被阻止。
                      // 然后 onPopInvoked 会被调用，didPop 会是 false。
                      // 最终，onPopInvoked 内部的逻辑会执行手动 pop 并返回 _popResult。
                      Navigate.pop(context);
                      // 或者使用 Navigate.pop(context); // 效果相同
                    },
                    child: const Text("手动返回 (触发 PopScope)"),
                  )
                ],
              )
          )
      ),
    );
  }
}