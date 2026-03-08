import 'package:flutter/material.dart';
import '../models/audio_message.dart'; // UserStatus enum'ı için

class OrbitAvatar extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isActive;
  final bool isMatch;
  final bool showSearchField;
  final bool isLiveModeActive;

  const OrbitAvatar({
    super.key,
    required this.item,
    required this.isActive,
    required this.isMatch,
    required this.showSearchField,
    required this.isLiveModeActive,
  });

  String getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return "${parts[0][0]}.${parts[parts.length - 1][0]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    bool isGroup = item['isGroup'];
    Color ringColor;
    Color innerColor;

    if (isActive) {
      ringColor = isLiveModeActive ? Colors.greenAccent : Colors.cyanAccent;
      innerColor = Colors.black.withValues(alpha: 0.9);
    } else if (showSearchField && isMatch) { // Arama aktif ve eşleşme varsa
      ringColor = Colors.orangeAccent;
      innerColor = Colors.black.withValues(alpha: 0.9);
    } else {
      ringColor = Colors.white30; 
      
      if (isGroup) {
         innerColor = Colors.deepPurpleAccent.withValues(alpha: 0.8);
      } else {
         if (item['status'] == UserStatus.busy) {
           innerColor = Colors.orangeAccent.shade400.withValues(alpha: 0.9);
         } else if (item['status'] == UserStatus.available) {
           innerColor = Colors.blueGrey.shade600;
         } else {
           innerColor = Colors.grey.shade800;
         }
      }
    }

    return Container(
      width: 60, height: 60, 
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: isActive ? 5.0 : 4.0),
        color: Colors.transparent, 
        boxShadow: [
           if (isActive) BoxShadow(color: ringColor.withValues(alpha: 0.5), blurRadius: 10)
        ],
      ),
      padding: const EdgeInsets.all(7.0), 
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: innerColor, 
        ),
        child: Center(
          child: isGroup 
              ? const Icon(Icons.groups, size: 22, color: Colors.white) 
              : Text(getInitials(item['name']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}