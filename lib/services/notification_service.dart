import 'package:flutter/foundation.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Function(String)? onNotificationTapped;

  Future<void> init() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings, 
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && onNotificationTapped != null) {
            onNotificationTapped!(response.payload!);
          }
        },
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      debugPrint("Bildirim başlatma hatası: $e");
    }
  }

  Future<void> checkForLaunchNotification() async {
    try {
      final NotificationAppLaunchDetails? launchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final response = launchDetails.notificationResponse;
        if (response != null && response.payload != null && onNotificationTapped != null) {
          onNotificationTapped!(response.payload!);
        }
      }
    } catch(e) {
      debugPrint("Kapalıyken açılma bildirimi hatası: $e");
    }
  }

  Future<void> showMessageNotification(String senderName) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'orbit_message_channel_v1', 
        'Sesli Mesajlar', 
        channelDescription: 'Yeni bir telsiz mesajı geldiğinde çalar.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 0, 
        title: 'Yeni Sesli Mesaj',
        body: '$senderName sana bir telsiz mesajı bıraktı.',
        notificationDetails: platformChannelSpecifics,
        payload: 'message', 
      );
    } catch (e) {
      debugPrint("Mesaj bildirimi hatası: $e");
    }
  }

  // 🚀 DÜZELTME: Artık 'soundName' parametresi alabiliyor (Örn: 'siren', 'radar' veya boş bırakılırsa varsayılan)
  Future<void> showCallNotification(String callerId, String callerName, {String? soundName}) async {
    try {
      // Android'de ses değiştirmek için Kanal ID'sinin farklı olması gerekir. O yüzden dinamik yaptık.
      String channelId = 'orbit_call_channel_${soundName ?? "default"}';

      AndroidNotificationSound? androidSound;
      if (soundName != null && soundName.isNotEmpty) {
         // Android için sesi 'android/app/src/main/res/raw/' klasöründen çekecek
         androidSound = RawResourceAndroidNotificationSound(soundName);
      }

      final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, 
        'Canlı Aramalar (${soundName ?? "Standart"})', 
        channelDescription: 'Canlı bağlantı istekleri.',
        importance: Importance.max, 
        priority: Priority.high,    
        enableVibration: true,
        playSound: true,
        sound: androidSound, // 🟢 Dinamik Özel Ses
        icon: '@mipmap/ic_launcher',
        category: AndroidNotificationCategory.call, 
        // 🚀 BÜYÜK HİLE (FLAG_INSISTENT): Bu 4 rakamı, bildirimin sen açana kadar susmamasını (loop) sağlar!
        additionalFlags: Int32List.fromList(<int>[4]), 
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: soundName != null ? '$soundName.wav' : null, // 🟢 iOS Özel Sesi
          interruptionLevel: InterruptionLevel.timeSensitive, 
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id: 1, 
        title: 'Telsiz Çağrısı',
        body: '📞 $callerName canlı bağlantı istiyor...',
        notificationDetails: platformChannelSpecifics,
        payload: 'call_$callerId', 
      );
    } catch (e) {
      debugPrint("Arama bildirimi hatası: $e");
    }
  }

  Future<void> cancelCallNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id: 1); 
    } catch (e) {
      debugPrint("Bildirim iptal hatası: $e");
    }
  }
}