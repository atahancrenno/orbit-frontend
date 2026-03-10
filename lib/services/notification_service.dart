import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton Pattern - Servisi her yerden tek bir kopyayla çağırabilmek için
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Android için ikon ayarı (@mipmap/ic_launcher varsayılan uygulama ikonudur)
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. iOS için başlangıç ayarları
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 🟢 HATA ÇÖZÜMÜ: Parametre adı 'settings' olarak belirtildi
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  // 🔊 NORMAL SESLİ MESAJ BİLDİRİMİ (Sessizce üstten düşer)
  Future<void> showMessageNotification(String senderName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'orbit_message_channel', // Kanal ID
      'Sesli Mesajlar', // Kullanıcının ayarlarda göreceği isim
      channelDescription: 'Yeni bir telsiz mesajı geldiğinde çalar.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    // 🟢 HATA ÇÖZÜMÜ: Parametre adları (id, title, body) eklendi
    await flutterLocalNotificationsPlugin.show(
      id: 0, 
      title: 'Yeni Sesli Mesaj',
      body: '$senderName sana bir telsiz mesajı bıraktı.',
      notificationDetails: platformChannelSpecifics,
    );
  }

  // 🚨 CANLI ARAMA BİLDİRİMİ (Telefonu titretir, Max öncelikle ekrana fırlar)
  Future<void> showCallNotification(String callerName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'orbit_call_channel', 
      'Canlı Aramalar', 
      channelDescription: 'Biri size telsizden canlı bağlanmak istediğinde çalar.',
      importance: Importance.max, // MAX önem!
      priority: Priority.high,    // Yüksek öncelik (Kilit ekranında bile görünür)
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true, // Ekranı uyandırmak için kritik!
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive, // iOS'ta rahatsız etme modunu deler
      ),
    );

    // 🟢 HATA ÇÖZÜMÜ: Parametre adları (id, title, body) eklendi
    await flutterLocalNotificationsPlugin.show(
      id: 1, 
      title: 'Telsiz Çağrısı',
      body: '📞 $callerName canlı bağlantı istiyor...',
      notificationDetails: platformChannelSpecifics,
    );
  }

  // Çağrı iptal olursa veya reddedilirse ekranda asılı kalan bildirimi silmek için
  Future<void> cancelCallNotification() async {
    // 🟢 HATA ÇÖZÜMÜ: 'id' parametre adı eklendi
    await flutterLocalNotificationsPlugin.cancel(id: 1); 
  }
}