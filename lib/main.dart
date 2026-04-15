import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 🟢 EKLENDİ: Çoklu dil desteği
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

import 'firebase_options.dart'; // 🟢 EKLENDİ: Firebase konfigürasyon dosyası
import 'screens/login_screen.dart';
import 'screens/orbit_main_screen.dart';
// 🟢 ASSUMPTION: Bir önceki adımda oluşturduğumuz yasal onay ekranı
import 'screens/legal_onboarding_screen.dart'; 
import 'services/notification_service.dart';

// 🚀 3. CEPHE (DERİN UYKU): Uygulama tamamen kapalıyken (killed) Firebase'den gelen 
// "Arama" komutunu dinleyen ve 30 saniyelik sireni başlatan gizli servis!
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 🟢 GÜNCELLENDİ: options parametresi eklendi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  // Eğer gelen kargo bir "Canlı Arama" ise:
  if (message.data['type'] == 'call') {
    String callerId = message.data['callerName'] ?? "Bilinmeyen";
    
    // Telefon hafızasındaki (kullanıcının seçtiği) zil sesini karanlıkta bile bul!
    final prefs = await SharedPreferences.getInstance();
    String ringtone = prefs.getString('call_ringtone') ?? "";

    // Zili Çal!
    await NotificationService().showCallNotification(
      callerId, 
      callerId, 
      soundName: ringtone.isNotEmpty ? ringtone : null
    );
  }
}

void main() async {
  // Flutter motorunu garantiye al
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint("🚀 Firebase başlatılıyor...");
    // 🟢 GÜNCELLENDİ: options parametresi eklendi
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase başarıyla başlatıldı!");
    
    // 🟢 BİLDİRİM MOTORU AKTİF EDİLDİ
    debugPrint("🚀 Bildirim servisi başlatılıyor...");
    await NotificationService().init(); 
    debugPrint("✅ Bildirim motoru başarıyla başlatıldı!");

    // 🟢 ARKA PLAN DİNLEYİCİSİ AKTİF EDİLDİ (KAPALIYKEN ÇALMA)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
  } catch (e) {
    // 🛑 EĞER BİR ŞEY ÇÖKERSE BEYAZ EKRANDA KALMAMASI İÇİN BURAYA DÜŞECEK
    debugPrint("❌ KRİTİK BAŞLATMA HATASI: $e");
  }
  // 🟢 REVENUECAT (ÖDEME ALTYAPISI) BAŞLATMA
  try {
    if (Platform.isIOS || Platform.isAndroid) {
      await Purchases.setLogLevel(LogLevel.error); // Test aşamasında debug yapılabilir
      
      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        // TODO: RevenueCat panelinden alınacak Google Play Public API Key buraya yazılacak
        configuration = PurchasesConfiguration("goog_BURAYA_PLAY_STORE_KEY_GELECEK");
      } else {
        // TODO: RevenueCat panelinden alınacak App Store Public API Key buraya yazılacak
        configuration = PurchasesConfiguration("appl_BURAYA_APP_STORE_KEY_GELECEK");
      }
      await Purchases.configure(configuration);
      // 🛡️ GÜVENLİK ZIRHI: Açılışta abonelik durumunu sunucudan teyit et
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    final prefs = await SharedPreferences.getInstance();
    
    if (customerInfo.entitlements.all["orbit_plus"]?.isActive == true) {
      debugPrint("✅ Doğrulandı: Kullanıcı gerçekten Plus üyesi.");
      await prefs.setBool('is_orbit_plus', true);
    } else {
      debugPrint("⚠️ Uyarı: Abonelik bulunamadı veya süresi dolmuş. Yetkiler alınıyor.");
      await prefs.setBool('is_orbit_plus', false);
    }


    }
  } catch (e) {
    debugPrint("RevenueCat Başlatma Hatası: $e");
  }
  // Hata olsa bile uygulamayı ZORLA başlat (Beyaz ekranı kır!)
  runApp(const OrbitApp());
}

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit PTT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      // 🟢 GÜNCELLENDİ: Arapça (RTL) ve diğer diller için yerelleştirme desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''), // Türkçe
        Locale('en', ''), // İngilizce
        Locale('ar', ''), // Arapça (Sağdan Sola)
        // Diğer desteklenen diller...
      ],
      // 🟢 GÜNCELLENDİ: Rotalama logic'i CheckAuthStatus widget'ına taşındı
      home: const CheckAuthStatus(), 
    );
  }
}

// 🟢 YENİ: Yasal Onay ve Auth Durumunu Sırayla Kontrol Eden Yönetici Widget
class CheckAuthStatus extends StatefulWidget {
  const CheckAuthStatus({super.key});

  @override
  State<CheckAuthStatus> createState() => _CheckAuthStatusState();
}

class _CheckAuthStatusState extends State<CheckAuthStatus> {
  // İlk başta bağlantı bekleniyor olarak ayarla
  bool? _legalAccepted;

  @override
  void initState() {
    super.initState();
    _checkLegalStatus();
  }

  Future<void> _checkLegalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 1. AŞAMA: Yasal Onay Kontrolü
      // Hafızada yoksa false döner.
      _legalAccepted = prefs.getBool('legal_accepted') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // SharedPreferences yüklenene kadar bekle
    if (_legalAccepted == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    // Yasal onay yoksa -> Yasal Onay Ekranına git (Hepsinden ÖNCE)
    if (!_legalAccepted!) {
      return const LegalOnboardingScreen();
    }

    // Yasal onay varsa -> 2. AŞAMA: FirebaseAuth Durumunu Dinle
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Eğer Firebase bağlantısı bekleniyorsa
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }
        // Eğer kullanıcı giriş yapmışsa -> Ana Ekran
        if (snapshot.hasData && snapshot.data != null) {
          return const OrbitMainScreen();
        }
        // Giriş yapmamışsa -> Login Ekranı
        return const LoginScreen();
      },
    );
  }
}