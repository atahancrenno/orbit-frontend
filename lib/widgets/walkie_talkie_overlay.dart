import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter_overlay_window/flutter_overlay_window.dart'; 
import '../utils/painters.dart'; 

class WalkieTalkieOverlay extends StatefulWidget {
  final String callerName;
  final String statusText; 
  final Color statusColor; 
  final int countdownSeconds;
  final VoidCallback onGoToApp;
  final VoidCallback onClose;
  final VoidCallback onMicPress;
  final VoidCallback onMicRelease;

  const WalkieTalkieOverlay({
    super.key, 
    required this.callerName,
    required this.statusText,
    this.statusColor = Colors.cyanAccent, 
    this.countdownSeconds = 15,
    required this.onGoToApp,
    required this.onClose,
    required this.onMicPress,
    required this.onMicRelease,
  });

  @override
  State<WalkieTalkieOverlay> createState() => _WalkieTalkieOverlayState();
}

class _WalkieTalkieOverlayState extends State<WalkieTalkieOverlay> with SingleTickerProviderStateMixin {
  bool isCallAccepted = false; 
  bool isPressed = false;
  late AnimationController _pulseController;
  
  Timer? _recordTimer;
  int _recordDuration = 0;
  late String _dynamicStatus;

  @override
  void initState() {
    super.initState();
    _dynamicStatus = widget.statusText;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController.repeat();

    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is String && event.startsWith("STATUS:")) {
        if (mounted) {
          setState(() {
            _dynamicStatus = event.replaceFirst("STATUS:", "");
            if (_isRemoteSpeaking && !isPressed && isCallAccepted) {
              _pulseController.repeat();
            } else if (!isPressed && isCallAccepted) {
              _pulseController.stop();
              _pulseController.reset();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isRemoteSpeaking => _dynamicStatus.toLowerCase().contains("konuşuyor") || _dynamicStatus.toLowerCase().contains("dinleniyor");

  String getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return "${parts[0][0]}.${parts[parts.length - 1][0]}".toUpperCase();
  }

  String formatName(String fullName) {
    List<String> parts = fullName.trim().split(' ');
    if (fullName.length <= 10) return fullName;
    if (parts.length > 1) return "${parts[0]} ${parts[parts.length - 1][0]}.";
    return fullName.substring(0, 10);
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  Widget _buildLaserBeam() {
    if (!isCallAccepted) return const SizedBox.shrink(); 

    bool fromMic = isPressed; 
    Color laserColor = fromMic ? Colors.redAccent : Colors.greenAccent;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double progress = _pulseController.value;
        if (fromMic) progress = 1.0 - progress;

        return Container(
          width: 140, 
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.transparent, laserColor, Colors.transparent],
              stops: [(progress - 0.3).clamp(0.0, 1.0), progress, (progress + 0.3).clamp(0.0, 1.0)],
            ),
            boxShadow: [BoxShadow(color: laserColor.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2)]
          ),
        );
      }
    );
  }

  Widget _buildIncomingCallControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "GELEN BAĞLANTI...",
          style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                FlutterOverlayWindow.shareData("REJECT_CALL");
                widget.onClose(); 
              },
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black,
                  border: Border.all(color: Colors.redAccent, width: 2.5),
                  boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)]
                ),
                child: const Icon(Icons.close, color: Colors.redAccent, size: 24),
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () {
                setState(() {
                  isCallAccepted = true;
                  _pulseController.stop();
                  _pulseController.reset();
                });
                FlutterOverlayWindow.shareData("ACCEPT_CALL");
              },
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black,
                  border: Border.all(color: Colors.greenAccent, width: 2.5),
                  boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)]
                ),
                child: const Icon(Icons.mic, color: Colors.greenAccent, size: 24),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActiveCallControls() {
    return Stack(
      children: [
        if (isPressed || _isRemoteSpeaking)
          Positioned(
            top: 12, left: 12, 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isPressed ? Colors.redAccent.withValues(alpha: 0.5) : Colors.greenAccent.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: isPressed ? Colors.redAccent : Colors.greenAccent,
                      boxShadow: [BoxShadow(color: isPressed ? Colors.redAccent : Colors.greenAccent, blurRadius: 5)]
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPressed ? _formatDuration(_recordDuration) : _dynamicStatus,
                    style: TextStyle(color: isPressed ? Colors.redAccent : Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
          
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              setState(() { isPressed = true; _recordDuration = 0; });
              _pulseController.repeat();
              widget.onMicPress();
              _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() => _recordDuration++); });
            },
            onTapUp: (_) {
              setState(() => isPressed = false);
              _recordTimer?.cancel(); 
              if (!_isRemoteSpeaking) { _pulseController.stop(); _pulseController.reset(); }
              widget.onMicRelease();
            },
            onTapCancel: () {
              setState(() => isPressed = false);
              _recordTimer?.cancel(); 
              if (!_isRemoteSpeaking) { _pulseController.stop(); _pulseController.reset(); }
              widget.onMicRelease();
            },
            child: SizedBox(
              width: 120, height: 120, 
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isPressed)
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          double progress = (_pulseController.value + (index / 3.0)) % 1.0;
                          return Container(
                            width: 65 + (progress * 50), height: 65 + (progress * 50),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0)), width: 2.0 + (progress * 2.5))),
                          );
                        },
                      );
                    }),
                  if (!isPressed)
                    SizedBox(width: 85, height: 85, child: const CircularProgressIndicator(value: 0.75, strokeWidth: 4.0, color: Colors.redAccent, backgroundColor: Colors.transparent)),
                  Container(
                    width: 65, height: 65, 
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black, 
                      border: Border.all(color: isPressed ? Colors.redAccent : Colors.cyanAccent, width: 3.0),
                      boxShadow: [BoxShadow(color: isPressed ? Colors.redAccent.withValues(alpha: 0.4) : Colors.cyanAccent.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 2)],
                    ),
                    child: Center(child: Icon(isPressed ? Icons.graphic_eq : Icons.mic, color: Colors.white, size: 28)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color avatarRingColor = !isCallAccepted ? Colors.redAccent : (_isRemoteSpeaking ? Colors.greenAccent : Colors.cyanAccent);

    return Material(
      color: Colors.transparent, 
      // 👇 SİHİR BURADA: Tuvalin tam ortasına oturttuk. Asla taşmaz! 👇
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent, 
          onTap: widget.onGoToApp, 
          child: Container(
            width: double.infinity,
            height: 160, // Sabit ve kesin yüksekliğimiz
            margin: const EdgeInsets.symmetric(horizontal: 16.0), 
            decoration: BoxDecoration(
              color: const Color(0xFF121212), 
              borderRadius: BorderRadius.circular(32), 
              border: Border.all(color: isCallAccepted ? widget.statusColor.withValues(alpha: 0.3) : Colors.redAccent.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: isCallAccepted ? widget.statusColor.withValues(alpha: 0.15) : Colors.redAccent.withValues(alpha: 0.15),
                  blurRadius: 20, spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                
                if (isCallAccepted)
                  Positioned(
                    bottom: 6,
                    right: 12,
                    child: IconButton(
                      icon: Icon(Icons.open_in_new, color: Colors.white.withValues(alpha: 0.5), size: 22),
                      onPressed: widget.onGoToApp,
                      tooltip: "Uygulamayı Aç",
                      splashRadius: 24,
                    ),
                  ),

                if (isCallAccepted)
                  Positioned(
                    top: 8, right: 12,
                    child: GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(6), 
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withValues(alpha: 0.15), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))),
                        child: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      ),
                    ),
                  ),

                if (isCallAccepted && (isPressed || _isRemoteSpeaking))
                  Positioned(top: 0, bottom: 0, child: Center(child: _buildLaserBeam())),

                Row(
                  children: [
                    // SOL BLOK
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: 140, height: 140, 
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              
                              CustomPaint(
                                size: const Size(140, 140),
                                painter: CurvedTextPainter(
                                  text: formatName(widget.callerName).toUpperCase(),
                                  radius: 46, color: Colors.white,
                                  statusColor: avatarRingColor, 
                                  baseAngle: -math.pi / 2, 
                                ),
                              ),

                              if (!isCallAccepted || _isRemoteSpeaking)
                                ...List.generate(3, (index) {
                                  return AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      double progress = (_pulseController.value + (index / 3.0)) % 1.0;
                                      return Container(
                                        width: 60 + (progress * 40), height: 60 + (progress * 40),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: avatarRingColor.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0)),
                                            width: 2.0 + (progress * 2.0),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),

                              Container(
                                width: 60, height: 60, 
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.transparent, 
                                  border: Border.all(color: avatarRingColor, width: 5.0), 
                                  boxShadow: [BoxShadow(color: avatarRingColor.withValues(alpha: 0.5), blurRadius: 10)],
                                ),
                                padding: const EdgeInsets.all(7.0), 
                                child: Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.9)), 
                                  child: Center(child: Text(getInitials(widget.callerName), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)))
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(width: 1, height: 120, color: Colors.white12),

                    // SAĞ BLOK
                    Expanded(
                      flex: 1,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        child: !isCallAccepted 
                            ? _buildIncomingCallControls()  
                            : _buildActiveCallControls(),   
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}