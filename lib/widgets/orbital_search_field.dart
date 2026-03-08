import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrbitalSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspacePressed;
  
  const OrbitalSearchField({
    super.key, 
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, 
      height: 32, 
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: Colors.grey.shade900.withValues(alpha: 0.95),
        shape: const StadiumBorder(side: BorderSide(color: Colors.cyanAccent, width: 1.0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 14, color: Colors.cyanAccent),
          const SizedBox(width: 8),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(), 
              onKeyEvent: (event) {
                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && controller.text.isEmpty) {
                  onBackspacePressed();
                }
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Roboto'), 
                cursorColor: Colors.cyanAccent,
                decoration: const InputDecoration(
                  hintText: "Kişi Ara...",
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}