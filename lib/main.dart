import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart'; // 🟢 ADAPTY EKLENDİ
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // 🛡️ ATT EKLENDİ

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/orbit_main_screen.dart';
import 'screens/legal_onboarding_screen.dart'; 
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  if (message.data['type'] == 'call') {
    String callerId = message.data['callerName'] ?? "Bilinmeyen";
    final prefs = await SharedPreferences.getInstance();
    String ringtone = prefs.getString('call_ringtone') ?? "";

    await NotificationService().showCallNotification(
      callerId, 
      callerId, 
      soundName: ringtone.isNotEmpty ? ringtone : null
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase Başlatma
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService().init(); 
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("❌ Firebase Hatası: $e");
  }

  // 2. Adapty Başlatma ve Abonelik Kontrolü
  try {
    // 🛡️ ADAPTY CANLI AKTİVASYON
    await Adapty().activate(
      configuration: AdaptyConfiguration(apiKey: 'public_live_XzbhvIvw.0t00vR53i6mSrXhKWBnY')
    );
    debugPrint("✅ Adapty Aktif Edildi!");

    // 🛡️ GÜVENLİK ZIRHI: Açılışta aboneliği sunucudan teyit et
    final profile = await Adapty().getProfile();
    final prefs = await SharedPreferences.getInstance();
    
    // 'premium' ismini Adapty panelindeki Access Level ID ile aynı yapmalısın.
    if (profile.accessLevels['premium']?.isActive == true) {
      debugPrint("✅ Doğrulandı: Kullanıcı gerçekten Plus üyesi.");
      await prefs.setBool('is_orbit_plus', true);
    } else {
      debugPrint("⚠️ Abonelik pasif. Ücretsiz mod aktif.");
      await prefs.setBool('is_orbit_plus', false);
    }
  } catch (e) {
    debugPrint("🛑 Adapty Başlatma Hatası: $e");
  }

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
        Locale('ar', ''),
      ],
      home: const CheckAuthStatus(), 
    );
  }
}

class CheckAuthStatus extends StatefulWidget {
  const CheckAuthStatus({super.key});

  @override
  State<CheckAuthStatus> createState() => _CheckAuthStatusState();
}

class _CheckAuthStatusState extends State<CheckAuthStatus> {
  bool? _legalAccepted;

  @override
  void initState() {
    super.initState();
    _checkLegalStatus();
    _requestTrackingPermission(); // 🛡️ ATT İZNİNİ ÇAĞIR
  }

  // 🛡️ UYGULAMA TAKİP İZNİ FONKSİYONU
  Future<void> _requestTrackingPermission() async {
    try {
      final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // UI'ın hazır olması için çok kısa bir süre bekle ve sor
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint("⚠️ ATT Hatası: $e");
    }
  }

  Future<void> _checkLegalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _legalAccepted = prefs.getBool('legal_accepted') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_legalAccepted == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
    }

    if (!_legalAccepted!) {
      return const LegalOnboardingScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const OrbitMainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}