import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final Color activeColor;
  final Color inactiveColor;
  final double time;

  CircularWaveformPainter({
    required this.progress, 
    required this.isPlaying, 
    required this.activeColor, 
    required this.inactiveColor, 
    required this.time
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6; 
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5; 

    int count = 20; 
    double startAngle = -math.pi; 
    double sweepAngle = math.pi;
    double angleStep = sweepAngle / (count - 1);

    List<double> baseH = [2, 4, 7, 5, 10, 15, 8, 12, 18, 10, 6, 14, 20, 12, 8, 16, 9, 13, 6, 11, 7, 4, 3, 2, 2];

    for (int i = 0; i < count; i++) {
      double angle = startAngle + (i * angleStep); 
      
      double h = baseH[i % baseH.length];
      if (isPlaying) {
         h = h + (math.sin(time + i) * 3); 
      }
      h = h.clamp(2.0, 15.0); 

      bool isActive = (i / count) <= progress;
      paint.color = isActive ? activeColor : inactiveColor;
      
      if (isActive) {
         paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 2); 
      } else {
         paint.maskFilter = null;
      }

      final innerPoint = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final outerPoint = Offset(
        center.dx + math.cos(angle) * (radius - h), 
        center.dy + math.sin(angle) * (radius - h),
      );

      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SmoothWaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final Color activeColor;
  final double time;

  SmoothWaveformPainter({
    required this.progress,
    required this.isPlaying,
    required this.activeColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2); 

    Paint inactivePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    Path activePath = Path();
    Path inactivePath = Path();
    
    double midY = size.height / 2;
    double width = size.width;
    
    activePath.moveTo(0, midY);
    inactivePath.moveTo(0, midY);

    for (double x = 0; x <= width; x++) {
      double yOffset = 0;
      if (isPlaying) {
        yOffset = math.sin((x / 10) + time) * 4 + math.cos((x / 5) + time * 1.5) * 2;
      } else {
        yOffset = math.sin(x / 10) * 4 + math.cos(x / 5) * 2;
      }
      
      double edgeDamping = math.sin((x / width) * math.pi); 
      double finalY = midY + (yOffset * edgeDamping);

      if (x <= width * progress) {
        activePath.lineTo(x, finalY);
        inactivePath.moveTo(x, finalY); 
      } else {
        inactivePath.lineTo(x, finalY);
      }
    }

    canvas.drawPath(inactivePath, inactivePaint);
    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- YENİ EKLENDİ: baseAngle PARAMETRESİ İLE AKILLI YÖRÜNGE HİZALAMASI ---
class CurvedTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final Color color;
  final Color? statusColor; 
  final double baseAngle; 

  CurvedTextPainter({
    required this.text, 
    required this.radius, 
    this.color = Colors.white70,
    this.statusColor,
    required this.baseAngle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    int totalSteps = text.length + (statusColor != null ? 2 : 0); 
    double stepAngle = 0.17;
    double totalSweep = (totalSteps - 1) * stepAngle;
    
    // Metni her zaman mikrofondan dışarı doğru bakan 'baseAngle' açısına ortala
    double startAngle = baseAngle - (totalSweep / 2);
    
    for (int i = 0; i < totalSteps; i++) {
      final double angle = startAngle + (i * stepAngle); 
      final double x = radius * math.cos(angle);
      final double y = radius * math.sin(angle);
      
      canvas.save(); 
      canvas.translate(x, y); 
      canvas.rotate(angle + math.pi / 2); 
      
      if (statusColor != null && i == 0) {
         Paint dotPaint = Paint()..color = statusColor!;
         canvas.drawCircle(const Offset(0, 0), 4.5, dotPaint); 
      } else if (statusColor != null && i == 1) {
         // Boşluk
      } else {
         int charIndex = statusColor != null ? i - 2 : i;
         textPainter.text = TextSpan(
           text: text[charIndex],
           style: TextStyle(
             color: color.withValues(alpha: 0.95), 
             fontSize: 8.5, 
             fontWeight: FontWeight.bold, 
             letterSpacing: 1.2,
             shadows: const [
               Shadow(
                 color: Colors.black87,
                 blurRadius: 4.0,
                 offset: Offset(1.0, 1.0),
               ),
             ],
           ),
         );
         textPainter.layout();
         textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      }
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class NeonRingPainter extends CustomPainter {
  final Color innerColor;
  final Color outerColor;
  final bool isRecording;
  final bool isLeftHanded;
  final double audioLevel; 

  NeonRingPainter({
    required this.innerColor,
    required this.outerColor,
    required this.isRecording,
    required this.isLeftHanded,
    this.audioLevel = 0.0, 
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final double extraRadius = isRecording ? (audioLevel * 12.0) : 0.0;
    
    final outerRadius = (size.width / 2) + extraRadius; 
    
    final innerRadius = (size.width / 2) - 10.0;

    final outerPaint = Paint()
      ..color = outerColor.withValues(alpha: 0.8 + (audioLevel * 0.2)) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 + (audioLevel * 2) 
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 5 + (audioLevel * 5)); 

    double startAngle;
    double sweepAngle;

    if (!isLeftHanded) {
      startAngle = -math.pi / 2;
      sweepAngle = 1.5 * math.pi; 
    } else {
      startAngle = 0.0;
      sweepAngle = 1.5 * math.pi;
    }
    
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
        outerPaint,
    );

    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant NeonRingPainter oldDelegate) {
    return oldDelegate.isRecording != isRecording || 
           oldDelegate.isLeftHanded != isLeftHanded || 
           oldDelegate.audioLevel != audioLevel;
  }
}