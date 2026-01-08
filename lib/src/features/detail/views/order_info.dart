import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omni_calendar_view/omni_calendar_view.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pop/toast.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../address/models/address_models.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import '../providers/confirm_order_provider.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/confirm_order_widgets.dart';
import '../utils/order_price_calculator.dart';
import '../models/order_model.dart';
import '../services/order_services.dart';
import '../providers/payment_provider.dart';
import 'payment_selection_sheet.dart';

/// 订单信息视图组件
class OrderInfoView extends ConsumerStatefulWidget {
  const OrderInfoView({
    super.key,
    required this.shopId,
    this.initialDiningDate,
    required this.remarkController,
    required this.remarkFocusNode,
    required this.customTipController,
    required this.customTipFocusNode,
  });

  final String shopId;
  final String? initialDiningDate; // 可选的初始日期参数
  final TextEditingController remarkController;
  final FocusNode remarkFocusNode;
  final TextEditingController customTipController;
  final FocusNode customTipFocusNode;

  @override
  ConsumerState<OrderInfoView> createState() => _OrderInfoViewState();
}

class _OrderInfoViewState extends ConsumerState<OrderInfoView> {
  final OmniCalendarController controller = OmniCalendarController(
    initialDate: DateTime.now(),
  );
  // 样式定义
  static final TextStyle titleText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  static final TextStyle textStyle = TextStyle(
    fontSize: 12.sp,
    color: Colors.grey[600],
  );
  static final TextStyle valueText = TextStyle(
    fontSize: 14.sp,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    // 监听自定义小费输入框焦点变化
    _focusListener = () {
      if (!widget.customTipFocusNode.hasFocus) {
        // 失去焦点时，调用处理函数（数字键盘没有确定键，需要在失焦时处理）
        _handleCustomTipInput(widget.customTipController.text);
      }
    };
    widget.customTipFocusNode.addListener(_focusListener);

    // 初始化日期并获取配送时间
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 如果传入了初始日期，使用传入的日期；否则使用当天
      final diningDateStr =
          widget.initialDiningDate ?? formatDiningDate(DateTime.now());
      ref.read(selectedDiningDateProvider(widget.shopId).notifier).state =
          diningDateStr;
      _fetchDeliveryTimes(diningDateStr);

      // 预加载钱包信息，提升支付方式弹窗打开速度
      ref.read(walletInfoProvider.notifier).loadWalletInfo();
      Logger.info('OrderInfoView', '预加载钱包信息...');
    });
  }

  @override
  void dispose() {
    // 移除焦点监听器
    widget.customTipFocusNode.removeListener(_focusListener);
    super.dispose();
  }

  /// 获取可配送时间列表
  Future<void> _fetchDeliveryTimes(String diningDate) async {
    // 设置加载状态
    ref.read(deliveryTimesLoadingProvider(widget.shopId).notifier).state = true;
    // 清空之前的数据
    ref.read(availableDeliveryTimesProvider(widget.shopId).notifier).state =
        null;

    try {
      final orderServices = OrderServices();
      final times = await orderServices.getAvailableDeliveryTimes(
        widget.shopId,
        diningDate,
      );
      ref.read(availableDeliveryTimesProvider(widget.shopId).notifier).state =
          times;
    } catch (e) {
      Logger.error('OrderInfoView', '获取配送时间失败: $e');
      ref.read(availableDeliveryTimesProvider(widget.shopId).notifier).state =
          [];
    } finally {
      ref.read(deliveryTimesLoadingProvider(widget.shopId).notifier).state =
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddress(),
            _buildPrivateChef(),
            _buildMealDetail(),
            _buildDeliveryTip(),
            _buildOrderAmount(),
            _buildPaymentMethod(),
            _buildRemark(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddress() {
    final l10n = AppLocalizations.of(context)!;
    final selectedAddress = ref.watch(selectedAddressProvider(widget.shopId));
    final addressText =
        selectedAddress != null
            ? _formatAddressForDisplay(selectedAddress)
            : l10n.confirmOrderAddress;

    return CapsuleButton(
      title: addressText,
      onTap: () async {
        final result = await AddressSelectionSheet.show(
          context: context,
          ref: ref,
        );
        if (result != null) {
          ref.read(selectedAddressProvider(widget.shopId).notifier).state =
              result;
        }
      },
      imagePath: "assets/images/location_b.png",
    );
  }

  String _formatAddressForDisplay(AddressItem address) {
    // 第一行：姓名和电话
    final firstLine = [
      address.name,
      address.mobile,
    ].where((element) => element.isNotEmpty).join(' · ');

    // 第二行：地址信息
    final secondLineParts =
        [
          address.address,
          if (address.detailAddress?.isNotEmpty ?? false)
            address.detailAddress!,
          address.state,
        ].where((element) => element.isNotEmpty).toList();
    final secondLine = secondLineParts.join(' · ');

    return '$firstLine\n$secondLine';
  }

  Widget _buildPrivateChef() {
    final l10n = AppLocalizations.of(context)!;
    final shop = ref.watch(shopDetailProvider(widget.shopId));
    final selectedDeliveryTime = ref.watch(
      selectedDeliveryTimeProvider(widget.shopId),
    );

    // 如果没有店铺数据，显示占位
    if (shop == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonSpacing.standard,
          Text(l10n.confirmOrderPrivateChef, style: titleText),
          CommonSpacing.medium,
          Text("Loading...", style: textStyle),
        ],
      );
    }

    // 格式化距离
    final distanceText =
        shop.distance != null ? "${shop.distance!.toStringAsFixed(1)}km" : "";

    // 格式化配送时间（只显示已选中的）
    final deliveryTimeText = selectedDeliveryTime?.time ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderPrivateChef, style: titleText),
        CommonSpacing.medium,
        Text(
          shop.localizedShopName,
          style: titleText.copyWith(fontSize: 14.sp),
        ),
        CommonSpacing.height(4.h),
        Row(
          children: [
            if (distanceText.isNotEmpty) ...[
              Text(
                "${l10n.confirmOrderDistance}$distanceText",
                style: textStyle,
              ),
              Icon(
                Icons.directions_car_outlined,
                size: 24.w,
                color: Colors.black,
              ),
            ],
            if (deliveryTimeText.isNotEmpty) ...[
              Text(l10n.confirmOrderPlan, style: textStyle),
              Text(
                "$deliveryTimeText ",
                style: textStyle.copyWith(color: AppTheme.primaryOrange),
              ),
              Text(l10n.confirmOrderStartDelivery, style: textStyle),
            ],
          ],
        ),
        // 显示日期选择器和配送时间选择器
        CommonSpacing.small,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text(l10n.confirmOrderDeliveryTime, style: titleText)],
          ),
        ),
        CommonSpacing.small,
        _buildDeliveryTimeSelector(),
      ],
    );
  }

  // 构建配送时间选择器
  Widget _buildDeliveryTimeSelector() {
    final l10n = AppLocalizations.of(context)!;
    final selectedDeliveryTime = ref.watch(
      selectedDeliveryTimeProvider(widget.shopId),
    );
    final availableDeliveryTimes = ref.watch(
      availableDeliveryTimesProvider(widget.shopId),
    );
    final isLoading = ref.watch(deliveryTimesLoadingProvider(widget.shopId));

    // Loading 状态
    if (isLoading) {
      return CommonIndicator(size: 16.w);
    }

    // 如果没有数据，显示空状态
    if (availableDeliveryTimes == null || availableDeliveryTimes.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(l10n.confirmOrderTodayNotDelivery, style: textStyle),
        ),
      );
    }

    return Row(
      children:
          availableDeliveryTimes.map((hour) {
            final isSelected = selectedDeliveryTime?.time == hour.time;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(
                        selectedDeliveryTimeProvider(widget.shopId).notifier,
                      )
                      .state = hour;
                },
                child: SelectableCapsuleItem(
                  title: hour.time ?? "",
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(
                          selectedDeliveryTimeProvider(widget.shopId).notifier,
                        )
                        .state = hour;
                  },
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMealDetail() {
    final l10n = AppLocalizations.of(context)!;
    final cartState = ref.watch(cartStateProvider(widget.shopId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderMealDetail, style: titleText),
        CommonSpacing.medium,
        if (cartState.items.isEmpty)
          Text("Cart is empty", style: textStyle)
        else
          CartItemList(
            shopId: widget.shopId,
            items: cartState.items,
            diningDate: cartState.diningDate,
          ),
      ],
    );
  }

  Widget _buildDeliveryTip() {
    final l10n = AppLocalizations.of(context)!;
    final customTipRate = ref.watch(customTipRateProvider(widget.shopId));
    final selectedTipRate =
        ref.watch(selectedTipRateProvider(widget.shopId)) ?? 0.10;
    final isEditingCustomTip = ref.watch(
      isEditingCustomTipProvider(widget.shopId),
    );

    // 判断是否选中了自定义小费
    final isCustomTipSelected = customTipRate != null;

    // 如果正在编辑，初始化输入框的值
    if (isEditingCustomTip &&
        widget.customTipController.text.isEmpty &&
        customTipRate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.customTipController.text = customTipRate.toString();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderDeliveryTip, style: titleText),
        CommonSpacing.medium,
        Text(l10n.confirmOrderDeliveryFeeTip, style: textStyle),
        CommonSpacing.small,
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(selectedTipRateProvider(widget.shopId).notifier)
                      .state = 0.10;
                  ref
                      .read(customTipRateProvider(widget.shopId).notifier)
                      .state = null;
                  ref
                      .read(isEditingCustomTipProvider(widget.shopId).notifier)
                      .state = false;
                  widget.customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "10%",
                  isSelected:
                      !isCustomTipSelected &&
                      !isEditingCustomTip &&
                      selectedTipRate == 0.10,
                  onTap: () {
                    ref
                        .read(selectedTipRateProvider(widget.shopId).notifier)
                        .state = 0.10;
                    ref
                        .read(customTipRateProvider(widget.shopId).notifier)
                        .state = null;
                    ref
                        .read(
                          isEditingCustomTipProvider(widget.shopId).notifier,
                        )
                        .state = false;
                    widget.customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(selectedTipRateProvider(widget.shopId).notifier)
                      .state = 0.12;
                  ref
                      .read(customTipRateProvider(widget.shopId).notifier)
                      .state = null;
                  ref
                      .read(isEditingCustomTipProvider(widget.shopId).notifier)
                      .state = false;
                  widget.customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "12%",
                  isSelected:
                      !isCustomTipSelected &&
                      !isEditingCustomTip &&
                      selectedTipRate == 0.12,
                  onTap: () {
                    ref
                        .read(selectedTipRateProvider(widget.shopId).notifier)
                        .state = 0.12;
                    ref
                        .read(customTipRateProvider(widget.shopId).notifier)
                        .state = null;
                    ref
                        .read(
                          isEditingCustomTipProvider(widget.shopId).notifier,
                        )
                        .state = false;
                    widget.customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(selectedTipRateProvider(widget.shopId).notifier)
                      .state = 0.15;
                  ref
                      .read(customTipRateProvider(widget.shopId).notifier)
                      .state = null;
                  ref
                      .read(isEditingCustomTipProvider(widget.shopId).notifier)
                      .state = false;
                  widget.customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "15%",
                  isSelected:
                      !isCustomTipSelected &&
                      !isEditingCustomTip &&
                      selectedTipRate == 0.15,
                  onTap: () {
                    ref
                        .read(selectedTipRateProvider(widget.shopId).notifier)
                        .state = 0.15;
                    ref
                        .read(customTipRateProvider(widget.shopId).notifier)
                        .state = null;
                    ref
                        .read(
                          isEditingCustomTipProvider(widget.shopId).notifier,
                        )
                        .state = false;
                    widget.customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(selectedTipRateProvider(widget.shopId).notifier)
                      .state = 0.20;
                  ref
                      .read(customTipRateProvider(widget.shopId).notifier)
                      .state = null;
                  ref
                      .read(isEditingCustomTipProvider(widget.shopId).notifier)
                      .state = false;
                  widget.customTipFocusNode.unfocus();
                },
                child: SelectableCapsuleItem(
                  title: "20%",
                  isSelected:
                      !isCustomTipSelected &&
                      !isEditingCustomTip &&
                      selectedTipRate == 0.20,
                  onTap: () {
                    ref
                        .read(selectedTipRateProvider(widget.shopId).notifier)
                        .state = 0.20;
                    ref
                        .read(customTipRateProvider(widget.shopId).notifier)
                        .state = null;
                    ref
                        .read(
                          isEditingCustomTipProvider(widget.shopId).notifier,
                        )
                        .state = false;
                    widget.customTipFocusNode.unfocus();
                  },
                ),
              ),
            ),
            Expanded(
              child:
                  ref.watch(isEditingCustomTipProvider(widget.shopId))
                      ? _buildCustomTipInput()
                      : GestureDetector(
                        onTap: () {
                          ref
                              .read(
                                isEditingCustomTipProvider(
                                  widget.shopId,
                                ).notifier,
                              )
                              .state = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.customTipFocusNode.requestFocus();
                          });
                        },
                        child: SelectableCapsuleItem(
                          title:
                              isCustomTipSelected
                                  ? "$customTipRate%"
                                  : l10n.other,
                          isSelected: isCustomTipSelected,
                          onTap: () {
                            ref
                                .read(
                                  isEditingCustomTipProvider(
                                    widget.shopId,
                                  ).notifier,
                                )
                                .state = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              widget.customTipFocusNode.requestFocus();
                            });
                          },
                        ),
                      ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建自定义小费输入框
  Widget _buildCustomTipInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 4.h),
      child: TextField(
        controller: widget.customTipController,
        focusNode: widget.customTipFocusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, color: Colors.white),
        decoration: InputDecoration(
          hintText: '',
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          suffix: Text(
            '%',
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          ),
        ),
        onSubmitted: (value) {
          _handleCustomTipInput(value);
        },
        onEditingComplete: () {
          _handleCustomTipInput(widget.customTipController.text);
        },
      ),
    );
  }

  /// 处理自定义小费输入
  void _handleCustomTipInput(String value) {
    final l10n = AppLocalizations.of(context)!;
    if (value.trim().isEmpty) {
      // 如果输入为空，取消编辑状态
      ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state =
          false;
      ref.read(customTipRateProvider(widget.shopId).notifier).state = null;
      widget.customTipController.clear();
      widget.customTipFocusNode.unfocus();
      return;
    }

    final tipValue = int.tryParse(value.trim());
    if (tipValue == null) {
      toast(l10n.pleaseEnterValidNumber);
      widget.customTipFocusNode.requestFocus();
      return;
    }

    if (tipValue < 0 || tipValue > 100) {
      toast(l10n.pleaseEnter0To100);
      widget.customTipFocusNode.requestFocus();
      return;
    }

    // 保存自定义小费比例
    ref.read(customTipRateProvider(widget.shopId).notifier).state = tipValue;
    ref.read(isEditingCustomTipProvider(widget.shopId).notifier).state = false;
    widget.customTipFocusNode.unfocus();
  }

  Widget _buildOrderAmount() {
    final l10n = AppLocalizations.of(context)!;
    final prices = OrderPriceCalculator.calculate(
      ref: ref,
      shopId: widget.shopId,
    );
    final pricesMap = prices.toMap();
    final selectedCoupon = ref.watch(selectedCouponProvider(widget.shopId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderOrderAmount, style: titleText),
        CommonSpacing.medium,
        _buildOrderAmountItem(
          title: l10n.confirmOrderMealSubtotal,
          value: "\$${pricesMap['mealSubtotal']!.toStringAsFixed(2)}",
        ),
        _buildOrderAmountItem(
          title: l10n.confirmOrderDeliveryFee,
          value: "\$${pricesMap['deliveryFee']!.toStringAsFixed(2)}",
        ),
        _buildOrderAmountItem(
          title: l10n.confirmOrderTaxAndServiceFee,
          value: "\$${pricesMap['taxAndServiceFee']!.toStringAsFixed(2)}",
        ),
        _buildOrderAmountItem(
          title: l10n.confirmOrderCouponDiscount,
          value: _getCouponDisplayValue(selectedCoupon, pricesMap),
          couponUsed: selectedCoupon != null,
          isCouponHint: _isCouponHintValue(selectedCoupon, pricesMap),
          onTap: () async {
            final l10n = AppLocalizations.of(context)!;
            final couponData = ref.read(couponDataProvider(widget.shopId));
            final isLoading = ref.read(couponLoadingProvider(widget.shopId));

            if (couponData == null ||
                couponData.list == null ||
                couponData.list!.isEmpty) {
              toast(l10n.noCoupon);
              return;
            }
            final availableCoupons =
                couponData.list!
                    .where((item) => (item.status ?? 0) == 1)
                    .toList();
            if (availableCoupons.isEmpty) {
              toast(l10n.noCoupon);
              return;
            }

            final result = await CouponSelectionSheet.show(
              context: context,
              ref: ref,
              shopId: widget.shopId,
              couponList: availableCoupons,
              isLoading: isLoading,
            );

            if (result != null) {
              ref.read(selectedCouponProvider(widget.shopId).notifier).state =
                  result;
            }
          },
        ),
        Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          height: 0.5.h,
          margin: EdgeInsets.symmetric(vertical: 10.h),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            "${l10n.confirmOrderTotal}: \$${pricesMap['orderTotal']!.toStringAsFixed(2)}",
            style: titleText,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// 获取优惠券显示值
  String _getCouponDisplayValue(
    CouponSelectionResult? selectedCoupon,
    Map<String, double> prices,
  ) {
    if (selectedCoupon != null) {
      return "-\$${prices['couponDiscount']!.toStringAsFixed(2)}";
    }

    // 检查是否有可用优惠券
    final couponData = ref.read(couponDataProvider(widget.shopId));
    if (couponData != null &&
        couponData.list != null &&
        couponData.list!.isNotEmpty) {
      final availableCoupons =
          couponData.list!.where((item) => (item.status ?? 0) == 1).toList();
      if (availableCoupons.isNotEmpty) {
        final l10n = AppLocalizations.of(context)!;
        return l10n.confirmOrderAvailableCoupons;
      }
    }

    return "\$0.00";
  }

  /// 判断是否为优惠券提示文本
  bool _isCouponHintValue(
    CouponSelectionResult? selectedCoupon,
    Map<String, double> prices,
  ) {
    if (selectedCoupon != null) {
      return false;
    }

    // 检查是否有可用优惠券
    final couponData = ref.read(couponDataProvider(widget.shopId));
    if (couponData != null &&
        couponData.list != null &&
        couponData.list!.isNotEmpty) {
      final availableCoupons =
          couponData.list!.where((item) => (item.status ?? 0) == 1).toList();
      if (availableCoupons.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Widget _buildOrderAmountItem({
    required String title,
    required String value,
    bool? couponUsed = false,
    bool isCouponHint = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: textStyle),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: valueText.copyWith(
                    color:
                        (couponUsed != null && couponUsed) || isCouponHint
                            ? AppTheme.primaryOrange
                            : Colors.black,
                  ),
                ),
                if (isCouponHint) ...[
                  CommonSpacing.width(4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.w,
                    color: AppTheme.primaryOrange,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final l10n = AppLocalizations.of(context)!;
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);

    // 默认显示文本或选中的支付方式名称
    String displayTitle = l10n.confirmOrderSelectPaymentMethod;
    String iconPath = "assets/images/wallet.png"; // 默认图标

    if (selectedMethod != null) {
      displayTitle = selectedMethod.displayName;
      iconPath = selectedMethod.iconPath;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSpacing.standard,
        Text(l10n.confirmOrderPaymentMethod, style: titleText),
        CommonSpacing.medium,
        CapsuleButton(
          title: displayTitle,
          onTap: () async {
            // 防止重复点击
            await PaymentSelectionSheet.show(context, ref);
            // 可以在这里处理返回结果
          },
          imagePath: iconPath,
        ),
        CommonSpacing.standard,
      ],
    );
  }

  // 最多三行的文本域
  Widget _buildRemark() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        // 点击备注区域时聚焦输入框
        widget.remarkFocusNode.requestFocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.only(bottom: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: TextField(
          controller: widget.remarkController,
          focusNode: widget.remarkFocusNode,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: l10n.confirmOrderRemark,
            border: InputBorder.none,
          ),
          style: textStyle,
          maxLines: 3,
        ),
      ),
    );
  }
}
