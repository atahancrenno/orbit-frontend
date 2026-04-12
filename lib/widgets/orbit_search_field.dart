import 'package:flutter/material.dart';

class OrbitSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const OrbitSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Arka plana tıklamayı engellemek için
      child: Container(
        width: 250, height: 50,
        decoration: BoxDecoration(
          color: Colors.black87, 
          borderRadius: BorderRadius.circular(25), 
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1),
            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)
          ]
        ),
        child: Center(
          child: TextField(
            controller: controller, 
            focusNode: focusNode, 
            autofocus: true, 
            cursorColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 1.0),
            decoration: InputDecoration(
              hintText: "Orbitte Ara...", 
              hintStyle: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.4), fontStyle: FontStyle.italic), 
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.saved_search, color: Colors.cyanAccent, size: 22),
              suffixIcon: controller.text.isNotEmpty 
                ? GestureDetector(
                    onTap: onClear, 
                    child: const Icon(Icons.cancel, color: Colors.cyanAccent, size: 18)
                  ) 
                : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}