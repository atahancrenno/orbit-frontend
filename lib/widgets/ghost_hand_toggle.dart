import 'package:flutter/material.dart';
import 'dart:async';

class GhostHandToggle extends StatefulWidget {
  final bool isLeftHanded;
  final VoidCallback onToggle;

  const GhostHandToggle({
    super.key, 
    required this.isLeftHanded, 
    required this.onToggle
  });

  @override
  State<GhostHandToggle> createState() => _GhostHandToggleState();
}

class _GhostHandToggleState extends State<GhostHandToggle> {
  bool _isInteracting = false;
  bool _isInitiallyVisible = true;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _startFadeTimer();
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isInitiallyVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        setState(() => _isInteracting = true);
        _fadeTimer?.cancel();
      },
      onPanCancel: () {
        setState(() => _isInteracting = false);
        _startFadeTimer();
      },
      onPanEnd: (_) {
        setState(() => _isInteracting = false);
        _startFadeTimer();
      },
      onTapDown: (_) {
        setState(() => _isInteracting = true);
        _fadeTimer?.cancel();
      },
      onTapUp: (_) {
        setState(() => _isInteracting = false);
        widget.onToggle();
        setState(() => _isInitiallyVisible = true);
        _startFadeTimer();
      },
      onTapCancel: () {
        setState(() => _isInteracting = false);
        _startFadeTimer();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _isInteracting ? 0.6 : (_isInitiallyVisible ? 0.10 : 0.01),
        child: Container(
          width: 30,
          height: 300,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _GhostArrowPainter(isLeftHanded: widget.isLeftHanded),
          ),
        ),
      ),
    );
  }
}

class _GhostArrowPainter extends CustomPainter {
  final bool isLeftHanded;

  _GhostArrowPainter({required this.isLeftHanded});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    double startX = isLeftHanded ? 0.0 : size.width;
    double apexX = isLeftHanded ? size.width : 0.0;
    double midY = size.height / 2;

    path.moveTo(startX, midY - 110);
    path.lineTo(apexX, midY);
    path.lineTo(startX, midY + 110);

    canvas.drawPath(path, paint..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3));
    canvas.drawPath(path, paint..maskFilter = null);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}