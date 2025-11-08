import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/address_models.dart';
import '../providers/address_provider.dart';
import '../services/address_services.dart';
import '../../../core/utils/logger/logger.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

enum _DeleteSheetAction { confirm, cancel, close }

class _AddressListItem extends StatefulWidget {
  const _AddressListItem({
    required this.child,
    required this.editLabel,
    required this.deleteLabel,
    required this.onEdit,
    required this.onDelete,
    required this.actionsWidth,
  });

  final Widget child;
  final String editLabel;
  final String deleteLabel;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final double actionsWidth;

  @override
  State<_AddressListItem> createState() => _AddressListItemState();
}

class _AddressListItemState extends State<_AddressListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _maxSlide => widget.actionsWidth;

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

  Future<void> _handleEdit() async {
    await _close();
    await widget.onEdit();
  }

  Future<void> _handleDelete() async {
    await _close();
    await widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: () {
        if (_controller.value > 0.0) {
          _close();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: widget.actionsWidth / 2,
                    child: _SlideActionButton(
                      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.7),
                      icon: Icons.edit,
                      label: widget.editLabel,
                      onTap: _handleEdit,
                    ),
                  ),
                  SizedBox(
                    width: widget.actionsWidth / 2,
                    child: _SlideActionButton(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.7),
                      icon: Icons.delete,
                      label: widget.deleteLabel,
                      onTap: _handleDelete,
                    ),
                  ),
                ],
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
        onTap: () {
          onTap();
        },
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

class _AddressPageState extends ConsumerState<AddressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressListProvider.notifier).loadAddresses();
    });
  }

  Future<void> _reload() async {
    await ref.read(addressListProvider.notifier).loadAddresses();
  }

  Future<void> _onEditAddress(AddressItem item) async {
    final result = await Navigate.push(
      context,
      Routes.addAddress,
      arguments: AddressFormArguments.edit(item),
    );
    if (result == true) {
      await _reload();
    }
  }

  Future<void> _onDeleteAddress(AddressItem item) async {
    await _showDeleteConfirmSheet(item);
  }

  Future<void> _showDeleteConfirmSheet(AddressItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await Pop.sheet<_DeleteSheetAction>(
      title: l10n.addressDeleteConfirmTitle,
  
      childBuilder: (dismiss) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              GestureDetector(
                onTap: () => dismiss(_DeleteSheetAction.cancel),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      l10n.btnCancel,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black87,fontWeight: FontWeight.w600),
                    ),
                  )
                ),
              ),
              Container(
                height: 0.5.h,
                color: Colors.grey.shade300,
              ),

              GestureDetector(
                onTap: () => dismiss(_DeleteSheetAction.confirm),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  width: double.infinity,
                  child: Center(child: Text(
                    l10n.btnConfirm,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black,fontWeight: FontWeight.w600),
                    ),
                  ),
                  ),
                ),
               Container(
                height: 3.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
               
              ),

                GestureDetector(
                  onTap: () => dismiss(_DeleteSheetAction.close),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    width: double.infinity,
                    child: Center(child: Text(
                      l10n.btnClose,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54,fontWeight: FontWeight.w400),
                    ),
                    ),
                  ),
                ),
            ],
          
        );
      },
    );

    if (result == _DeleteSheetAction.confirm) {
      await _deleteAddress(item);
    }
  }

  Future<void> _deleteAddress(AddressItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final addressId = item.id;
    if (addressId == null) {
      Pop.toast(l10n.loadingFailedWithError, toastType: ToastType.error);
      Logger.error('AddressPage', '尝试删除缺少 ID 的地址');
      return;
    }

    final loadingId = Pop.loading();
    try {
      await AddressServices.deleteUserAddress(addressId);
      await _reload();
      Pop.hideLoading(loadingId);
      Pop.toast(l10n.addressDeleteSuccess, toastType: ToastType.success);
    } catch (e) {
      Pop.hideLoading(loadingId);
      Logger.error('AddressPage', '删除地址失败: $e');
      Pop.toast(e.toString(), toastType: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<AddressListState>(addressListProvider, (previous, next) {
      if (!mounted) return;
      if (next.error != null && next.addresses.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Pop.toast(next.error!, toastType: ToastType.error);
          }
        });
      }
    });
    final addressState = ref.watch(addressListProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.address,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Expanded(
                child: _buildContent(
                  context,
                  l10n,
                  addressState,
                ),
              ),
              CommonSpacing.large,
              _buildAddButton(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    AddressListState state,
  ) {
    if (state.isLoading && state.addresses.isEmpty) {
      return const Center(child: CommonIndicator());
    }

    if (state.error != null && state.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            CommonSpacing.medium,
            SizedBox(
              width: 160.w,
              child: ElevatedButton(
                onPressed: _reload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  l10n.tryAgainText,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonImage(
              imagePath: 'assets/images/empty_search.png',
              width: 180.w,
              height: 150.h,
            ),
            CommonSpacing.large,
            Text(
              l10n.emptyListText,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            CommonSpacing.medium,
            SizedBox(
              width: 160.w,
              child: ElevatedButton(
                onPressed: _reload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  l10n.tryAgainText,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryOrange,
      onRefresh: _reload,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 16.h,
          bottom: 16.h,
        ),
        itemBuilder: (context, index) {
          final item = state.addresses[index];
          return _buildAddressItem(l10n, item);
        },
        separatorBuilder: (_, __) => CommonSpacing.large,
        itemCount: state.addresses.length,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () {
          Navigate.push(context, Routes.addAddress);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              l10n.addAddress,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressItem(
    AppLocalizations l10n,
    AddressItem item,
  ) {
    final detailParts = [
      item.address,
      if (item.detailAddress?.isNotEmpty ?? false) item.detailAddress!,
      item.state,
    ].where((element) => element.isNotEmpty).toList();

    return _AddressListItem(
      actionsWidth: 160.w,
      editLabel: l10n.btnEdit,
      deleteLabel: l10n.btnDelete,
      onEdit: () => _onEditAddress(item),
      onDelete: () => _onDeleteAddress(item),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonImage(
                  imagePath: 'assets/images/location.png',
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.contain,
                ),
                CommonSpacing.width(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          if (item.defaultStatus)
                            Container(
                              margin: EdgeInsets.only(left: 6.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                l10n.defaultAddress,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      CommonSpacing.small,
                      Text(
                        item.mobile,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      CommonSpacing.small,
                      Text(
                        detailParts.join(' · '),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
