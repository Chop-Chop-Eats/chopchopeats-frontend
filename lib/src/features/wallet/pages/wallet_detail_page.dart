import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_empty.dart';
import '../../../core/widgets/common_indicator.dart';
import '../providers/wallet_provider.dart';
import '../widgets/balance_item.dart';

class WalletDetailPage extends ConsumerStatefulWidget {
  const WalletDetailPage({super.key});

  @override
  ConsumerState<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends ConsumerState<WalletDetailPage> {
  @override
  void initState() {
    super.initState();
    // 加载全部钱包交易记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查是否已加载过，避免重复加载
      final currentState = ref.read(walletHistoryProvider);
      Logger.info(
        "WalletDetailPage",
        "加载全部钱包交易记录 hasLoaded=${currentState.hasLoaded}, isLoading=${currentState.isLoading}",
      );
      // 如果未加载过且不在加载中，则加载
      if (!currentState.hasLoaded && !currentState.isLoading) {
        ref.read(walletHistoryProvider.notifier).loadWalletHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final walletHistoryState = ref.watch(walletHistoryProvider);
    final isLoading = ref.watch(walletHistoryLoadingProvider);
    final history = walletHistoryState.history;
    final dateFormat = DateFormat('yyyy-MM-dd');

    // 构建列表项
    List<Widget> items = [];
    for (final historyItem in history) {
      // 添加日期标题
      items.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(historyItem.transactionDate, style: AppValues.labelValue),
        ),
      );
      // 添加该日期下的所有交易明细
      for (final detail in historyItem.transactionDetail) {
        items.add(
          BalanceItem(
            title: detail.getLocalizedPayTypeName(),
            value: '\$${detail.transactionAmount.toStringAsFixed(2)}',
            time: dateFormat.format(detail.recordDate),
            balance: '\$${detail.balanceAfter.toStringAsFixed(2)}',
          ),
        );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(
            title: l10n.walletTitle,
            backgroundColor: Colors.transparent,
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CommonIndicator())
                    : history.isEmpty
                    ? CommonEmpty()
                    : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return items[index];
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
