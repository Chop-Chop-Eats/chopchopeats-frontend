import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/common_image.dart';
import '../models/detail_model.dart';

class CarouselBackground extends StatelessWidget {
  final ShopModel? shop;
  final double logoHeight;
  const CarouselBackground({super.key, required this.shop, required this.logoHeight});

  @override
  Widget build(BuildContext context) {
   // 获取背景图列表
    final backgroundImages = shop?.backgroundImage?.where((img) => img.url != null).toList() ?? [];
    
    // 如果没有背景图或为空，使用默认图片
    if (backgroundImages.isEmpty) {
      return CommonImage(
        imagePath: "assets/images/banner.png",
        height: logoHeight,
        width: 1.sw,
      );
    }

    // 如果只有一张图，直接显示
    if (backgroundImages.length == 1) {
      return CommonImage(
        imagePath: backgroundImages.first.url!,
        height: logoHeight,
        width: 1.sw,
      );
    }

    // 多张图片时使用轮播图
    return CarouselSlider(
      options: CarouselOptions(
        height: logoHeight,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
      ),
      items: backgroundImages.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return CommonImage(
              imagePath: image.url!,
              height: logoHeight,
              width: 1.sw,
            );
          },
        );
      }).toList(),
    );
  }
}