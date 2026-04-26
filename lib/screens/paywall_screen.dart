import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'orbit_main_screen.dart'; // Başarılı olursa ana ekrana yönlendirmek için

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  AdaptyPaywall? _paywall;
  List<AdaptyPaywallProduct>? _products;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPaywallData();
  }

  // 1. Adapty'den Ürünleri Çekme Operasyonu
  Future<void> _loadPaywallData() async {
    try {
      // Adapty panelindeki "Placement ID" ile vitrini buluyoruz
      final paywall = await Adapty().getPaywall(placementId: 'default_placement');
      
      // Analitik için vitrinin gösterildiğini Adapty'e bildiriyoruz
      await Adapty().logShowPaywall(paywall: paywall);
      
      // Vitrindeki ürünleri (orbit_plus_1m) çekiyoruz
      final products = await Adapty().getPaywallProducts(paywall: paywall);

      setState(() {
        _paywall = paywall;
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
      final profile = await Adapty().makePurchase(product: product);
      
      // Adapty panelindeki "Access level ID" ile kontrol ediyoruz
      if (profile.accessLevels['premium']?.isActive == true) {
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
        const SnackBar(content: Text('Satın alma işlemi tamamlanamadı.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  // 3. Satın Almaları Geri Yükleme (Apple Zorunluluğu)
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
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  // Yasal Link Açıcı
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
              ? const Center(child: Text("Paketler şu an yüklenemiyor.", style: TextStyle(color: Colors.white)))
              : Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo / İkon
                        const Icon(Icons.satellite_alt, size: 80, color: Colors.cyanAccent),
                        const SizedBox(height: 20),
                        
                        // Başlık
                        const Text(
                          "Orbit Plus",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        
                        // Özellikler
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Sınırsız telsiz erişimi, özel frekanslar ve reklamsız kesintisiz iletişim gücüne katılın.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Satın Alma Butonu (Mağazadan gelen fiyatı gösterir)
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
                                  "Abone Ol - ${_products!.first.localizedPrice}", 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Restore Butonu
                        TextButton(
                          onPressed: _isPurchasing ? null : _restorePurchases,
                          child: const Text("Satın Almaları Geri Yükle", style: TextStyle(color: Colors.cyanAccent)),
                        ),
                        
                        const SizedBox(height: 30),

                        // Yasal Linkler
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => _launchURL('https://senin-gizlilik-linkin.com'), // BURAYI DEĞİŞTİR
                              child: const Text('Gizlilik Politikası', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                            const Text('|', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () => _launchURL('https://senin-sartlar-linkin.com'), // BURAYI DEĞİŞTİR
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