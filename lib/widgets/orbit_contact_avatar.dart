import 'package:flutter/material.dart';

class OrbitContactAvatar extends StatelessWidget {
  final Map<String, dynamic> contact;
  final bool isActive;
  final bool isMatch;
  final bool isLive;
  final bool showSearchField;
  final int unreadCount;
  final String userName;
  final Color myCustomColor;
  final Color? statusColor; // 🟢 YENİ: Durum rengini buraya aldık!

  const OrbitContactAvatar({
    super.key,
    required this.contact,
    required this.isActive,
    required this.isMatch,
    required this.isLive,
    required this.showSearchField,
    required this.unreadCount,
    required this.userName,
    required this.myCustomColor,
    this.statusColor, // 🟢 YENİ
  });

  String _getInitials(String name) {
    if (name == "Davet Et" || name.trim().isEmpty) return "";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return "";
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return "${parts[0][0]}.${parts.last[0]}".toUpperCase();
  }

  Color _getAutoAvatarColor(String name) {
    final List<Color> avatarColors = [
      Colors.blueAccent, Colors.redAccent, Colors.greenAccent,
      Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent,
      Colors.pinkAccent, Colors.indigoAccent
    ];
    int hash = name.hashCode.abs();
    return avatarColors[hash % avatarColors.length].withValues(alpha: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    bool isGroup = contact['isGroup'] ?? false;
    Color ringColor;
    Color innerColor;

    if (isLive) {
      ringColor = Colors.greenAccent;
      innerColor = Colors.black.withValues(alpha: 0.9);
    } else if (isActive) {
      ringColor = statusColor ?? Colors.cyanAccent; // 🟢 Seçiliyken durum renginde parlasın
      innerColor = Colors.black.withValues(alpha: 0.9);
    } else if (showSearchField && isMatch) {
      ringColor = Colors.orangeAccent;
      innerColor = Colors.black.withValues(alpha: 0.9);
    } else {
      ringColor = statusColor ?? Colors.white30; // 🟢 İnce Çerçeve Rengi (Duruma göre değişir)
      if (isGroup) {
        innerColor = Colors.deepPurpleAccent.withValues(alpha: 0.8);
      } else if (contact['name'] == userName) {
        innerColor = myCustomColor;
      } else {
        innerColor = _getAutoAvatarColor(contact['name']); // İç rengi koruduk ki yazılar okunsun
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: (isActive || isLive) ? 5.0 : 3.0),
            color: Colors.transparent,
            // 🟢 SİHİRLİ NEON HALKA: Durum rengine göre dışarıya doğru neon ışık saçar
            boxShadow: [ 
              if (isActive || isLive) 
                BoxShadow(color: ringColor.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2)
              else if (statusColor != null)
                BoxShadow(color: ringColor.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)
            ],
          ),
          padding: const EdgeInsets.all(7.0),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: innerColor),
            child: Center(
              child: isGroup
                ? const Icon(Icons.groups, size: 22, color: Colors.white)
                : Text(_getInitials(contact['name']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5))
            )
          ),
        ),
        
        if (unreadCount > 0)
          Positioned(
            top: -2, right: -2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.redAccent, shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 6)]
              ),
              child: Text(
                unreadCount > 9 ? "9+" : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          )
      ],
    );
  }
}