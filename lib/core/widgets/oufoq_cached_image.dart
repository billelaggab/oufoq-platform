import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// صورة شبكية مع كاش، حساب ذكي للعرض، وحالة بديلة أنيقة.
class OufoqCachedImage extends StatelessWidget {
  const OufoqCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry radiusGeometry =
        borderRadius ?? BorderRadius.circular(12);
    final BorderRadius radius =
        radiusGeometry.resolve(Directionality.maybeOf(context));
    final int? cacheWidth = memCacheWidth ?? _resolveCacheWidth(context);

    final Widget child = (imageUrl == null || imageUrl!.isEmpty)
        ? _buildPlaceholder(context)
        : CachedNetworkImage(
            imageUrl: imageUrl!,
            height: height,
            width: width,
            fit: fit,
            memCacheWidth: cacheWidth,
            placeholder: (BuildContext context, String url) =>
                _buildLoading(context),
            errorWidget: (BuildContext context, String url, Object error) =>
                _buildPlaceholder(context),
          );

    return ClipRRect(borderRadius: radius, child: child);
  }

  int? _resolveCacheWidth(BuildContext context) {
    final double devicePixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final double screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 360;
    return (screenWidth * devicePixelRatio).round();
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: AppTheme.customOf(context).adSurface,
      alignment: AlignmentDirectional.center,
      child: Icon(
        Icons.image_outlined,
        color: AppTheme.customOf(context).textSecondary,
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Image.asset(
      'assets/images/placeholder_news.png',
      height: height,
      width: width,
      fit: fit,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) =>
              _buildLoading(context),
    );
  }
}
