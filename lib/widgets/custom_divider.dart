import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  /// Color of the dots. Defaults to a soft grey.
  final Color? color;

  /// Radius of each dot. Default: 1.5
  final double dotRadius;

  /// Gap between dot centres. Default: 7
  final double gap;

  /// Total height of the widget (should be ≥ dotRadius * 2). Default: 1
  final double height;

  /// Optional widget shown centred on the divider (e.g. a label or icon).
  final Widget? center;

  /// Indent from left edge (mirrors [Divider.indent]). Default: 0
  final double indent;

  /// Indent from right edge. Default: 0
  final double endIndent;

  const DottedDivider({
    super.key,
    this.color,
    this.dotRadius = 1.5,
    this.gap = 7,
    this.height = 1,
    this.center,
    this.indent = 0,
    this.endIndent = 0,
  });

  // ── Named constructors ─────────────────────────────────────────────────────

  /// Thick primary-coloured dots — good for section separators.
  factory DottedDivider.primary({Color color = const Color(0xFFE07840)}) =>
      DottedDivider(color: color, dotRadius: 2, gap: 8);

  /// Coupon tear-line style — notch circles + dots + scissors icon.
  /// Use this as a direct replacement for the _DashedDivider in coupon_page.dart.
  static Widget tearLine({Color? color}) => _TearLineDivider(color: color);

  /// Dots with a centred label chip (e.g. "OR", "TODAY").
  static Widget withLabel({
    required String label,
    Color? dotColor,
    Color? labelColor,
    Color? labelBg,
    double dotRadius = 1.5,
    double gap = 7,
  }) {
    return DottedDivider(
      color: dotColor,
      dotRadius: dotRadius,
      gap: gap,
      height: 20,
      center: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: labelBg ?? const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: dotColor?.withOpacity(0.3) ?? Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: labelColor ?? Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? Colors.grey.shade300;

    if (center == null) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: SizedBox(
          height: dotRadius * 2,
          child: CustomPaint(
            size: Size.infinite,
            painter: _DottedLinePainter(
              color: dotColor,
              dotRadius: dotRadius,
              gap: gap,
            ),
          ),
        ),
      );
    }

    // With a center widget: split the line around it
    return Row(
      children: [
        SizedBox(width: indent),
        Expanded(
          child: SizedBox(
            height: dotRadius * 2,
            child: CustomPaint(
              painter: _DottedLinePainter(
                color: dotColor,
                dotRadius: dotRadius,
                gap: gap,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: center!,
        ),
        Expanded(
          child: SizedBox(
            height: dotRadius * 2,
            child: CustomPaint(
              painter: _DottedLinePainter(
                color: dotColor,
                dotRadius: dotRadius,
                gap: gap,
              ),
            ),
          ),
        ),
        SizedBox(width: endIndent),
      ],
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double gap;

  const _DottedLinePainter({
    required this.color,
    required this.dotRadius,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cy = size.height / 2;
    double x = dotRadius;
    while (x < size.width) {
      canvas.drawCircle(Offset(x, cy), dotRadius, paint);
      x += dotRadius * 2 + gap;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter old) =>
      old.color != color || old.dotRadius != dotRadius || old.gap != gap;
}

// ══════════════════════════════════════════════════════════════════════════════
// _TearLineDivider  (coupon style with notch circles + scissors)
// ══════════════════════════════════════════════════════════════════════════════

class _TearLineDivider extends StatelessWidget {
  final Color? color;

  const _TearLineDivider({this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade300;
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          // Left notch (half circle punched out from card edge)
          _Notch(color: c, side: _NotchSide.left),
          const SizedBox(width: 2),
          // Dotted line (left half)
          Expanded(
            child: CustomPaint(
              painter: _DottedLinePainter(
                color: c,
                dotRadius: 1.5,
                gap: 5,
              ),
            ),
          ),
          // Scissors icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.content_cut_rounded, size: 14, color: c),
          ),
          // Dotted line (right half)
          Expanded(
            child: CustomPaint(
              painter: _DottedLinePainter(
                color: c,
                dotRadius: 1.5,
                gap: 5,
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Right notch
          _Notch(color: c, side: _NotchSide.right),
        ],
      ),
    );
  }
}

enum _NotchSide { left, right }

/// Half-circle that overlaps the card border, giving a punched-out coupon look.
class _Notch extends StatelessWidget {
  final Color color;
  final _NotchSide side;

  const _Notch({required this.color, required this.side});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(side == _NotchSide.left ? -10 : 10, 0),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          // The background should match the page background so it looks
          // like a hole. Use kBg or your scaffold background color here.
          color: const Color(0xFFF5F5F5), // ← change to kBg / your bg
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
      ),
    );
  }
}
