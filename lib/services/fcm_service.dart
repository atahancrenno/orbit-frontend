import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'socket_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 Arka planda bildirim alındı: ${message.data}");
}

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 1. İzinleri Al
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    
    // 🟢 İOS KİLİT EKRANI İÇİN ZORUNLU AYAR
    // Bu ayar Apple'a "Ne olursa olsun bildirimi ekranda göster ve öt" der.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, 
      badge: true, 
      sound: true,
    );
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Uygulama Ekranda Açıkken Gelen Bildirim
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📱 Uygulama zaten açık, gelen bildirim pas geçildi (Soket halledecek).");
    });

    // 3. Kullanıcı Kilit Ekranındaki / Arka Plandaki BİLDİRİME TIKLADIĞINDA
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // 4. Uygulama Tamamen KAPALIYKEN Bildirime Tıklanıp Açılırsa
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    debugPrint("👆 Kullanıcı telsiz bildirimine tıkladı, uygulama açıldı!");
    
    if (message.data['type'] == 'call') {
      final callerName = message.data['callerName'] ?? 'Bilinmeyen Kişi';
      
      // Uygulama uyanıp, UI'ın kendini çizmesi için 1.5 saniye zaman tanıyoruz.
      // Sonra uygulamanın kendi içindeki şık arama pop-up'ını tetikliyoruz!
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (SocketService().onCallReceived != null) {
           SocketService().onCallReceived!(callerName);
        }
      });
    }
  }
}