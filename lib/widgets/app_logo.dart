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

  // ✅ المسار الصحيح بدون lib/
  static const String _logoPath = 'lib/assets/images/HerCare-v1.png';

  // ── Border Radius حسب الشكل ─────────────────
  BorderRadius get _radius => isCircle
      ? BorderRadius.circular(size)
      : BorderRadius.circular(size * 0.22);

  // ── Fallback Icon إذا الصورة غير موجودة ─────
  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2563EB).withValues(alpha: 0.15),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : _radius,
      ),
      child: Icon(
        Icons.favorite_rounded,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  // ── الصورة الأساسية ──────────────────────────
  Widget _image({double? customSize}) {
    final s = customSize ?? size;
    return Container(
      padding: EdgeInsets.all((s * 0.06).clamp(2, 8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        border: Border.all(
          color: const Color(0x11000000),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Image.asset(
          _logoPath,
          width: s,
          height: s,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── مع Border ───────────────────────────────
    if (borderColor != null && borderWidth > 0) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : _radius,
          border: Border.all(
            color: borderColor!,
            width: borderWidth,
          ),
          color: backgroundColor ?? Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: _image(customSize: size - (borderWidth * 2)),
        ),
      );
    }

    // ── بدون Border ──────────────────────────────
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : _radius,
      ),
      child: _image(),
    );
  }
}

