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
import '../widgets/address_list_item.dart';
import '../widgets/address_actions.dart';
import '../widgets/address_card.dart';
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
    final action = await AddressActions.showDeleteConfirmSheet(context);
    if( mounted && context.mounted) {
      if (action == DeleteSheetAction.confirm) {
        final success = await AddressActions.deleteAddress(
          context: context,
          item: item,
        );
        if (success) {
            await _reload();
          }
        }
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
    return AddressListItem(
      actionsWidth: 160.w,
      actions: [
        AddressSlideAction(
          backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.7),
          icon: Icons.edit,
          label: l10n.btnEdit,
          onTap: () => _onEditAddress(item),
        ),
        AddressSlideAction(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.7),
          icon: Icons.delete,
          label: l10n.btnDelete,
          onTap: () => _onDeleteAddress(item),
        ),
      ],
      child: AddressCard(
        address: item,
        showDefaultBadge: true,
      ),
    );
  }
}

