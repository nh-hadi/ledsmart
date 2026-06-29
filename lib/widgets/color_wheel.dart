import 'dart:math' as math;
import 'package:flutter/material.dart';

class NixieColorWheel extends StatefulWidget {
  final int r, g, b;
  final Function(int, int, int) padaWarnaBerubah;

  const NixieColorWheel({
    super.key,
    required this.r,
    required this.g,
    required this.b,
    required this.padaWarnaBerubah,
  });

  @override
  State<NixieColorWheel> createState() => _NixieColorWheelState();
}

class _NixieColorWheelState extends State<NixieColorWheel> {
  Offset _posisiMarker = Offset.zero;
  bool _initialized = false;
  final double _radius = 110.0;

  void _hitungPosisiDariWarna(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hsv = HSVColor.fromColor(Color.fromARGB(255, widget.r, widget.g, widget.b));
    final angle = hsv.hue * math.pi / 180.0;
    final distance = hsv.saturation * _radius;
    _posisiMarker = Offset(
      center.dx + math.cos(angle) * distance,
      center.dy + math.sin(angle) * distance,
    );
    _initialized = true;
  }

  void _prosesSentuhan(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final offset = localPosition - center;
    double distance = offset.distance;
    if (distance > _radius) distance = _radius;
    double angle = math.atan2(offset.dy, offset.dx);
    double hue = angle * 180.0 / math.pi;
    if (hue < 0) hue += 360.0;
    double saturation = distance / _radius;
    final rgbColor = HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
    setState(() {
      _posisiMarker =
          center + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
    });
    widget.padaWarnaBerubah(rgbColor.red, rgbColor.green, rgbColor.blue);
  }

  @override
  Widget build(BuildContext context) {
    _initialized = false;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 240);
        if (!_initialized) _hitungPosisiDariWarna(size);
        return Container(
          color: const Color(0xFF151233),
          child: GestureDetector(
            onPanDown: (d) => _prosesSentuhan(d.localPosition, size),
            onPanUpdate: (d) => _prosesSentuhan(d.localPosition, size),
            child: CustomPaint(
              size: size,
              painter: ColorWheelPainter(
                radius: _radius,
                posisiMarker: _posisiMarker,
                warnaAktif: Color.fromARGB(255, widget.r, widget.g, widget.b),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ColorWheelPainter extends CustomPainter {
  final double radius;
  final Offset posisiMarker;
  final Color warnaAktif;

  ColorWheelPainter({
    required this.radius,
    required this.posisiMarker,
    required this.warnaAktif,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF151233),
    );

    final sweepPaint = Paint()
      ..shader = SweepGradient(colors: const [
        Color(0xFFFF0000),
        Color(0xFFFFFF00),
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFF0000FF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ]).createShader(rect);
    canvas.drawCircle(center, radius, sweepPaint);

    final satPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, satPaint);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.drawCircle(
      posisiMarker,
      14,
      Paint()
        ..color = warnaAktif.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawCircle(posisiMarker, 9, Paint()..color = warnaAktif);
    canvas.drawCircle(
      posisiMarker,
      9,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant ColorWheelPainter old) =>
      old.posisiMarker != posisiMarker || old.warnaAktif != warnaAktif;
}
