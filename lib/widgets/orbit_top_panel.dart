import 'package:flutter/material.dart';

class OrbitTopPanel extends StatelessWidget {
  final String activeContactName;
  final dynamic activeContactStatus; 
  final bool isGroup;
  final bool isCurrentlyLive;
  final bool isCurrentUserAdmin;
  final String liveDurationText;
  final Set<String> mutedContacts;
  final Function(String) onToggleMute;
  final Function(String) onToggleBlock;
  final bool showOnlyUnread;
  final VoidCallback onToggleFilter;
  final bool hapticEnabled;
  final List<String> activeLiveGroupMembers;
  final VoidCallback onRemoveContact; // 🟢 YENİ: Silme işlemi için eklendi

  const OrbitTopPanel({
    super.key,
    required this.activeContactName,
    required this.activeContactStatus,
    required this.isGroup,
    required this.isCurrentlyLive,
    required this.isCurrentUserAdmin,
    required this.liveDurationText,
    required this.mutedContacts,
    required this.onToggleMute,
    required this.onToggleBlock,
    required this.showOnlyUnread,
    required this.onToggleFilter,
    required this.hapticEnabled,
    required this.activeLiveGroupMembers,
    required this.onRemoveContact, // 🟢 YENİ
  });

  Color _getStatusColor(dynamic status) {
    String s = status.toString();
    if (s.contains('available')) return Colors.greenAccent;
    if (s.contains('busy')) return Colors.redAccent;
    if (s.contains('away')) return Colors.orangeAccent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8), 
              borderRadius: BorderRadius.circular(30), 
              border: Border.all(
                color: isCurrentlyLive ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white24, 
                width: 1.0
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isGroup && !isCurrentlyLive) ...[
                  Icon(Icons.circle, color: _getStatusColor(activeContactStatus), size: 10),
                  const SizedBox(width: 6),
                ] else ...[
                  Icon(isGroup ? Icons.groups : Icons.person, size: 14, color: isCurrentlyLive ? Colors.greenAccent : Colors.white70),
                  const SizedBox(width: 6),
                ],
                
                Flexible(
                  child: Text(
                    activeContactName,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (isGroup && isCurrentUserAdmin) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15), 
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 0.5)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 10),
                        const SizedBox(width: 2),
                        const Text("G.Y", style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                
                if (isCurrentlyLive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.greenAccent, size: 8),
                        const SizedBox(width: 4),
                        Text(liveDurationText, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ),
                ],
                
                if (mutedContacts.contains(activeContactName)) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.notifications_off, color: Colors.orangeAccent, size: 12),
                ],
                
                // 🟢 GÜNCELLEME: Menüyü hem grup hem de kişiler için açıyoruz ki "Yörüngeden Çıkar" hepsinde çalışsın
                const SizedBox(width: 2),
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                    color: Colors.grey.shade900.withValues(alpha: 0.95),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white24)),
                    offset: const Offset(0, 30),
                    onSelected: (value) {
                      if (value == 'mute') {
                        onToggleMute(activeContactName);
                      } else if (value == 'block') {
                        onToggleBlock(activeContactName);
                      } else if (value == 'filter') {
                        onToggleFilter();
                      } else if (value == 'remove') {
                        onRemoveContact(); // 🟢 YENİ
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      bool isMuted = mutedContacts.contains(activeContactName);
                      return [
                        PopupMenuItem(
                          value: 'filter',
                          child: Row(
                            children: [
                              Icon(showOnlyUnread ? Icons.filter_alt : Icons.filter_alt_outlined, color: Colors.cyanAccent, size: 16),
                              const SizedBox(width: 8),
                              Text(showOnlyUnread ? "Tümünü Göster" : "Okunmayanları Süz", style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem(
                          value: 'mute',
                          child: Row(
                            children: [
                              Icon(isMuted ? Icons.notifications_active : Icons.notifications_off, color: Colors.orangeAccent, size: 16),
                              const SizedBox(width: 8),
                              Text(isMuted ? "Sesi Aç" : "Sessize Al", style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (!isGroup)
                          PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                const Icon(Icons.block, color: Colors.orangeAccent, size: 16),
                                const SizedBox(width: 8),
                                const Text("Kişiyi Engelle", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                              ],
                            ),
                          ),
                        const PopupMenuDivider(height: 1),
                        // 🟢 YENİ: Yörüngeden Çıkar Seçeneği
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep, color: Colors.redAccent, size: 16),
                              SizedBox(width: 8),
                              Text("Yörüngeden Çıkar", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        
        if (isGroup && isCurrentlyLive && activeLiveGroupMembers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: activeLiveGroupMembers.map((member) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4), 
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.1), 
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 0.5), 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.greenAccent, size: 6), 
                    const SizedBox(width: 4), 
                    Text(member, style: const TextStyle(fontSize: 9, color: Colors.greenAccent))
                  ]
                ),
              )).toList(),
            ),
          )
      ],
    );
  }
}