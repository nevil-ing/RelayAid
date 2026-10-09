import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

class RelayAidMark extends StatelessWidget {
  const RelayAidMark({this.size = AppSpacing.space32, this.color, super.key});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: RelayAidMarkPainter(
        color ?? Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class RelayAidBrand extends StatelessWidget {
  const RelayAidBrand({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const RelayAidMark(),
      const SizedBox(width: AppSpacing.space8),
      Flexible(
        child: Text(
          'RelayAid',
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// Three linked paths represent reporting, coordination and response.
/// The same vector is rendered for app icons, launch art and the README.
class RelayAidMarkPainter extends CustomPainter {
  const RelayAidMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(21, 66)
        ..lineTo(42, 27)
        ..quadraticBezierTo(50, 13, 58, 27)
        ..lineTo(70, 49),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(62, 34)
        ..lineTo(84, 73)
        ..quadraticBezierTo(92, 87, 75, 87)
        ..lineTo(49, 87),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(69, 87)
        ..lineTo(24, 87)
        ..quadraticBezierTo(8, 87, 16, 73)
        ..lineTo(29, 50),
      paint,
    );
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(50, 60), 8, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RelayAidMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
