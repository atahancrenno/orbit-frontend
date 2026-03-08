import 'package:flutter/material.dart';

class ConnectionArrows extends StatefulWidget {
  final Color color; 
  const ConnectionArrows({super.key, this.color = Colors.cyanAccent});
  
  @override
  State<ConnectionArrows> createState() => _ConnectionArrowsState();
}

class _ConnectionArrowsState extends State<ConnectionArrows> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Işının akış hızı
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Genişlik, kişi widget'ı kenarı ile mikrofon kenarı arasındaki tahmini mesafe kadardır.
    return SizedBox(
      width: 70, 
      height: 20, // Işının kaplayacağı dikey alan
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: NeonBeamPainter(
              progress: _controller.value,
              beamColor: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class NeonBeamPainter extends CustomPainter {
  final double progress;
  final Color beamColor;

  NeonBeamPainter({required this.progress, required this.beamColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Işının başlama ve bitiş koordinatları
    final double startX = 0;
    final double endX = size.width;
    final double centerY = size.height / 2;

    // Işının anlık konumu (soldan sağa doğru akıyor)
    double currentX = startX + (endX - startX) * progress;

    // --- 1. Sönük Arka Plan İzi (Işının Rotası) ---
    final bgPaint = Paint()
      ..color = beamColor.withValues(alpha: 0.1)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), bgPaint);

    // --- 2. Akan Parlak Işın (Kuyruklu Yıldız Efekti) ---
    // Kuyruğun uzunluğu
    double tailLength = 30.0;
    double tailStart = currentX - tailLength;
    if (tailStart < startX) tailStart = startX;

    // Kuyruk için Gradyan boya (Başı parlak, arkası silik)
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [beamColor.withValues(alpha: 0.0), beamColor, beamColor],
        stops: const [0.0, 0.8, 1.0],
      ).createShader(Rect.fromPoints(Offset(tailStart, centerY - 2), Offset(currentX, centerY + 2)))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3); // Neon Parlama

    canvas.drawLine(Offset(tailStart, centerY), Offset(currentX, centerY), beamPaint);

    // --- 3. Işının Ucundaki Enerji Topu (Parlak Nokta) ---
    final dotPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(currentX, centerY), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant NeonBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}