import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SmsService {
  // 🟢 CLICKATELL API ANAHTARI YERLEŞTİRİLDİ
  static const String _clickatellApiKey = "LlhoMFHiQy-ZhHmfrYk_YA==";

  // 6 Haneli Rastgele Doğrulama Kodu Üretir
  static String generateOTP() {
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  // Clickatell üzerinden SMS gönderir
  static Future<bool> sendOTP(String phoneNumber, String otpCode) async {
    try {
      // Numarayı Clickatell'in istediği formata getir 
      // (Başında + olmadan, ülke koduyla. Örn: 905551234567)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\+\(\)-]'), '');
      
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '90${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('90') && cleanPhone.length == 10) {
        cleanPhone = '90$cleanPhone';
      }

      // Mesaj içeriği
      String message = "Orbit PTT dogrulama kodunuz: $otpCode";
      
      // Clickatell Basic HTTP API URL yapısı
      // Not: Türkçe karakter sorunlarını önlemek için queryParameters kullanmak daha sağlıklıdır.
      final Uri url = Uri.parse("https://platform.clickatell.com/messages/http/send").replace(
        queryParameters: {
          'apiKey': _clickatellApiKey,
          'to': cleanPhone,
          'content': message,
        },
      );

      debugPrint("🚀 SMS Gönderiliyor: $cleanPhone -> Kod: $otpCode");

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 202) {
        debugPrint("✅ SMS Başarıyla Gönderildi! API Yanıtı: ${response.body}");
        return true;
      } else {
        debugPrint("❌ SMS Gönderim Hatası! Durum Kodu: ${response.statusCode}");
        debugPrint("Hata Detayı: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ SMS Servis Çökmesi: $e");
      return false;
    }
  }
}