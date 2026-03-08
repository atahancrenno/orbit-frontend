import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

class IncomingCallOverlay extends StatefulWidget {
  final String callerName;
  
  const IncomingCallOverlay({super.key, required this.callerName});

  // Bu fonksiyon, kilit ekranını tam ekran olarak aşağıdan yukarı kaydırarak açar.
  static void show(BuildContext context, String callerName) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Ekrana boş tıklayarak kapanmasını engeller (Gerçek arama gibi)
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => IncomingCallOverlay(callerName: callerName),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutExpo)
          ),
          child: child,
        );
      },
    );
  }

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> with TickerProviderStateMixin {
  bool _isAccepted = false;
  bool _isRecording = false;
  
  // 30 Saniyelik Hareketsizlik Zamanlayıcısı
  int _inactivitySeconds = 30;
  Timer? _inactivityTimer;
  
  // Çalma (Ringing) animasyonu için
  late AnimationController _ringPulseController;

  @override
  void initState() {
    super.initState();
    _ringPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    
    // Aramanın geldiğini hissettirmek için titreşim başlat
    _simulateRingingVibration();
  }

  void _simulateRingingVibration() async {
    for (int i = 0; i < 5; i++) {
      if (_isAccepted || !mounted) break;
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    _ringPulseController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _acceptCall() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isAccepted = true;
    });
    _startInactivityTimer();
  }

  void _rejectCall() {
    HapticFeedback.selectionClick();
    Navigator.pop(context); // Ekranı kapat
  }

  void _endCall() {
    HapticFeedback.lightImpact();
    Navigator.pop(context); // Bağlantıyı kopar
  }

  // Kullanıcı hiçbir şeye basmazsa 30 saniye sonra bağlantı kopar
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    setState(() => _inactivitySeconds = 30);
    
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _inactivitySeconds--;
          if (_inactivitySeconds <= 0) {
            timer.cancel();
            _endCall();
          }
        });
      }
    });
  }

  // PTT (Bas Konuş) İşlemleri
  void _onPttPressStart(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    _inactivityTimer?.cancel(); // Konuşurken süreyi durdur
    setState(() {
      _isRecording = true;
    });
  }

  void _onPttPressEnd(LongPressEndDetails details) {
    HapticFeedback.lightImpact();
    setState(() {
      _isRecording = false;
    });
    _startInactivityTimer(); // Bırakınca 30 saniyeyi baştan başlat
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return "${parts[0][0]}.${parts[parts.length - 1][0]}".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Arka planı tamamen siyah ve bulanık yap (Kilit Ekranı Hissi)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(color: Colors.black.withValues(alpha: 0.85)),
            ),
          ),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation), child: child)),
              child: _isAccepted ? _buildActiveCallUI() : _buildIncomingCallUI(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. AŞAMA: ÇALAN / GELEN ARAMA EKRANI ---
  Widget _buildIncomingCallUI() {
    return Column(
      key: const ValueKey('incoming'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text("GELEN TELSİZ BAĞLANTISI", style: TextStyle(color: Colors.greenAccent, fontSize: 14, letterSpacing: 3.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            // Titreşen Profil Fotoğrafı
            AnimatedBuilder(
              animation: _ringPulseController,
              builder: (context, child) {
                return Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5 + (_ringPulseController.value * 0.5)), width: 3),
                    boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: _ringPulseController.value * 0.5), blurRadius: 40, spreadRadius: 10)],
                    color: Colors.grey.shade900,
                  ),
                  child: Center(child: Text(_getInitials(widget.callerName), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
                );
              }
            ),
            const SizedBox(height: 30),
            Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Canlı Görüşme İstiyor...", style: TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ),

        // Kabul Et / Reddet Butonları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Reddet Butonu
            Column(
              children: [
                FloatingActionButton.large(
                  heroTag: "reject",
                  backgroundColor: Colors.redAccent,
                  onPressed: _rejectCall,
                  child: const Icon(Icons.close, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text("Reddet", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold))
              ],
            ),
            
            // Kabul Et Butonu
            Column(
              children: [
                AnimatedBuilder(
                  animation: _ringPulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_ringPulseController.value * 0.05),
                      child: FloatingActionButton.large(
                        heroTag: "accept",
                        backgroundColor: Colors.greenAccent,
                        onPressed: _acceptCall,
                        child: const Icon(Icons.mic, color: Colors.black, size: 40),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 12),
                const Text("Kabul Et", style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold))
              ],
            ),
          ],
        )
      ],
    );
  }

  // --- 2. AŞAMA: KABUL EDİLDİ (PTT EKRANI) ---
  Widget _buildActiveCallUI() {
    return Column(
      key: const ValueKey('active'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Üst Kısım: Kişi Bilgisi ve Süre
        Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.graphic_eq, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 8),
                    Text("Canlı Bağlantı Kapanmasına: ${_inactivitySeconds}s", style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Orta Kısım: Dev PTT Mikrofonu
        GestureDetector(
          onLongPressStart: _onPttPressStart,
          onLongPressEnd: _onPttPressEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 220 : 180,
            height: _isRecording ? 220 : 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: _isRecording ? Colors.redAccent : Colors.cyanAccent, width: _isRecording ? 8 : 4),
              boxShadow: [
                BoxShadow(color: _isRecording ? Colors.redAccent.withValues(alpha: 0.6) : Colors.cyanAccent.withValues(alpha: 0.3), blurRadius: _isRecording ? 60 : 30, spreadRadius: _isRecording ? 10 : 5)
              ]
            ),
            child: Icon(
              _isRecording ? Icons.graphic_eq : Icons.mic,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),

        // Alt Kısım: Sonlandır Butonu
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)))),
            onPressed: _endCall,
            icon: const Icon(Icons.call_end),
            label: const Text("Bağlantıyı Kopar", style: TextStyle(fontSize: 16)),
          ),
        )
      ],
    );
  }
}