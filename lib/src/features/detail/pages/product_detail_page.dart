import 'package:carousel_slider/carousel_slider.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/features/detail/widgets/sku_counter.dart';
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
  String? _selectedSkuId;

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
    final selectedSku = _currentSku(product);

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
                    _buildProductInfo(product, selectedSku, diningDate),
                    CommonSpacing.medium,
                    if (product.skuSetting == 1 && product.skus.isNotEmpty)
                      _buildSkuInfo(product, l10n),
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
                      "\$${cartState.totals.subtotal.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
                _buildCartButton(product, selectedSku, diningDate, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartButton(
    SaleProductModel product,
    SaleProductSku? selectedSku,
    String diningDate,
    AppLocalizations l10n,
  ) {
    final cartState = ref.watch(cartStateProvider(widget.shopId));
    final isBusy = cartState.isUpdating || cartState.isOperating;

    return GestureDetector(
      onTap: isBusy
          ? null
          : () => _handleAddToCart(product, selectedSku, diningDate, l10n),
      child: Container(
        decoration: BoxDecoration(
          color: isBusy ? Colors.grey[400] : AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(22.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        child: isBusy
            ? CommonIndicator(strokeWidth: 2, color: Colors.white, size: 14.w)
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
      items: images.map((image) {
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
    SaleProductSku? selectedSku,
    String diningDate,
  ) {
    final displayPrice = product.productPrice ?? (selectedSku?.price ?? 0.0);

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
            SkuCounter(
              shopId: widget.shopId,
              productId: product.id,
              productName: product.localizedName,
              productSpecId: selectedSku?.id ?? '',
              productSpecName: selectedSku?.skuName ?? product.localizedName,
              diningDate: diningDate,
              price: displayPrice,
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
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: product.skus.map((sku) {
            final isSelected = sku.id == _selectedSkuId;
            return _buildSkuItem(sku, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkuItem(SaleProductSku sku, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (sku.id == null) {
          toast.warn('该规格不可用');
          return;
        }
        setState(() {
          _selectedSkuId = sku.id;
        });
        Logger.info("ProductDetailPage", "点击规格: ${sku.skuName}");
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.grey[300]!,
            width: 1.w,
          ),
        ),
        child: Text(
          sku.skuName ?? '',
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _ensureDefaultSku(SaleProductModel product) {
    if (_selectedSkuId != null) return;
    if (product.skus.isEmpty) return;
    final candidate = product.skus.firstWhere(
      (sku) => (sku.id ?? '').isNotEmpty,
      orElse: () => product.skus.first,
    );
    if (candidate.id == null || candidate.id!.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedSkuId != null) return;
      setState(() {
        _selectedSkuId = candidate.id;
      });
    });
  }

  SaleProductSku? _currentSku(SaleProductModel product) {
    if (_selectedSkuId == null) {
      return product.skus.isNotEmpty ? product.skus.first : null;
    }
    try {
      return product.skus.firstWhere((sku) => sku.id == _selectedSkuId);
    } catch (_) {
      return product.skus.isNotEmpty ? product.skus.first : null;
    }
  }

  Future<void> _handleAddToCart(
    SaleProductModel product,
    SaleProductSku? selectedSku,
    String diningDate,
    AppLocalizations l10n,
  ) async {
    final cartState = ref.read(cartStateProvider(widget.shopId));
    final isBusy = cartState.isUpdating || cartState.isOperating;
    if (isBusy) return;

    final notifier = ref.read(cartProvider.notifier);
    final displayPrice = product.productPrice ?? (selectedSku?.price ?? 0.0);

    try {
      if (product.skuSetting == 1) {
        if (selectedSku == null || selectedSku.id == null) {
          toast.warn('请选择规格');
          return;
        }
        await notifier.increment(
          shopId: widget.shopId,
          diningDate: diningDate,
          productId: product.id,
          productName: product.localizedName,
          productSpecId: selectedSku.id ?? '',
          productSpecName: selectedSku.skuName ?? product.localizedName,
          price: displayPrice,
        );
      } else {
        final sku = product.skus.isNotEmpty ? product.skus.first : null;
        final specId = sku?.id ?? '';
        final specName = sku?.skuName ?? '';

        await notifier.increment(
          shopId: widget.shopId,
          diningDate: diningDate,
          productId: product.id,
          productName: product.localizedName,
          productSpecId: specId,
          productSpecName: specName,
          price: displayPrice,
        );
      }

      toast.success(l10n.addToCartSuccess);
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigate.pop(context);
        }
      }
    } catch (e) {
      Logger.error('ProductDetailPage', '加入购物车失败: $e');
      toast.warn('加入购物车失败，请稍后重试');
    }
  }
}
