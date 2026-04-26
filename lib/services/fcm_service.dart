import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
    
    // 🚀 [YENİ] CİHAZ KİMLİĞİ (FCM TOKEN) ALMA VE KARARGAHA BİLDİRME
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      debugPrint("🔥 Cihaz FCM Token alındı: $fcmToken");
      await _sendTokenToBackend(fcmToken);
    }

    // 🚀 [YENİ] Token herhangi bir sebeple yenilenirse (Uygulama silinip yüklenirse vs.)
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });
    
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

  // 🛂 [GÜMRÜK KÖPRÜSÜ]: FCM Token'ı DigitalOcean Backend'ine Kaydetme
  static Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('auth_token');

      if (jwtToken == null || jwtToken.isEmpty) {
        debugPrint("⚠️ Zırhlı Bilet (JWT) yok, FCM Token Karargah'a gönderilemedi.");
        return;
      }

      // Backend'deki FCM Güncelleme Rotası (Rotayı kendi API yapına göre adlandırdım)
      final response = await http.put(
        Uri.parse('http://188.166.101.147:3005/api/users/update-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ FCM Token başarıyla Karargah'a (Backend) kaydedildi!");
      } else {
        debugPrint("🛑 FCM Token kaydedilemedi. Sunucu Kodu: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("💥 FCM Token gönderim hatası: $e");
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