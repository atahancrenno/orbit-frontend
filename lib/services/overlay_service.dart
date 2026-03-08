import 'package:flutter/foundation.dart'; // Bu satırı ekledik
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static Future<void> showWalkieTalkieOverlay() async {
    debugPrint("🟢 Overlay tetiklendi! İzin kontrol ediliyor...");
    
    if (await FlutterOverlayWindow.isActive()) {
      debugPrint("🟡 Pencere zaten açık, yeni açılış engellendi.");
      return;
    }
    
    bool status = await FlutterOverlayWindow.isPermissionGranted();
    debugPrint("🟢 İzin durumu: $status");
    
    if (!status) {
      debugPrint("🟡 İzin yok, kullanıcıdan isteniyor...");
      await FlutterOverlayWindow.requestPermission();
      return;
    }

    debugPrint("🟢 İzin var! Pencere ekrana çiziliyor...");
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: "Orbit PTT",
      overlayContent: "Canlı Görüşme",
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      height: 350, 
    );
    debugPrint("🟢 Pencere komutu gönderildi.");
  }

  static Future<void> closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }
}