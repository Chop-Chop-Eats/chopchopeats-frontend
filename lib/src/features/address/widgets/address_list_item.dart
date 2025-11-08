import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_spacing.dart';

class AddressSlideAction {
  const AddressSlideAction({
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color backgroundColor;
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
}

class AddressListItem extends StatefulWidget {
  const AddressListItem({
    super.key,
    required this.child,
    required this.actionsWidth,
    required this.actions,
    this.toggleOnTap = true,
  }) : assert(actionsWidth > 0),
       assert(actions.length == 2, '当前列表项暂仅支持两个操作按钮');

  final Widget child;
  final double actionsWidth;
  final List<AddressSlideAction> actions;
  final bool toggleOnTap;

  @override
  State<AddressListItem> createState() => _AddressListItemState();
}

class _AddressListItemState extends State<AddressListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _maxSlide => widget.actionsWidth;

  bool get _isOpen => _controller.value > 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final newValue = (_controller.value - delta / _maxSlide).clamp(0.0, 1.0);
    _controller.value = newValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _open();
    } else if (velocity > 300) {
      _close();
    } else if (_controller.value >= 0.5) {
      _open();
    } else {
      _close();
    }
  }

  Future<void> _open() {
    return _controller.animateTo(
      1.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 180),
    );
  }

  Future<void> _close() {
    return _controller.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 180),
    );
  }

  Future<void> _handleActionTap(AddressSlideAction action) async {
    await _close();
    await action.onTap();
  }

  void _handleTap() {
    if (!widget.toggleOnTap) return;
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionWidth = widget.actionsWidth / widget.actions.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: _handleTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actions.map((action) {
                  return SizedBox(
                    width: actionWidth,
                    child: _SlideActionButton(
                      backgroundColor: action.backgroundColor,
                      icon: action.icon,
                      label: action.label,
                      onTap: () => _handleActionTap(action),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offsetX = -_controller.value * _maxSlide;
              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: child,
              );
            },
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _SlideActionButton extends StatelessWidget {
  const _SlideActionButton({
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color backgroundColor;
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
            CommonSpacing.small,
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

