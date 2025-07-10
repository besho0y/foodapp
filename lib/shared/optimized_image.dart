import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class OptimizedImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final bool isCircular;
  final Color? backgroundColor;
  final Duration? fadeInDuration;
  final double? memCacheWidth;
  final double? memCacheHeight;

  const OptimizedImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.heroTag,
    this.isCircular = false,
    this.backgroundColor,
    this.fadeInDuration,
    this.memCacheWidth,
    this.memCacheHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageWidget(context);

    // Add hero animation if heroTag is provided
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    // Add circular clipping if requested
    if (isCircular) {
      imageWidget = ClipOval(child: imageWidget);
    } else if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImageWidget(BuildContext context) {
    // Handle null or empty URLs
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget(context);
    }

    // Handle network images
    if (imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth?.toInt(),
        memCacheHeight: memCacheHeight?.toInt(),
        fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 200),
        placeholder: (context, url) =>
            placeholder ?? _buildShimmerPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(context),
        cacheManager: DefaultCacheManager(),
      );
    }

    // Handle asset images
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget(context);
        },
      );
    }

    // Default fallback
    return _buildErrorWidget(context);
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[300],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? (isDark ? Colors.grey[800] : Colors.grey[300]),
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: (width != null && height != null)
              ? (width! < height! ? width! * 0.3 : height! * 0.3)
              : 24.sp,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }
}

// Specialized widgets for different use cases
class RestaurantImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final String? heroTag;

  const RestaurantImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OptimizedImageWidget(
      imageUrl: imageUrl,
      width: width ?? double.infinity,
      height: height ?? 85.h,
      fit: BoxFit.cover,
      heroTag: heroTag,
      memCacheWidth: 200, // Optimize memory usage
      memCacheHeight: 150,
      errorWidget: _buildRestaurantErrorWidget(),
    );
  }

  Widget _buildRestaurantErrorWidget() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 85.h,
      color: Colors.grey[300],
      child: Icon(
        Icons.restaurant,
        size: 40.sp,
        color: Colors.grey[600],
      ),
    );
  }
}

class CategoryImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const CategoryImageWidget({
    Key? key,
    this.imageUrl,
    this.size = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OptimizedImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      isCircular: true,
      memCacheWidth: 100, // Small cache for categories
      memCacheHeight: 100,
      errorWidget: _buildCategoryErrorWidget(context),
    );
  }

  Widget _buildCategoryErrorWidget(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[300],
      ),
      child: Icon(
        Icons.category,
        size: size * 0.5,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.orange
            : Colors.grey[600],
      ),
    );
  }
}

class BannerImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const BannerImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OptimizedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      memCacheWidth: 400, // Higher quality for banners
      memCacheHeight: 200,
      fadeInDuration: const Duration(milliseconds: 300),
      errorWidget: _buildBannerErrorWidget(),
    );
  }

  Widget _buildBannerErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image,
        size: 50.sp,
        color: Colors.grey[600],
      ),
    );
  }
}

class ItemImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final String? heroTag;

  const ItemImageWidget({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OptimizedImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      heroTag: heroTag,
      memCacheWidth: 250, // Medium quality for items
      memCacheHeight: 200,
      errorWidget: _buildItemErrorWidget(),
    );
  }

  Widget _buildItemErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.fastfood,
        size: 40.sp,
        color: Colors.grey[600],
      ),
    );
  }
}

// Cache management utilities
class ImageCacheManager {
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  // Clear image cache
  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  // Get cache size
  static Future<int> getCacheSize() async {
    // Note: This is a simplified version
    // In newer versions of flutter_cache_manager, direct database access may not be available
    return 0; // Placeholder - cache size monitoring can be added later if needed
  }

  // Pre-cache important images
  static Future<void> preCacheImage(
      String imageUrl, BuildContext context) async {
    if (imageUrl.startsWith('http')) {
      await precacheImage(CachedNetworkImageProvider(imageUrl), context);
    } else if (imageUrl.startsWith('assets/')) {
      await precacheImage(AssetImage(imageUrl), context);
    }
  }

  // Pre-cache multiple images
  static Future<void> preCacheImages(
      List<String> imageUrls, BuildContext context) async {
    for (String url in imageUrls) {
      try {
        await preCacheImage(url, context);
      } catch (e) {
        print('Error pre-caching image $url: $e');
      }
    }
  }
}
