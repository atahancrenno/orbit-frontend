import 'package:flutter/material.dart';

class OrbitGridMenu extends StatelessWidget {
  final bool isLeftHanded;
  final double menuX;
  final double menuY;
  final double orbitRadius;
  final bool showSearchField;
  final int activeIndex;
  
  // Aksiyonlar
  final VoidCallback onSavedMessagesTap;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;

  const OrbitGridMenu({
    super.key,
    required this.isLeftHanded,
    required this.menuX,
    required this.menuY,
    required this.orbitRadius,
    required this.showSearchField,
    required this.activeIndex,
    required this.onSavedMessagesTap,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onSettingsTap,
  });

  Widget _buildIcon(IconData icon, bool isSearchBtn, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.8), 
          border: Border.all(color: (isSearchBtn && showSearchField) ? Colors.orangeAccent : Colors.white24, width: 1.5),
        ),
        child: Icon(icon, size: 18, color: (isSearchBtn && showSearchField) ? Colors.orangeAccent : color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isLeftHanded ? menuX - orbitRadius - 60 : menuX + orbitRadius - 20, 
      top: menuY - 40, 
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: showSearchField ? 0.0 : 1.0, 
        child: IgnorePointer(
          ignoring: showSearchField, 
          child: SizedBox(
            width: 80, 
            height: 80, 
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0, 
              crossAxisSpacing: 8.0, 
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIcon(Icons.bookmark, false, onSavedMessagesTap, Colors.orangeAccent),
                _buildIcon(Icons.search, true, onSearchTap, Colors.white),
                _buildIcon(Icons.person_outline, false, onProfileTap, Colors.white),
                _buildIcon(Icons.settings, false, onSettingsTap, Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}