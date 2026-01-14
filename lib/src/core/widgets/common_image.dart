import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 通用图片组件
/// 自动识别网络图片和本地图片，提供统一的图片展示接口
class CommonImage extends StatelessWidget {
  /// 图片路径（必传）
  final String imagePath;
  
  /// 图片宽度
  final double? width;
  
  /// 图片高度
  final double? height;
  
  /// 填充模式
  final BoxFit fit;
  
  /// 占位符组件
  final Widget? placeholder;
  
  /// 错误组件
  final Widget? errorWidget;
  
  /// 圆角半径
  final double? borderRadius;
  
  /// 边框半径（用于ClipRRect）
  final BorderRadius? borderRadiusClip;
  
  /// 图片装饰
  final BoxDecoration? decoration;

  /// 图片颜色
  final Color? color;

  const CommonImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.borderRadiusClip,
    this.decoration,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 判断图片类型
    final bool isNetworkImage = _isNetworkImage(imagePath);
    final bool isLocalFile = _isLocalFile(imagePath);
    
    Widget imageWidget;
    
    if (isNetworkImage) {
      // 网络图片 - 使用 cached_network_image
      // 获取设备像素比以确保高清显示
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final cacheWidth = width != null ? (width! * devicePixelRatio).toInt() : null;
      final cacheHeight = height != null ? (height! * devicePixelRatio).toInt() : null;
      
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        // 缓存配置 - 根据设备像素比设置，确保高清显示
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,
        color: color,
      );
    } else if (isLocalFile) {
      // 本地文件路径
      imageWidget = Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // 本地资源图片
      imageWidget = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    // 应用装饰
    Widget decoratedWidget = imageWidget;
    
    // 如果有圆角或装饰，添加Container包装
    if (borderRadius != null || borderRadiusClip != null || decoration != null) {
      decoratedWidget = Container(
        width: width,
        height: height,
        decoration: decoration,
        child: ClipRRect(
          borderRadius: borderRadiusClip ?? 
              (borderRadius != null ? BorderRadius.circular(borderRadius!) : BorderRadius.zero),
          child: imageWidget,
        ),
      );
    } else if (borderRadius != null) {
      // 只有圆角的情况
      decoratedWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: imageWidget,
      );
    }

    return decoratedWidget;
  }

  /// 判断是否为网络图片
  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || 
           path.startsWith('https://') ||
           path.startsWith('//');
  }

  /// 判断是否为本地文件路径
  bool _isLocalFile(String path) {
    // 移除file://前缀（如果有）
    final cleanPath = path.replaceFirst('file://', '');
    // 判断是否为绝对路径（Unix/Mac/iOS以/开头，Windows以盘符开头）
    return cleanPath.startsWith('/') || 
           (cleanPath.length > 1 && cleanPath[1] == ':'); // Windows路径如 C:\
  }

  /// 构建占位符组件
  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }
    
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.image,
        color: Colors.grey[400],
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : 24.w,
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }
    
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[400],
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : 24.w,
      ),
    );
  }
}

/// 圆形图片组件
class CommonCircularImage extends StatelessWidget {
  /// 图片路径（必传）
  final String imagePath;
  
  /// 图片尺寸
  final double size;
  
  /// 填充模式
  final BoxFit fit;
  
  /// 占位符组件
  final Widget? placeholder;
  
  /// 错误组件
  final Widget? errorWidget;
  
  /// 边框宽度
  final double? borderWidth;
  
  /// 边框颜色
  final Color? borderColor;

  /// 图片颜色
  final Color? color;

  const CommonCircularImage({
    super.key,
    required this.imagePath,
    required this.size,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderWidth,
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth != null && borderColor != null
            ? Border.all(width: borderWidth!, color: borderColor!)
            : null,
      ),
      child: ClipOval(
        child: CommonImage(
          imagePath: imagePath,
          width: size,
          height: size,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
          color: color,
        ),
      ),
    );
  }
}

/// 圆角矩形图片组件
class CommonRoundedImage extends StatelessWidget {
  /// 图片路径（必传）
  final String imagePath;
  
  /// 图片宽度
  final double? width;
  
  /// 图片高度
  final double? height;
  
  /// 圆角半径
  final double borderRadius;
  
  /// 填充模式
  final BoxFit fit;
  
  /// 占位符组件
  final Widget? placeholder;
  
  /// 错误组件
  final Widget? errorWidget;

  /// 图片颜色
  final Color? color;

  const CommonRoundedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CommonImage(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      borderRadiusClip: BorderRadius.circular(borderRadius),
      color: color,
    );
  }
}
