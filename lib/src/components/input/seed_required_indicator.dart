// Internal: not exported from package:seed_design.
//
// Shared by SeedField and SeedFieldset so both render the official
// Field.RequiredIndicator glyph.
import 'package:material_ui/material_ui.dart';

/// Paints the official Field required-indicator asterisk on a 6×6 grid.
class SeedRequiredIndicatorPainter extends CustomPainter {
  /// Paints the 6×6 required asterisk in [color].
  const SeedRequiredIndicatorPainter(this.color);

  /// Fill color of the asterisk.
  final Color color;

  static final Path _path = Path()
    ..moveTo(3.75002, 1.55859)
    ..lineTo(4.41318, 1.09468)
    ..cubicTo(4.75243, 0.857361, 5.21982, 0.939865, 5.45732, 1.27899)
    ..cubicTo(5.69499, 1.61836, 5.61243, 2.08615, 5.27295, 2.32366)
    ..lineTo(4.30763, 2.99902)
    ..lineTo(5.27372, 3.67612)
    ..cubicTo(5.61285, 3.91381, 5.69517, 4.38137, 5.45761, 4.72059)
    ..cubicTo(5.21999, 5.0599, 4.7523, 5.14233, 4.41299, 4.90471)
    ..lineTo(3.75002, 4.44043)
    ..lineTo(3.75002, 5.25)
    ..cubicTo(3.75002, 5.66421, 3.41423, 6, 3.00002, 6)
    ..cubicTo(2.5858, 6, 2.25002, 5.66421, 2.25002, 5.25)
    ..lineTo(2.25002, 4.44043)
    ..lineTo(1.58704, 4.90471)
    ..cubicTo(1.24773, 5.14233, 0.780041, 5.0599, 0.542418, 4.72059)
    ..cubicTo(0.304856, 4.38137, 0.387176, 3.91381, 0.726309, 3.67612)
    ..lineTo(1.6924, 2.99902)
    ..lineTo(0.727079, 2.32366)
    ..cubicTo(0.387603, 2.08615, 0.305043, 1.61836, 0.542707, 1.27899)
    ..cubicTo(0.780206, 0.939865, 1.2476, 0.857361, 1.58685, 1.09468)
    ..lineTo(2.25002, 1.55859)
    ..lineTo(2.25002, 0.75)
    ..cubicTo(2.25002, 0.335786, 2.5858, 0, 3.00002, 0)
    ..cubicTo(3.41423, 0, 3.75002, 0.335786, 3.75002, 0.75)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 6, size.height / 6);
    canvas.drawPath(_path, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(SeedRequiredIndicatorPainter oldDelegate) =>
      color != oldDelegate.color;
}
