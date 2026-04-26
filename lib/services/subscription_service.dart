import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/paywall_screen.dart';

class SubscriptionService {
  static const String premiumKey = 'is_orbit_plus';

  // 1. Durumu Kontrol Et (Hem Yerel Hem Sunucu)
  static Future<bool> isPremium() async {
    try {
      final profile = await Adapty().getProfile();
      bool active = profile.accessLevels['premium']?.isActive ?? false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(premiumKey, active);
      
      return active;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(premiumKey) ?? false;
    }
  }

  // 2. Paywall'u Açma Fonksiyonu
  static void showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaywallScreen()),
    );
  }
}