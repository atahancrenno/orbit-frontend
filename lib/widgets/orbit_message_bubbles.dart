import 'package:flutter/material.dart';
import '../models/audio_message.dart';

class OrbitMessageBubbles {
  static Widget buildLiveLogView(AudioMessage msg, String formattedDuration) {
    Color logColor = msg.isMe ? Colors.cyanAccent : Colors.greenAccent;
    
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          border: Border(
            left: BorderSide(color: logColor.withValues(alpha: 0.5), width: 3),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
            topLeft: Radius.circular(3),
            bottomLeft: Radius.circular(3),
          )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq, size: 14, color: logColor),
            const SizedBox(width: 8),
            Text(
              msg.isMe ? "Canlı İletim ($formattedDuration)" : "${msg.senderName ?? msg.contactName} ($formattedDuration)", 
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11)
            ),
            const SizedBox(width: 12),
            Text(msg.time, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  static Widget buildDeletedMessageView(AudioMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black54, border: Border.all(color: Colors.white12, width: 0.5), borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, size: 12, color: Colors.white30),
            SizedBox(width: 4),
            Text("Ses mesajı silindi", style: TextStyle(color: Colors.white30, fontSize: 9, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}