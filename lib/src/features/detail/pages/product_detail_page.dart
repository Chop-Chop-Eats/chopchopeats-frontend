import 'package:carousel_slider/carousel_slider.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/features/detail/providers/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
import '../models/order_model.dart';
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;
  final String shopId;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.shopId,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final Set<String> _selectedSkuIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = ProductDetailParams(
        productId: widget.productId,
        shopId: widget.shopId,
      );
      final currentState = ref.read(productDetailProvider(params));
      if (currentState.product == null && !currentState.isLoading) {
        ref
            .read(productDetailProvider(params).notifier)
            .loadProductDetail(widget.productId, widget.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final params = ProductDetailParams(
      productId: widget.productId,
      shopId: widget.shopId,
    );

    final product = ref.watch(productDetailDataProvider(params));
    final isLoading = ref.watch(productDetailLoadingProvider(params));
    final error = ref.watch(productDetailErrorProvider(params));

    return Scaffold(
      appBar: CommonAppBar(title: '', backgroundColor: Colors.transparent),
      body: _buildBody(isLoading, error, product, l10n),
    );
  }

  Widget _buildBody(
    bool isLoading,
    String? error,
    SaleProductModel? product,
    AppLocalizations l10n,
  ) {
    if (isLoading) {
      return const Center(child: CommonIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
              CommonSpacing.medium,
              Text(
                l10n.loadingFailedMessage(error),
                style: TextStyle(fontSize: 14.sp, color: Colors.red[500]),
              ),
              CommonSpacing.small,
              Text(
                error,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              CommonSpacing.medium,
              ElevatedButton(
                onPressed: () {
                  final params = ProductDetailParams(
                    productId: widget.productId,
                    shopId: widget.shopId,
                  );
                  ref
                      .read(productDetailProvider(params).notifier)
                      .loadProductDetail(widget.productId, widget.shopId);
                },
                child: Text(l10n.tryAgainText),
              ),
            ],
          ),
        ),
      );
    }

    if (product == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 48.w, color: Colors.grey[300]),
              CommonSpacing.medium,
              Text(
                '商品不存在',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    _ensureDefaultSku(product);
    final cartState = ref.watch(cartStateProvider(widget.shopId));
    final diningDate = cartState.diningDate;
    final selectedSkus = _currentSkus(product);
    final quantity = _getQuantityInCart(cartState, product.id, selectedSkus);
    final totalPrice = _calculateTotalPrice(product, selectedSkus, quantity);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              _buildProductImages(product),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFfbfbfb),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(product, selectedSkus, diningDate),
                    CommonSpacing.medium,
                    if (product.skuSetting == 1 && product.skus.isNotEmpty)
                      _buildSkuInfo(product, l10n),
                    // CommonSpacing.medium,
                    // if (selectedSkus.isNotEmpty)
                    //   _buildSelectedSkusDisplay(selectedSkus, totalPrice),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "总价",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    CommonSpacing.width(4.w),
                    Text(
                      "\$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
                _buildCartButton(product, selectedSkus, diningDate, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartButton(
    SaleProductModel product,
    List<SaleProductSku> selectedSkus,
    String diningDate,
    AppLocalizations l10n,
  ) {
    final cartState = ref.watch(cartStateProvider(widget.shopId));
    final isBusy = cartState.isUpdating || cartState.isOperating;

    return GestureDetector(
      onTap:
          isBusy
              ? null
              : () => _handleAddToCart(product, selectedSkus, diningDate, l10n),
      child: Container(
        decoration: BoxDecoration(
          color: isBusy ? Colors.grey[400] : AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(22.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        child:
            isBusy
                ? CommonIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                  size: 14.w,
                )
                : Text(
                  l10n.addToCart,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildProductImages(SaleProductModel product) {
    final images = product.carouselImages ?? [];
    if (images.isEmpty && product.imageThumbnail != null) {
      return SizedBox(
        width: double.infinity,
        height: 300.h,
        child: CommonImage(imagePath: product.imageThumbnail!, height: 300.h),
      );
    }

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300.h,
        color: Colors.grey[200],
        child: Icon(Icons.image, size: 64.w, color: Colors.grey[400]),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 300.h,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 10),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
      ),
      items:
          images.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  color: Color(0xFFF4F4F4),
                  alignment: Alignment.center,
                  child: CommonImage(
                    imagePath: image.url!,
                    height: 120.h,
                    width: 120.w,
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  Widget _buildTag(String title, String imagePath, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          CommonImage(
            imagePath: imagePath,
            width: 16.w,
            height: 16.h,
            color: Colors.white,
          ),
          CommonSpacing.width(4.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(
    SaleProductModel product,
    List<SaleProductSku> selectedSkusList,
    String diningDate,
  ) {
    // 构建selectedSkus列表
    List<SelectedSkuVO>? selectedSkus;
    if (selectedSkusList.isNotEmpty) {
      selectedSkus =
          selectedSkusList
              .where((sku) => sku.id != null)
              .map(
                (sku) => SelectedSkuVO(
                  id: sku.id!,
                  skuName: sku.skuName ?? '',
                  englishSkuName: sku.englishSkuName,
                  skuPrice: sku.price,
                  skuGroupId: sku.skuGroupId,
                  skuGroupType: sku.skuGroupType,
                ),
              )
              .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTag('New', 'assets/images/fire.png', const Color(0xFFffb700)),
            if (product.hotMark == true)
              _buildTag(
                'Hot',
                'assets/images/search_fire.png',
                AppTheme.primaryOrange,
              ),
          ],
        ),
        CommonSpacing.medium,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.localizedName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            CommonSpacing.width(16.w),
            // 显示SkuCounter（详情页中最小数量为1）
            _DetailPageSkuCounter(
              shopId: widget.shopId,
              productId: product.id,
              productName: product.chineseName,
              englishProductName: product.englishName,
              selectedSkus: selectedSkus,
              diningDate: diningDate,
            ),
          ],
        ),
        CommonSpacing.medium,
        if (product.localizedDescription != null)
          Text(
            product.localizedDescription!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildSkuInfo(SaleProductModel product, AppLocalizations l10n) {
    // 按skuGroupType和skuGroupId分组
    final Map<int, Map<int, List<SaleProductSku>>> groupedSkus = {};
    for (final sku in product.skus) {
      if (sku.id == null || sku.id!.isEmpty) continue;
      final groupType = sku.skuGroupType ?? 1;
      final groupId = sku.skuGroupId ?? 0;
      groupedSkus.putIfAbsent(groupType, () => {});
      groupedSkus[groupType]!.putIfAbsent(groupId, () => []).add(sku);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectSpec,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        CommonSpacing.small,
        // 先显示互斥类型(type=2)
        if (groupedSkus.containsKey(2))
          ...groupedSkus[2]!.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (groupedSkus[2]!.length > 1)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      '分组 ${entry.key}（单选）',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children:
                      entry.value.map((sku) {
                        final isSelected = _selectedSkuIds.contains(sku.id);
                        return _buildSkuItem(sku, isSelected);
                      }).toList(),
                ),
                CommonSpacing.small,
              ],
            );
          }),
        // 再显示可叠加类型(type=1)
        if (groupedSkus.containsKey(1))
          ...groupedSkus[1]!.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (groupedSkus[1]!.length > 1 || groupedSkus.containsKey(2))
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      '分组 ${entry.key}（多选）',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children:
                      entry.value.map((sku) {
                        final isSelected = _selectedSkuIds.contains(sku.id);
                        return _buildSkuItem(sku, isSelected);
                      }).toList(),
                ),
                CommonSpacing.small,
              ],
            );
          }),
      ],
    );
  }

  Widget _buildSelectedSkusDisplay(
    List<SaleProductSku> selectedSkus,
    double totalPrice,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已选规格',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '总计: \$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
          CommonSpacing.small,
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children:
                selectedSkus.map((sku) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppTheme.primaryOrange,
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sku.localizedSkuName ?? sku.skuName ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        CommonSpacing.width(4.w),
                        Text(
                          '+\$${sku.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkuItem(SaleProductSku sku, bool isSelected) {
    // Format price: remove decimals if .00
    final priceStr =
        sku.price.truncateToDouble() == sku.price
            ? sku.price.toStringAsFixed(0)
            : sku.price.toStringAsFixed(2);

    return GestureDetector(
      onTap: () {
        if (sku.id == null) {
          toast.warn('该规格不可用');
          return;
        }
        setState(() {
          final skuGroupType = sku.skuGroupType ?? 1;
          final skuGroupId = sku.skuGroupId ?? 0;

          if (skuGroupType == 2) {
            // 互斥类型：取消同组其他SKU，选中当前SKU
            _selectedSkuIds.removeWhere((id) {
              // 查找同组的其他SKU并移除
              final params = ProductDetailParams(
                productId: widget.productId,
                shopId: widget.shopId,
              );
              final product = ref.read(productDetailDataProvider(params));
              if (product == null) return false;

              final otherSku = product.skus.firstWhere(
                (s) => s.id == id,
                orElse:
                    () => SaleProductSku(
                      price: 0,
                      status: 0,
                      skuGroupId: -1,
                      skuGroupType: -1,
                    ),
              );
              return otherSku.skuGroupId == skuGroupId &&
                  otherSku.skuGroupType == 2;
            });
            _selectedSkuIds.add(sku.id!);
          } else {
            // 可叠加类型：切换选中状态
            if (isSelected) {
              _selectedSkuIds.remove(sku.id);
            } else {
              _selectedSkuIds.add(sku.id!);
            }
          }
        });
        Logger.info(
          "ProductDetailPage",
          "点击规格: ${sku.skuName}, 当前选中: $_selectedSkuIds",
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sku.skuName ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              width: 1.w,
              height: 14.h,
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.5)
                      : const Color(0xFFD8D8D8),
            ),
            Text(
              '\$$priceStr',
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ensureDefaultSku(SaleProductModel product) {
    // 默认不选择任何SKU，由用户手动选择
  }

  List<SaleProductSku> _currentSkus(SaleProductModel product) {
    if (_selectedSkuIds.isEmpty) {
      return [];
    }
    return product.skus
        .where((sku) => _selectedSkuIds.contains(sku.id))
        .toList();
  }

  double _calculateTotalPrice(
    SaleProductModel product,
    List<SaleProductSku> selectedSkus,
    int quantity,
  ) {
    // (商品基础价 + 所有选中SKU的附加价) × 数量
    final basePrice = product.productPrice ?? 0.0;
    final skusPrice = selectedSkus.fold<double>(
      0.0,
      (sum, sku) => sum + sku.price,
    );
    return (basePrice + skusPrice) * quantity;
  }

  int _getQuantityInCart(
    CartState cartState,
    String productId,
    List<SaleProductSku> selectedSkus,
  ) {
    // 查找匹配的购物车条目
    CartItemModel? matchedItem;
    for (final item in cartState.items) {
      if (item.productId == productId) {
        // 检查 selectedSkus 是否匹配
        if (selectedSkus.isNotEmpty) {
          // 需要匹配所有的 SKU ID
          final targetSkuIds = selectedSkus.map((s) => s.id).toSet();
          final itemSkuIds =
              (item.selectedSkus?.map((s) => s.id).toSet()) ?? {};

          if (targetSkuIds.length == itemSkuIds.length &&
              targetSkuIds.every((id) => itemSkuIds.contains(id))) {
            matchedItem = item;
            break;
          }
        } else if (item.selectedSkus == null || item.selectedSkus!.isEmpty) {
          // 没有SKU的商品
          matchedItem = item;
          break;
        }
      }
    }

    final cartQuantity = matchedItem?.quantity ?? 0;
    // 详情页显示数量至少为1
    return cartQuantity >= 1 ? cartQuantity : 1;
  }

  Future<void> _handleAddToCart(
    SaleProductModel product,
    List<SaleProductSku> selectedSkusList,
    String diningDate,
    AppLocalizations l10n,
  ) async {
    final cartState = ref.read(cartStateProvider(widget.shopId));
    final isBusy = cartState.isUpdating || cartState.isOperating;
    if (isBusy) return;

    final notifier = ref.read(cartProvider.notifier);

    try {
      // 立即返回上一页（乐观更新）
      if (mounted) {
        Navigate.pop(context);
      }

      if (product.skuSetting == 1) {
        // 检查是否所有互斥组都已选择
        final mutualExclusiveGroups = <int>{};
        for (final sku in product.skus) {
          if (sku.skuGroupType == 2) {
            mutualExclusiveGroups.add(sku.skuGroupId ?? 0);
          }
        }

        for (final groupId in mutualExclusiveGroups) {
          final hasSelection = selectedSkusList.any(
            (sku) => sku.skuGroupType == 2 && sku.skuGroupId == groupId,
          );
          if (!hasSelection) {
            toast.warn('请选择所有必选规格');
            return;
          }
        }

        // 构建selectedSkus列表（传递所有选中的SKU）
        final selectedSkus =
            selectedSkusList
                .where((sku) => sku.id != null)
                .map(
                  (sku) => SelectedSkuVO(
                    id: sku.id!,
                    skuName: sku.skuName ?? '',
                    englishSkuName: sku.englishSkuName,
                    skuPrice: sku.price,
                    skuGroupId: sku.skuGroupId,
                    skuGroupType: sku.skuGroupType,
                  ),
                )
                .toList();

        await notifier.increment(
          shopId: widget.shopId,
          diningDate: diningDate,
          productId: product.id,
          productName: product.chineseName,
          englishProductName: product.englishName,
          selectedSkus: selectedSkus,
          productPrice: product.productPrice,
        );
      } else {
        // 没有SKU的商品
        await notifier.increment(
          shopId: widget.shopId,
          diningDate: diningDate,
          productId: product.id,
          productName: product.chineseName,
          englishProductName: product.englishName,
          selectedSkus: null,
          productPrice: product.productPrice,
        );
      }

      toast.success(l10n.addToCartSuccess);
    } catch (e) {
      Logger.error('ProductDetailPage', '加入购物车失败: $e');
      toast.warn('加入购物车失败，请稍后重试');
    }
  }
}

/// 详情页专用的SKU计数器（最小数量为1）
class _DetailPageSkuCounter extends ConsumerWidget {
  const _DetailPageSkuCounter({
    required this.shopId,
    required this.productId,
    required this.productName,
    this.englishProductName,
    this.selectedSkus,
    this.diningDate,
  });

  final String shopId;
  final String productId;
  final String productName;
  final String? englishProductName;
  final List<SelectedSkuVO>? selectedSkus;
  final String? diningDate;

  String get _productSpecId =>
      selectedSkus?.isNotEmpty == true ? selectedSkus!.first.id : '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartStateProvider(shopId));

    // 查找匹配的购物车条目
    CartItemModel? matchedItem;
    for (final item in cartState.items) {
      if (item.productId == productId) {
        // 检查 selectedSkus 是否匹配
        if (selectedSkus != null && selectedSkus!.isNotEmpty) {
          // 需要匹配所有的 SKU ID
          final targetSkuIds = selectedSkus!.map((s) => s.id).toSet();
          final itemSkuIds =
              (item.selectedSkus?.map((s) => s.id).toSet()) ?? {};

          if (targetSkuIds.length == itemSkuIds.length &&
              targetSkuIds.every((id) => itemSkuIds.contains(id))) {
            matchedItem = item;
            break;
          }
        } else if (item.selectedSkus == null || item.selectedSkus!.isEmpty) {
          // 没有SKU的商品
          matchedItem = item;
          break;
        }
      }
    }

    final cartQuantity = matchedItem?.quantity ?? 0;

    // 详情页显示数量：购物车数量 >= 1 ? 购物车数量 : 1
    final displayQuantity = cartQuantity >= 1 ? cartQuantity : 1;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            enabled: displayQuantity > 1, // 只有数量>1时才能减少
            onTap: () => _onDecrease(ref),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              displayQuantity.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            enabled: true,
            onTap: () => _onIncrease(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        decoration:
            enabled
                ? null
                : BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.r),
                ),
        child: Icon(
          icon,
          size: 16.w,
          color: enabled ? Colors.black : Colors.grey[400],
        ),
      ),
    );
  }

  Future<void> _onIncrease(WidgetRef ref) async {
    try {
      await ref
          .read(cartProvider.notifier)
          .increment(
            shopId: shopId,
            diningDate: diningDate,
            productId: productId,
            productName: productName,
            englishProductName: englishProductName,
            selectedSkus: selectedSkus,
            productPrice: _getProductPrice(ref),
          );
    } catch (e) {
      Logger.error('_DetailPageSkuCounter', '增加数量失败: $e');
    }
  }

  double? _getProductPrice(WidgetRef ref) {
    try {
      final params = ProductDetailParams(productId: productId, shopId: shopId);
      final product = ref.read(productDetailDataProvider(params));
      return product?.productPrice;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onDecrease(WidgetRef ref) async {
    try {
      await ref
          .read(cartProvider.notifier)
          .decrement(
            shopId: shopId,
            diningDate: diningDate,
            productId: productId,
            productSpecId: _productSpecId,
          );
    } catch (e) {
      Logger.error('_DetailPageSkuCounter', '减少数量失败: $e');
    }
  }
}
