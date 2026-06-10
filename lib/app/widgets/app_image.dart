import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';

enum AppImageType { network, asset, file }

/// A reusable Image component supporting Network, Asset, and File images.
/// Includes support for Aspect Ratio, Border Radius, Error Fallback, and Loading State.
class AppImage extends StatelessWidget {
  final String path;
  final AppImageType type;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BoxFit fit;
  final double borderRadius;
  final Color? backgroundColor;
  final Widget? errorWidget;

  const AppImage.network(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.backgroundColor,
    this.errorWidget,
  }) : type = AppImageType.network;

  const AppImage.asset(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.backgroundColor,
    this.errorWidget,
  }) : type = AppImageType.asset;

  const AppImage.file(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.backgroundColor,
    this.errorWidget,
  }) : type = AppImageType.file;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImage(context);

    // Apply background color if provided
    if (backgroundColor != null) {
      imageWidget = Container(color: backgroundColor, child: imageWidget);
    }

    // Apply aspect ratio if provided
    if (aspectRatio != null) {
      imageWidget = AspectRatio(aspectRatio: aspectRatio!, child: imageWidget);
    } else if (width != null || height != null) {
      imageWidget = SizedBox(width: width, height: height, child: imageWidget);
    }

    // Apply border radius
    if (borderRadius > 0) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImage(BuildContext context) {
    switch (type) {
      case AppImageType.network:
        return Image.network(
          path,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingState(context);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState(context);
          },
        );
      case AppImageType.asset:
        return Image.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState(context);
          },
        );
      case AppImageType.file:
        return Image.file(
          File(path),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorState(context);
          },
        );
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      color: context.surface,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    if (errorWidget != null) return errorWidget!;

    return Container(
      color: context.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: context.textTertiary,
        size: 32,
      ),
    );
  }
}
