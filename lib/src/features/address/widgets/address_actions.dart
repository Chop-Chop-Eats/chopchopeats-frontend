import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/address_models.dart';
import '../services/address_services.dart';

enum DeleteSheetAction { confirm, cancel, close }

class AddressActions {
  const AddressActions._();

  static Future<DeleteSheetAction?> showDeleteConfirmSheet(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Pop.sheet<DeleteSheetAction>(
      title: l10n.addressDeleteConfirmTitle,
      childBuilder: (dismiss) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => dismiss(DeleteSheetAction.cancel),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                width: double.infinity,
                child: Center(
                  child: Text(
                    l10n.btnCancel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 0.5.h,
              color: Colors.grey.shade300,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => dismiss(DeleteSheetAction.confirm),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                width: double.infinity,
                child: Center(
                  child: Text(
                    l10n.btnConfirm,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
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
              behavior: HitTestBehavior.opaque,
              onTap: () => dismiss(DeleteSheetAction.close),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                width: double.infinity,
                child: Center(
                  child: Text(
                    l10n.btnClose,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            CommonSpacing.small,
          ],
        );
      },
    );
  }

  static Future<bool> deleteAddress({
    required BuildContext context,
    required AddressItem item,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final addressId = item.id;
    if (addressId == null) {
      Pop.toast(l10n.loadingFailedWithError, toastType: ToastType.error);
      Logger.error('AddressPage', '尝试删除缺少 ID 的地址');
      return false;
    }

    final loadingId = Pop.loading();
    try {
      await AddressServices.deleteUserAddress(addressId);
      Pop.hideLoading(loadingId);
      Pop.toast(l10n.addressDeleteSuccess, toastType: ToastType.success);
      return true;
    } catch (e) {
      Pop.hideLoading(loadingId);
      Logger.error('AddressPage', '删除地址失败: $e');
      Pop.toast(e.toString(), toastType: ToastType.error);
      return false;
    }
  }
}

