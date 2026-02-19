import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

/// Centralized premium loading widgets for the app.
class AppLoaders {
  static const Color primaryColor = Colors.orange;
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);

  /// A premium branded animated spinner.
  static Widget loadingIndicator({
    Color color = primaryColor,
    double size = 60.0,
  }) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer high-speed ring
          SpinKitRing(
            color: color,
            size: size,
            lineWidth: 1.5,
            duration: const Duration(milliseconds: 1000),
          ),
          // Inner soft pulse
          SpinKitPulse(color: color.withOpacity(0.2), size: size * 0.85),
          // Center Branded Logo
          Container(
            height: size * 0.5,
            width: size * 0.5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A smaller spinner for buttons or inline use.
  static Widget buttonLoader({Color color = Colors.white, double size = 30.0}) {
    return Center(
      child: SpinKitThreeBounce(color: color, size: size * 0.6),
    );
  }

  /// A base shimmer wrapper.
  static Widget shimmerWrapper({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }

  /// A shimmer box for placeholders.
  static Widget shimmerBox({
    double? width,
    double? height,
    double borderRadius = 8,
  }) {
    return shimmerWrapper(
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// A shimmer for list items (e.g., Orders or Pairs).
  static Widget listShimmer({int itemCount = 8, double height = 80}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: [
            shimmerBox(width: 48, height: 48, borderRadius: 12),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(width: index % 2 == 0 ? 120 : 150, height: 14),
                  const SizedBox(height: 8),
                  shimmerBox(width: index % 2 == 0 ? 80 : 60, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                shimmerBox(width: 50, height: 14),
                const SizedBox(height: 8),
                shimmerBox(width: 30, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A shimmer for grid items.
  static Widget gridShimmer({int itemCount = 4}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => shimmerBox(borderRadius: 12),
    );
  }
}
