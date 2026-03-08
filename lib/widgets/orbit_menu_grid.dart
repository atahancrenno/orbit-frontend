import 'package:flutter/material.dart';

class OrbitMenuGrid extends StatelessWidget {
  final bool isLeftHanded;
  final bool showSearchField;
  final double menuX;
  final double menuY;
  final double orbitRadius;
  final double screenWidth;
  final VoidCallback onToggleHand; // Ana ekran hata vermesin diye burada bırakıldı
  final VoidCallback onSearchTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onContactAddTap;

  const OrbitMenuGrid({
    super.key,
    required this.isLeftHanded,
    required this.showSearchField,
    required this.menuX,
    required this.menuY,
    required this.orbitRadius,
    required this.screenWidth,
    required this.onToggleHand,
    required this.onSearchTap,
    required this.onBookmarkTap,
    required this.onSettingsTap,
    required this.onContactAddTap,
  });

  Widget _buildGridActionIcon(IconData icon, bool isSearchBtn, VoidCallback? onTapOverride, Color color) {
    return GestureDetector(
      onTap: onTapOverride,
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
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      // 🟢 MÜKEMMEL SİMETRİ: Her iki tarafta da ekranın kenarından tam 30 piksel içeride olacak! (Eski ok tuşu tamamen silindi)
      left: isLeftHanded ? 30.0 : screenWidth - 110.0, 
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
              // Eski kodda gereksiz yere if/else ile iki kez yazılmıştı, kodu sadeleştirdik.
              children: [
                _buildGridActionIcon(Icons.search, true, onSearchTap, Colors.white),
                _buildGridActionIcon(Icons.bookmark, false, onBookmarkTap, Colors.orangeAccent),
                _buildGridActionIcon(Icons.settings, false, onSettingsTap, Colors.white),
                _buildGridActionIcon(Icons.person_add_alt_1, false, onContactAddTap, Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}