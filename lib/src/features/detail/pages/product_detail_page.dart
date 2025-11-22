import 'package:carousel_slider/carousel_slider.dart';
import 'package:chop_user/src/features/detail/widgets/sku_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/detail_model.dart';
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
  @override
  void initState() {
    super.initState();
    // 在初始化后加载商品详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = ProductDetailParams(
        productId: widget.productId,
        shopId: widget.shopId,
      );
      final currentState = ref.read(productDetailProvider(params));
      // 只有当商品为空且未加载时才请求
      if (currentState.product == null && !currentState.isLoading) {
        ref
            .read(productDetailProvider(params).notifier)
            .loadProductDetail(widget.productId, widget.shopId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = ProductDetailParams(
      productId: widget.productId,
      shopId: widget.shopId,
    );

    final product = ref.watch(productDetailDataProvider(params));
    final isLoading = ref.watch(productDetailLoadingProvider(params));
    final error = ref.watch(productDetailErrorProvider(params));

    return Scaffold(
      appBar: CommonAppBar(title: '', backgroundColor: Colors.transparent),
      body: _buildBody(isLoading, error, product),
    );
  }

  Widget _buildBody(bool isLoading, String? error, SaleProductModel? product) {
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
                '加载失败',
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
                child: const Text('重试'),
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

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child:  Column(
            children: [
              // 商品图片
              _buildProductImages(product),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFfbfbfb),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w , vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(product),
                    CommonSpacing.medium,
                    if (product.skuSetting == 1 && product.skus.isNotEmpty)
                      _buildSkuInfo(product),
                  ],
                ),
              ),
            ],
          ),
        ),
       
        // 底部购物车
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
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                    CommonSpacing.width(4.w),
                    Text(
                      "\$${100.00}",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
                _buildCartButton(),
              ],
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: () {
        Logger.info("ProductDetailPage", "点击加入购物车");
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Text(
          '加入购物车', 
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)
        ),
      )
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

  Widget _buildTag(String title , String imagePath, Color color){
    return Container(
      padding: EdgeInsets.symmetric(horizontal:4.w, vertical: 1.h ),
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(6.r)
      ),
      child: Row(
        children: [
          CommonImage(imagePath: imagePath, width: 16.w, height: 16.h , color: Colors.white),
          CommonSpacing.width(4.w),
          Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildProductInfo(SaleProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTag('New',  'assets/images/fire.png', const Color(0xFFffb700)),
            if(product.hotMark == true)
              _buildTag('Hot', 'assets/images/search_fire.png', AppTheme.primaryOrange),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                product.localizedName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SkuCounter()
          ],
        ),
        CommonSpacing.medium,
        if(product.highlight != null)
          Text(
            product.highlight!,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        CommonSpacing.medium,
        if (product.localizedDescription != null)
          Text(
            product.localizedDescription!,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        
      ],
    );
  }

  Widget _buildSkuInfo(SaleProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '规格',
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
          children:
              product.skus.map((sku) {
                return _buildSkuItem(sku , true);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkuItem(SaleProductSku sku , bool isSelected) {
    return GestureDetector(
      onTap: () {
        Logger.info("ProductDetailPage", "点击规格: ${sku.skuName}");
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppTheme.primaryOrange : Colors.grey[200]!, width: 1.w), // 选中的样式
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sku.skuName ?? '默认规格',
              style: TextStyle(fontSize: 12.sp, color: isSelected ? AppTheme.primaryOrange : Colors.black  , fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
