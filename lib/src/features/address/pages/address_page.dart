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

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
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

    return Container(
      padding: EdgeInsets.all(16.w),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonImage(
                imagePath: 'assets/images/location.png',
                width: 40.w,
                height: 40.w,
              ),
              CommonSpacing.width(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (item.defaultStatus)
                          Container(
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
    );
  }
}
