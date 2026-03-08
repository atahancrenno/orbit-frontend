import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsBottomSheet extends StatelessWidget {
  // GÜNCELLEME: Başlangıç sekmesini belirlemek için eklendi (0: Orbit, 1: Davet)
  final int initialIndex;
  const ContactsBottomSheet({super.key, this.initialIndex = 0});

  static void show(BuildContext context, {int initialIndex = 0}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ContactsBottomSheet(initialIndex: initialIndex),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return "${parts[0][0]}.${parts[parts.length - 1][0]}".toUpperCase();
  }

  Future<void> _inviteViaWhatsApp(BuildContext context, String name) async {
    const String message = "Seni Orbit'e davet ediyorum! Sen de kendini yörüngeye fırlat: https://orbitapp.com/invite";
    final Uri url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cihazında WhatsApp yüklü değil!")));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yönlendirme başarısız oldu.")));
      }
    }
  }

  Widget _buildContactListTile(BuildContext context, String name, {required bool isOrbitUser}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: isOrbitUser ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.grey.shade800,
        child: Text(_getInitials(name), style: TextStyle(color: isOrbitUser ? Colors.cyanAccent : Colors.white70, fontWeight: FontWeight.bold)),
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: Text(isOrbitUser ? "Orbit'te çevrimiçi" : "Rehberinde kayıtlı", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      trailing: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOrbitUser ? Colors.cyanAccent.withValues(alpha: 0.2) : const Color(0xFF25D366).withValues(alpha: 0.2),
          foregroundColor: isOrbitUser ? Colors.cyanAccent : const Color(0xFF25D366),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), 
            side: BorderSide(color: isOrbitUser ? Colors.cyanAccent.withValues(alpha: 0.5) : const Color(0xFF25D366).withValues(alpha: 0.5))
          ),
        ),
        onPressed: () {
          if (isOrbitUser) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name yörüngeye eklendi!")));
          } else {
            _inviteViaWhatsApp(context, name);
          }
        },
        icon: isOrbitUser ? const SizedBox.shrink() : const Icon(Icons.wechat, size: 16), 
        label: Text(isOrbitUser ? "Ekle ➕" : "Davet Et", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)],
      ),
      child: DefaultTabController(
        length: 2,
        initialIndex: initialIndex, // GÜNCELLEME BURADA
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Yörüngeye Ekle", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(icon: Icon(Icons.radar), text: "Orbit'tekiler"),
                Tab(icon: Icon(Icons.share), text: "Davet Et"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildContactListTile(context, "Ahmet Yılmaz", isOrbitUser: true),
                      _buildContactListTile(context, "Zeynep Demir", isOrbitUser: true),
                      _buildContactListTile(context, "Mert Can", isOrbitUser: true),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildContactListTile(context, "Veli Kavak", isOrbitUser: false),
                      _buildContactListTile(context, "Ayşe Nur", isOrbitUser: false),
                      _buildContactListTile(context, "Hakan Şahin", isOrbitUser: false),
                      _buildContactListTile(context, "Burcu Ekin", isOrbitUser: false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}