import 'dart:math' as math;

import 'package:flutter/material.dart';

/// When the window is narrower than [sidebarWidth] + [minMainWidth], allows
/// horizontal scrolling instead of a yellow/black RenderFlex overflow strip.
class ResponsiveDashboardShell extends StatelessWidget {
  const ResponsiveDashboardShell({
    super.key,
    required this.sidebarWidth,
    required this.minMainWidth,
    required this.sidebar,
    required this.main,
  });

  final double sidebarWidth;
  final double minMainWidth;
  final Widget sidebar;
  final Widget main;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minTotal = sidebarWidth + minMainWidth;
        final shellW = math.max(constraints.maxWidth, minTotal);
        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: false,
            child: SizedBox(
              width: shellW,
              height: constraints.maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: sidebarWidth, child: sidebar),
                  SizedBox(
                    width: shellW - sidebarWidth,
                    child: main,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Two-column split (e.g. messages): scroll horizontally if too narrow.
class ResponsiveHorizontalSplit extends StatelessWidget {
  const ResponsiveHorizontalSplit({
    super.key,
    required this.leftWidth,
    required this.minRightWidth,
    required this.left,
    required this.right,
    this.between,
    this.betweenWidth = 0,
  });

  final double leftWidth;
  final double minRightWidth;
  final Widget left;
  final Widget right;
  /// Optional divider between panels (e.g. [VerticalDivider]).
  final Widget? between;
  final double betweenWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = between == null ? 0.0 : betweenWidth;
        final minTotal = leftWidth + gap + minRightWidth;
        final w = math.max(constraints.maxWidth, minTotal);
        final rightW = w - leftWidth - gap;
        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: false,
            child: SizedBox(
              width: w,
              height: constraints.maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: leftWidth, child: left),
                  if (between != null)
                    SizedBox(width: gap, child: between),
                  SizedBox(width: rightW, child: right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
