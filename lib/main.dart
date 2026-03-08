import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🟢 DÖNDÜRME KİLİDİ İÇİN GEREKLİ KÜTÜPHANE
import 'package:audio_session/audio_session.dart';

// Ekranlar ve Servisler
import 'screens/orbit_main_screen.dart';
import 'services/socket_service.dart';

void main() async {
  // 1. Flutter motorunu güvenle başlatır
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 2. EKRANI DİK (PORTRAIT) MODDA KİLİTLE! 🟢
  // Bu kod sayesinde telefon yan çevrilse bile uygulamamız asla dönmeyecek ve UI bozulmayacak.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 3. WHATSAPP'IN KULLANDIĞI "AGRESİF" GLOBAL SES POLİTİKASI 
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration( // DİKKAT: Buradaki const kaldırıldı (Hata vermemesi için)
    avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers | AVAudioSessionCategoryOptions.defaultToSpeaker,
    avAudioSessionMode: AVAudioSessionMode.voiceChat, // Telsiz modu
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.speech,
      flags: AndroidAudioFlags.none,
      usage: AndroidAudioUsage.voiceCommunication, 
    ),
    // DİKKAT: "gainTransientExclusive" -> Tüm diğer sesleri ez, donanımın tek sahibi benim demek!
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientExclusive,
    androidWillPauseWhenDucked: true,
  ));

  // 4. KOTLIN ÇEKİRDEĞİNE "TELSİZ MODUNA GEÇ" EMRİNİ GÖNDER 
  if (Platform.isAndroid) {
    const platform = MethodChannel('com.example.orbit_ptt/audio_master');
    try {
      final String result = await platform.invokeMethod('forceWalkieTalkieMode');
      debugPrint("🛠️ NATIVE DONANIM: $result");
    } catch (e) {
      debugPrint("🛠️ Native Donanım Hatası: $e");
    }
  }

  // 5. Uygulama açılır açılmaz Telsiz sunucusuna bağlanır
  SocketService().initConnection();

  // Orijinal İsme Geri Dönüldü!
  runApp(const OrbitApp());
}

// 🟢 ANDROID KAYAN PENCERE (OVERLAY) İÇİN ZORUNLU ARKA PLAN MOTORU 🟢
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Center(
          child: Text(
            "Orbit Telsiz Aktif", 
            style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    ),
  );
}

// Sınıf adı orijinal haline (OrbitApp) çevrildi!
class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit PTT',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, 
        useMaterial3: true,
      ),
      home: const OrbitMainScreen(), 
    );
  }
}