import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:chop_user/src/core/widgets/common_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_empty.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../detail/views/manage_payment_methods_page.dart';
import '../providers/wallet_provider.dart';
import '../widgets/balance_item.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  @override
  void initState() {
    super.initState();
    // 每次进入页面都刷新钱包信息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletInfoProvider.notifier).loadWalletInfo();
    });
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final walletInfoState = ref.watch(walletInfoProvider);
    final isLoading = ref.watch(walletInfoLoadingProvider);

    Logger.info('WalletPage', 'build: isLoading=$isLoading, hasLoaded=${walletInfoState.hasLoaded}, error=${walletInfoState.error}, balance=${walletInfoState.walletInfo?.balance}');

    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(title: l10n.walletTitle, backgroundColor: Colors.transparent),
          Expanded(
            child: isLoading
                ? const Center(child: CommonIndicator())
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        CommonSpacing.large,
                        // 钱包信息 getMyWalletInfo 接口
                        _buildWalletInfo(walletInfoState.walletInfo, l10n),
                        // 支付方式
                        _buildPaymentMethod(l10n),
                        // 余额明细
                        Expanded(
                          child: _buildBalanceDetail(walletInfoState.recentHistory, l10n),
                        )
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      margin: EdgeInsets.only(bottom: 24.h),
      child: child,
    );
  }

  Widget _buildWalletInfo(walletInfo, AppLocalizations l10n) {
    final balance = walletInfo?.balance ?? 0.0;
    Logger.info(
      'WalletPage',
      '构建钱包信息: balance=\$${balance.toStringAsFixed(2)}, walletInfo=${walletInfo != null ? "not null (userId=${walletInfo.userId})" : "null"}',
    );
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.walletBalance, style: AppValues.labelValue),
          CommonSpacing.medium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // balance 字段
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: AppValues.labelTitle.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w500),
              ),
              CommonButton(
                text: l10n.recharge,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                borderRadius: BorderRadius.circular(8.r),
                onPressed: () {
                  Navigate.push(context, Routes.recharge);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(AppLocalizations l10n) {
    return _buildCard(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagePaymentMethodsPage()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.confirmOrderPaymentMethod, style: AppValues.labelTitle),
            Row(
              children: [
                Text(l10n.manageBoundCards, style: AppValues.labelValue),
                CommonSpacing.width(4.w),
                Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade600),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDetail(List recentHistory, AppLocalizations l10n) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return _buildCard(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigate.push(context, Routes.walletDetail);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.balanceDetail, style: AppValues.labelTitle),
                Row(
                  children: [
                    Text(l10n.btnViewAll, style: AppValues.labelValue),
                    CommonSpacing.width(4.w),
                    Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade600),
                  ],
                ),
              ],
            ),
          ),
          
          CommonSpacing.medium,
          Expanded(
            child: recentHistory.isEmpty
                ? CommonEmpty()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: recentHistory.length,
                    itemBuilder: (context, index) {
                      final item = recentHistory[index];
                      return _buildBalanceDetailItem(
                        title: item.txTypeName,
                        value: '\$${item.transactionAmount.toStringAsFixed(2)}',
                        time: dateFormat.format(item.recordDate),
                        balance: '\$${item.balanceAfter.toStringAsFixed(2)}',
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceDetailItem({
    required String title,
    required String value,
    required String time,
    required String balance,
  }) {
    return BalanceItem(
      title: title,
      value: value,
      time: time,
      balance: balance,
    );
  }
}