import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自定义上拉加载更多底部组件
/// 采用简约的波浪动画设计
class CustomRefreshFooter extends StatelessWidget {
  const CustomRefreshFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomLoadMoreIndicator(
      child: SizedBox.shrink(),
    );
  }
}

/// 自定义加载更多指示器
class CustomLoadMoreIndicator extends StatefulWidget {
  final Widget child;
  final double height;
  final Color? primaryColor;
  final String? loadingText;

  const CustomLoadMoreIndicator({
    super.key,
    required this.child,
    this.height = 60.0,
    this.primaryColor,
    this.loadingText,
  });

  @override
  State<CustomLoadMoreIndicator> createState() => _CustomLoadMoreIndicatorState();
}

class _CustomLoadMoreIndicatorState extends State<CustomLoadMoreIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() {
    _waveController.repeat();
    _fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final loadingText = widget.loadingText ?? '正在加载...';

    return Container(
      height: widget.height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_waveAnimation, _fadeAnimation]),
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 波浪动画
                SizedBox(
                  height: 20.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final animationValue = (_waveAnimation.value + delay) % 1.0;
                          final height = (0.5 + 0.5 * (1 - (animationValue - 0.5).abs() * 2)).clamp(0.0, 1.0);
                          
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            width: 3.w,
                            height: (height * 20).h,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.6 + 0.4 * _fadeAnimation.value),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                SizedBox(height: 8.h),
                // 加载文本
                Text(
                  loadingText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 没有更多数据的指示器
class CustomNoMoreIndicator extends StatelessWidget {
  final String? text;
  final Color? primaryColor;

  const CustomNoMoreIndicator({
    super.key,
    this.text,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = this.primaryColor ?? Theme.of(context).primaryColor;
    final text = this.text ?? '没有更多了';

    return Container(
      height: 50.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            primaryColor.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 左侧装饰线
            Container(
              width: 30.w,
              height: 1.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    primaryColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // 文本
            Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: primaryColor.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 12.w),
            // 右侧装饰线
            Container(
              width: 30.w,
              height: 1.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}