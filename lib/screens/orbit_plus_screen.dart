import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adapty_flutter/adapty_flutter.dart'; // 🟢 ADAPTY EKLENDİ
import 'dart:ui';

import 'orbit_main_screen.dart';

class OrbitPlusScreen extends StatefulWidget {
  const OrbitPlusScreen({super.key});

  @override
  State<OrbitPlusScreen> createState() => _OrbitPlusScreenState();
}

class _OrbitPlusScreenState extends State<OrbitPlusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _currentLang = 'tr';
  bool _isLoading = false; 

  final Map<String, Map<String, String>> _texts = {
    'title': {'tr': 'Orbit Plus', 'en': 'Orbit Plus', 'de': 'Orbit Plus', 'ru': 'Orbit Plus'},
    'subtitle': {'tr': 'Sınırları Aşan Kesintisiz İletişim', 'en': 'Seamless Communication Beyond Limits', 'de': 'Nahtlose Kommunikation über Grenzen hinweg', 'ru': 'Бесшовная связь без границ'},
    'feat_1_title': {'tr': 'Reklamsız Ses Efektleri', 'en': 'Ad-Free Voice Effects'},
    'feat_1_desc': {'tr': 'Tüm frekanslara ve ses efektlerine anında, reklamsız erişim sağlayın.', 'en': 'Instant, ad-free access to all frequencies and voice effects.'},
    'feat_2_title': {'tr': 'Genişletilmiş Grup Ağları', 'en': 'Extended Group Networks'},
    'feat_2_desc': {'tr': 'Daha kalabalık gruplar kurun ve iletişiminizi genişletin.', 'en': 'Create larger groups and expand your communication.'},
    'feat_3_title': {'tr': 'Sınırsız Mesaj Arşivi', 'en': 'Unlimited Message Archive'},
    'feat_3_desc': {'tr': 'Önemli telsiz kayıtlarınızı süre sınırı olmadan güvenle saklayın.', 'en': 'Safely store your important radio logs without time limits.'},
    'feat_4_title': {'tr': 'Yüksek Kaliteli Ses', 'en': 'High-Quality Audio'},
    'feat_4_desc': {'tr': 'Kristal netliğinde, stüdyo kalitesinde ses iletimi deneyimleyin.', 'en': 'Experience crystal clear, studio-quality audio transmission.'},
    'btn_upgrade': {'tr': 'Orbit Plus\'a Geç', 'en': 'Upgrade to Orbit Plus'},
    'btn_skip': {'tr': 'Geri Dön', 'en': 'Go Back'},
    'restore': {'tr': 'Satın Almaları Geri Yükle', 'en': 'Restore Purchases'},
  };

  String _t(String key) {
    return _texts[key]?[_currentLang] ?? _texts[key]?['en'] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _currentLang = prefs.getString('app_lang') ?? 'tr');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (Navigator.canPop(context)) Navigator.pop(context); 
    else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OrbitMainScreen()));
  }

  // 🚀 GERÇEK SATIN ALMA AKIŞI
  Future<void> _startPurchaseFlow() async {
    setState(() => _isLoading = true);

    try {
      // 1. Adapty'den Paywall ve Ürünleri çek
      // DİKKAT: 'default_placement' Adapty panelindeki Placement ID ile aynı olmalı.
      final paywall = await Adapty().getPaywall(placementId: 'default_placement');
      final products = await Adapty().getPaywallProducts(paywall: paywall);

      if (products.isNotEmpty) {
        // 2. Ödeme ekranını başlat
        final profile = await Adapty().makePurchase(product: products.first);

        // 3. Başarılıysa yetkiyi kontrol et ve kaydet
        if (profile.accessLevels['premium']?.isActive == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_orbit_plus', true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aramıza hoş geldin Komutan! Orbit Plus devrede."), backgroundColor: Colors.amber));
            _goBack();
          }
        }
      }
    } catch (e) {
      debugPrint("Satın alma hatası: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🛡️ GERİ YÜKLEME (APPLE ONAYI İÇİN ŞART)
  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    try {
      final profile = await Adapty().restorePurchases();
      if (profile.accessLevels['premium']?.isActive == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_orbit_plus', true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aboneliğiniz başarıyla geri yüklendi."), backgroundColor: Colors.greenAccent));
          _goBack();
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geri yüklenecek aktif abonelik bulunamadı."), backgroundColor: Colors.orange));
      }
    } catch (e) {
      debugPrint("Geri yükleme hatası: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFeatureRow(IconData icon, String titleKey, String descKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.amber.withValues(alpha: 0.3))),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_t(titleKey), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_t(descKey), style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber.withValues(alpha: 0.05)))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.amber.withValues(alpha: 0.8), Colors.orangeAccent.withValues(alpha: 0.8)]), boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)]),
                                child: const Icon(Icons.stars_rounded, color: Colors.black, size: 48),
                              ),
                              const SizedBox(height: 24),
                              Text(_t('title'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              Text(_t('subtitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 40),
                              _buildFeatureRow(Icons.mic_off, 'feat_1_title', 'feat_1_desc'),
                              _buildFeatureRow(Icons.groups, 'feat_2_title', 'feat_2_desc'),
                              _buildFeatureRow(Icons.all_inbox, 'feat_3_title', 'feat_3_desc'),
                              _buildFeatureRow(Icons.high_quality, 'feat_4_title', 'feat_4_desc'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity, height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 10, shadowColor: Colors.amber.withValues(alpha: 0.5)),
                            onPressed: _isLoading ? null : _startPurchaseFlow,
                            child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : Text(_t('btn_upgrade'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _goBack,
                          child: Text(_t('btn_skip'), style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        // 🟢 GERİ YÜKLEME BUTONU (APPLE İÇİN ZORUNLU)
                        TextButton(
                          onPressed: _isLoading ? null : _restorePurchases,
                          child: Text(_t('restore'), style: const TextStyle(color: Colors.white30, fontSize: 12, decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}