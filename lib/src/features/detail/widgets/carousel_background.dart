import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_image.dart';
import '../models/detail_model.dart';

class CarouselBackground extends StatefulWidget {
  final ShopModel? shop;
  final double logoHeight;
  const CarouselBackground({super.key, required this.shop, required this.logoHeight});

  @override
  State<CarouselBackground> createState() => _CarouselBackgroundState();
}

class _CarouselBackgroundState extends State<CarouselBackground> {
  CarouselSliderController? _carouselController;

  @override
  void initState() {
    super.initState();
    // 只在需要轮播图时创建 controller
    final backgroundImages = widget.shop?.backgroundImage?.where((img) => img.url != null).toList() ?? [];
    if (backgroundImages.length > 1) {
      _carouselController = CarouselSliderController();
    }
  }

  @override
  void didUpdateWidget(CarouselBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 shop 变化时，如果从多图变为少图，需要清理 controller
    final oldImages = oldWidget.shop?.backgroundImage?.where((img) => img.url != null).toList() ?? [];
    final newImages = widget.shop?.backgroundImage?.where((img) => img.url != null).toList() ?? [];
    
    // 如果从多图变为单图或空，清理 controller
    if (oldImages.length > 1 && newImages.length <= 1 && _carouselController != null) {
      _carouselController = null;
    }
    // 如果从单图或空变为多图，创建 controller
    else if (oldImages.length <= 1 && newImages.length > 1) {
      _carouselController = CarouselSliderController();
    }
    // 如果 shop ID 变化，重新创建 controller（通过 key 实现强制重建）
    else if (oldWidget.shop?.id != widget.shop?.id) {
      _carouselController = newImages.length > 1 ? CarouselSliderController() : null;
    }
  }

  @override
  void dispose() {
    // Controller 会在组件销毁时自动清理，不需要手动 dispose
    _carouselController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取背景图列表
    final backgroundImages = widget.shop?.backgroundImage?.where((img) => img.url != null).toList() ?? [];
    
    // 如果没有背景图或为空，使用默认图片
    if (backgroundImages.isEmpty) {
      return CommonImage(
        imagePath: "assets/images/banner.png",
        height: widget.logoHeight,
        width: 1.sw,
      );
    }

    // 如果只有一张图，直接显示
    if (backgroundImages.length == 1) {
      return CommonImage(
        imagePath: backgroundImages.first.url!,
        height: widget.logoHeight,
        width: 1.sw,
      );
    }

    // 多张图片时使用轮播图
    // 使用 key 确保组件正确重建，避免定时器错误
    return CarouselSlider(
      key: ValueKey('carousel_${widget.shop?.id}_${backgroundImages.length}'),
      carouselController: _carouselController,
      options: CarouselOptions(
        height: widget.logoHeight,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
        pauseAutoPlayOnTouch: true,
        pauseAutoPlayOnManualNavigate: true,
        // 禁用无限滚动，避免边界情况
        enableInfiniteScroll: backgroundImages.length > 1,
      ),
      items: backgroundImages.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return CommonImage(
              imagePath: image.url!,
              height: widget.logoHeight,
              width: 1.sw,
            );
          },
        );
      }).toList(),
    );
  }
}