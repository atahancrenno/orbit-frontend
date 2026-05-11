import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'orbit_main_screen.dart'; 

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  // Kaldırıldı: AdaptyPaywall? _paywall; (Kullanılmadığı için)
  List<AdaptyPaywallProduct>? _products;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPaywallData();
  }

  // 1. Adapty'den Ürünleri Çekme Operasyonu (GÜVENLİ TAKTİK)
  Future<void> _loadPaywallData() async {
    try {
      // 🟢 Adapty panelindeki Placement ID ne olursa olsun bulmaya çalışır
      final paywall = await Adapty().getPaywall(placementId: 'default_placement'); // ADAPTY PANELİNDEKİ İSİMLE AYNI OLMALI
      await Adapty().logShowPaywall(paywall: paywall);
      final products = await Adapty().getPaywallProducts(paywall: paywall);

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("🛑 Paywall Çekilemedi: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Satın Alma Operasyonu
  Future<void> _makePurchase(AdaptyPaywallProduct product) async {
    setState(() => _isPurchasing = true);
    try {
      final result = await Adapty().makePurchase(product: product);
      
      if (result is AdaptyPurchaseResultSuccess && result.profile.accessLevels['premium']?.isActive == true) {
        debugPrint("✅ Satın alma başarılı! Premium Aktif.");
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_orbit_plus', true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orbit Plus\'a Hoş Geldiniz! 🚀'), backgroundColor: Colors.green),
        );
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrbitMainScreen()),
        );
      }
    } catch (e) {
      debugPrint("🛑 Satın Alma İptal veya Hata: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satın alma işlemi iptal edildi veya tamamlanamadı.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  // 3. Satın Almaları Geri Yükleme
  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    try {
      final profile = await Adapty().restorePurchases();
      if (profile.accessLevels['premium']?.isActive == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_orbit_plus', true);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aboneliğiniz başarıyla geri yüklendi! 🚀'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrbitMainScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geri yüklenecek aktif abonelik bulunamadı.')),
        );
      }
    } catch (e) {
      debugPrint("🛑 Restore Hatası: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı hatası.')),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Link açılamadı: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : _products == null || _products!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                      const SizedBox(height: 16),
                      const Text("Paketler şu an yüklenemiyor.\nLütfen internet bağlantınızı kontrol edin.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                        onPressed: _loadPaywallData,
                        child: const Text("Tekrar Dene", style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.satellite_alt, size: 80, color: Colors.cyanAccent),
                        const SizedBox(height: 20),
                        
                        const Text(
                          "Orbit Plus",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Sınırsız telsiz erişimi, özel frekanslar ve reklamsız kesintisiz iletişim gücüne katılın.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 40),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: _isPurchasing ? null : () => _makePurchase(_products!.first),
                            child: _isPurchasing 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : Text(
                                  "Abone Ol - ${_products!.first.price.localizedString}", 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: _isPurchasing ? null : _restorePurchases,
                          child: const Text("Satın Almaları Geri Yükle", style: TextStyle(color: Colors.cyanAccent)),
                        ),
                        
                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => _launchURL('https://orbit-talk.com/privacy.html'), // 🟢 YENİ SİTEMİZİN LİNKİ EKLENDİ
                              child: const Text('Gizlilik Politikası', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                            const Text('|', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () => _launchURL('https://orbit-talk.com/terms.html'), // 🟢 YENİ SİTEMİZİN LİNKİ EKLENDİ
                              child: const Text('Kullanım Şartları', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
    );
  }
}