import 'package:flutter/material.dart';
import '../utils/painters.dart';

class OrbitPttArea extends StatelessWidget {
  final bool isIncomingCallActive;
  final bool isRecording;
  final bool isCancelled;
  final bool isWaitingForLiveApproval;
  final bool isLive;
  final bool isLeftHanded;
  final double dragOffset;
  final double dragVerticalOffset;
  final double pttSlideOffset;
  final AnimationController hapticRejectPulseController;
  final AnimationController hapticAcceptPulseController;
  final AnimationController entranceController;
  final AnimationController pulseController;
  final ValueNotifier<double> audioLevel;
  final String recordDurationText;
  final void Function(PointerDownEvent) onPointerDown;
  final void Function(PointerMoveEvent) onPointerMove;
  final void Function(PointerUpEvent) onPointerUp;
  final void Function(PointerCancelEvent) onPointerCancel;
  final VoidCallback onTapCancelCall;
  final Widget Function(int) buildCallingWave;
  final Widget Function(int) buildRealWave;
  final bool isNodeBeingPulledInward;

  const OrbitPttArea({
    super.key,
    required this.isIncomingCallActive,
    required this.isRecording,
    required this.isCancelled,
    required this.isWaitingForLiveApproval,
    required this.isLive,
    required this.isLeftHanded,
    required this.dragOffset,
    required this.dragVerticalOffset,
    required this.pttSlideOffset,
    required this.hapticRejectPulseController,
    required this.hapticAcceptPulseController,
    required this.entranceController,
    required this.pulseController,
    required this.audioLevel,
    required this.recordDurationText,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onPointerCancel,
    required this.onTapCancelCall,
    required this.buildCallingWave,
    required this.buildRealWave,
    required this.isNodeBeingPulledInward,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 325, height: 325,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isIncomingCallActive)
            Container(
              width: 270, height: 64,
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: const EdgeInsets.only(left: 16.0), child: Row(children: [const Icon(Icons.keyboard_double_arrow_left, color: Colors.white30, size: 16), const SizedBox(width: 4), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withValues(alpha: 0.2)), child: const Icon(Icons.close, color: Colors.redAccent, size: 20))],)),
                  Padding(padding: const EdgeInsets.only(right: 16.0), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withValues(alpha: 0.2)), child: const Icon(Icons.check, color: Colors.greenAccent, size: 20)), const SizedBox(width: 4), const Icon(Icons.keyboard_double_arrow_right, color: Colors.white30, size: 16)],)),
                ]
              )
            ),

          // 🟢 GÜNCELLENDİ: CANLI BAĞLANTIYI KAPATMA YÖNERGESİ (En alta, geniş ve ferah alana alındı)
          if (isRecording && isLive && !isWaitingForLiveApproval)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              bottom: 10, 
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isCancelled ? 0.0 : 1.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.keyboard_double_arrow_down, color: Colors.white54, size: 20),
                    const SizedBox(height: 4),
                    const Text("Canlı Bağlantıyı Kapat", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withValues(alpha: 0.2)),
                      child: const Icon(Icons.call_end, color: Colors.redAccent, size: 24)
                    )
                  ]
                )
              )
            ),
          
          if (isRecording && isCancelled && !isWaitingForLiveApproval && !isLive)
            const Positioned(top: 50, child: Icon(Icons.delete, color: Colors.redAccent, size: 30)),
            
          // 🟢 GÜNCELLENDİ: İPTAL ET YÖNERGESİ (Artık canlı yayındayken de mesajı iptal etmek için görünecek)
          if (isRecording && !isWaitingForLiveApproval)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100), 
              left: isLeftHanded ? null : 15 + (dragOffset * 0.5), 
              right: isLeftHanded ? 15 - (dragOffset * 0.5) : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200), opacity: isCancelled ? 0.0 : (1.0 - (dragOffset.abs() / 100)).clamp(0.0, 1.0),
                child: Row(children: [if (!isLeftHanded) const Icon(Icons.chevron_left, color: Colors.white54), const Text(" İptal Et", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)), if (isLeftHanded) const Icon(Icons.chevron_right, color: Colors.white54)]),
              ),
            ),

          Transform.translate(
            offset: Offset(isIncomingCallActive ? pttSlideOffset : dragOffset, dragVerticalOffset),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: onPointerDown, onPointerMove: onPointerMove, onPointerUp: onPointerUp, onPointerCancel: onPointerCancel,
              child: GestureDetector(
                onTap: onTapCancelCall,
                child: SizedBox(
                  width: 130, height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isIncomingCallActive || isNodeBeingPulledInward) ...List.generate(3, (i) => buildCallingWave(i)),
                      if (isRecording && !isCancelled && !isWaitingForLiveApproval && !isLive) ...List.generate(3, (i) => buildRealWave(i)),
                      if (isWaitingForLiveApproval) ...List.generate(2, (i) => buildCallingWave(i)),
                      
                      ScaleTransition(
                        scale: CurvedAnimation(parent: entranceController, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
                        child: SizedBox(
                          width: 117, height: 117,
                          child: ValueListenableBuilder<double>(
                            valueListenable: audioLevel,
                            builder: (context, level, child) {
                              return CustomPaint(
                                painter: NeonRingPainter(
                                  innerColor: isNodeBeingPulledInward ? Colors.greenAccent : ((isWaitingForLiveApproval || isIncomingCallActive) ? Colors.redAccent : Colors.cyanAccent),
                                  outerColor: isNodeBeingPulledInward ? Colors.green.shade900 : ((isWaitingForLiveApproval || isIncomingCallActive) ? Colors.red.shade900 : Colors.redAccent.shade200),
                                  isRecording: isRecording || isWaitingForLiveApproval || isIncomingCallActive || isNodeBeingPulledInward,
                                  isLeftHanded: isLeftHanded,
                                  audioLevel: level
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isNodeBeingPulledInward
                                            ? Icons.wifi_tethering
                                            : (isIncomingCallActive ? Icons.phone_in_talk : (isWaitingForLiveApproval ? Icons.call_end : (isCancelled ? Icons.delete_outline : (isRecording ? Icons.graphic_eq : Icons.mic)))),
                                        size: isRecording || isWaitingForLiveApproval || isIncomingCallActive || isNodeBeingPulledInward ? 35 : 45,
                                        color: Colors.white
                                      ),
                                      
                                      if (isNodeBeingPulledInward)
                                        const Padding(padding: EdgeInsets.only(top: 4.0), child: Text("ARAMAK İÇİN\nBIRAK", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)))
                                      else if (isWaitingForLiveApproval)
                                        const Padding(padding: EdgeInsets.only(top: 4.0), child: Text("İPTAL ET", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)))
                                      else if (isRecording && !isCancelled && !isLive)
                                        Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(recordDurationText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)))
                                      else if (isIncomingCallActive)
                                        const Padding(padding: EdgeInsets.only(top: 4.0), child: Text("KAYDIR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0))),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}