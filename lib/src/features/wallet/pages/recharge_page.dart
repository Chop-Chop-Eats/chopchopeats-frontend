import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../providers/wallet_provider.dart';

class RechargePage extends ConsumerStatefulWidget {
  const RechargePage({super.key});

  @override
  ConsumerState<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends ConsumerState<RechargePage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 加载充值卡列表（如果还没有数据）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(rechargeCardListProvider);
      // 如果已有数据且不在加载中，则不重新加载
      if (currentState.cards.isEmpty && !currentState.isLoading) {
        ref.read(rechargeCardListProvider.notifier).loadRechargeCardList();
      }
    });
    
    // 监听输入金额变化，同步到 provider
    _amountController.addListener(() {
      ref.read(rechargePageStateProvider.notifier).updateInputAmount(_amountController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rechargeCardListState = ref.watch(rechargeCardListProvider);
    final rechargePageState = ref.watch(rechargePageStateProvider);
    final isLoading = ref.watch(rechargeCardListLoadingProvider);
    final cards = rechargeCardListState.cards;
    final displayAmount = ref.watch(rechargeDisplayAmountProvider);

    return Scaffold(
      body: Column(
        children: [
          CommonAppBar(title: l10n.walletRecharge, backgroundColor: Colors.transparent),
          Expanded(
            child: isLoading
                ? const Center(child: CommonIndicator())
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonSpacing.standard,
                        Text(l10n.selectOrEnterRechargeAmount, style: AppValues.labelTitle),
                        CommonSpacing.standard,
                        if (cards.isNotEmpty)
                          Row(
                            children: cards.asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              return Expanded(
                                child: _buildAmountItem(
                                  tip: card.localizedTitle,
                                  amount: card.rechargeAmount.toStringAsFixed(0),
                                  onTap: () {
                                    ref.read(rechargePageStateProvider.notifier).selectCard(index);
                                    // 同步清空输入框
                                    _amountController.clear();
                                  },
                                  isSelected: rechargePageState.selectedCardIndex == index,
                                ),
                              );
                            }).toList(),
                          ),
                        CommonSpacing.standard,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "\$",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            CommonSpacing.width(4.w),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: l10n.enterRechargeAmount,
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey.shade500,
                                  ),
                                  border: null,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                                ),
                              ),
                            )
                          ],
                        ),
                        CommonSpacing.standard,
                       
                        CommonButton(
                          // 加个空格 用来隔开
                          text: "${l10n.recharge} ${displayAmount ?? ""}",
                          onPressed: () {
                            final amount = ref.read(rechargePageStateProvider.notifier).getCurrentAmount();
                            if (amount != null) {
                              Logger.info("RechargePage", "当前充值金额: \$${amount.toStringAsFixed(2)}");
                            } else {
                              Logger.info("RechargePage", "当前充值金额: 未设置");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  Widget _buildAmountItem({
    required String tip,
    required String amount,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: !isSelected ? Colors.transparent : AppTheme.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color:  AppTheme.primaryOrange ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), topRight: Radius.circular(6.r) , bottomLeft: Radius.circular(0.r), bottomRight: Radius.circular(6.r) ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Text(tip, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.normal, color: Colors.white),),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric( vertical: 12.h),
              child: Text("\$$amount", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),),
            )
          ],
        ),
      ),
    );
  }
}