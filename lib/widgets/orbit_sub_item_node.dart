import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/painters.dart';

class OrbitSubItemNode extends StatelessWidget {
  final int index;
  final Map<String, dynamic> item;
  final double itemSpacingAngle;
  final double scrollOffset;
  final double menuX;
  final double menuY;
  final double orbitRadius;
  final bool isLeftHanded;
  final VoidCallback onTap;

  const OrbitSubItemNode({
    super.key,
    required this.index,
    required this.item,
    required this.itemSpacingAngle,
    required this.scrollOffset,
    required this.menuX,
    required this.menuY,
    required this.orbitRadius,
    required this.isLeftHanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double startAngle = -0.35 * math.pi;
    double angle = startAngle - (index * itemSpacingAngle) + scrollOffset;

    double baseOpacity = 1.0;
    if (angle > -0.1 * math.pi || angle < -1.8 * math.pi) {
      baseOpacity = 0.0;
    }

    // Orijinal dosyadaki mükemmel kenar kaybolma (Fade) matematiği korundu!
    double fadeOpacity = 1.0;
    double fadeDistance = 40.0;
    double tempX = menuX + orbitRadius * math.cos(angle);
    if (isLeftHanded) {
      tempX = menuX - orbitRadius * math.cos(angle);
    }

    if (!isLeftHanded) {
      double dist = (menuX + orbitRadius - 15) - tempX;
      if (dist <= 0) {
        fadeOpacity = 0.0;
      } else if (dist < fadeDistance) {
        fadeOpacity = dist / fadeDistance;
      }
    } else {
      double dist = tempX - (menuX - orbitRadius + 15);
      if (dist <= 0) {
        fadeOpacity = 0.0;
      } else if (dist < fadeDistance) {
        fadeOpacity = dist / fadeDistance;
      }
    }

    double finalOpacity = (baseOpacity * fadeOpacity).clamp(0.0, 1.0);

    double xOffset = orbitRadius * math.cos(angle);
    double yOffset = orbitRadius * math.sin(angle);
    if (isLeftHanded) {
      xOffset = -xOffset;
    }

    double globalAngle = math.atan2(yOffset, xOffset);
    
    String name = item['name'] ?? '';
    if (name.length > 10) {
      name = name.substring(0, 10);
    }
    
    Color itemColor = item['color'] ?? Colors.cyanAccent;

    return Positioned(
      left: menuX + xOffset - 50, // 🟢 100x100 olduğu için merkeze hizalamak adına -50 yapıldı
      top: menuY + yOffset - 50,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: finalOpacity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 100, height: 100, // 🟢 Boyut Kişi Widget'ları ile eşitlendi (100x100)
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🟢 Sadece Ses Efektleri/Dürtmeler için kavisli yazıyı çiz. Emojiyse ÇİZME!
                if (item['emoji'] == null)
                  CustomPaint(
                    painter: CurvedTextPainter(
                      text: name.toUpperCase(),
                      radius: 46, // Yarıçap kişi widget'ı ile aynı yapıldı
                      color: itemColor,
                      baseAngle: globalAngle,
                    ),
                  ),
                
                // 🟢 İç Avatar Kutusu boyutu ve Fontlar büyütüldü
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                    border: Border.all(color: itemColor.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [BoxShadow(color: itemColor.withValues(alpha: 0.2), blurRadius: 8)],
                  ),
                  alignment: Alignment.center,
                  child: item['emoji'] != null 
                    ? Text(item['emoji'], style: const TextStyle(fontSize: 32)) // 🟢 Emoji devasa oldu
                    : Icon(item['icon'], color: itemColor, size: 28), // 🟢 İkonlar da büyütüldü
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}