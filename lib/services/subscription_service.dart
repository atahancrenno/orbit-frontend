import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import '../screens/orbit_plus_screen.dart';

class SubscriptionService {
  // 🚨 DİKKAT: Adapty panelinde Placement ID olarak ne belirlediysen onu buraya yaz.
  // Ekran görüntüsünde adını "Ana Yerleşim" yapmışsın, eğer ID'sini "main_placement" yaptıysan sorun yok.
  static const String placementId = "main_placement";

  // Kullanıcının Orbit Plus üyesi olup olmadığını kontrol eden altın fonksiyon
  static Future<bool> isPremium() async {
    try {
      final profile = await Adapty().getProfile();
      // Adapty panelinde oluşturduğumuz Access Level ID'si: premium
      return profile.accessLevels['premium']?.isActive ?? false;
    } catch (e) {
      debugPrint("🚨 Premium Kontrol Hatası: $e");
      return false;
    }
  }

  // Ödeme ekranını (Orbit Plus Vitrinini) açan fonksiyon
  static void showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrbitPlusScreen()),
    );
  }

  // Kullanıcı cihaz değiştirirse satın alımlarını geri yüklemesi için
  static Future<bool> restorePurchases() async {
    try {
      final profile = await Adapty().restorePurchases();
      return profile.accessLevels['premium']?.isActive ?? false;
    } catch (e) {
      debugPrint("🚨 Satın Alım Geri Yükleme Hatası: $e");
      return false;
    }
  }
}