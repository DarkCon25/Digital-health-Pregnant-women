import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool isCircle;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.isCircle = true,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
  });

  static const String _logoPath = 'lib/assets/images/HerCare-v1.png';
  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(isCircle ? size : size * 0.22),
      child: Image.asset(
        _logoPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ✅ Fallback إذا لم توجد الصورة
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.15),
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  isCircle ? null : BorderRadius.circular(size * 0.22),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          );
        },
      ),
    );

    // إذا كان عليه Border
    if (borderColor != null && borderWidth > 0) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(size * 0.22),
          border: Border.all(
            color: borderColor!,
            width: borderWidth,
          ),
          color: backgroundColor ?? Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isCircle ? size : size * 0.22),
            child: Image.asset(
              _logoPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: size * 0.5,
                );
              },
            ),
          ),
        ),
      );
    }

    return image;
  }
}
