import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/constants/app_values.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../detail/models/payment_models.dart';
import '../../detail/views/payment_selection_sheet.dart';
import '../../mine/providers/mine_provider.dart';
import '../models/wallet_models.dart';
import '../providers/wallet_provider.dart';
import '../services/wallet_services.dart';
import 'recharge_result_page.dart';

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
    // 加载充值卡列表（如果还没有加载过）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(rechargeCardListProvider);
      // 如果未加载过且不在加载中，则加载
      if (!currentState.hasLoaded && !currentState.isLoading) {
        ref.read(rechargeCardListProvider.notifier).loadRechargeCardList();
      }
    });

    // 监听输入金额变化，同步到 provider
    _amountController.addListener(() {
      ref
          .read(rechargePageStateProvider.notifier)
          .updateInputAmount(_amountController.text);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleRecharge(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 使用统一的方法获取充值信息
    final rechargeInfo =
        ref.read(rechargePageStateProvider.notifier).getRechargeInfo();
    if (rechargeInfo == null) {
      toast(l10n.enterRechargeAmount);
      return;
    }

    Logger.info(
      "RechargePage",
      "当前充值金额: \$${rechargeInfo.amount.toStringAsFixed(2)}, 赠送: \$${rechargeInfo.bonus.toStringAsFixed(2)}",
    );

    // 打开支付选择页面（隐藏钱包选项）
    final selectedMethod = await PaymentSelectionSheet.show(
      context,
      ref,
      hideWallet: true,
    );

    if (selectedMethod == null) {
      Logger.info("RechargePage", "用户取消支付方式选择");
      return;
    }

    Logger.info("RechargePage", "选择的支付方式: ${selectedMethod.displayName}");

    // 如果选择了钱包支付
    if (selectedMethod.type == AppPaymentMethodType.wallet) {
      _processWalletPayment(context, ref, rechargeInfo);
    }
    // 如果选择了银行卡支付
    else if (selectedMethod.type == AppPaymentMethodType.stripeCard) {
      _processStripePayment(context, ref, rechargeInfo, selectedMethod.card!);
    }
  }

  Future<void> _processWalletPayment(
    BuildContext context,
    WidgetRef ref,
    ({double amount, double bonus, String cardId}) rechargeInfo,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    Pop.loading();

    try {
      // 创建充值订单
      final params = RechargeCardOrderParams(
        rechargeCardId: rechargeInfo.cardId,
        rechargeAmount: rechargeInfo.amount,
        bonusAmount: rechargeInfo.bonus,
        payAmount: rechargeInfo.amount,
        orderSource: 1,
        payType: 2, // 2=钱包余额支付
      );

      await WalletServices.createRechargeCardOrder(params);

      Pop.hideLoading();

      if (!context.mounted) return;

      // 刷新钱包信息和用户信息
      await Future.wait([
        ref.read(walletInfoProvider.notifier).loadWalletInfo(),
        ref.read(userInfoProvider.notifier).loadUserInfo(),
      ]);

      if (!context.mounted) return;

      // 跳转到成功页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RechargeResultPage(
            isSuccess: true,
            amount: rechargeInfo.amount + rechargeInfo.bonus,
          ),
        ),
      );
    } catch (e) {
      Pop.hideLoading();
      if (!context.mounted) return;

      Logger.error("RechargePage", "钱包支付失败: $e");

      // 提取友好的错误信息
      String errorMessage = l10n.rechargeFailed;
      if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RechargeResultPage(
            isSuccess: false,
            message: errorMessage,
          ),
        ),
      );
    }
  }

  Future<void> _processStripePayment(
    BuildContext context,
    WidgetRef ref,
    ({double amount, double bonus, String cardId}) rechargeInfo,
    StripePaymentMethodModel card,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    Pop.loading();

    try {
      // 1. 创建充值订单
      final params = RechargeCardOrderParams(
        rechargeCardId: rechargeInfo.cardId,
        rechargeAmount: rechargeInfo.amount,
        bonusAmount: rechargeInfo.bonus,
        payAmount: rechargeInfo.amount,
        orderSource: 1,
        payType: 1, // 1=Stripe
      );

      // 创建充值订单，返回 orderNo
      final orderNo = await WalletServices.createRechargeCardOrder(params);

      // 2. 创建 Stripe PaymentIntent（传入数据库中的支付方式ID）
      final spiResult = await WalletServices.createRechargeSPI(
        orderNo,
        card.id,
      );

      final status = spiResult['status'] as String?;

      // 如果支付已经成功，直接跳转到成功页面
      if (status == 'succeeded') {
        Pop.hideLoading();

        if (!context.mounted) return;

        // 刷新钱包信息和用户信息
        Pop.loading();
        await Future.wait([
          ref.read(walletInfoProvider.notifier).loadWalletInfo(),
          ref.read(userInfoProvider.notifier).loadUserInfo(),
        ]);
        Pop.hideLoading();

        if (!context.mounted) return;

        // 跳转到成功页面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RechargeResultPage(
              isSuccess: true,
              amount: rechargeInfo.amount + rechargeInfo.bonus,
            ),
          ),
        );
        return;
      }

      final clientSecret = spiResult['clientSecret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception(l10n.rechargeFailed);
      }

      Pop.hideLoading();

      if (!context.mounted) return;

      // 3. 初始化并展示支付页面
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: '充值 \$${rechargeInfo.amount.toStringAsFixed(2)}',
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFFF6B00),
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      // 4. 展示支付页面
      await Stripe.instance.presentPaymentSheet();

      if (!context.mounted) return;

      Pop.loading();

      // 5. 刷新钱包信息和用户信息
      await Future.wait([
        ref.read(walletInfoProvider.notifier).loadWalletInfo(),
        ref.read(userInfoProvider.notifier).loadUserInfo(),
      ]);

      Pop.hideLoading();

      if (!context.mounted) return;

      // 跳转到成功页面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RechargeResultPage(
            isSuccess: true,
            amount: rechargeInfo.amount + rechargeInfo.bonus,
          ),
        ),
      );
    } on StripeException catch (e) {
      Pop.hideLoading();
      if (!context.mounted) return;

      Logger.error("RechargePage", "Stripe支付失败: ${e.error.localizedMessage}");

      if (e.error.code == FailureCode.Canceled) {
        toast("取消支付");
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RechargeResultPage(
              isSuccess: false,
              message: e.error.localizedMessage ?? l10n.rechargeFailed,
            ),
          ),
        );
      }
    } catch (e) {
      Pop.hideLoading();
      if (!context.mounted) return;

      Logger.error("RechargePage", "充值失败: $e");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RechargeResultPage(
            isSuccess: false,
            message: l10n.rechargeFailed,
          ),
        ),
      );
    }
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
          CommonAppBar(
              title: l10n.walletRecharge, backgroundColor: Colors.transparent),
          Expanded(
            child: isLoading
                ? const Center(child: CommonIndicator())
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonSpacing.standard,
                        Text(l10n.selectOrEnterRechargeAmount,
                            style: AppValues.labelTitle),
                        CommonSpacing.standard,
                        if (cards.isNotEmpty)
                          Row(
                            children: cards.asMap().entries.map((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              return Expanded(
                                child: _buildAmountItem(
                                  tip: card.localizedTitle,
                                  amount:
                                      card.rechargeAmount.toStringAsFixed(0),
                                  onTap: () {
                                    ref
                                        .read(
                                            rechargePageStateProvider.notifier)
                                        .selectCard(index);
                                    // 同步清空输入框
                                    _amountController.clear();
                                  },
                                  isSelected:
                                      rechargePageState.selectedCardIndex ==
                                          index,
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0.w, vertical: 0.h),
                                ),
                              ),
                            )
                          ],
                        ),
                        CommonSpacing.standard,
                        CommonButton(
                          text: "${l10n.recharge} ${displayAmount ?? ""}",
                          onPressed: () => _handleRecharge(context, ref),
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
          color: !isSelected
              ? Colors.transparent
              : AppTheme.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.primaryOrange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(6.r),
                    bottomLeft: Radius.circular(0.r),
                    bottomRight: Radius.circular(6.r)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Text(
                tip,
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                "\$$amount",
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}
