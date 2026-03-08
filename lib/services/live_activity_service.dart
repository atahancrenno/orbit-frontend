import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';

class LiveActivityService {
  static final _liveActivitiesPlugin = LiveActivities();
  static String? _activityId;
  static bool _isInitialized = false;

  static const String _appGroupId = "group.orbit.ptt";

  static Future<void> _init() async {
    if (!Platform.isIOS) return;

    if (!_isInitialized) {
      try {
        await _liveActivitiesPlugin.init(appGroupId: _appGroupId);
        _isInitialized = true;
      } catch (e) {
        debugPrint("❌ Live Activity Init Hatası: $e");
      }
    }
  }

  static Future<void> startCall(String callerName, String status, String color) async {
    if (!Platform.isIOS) return;

    await _init();

    try {
      bool hasPermissions = await _liveActivitiesPlugin.areActivitiesEnabled();
      if (!hasPermissions) {
        debugPrint("❌ İZİN YOK! Lütfen telefon ayarlarından Live Activities'i açın.");
        return;
      }

      final Map<String, dynamic> data = {
        'callerName': callerName,
        'statusText': status,
        'timerText': '00:00',
        'themeColor': color,
      };

      String customId = "orbit_call_${DateTime.now().millisecondsSinceEpoch}";
      
      // 👇 DOĞRU KULLANIM BURASI! (1. String ID, 2. Map Veri) 👇
      _activityId = await _liveActivitiesPlugin.createActivity(customId, data);
      
      debugPrint("✅ Aktivite Başarıyla Başlatıldı! ID: $_activityId");
    } catch (e) {
      debugPrint("❌ Aktivite başlatılırken hata oluştu: $e");
    }
  }

  static Future<void> updateStatus(String status, String timer, String color) async {
    if (!Platform.isIOS || _activityId == null) return;

    try {
      final Map<String, dynamic> data = {
        'callerName': 'Ayşe Yılmaz', 
        'statusText': status,
        'timerText': timer,
        'themeColor': color,
      };
      await _liveActivitiesPlugin.updateActivity(_activityId!, data);
      debugPrint("🔄 Aktivite Güncellendi: $status");
    } catch (e) {
      debugPrint("❌ Aktivite güncellenirken hata: $e");
    }
  }

  static Future<void> endCall() async {
    if (!Platform.isIOS || _activityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_activityId!);
      _activityId = null;
      debugPrint("🛑 Aktivite Sonlandırıldı.");
    } catch (e) {
      debugPrint("❌ Aktivite sonlandırılırken hata: $e");
    }
  }
}