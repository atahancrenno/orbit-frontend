import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'orbit_contact_avatar.dart';
import '../utils/painters.dart';
import 'connection_arrows.dart';

class OrbitContactNode extends StatefulWidget {
  final int index;
  final Map<String, dynamic> contact;
  final double itemSpacingAngle;
  final double scrollOffset;
  final double menuX;
  final double menuY;
  final double orbitRadius;
  final bool isLeftHanded;
  final bool showSearchField;
  final String searchQuery;
  final int activeIndex;
  final bool isLive;
  final bool anyLiveActive;
  final bool showConnectionArrows;
  final double animVal;
  final String? currentlyPlayingQueueItemSender;
  final int unreadCount;
  final String userName;
  final Color myCustomColor;
  final Color? statusColor;
  
  final bool isMenuExpanded; 

  final VoidCallback onOpenContacts;
  final VoidCallback onSearchedPersonSelected;
  final VoidCallback onPersonSelected;
  final VoidCallback onRequestLiveConnection;
  
  final Function(int index, double radialOffset) onNodeDragUpdate;
  final Function(int index) onNodeInteractionEnded;
  final Function(int index) onNodeInteractionStarted;
  final VoidCallback onRemoveContact;
  
  final Widget Function(int) incomingWaveBuilder;

  const OrbitContactNode({
    super.key,
    required this.index,
    required this.contact,
    required this.itemSpacingAngle,
    required this.scrollOffset,
    required this.menuX,
    required this.menuY,
    required this.orbitRadius,
    required this.isLeftHanded,
    required this.showSearchField,
    required this.searchQuery,
    required this.activeIndex,
    required this.isLive,
    required this.anyLiveActive,
    required this.showConnectionArrows,
    required this.animVal,
    required this.currentlyPlayingQueueItemSender,
    required this.unreadCount,
    required this.userName,
    required this.myCustomColor,
    required this.statusColor,
    required this.isMenuExpanded,
    required this.onOpenContacts,
    required this.onSearchedPersonSelected,
    required this.onPersonSelected,
    required this.onRequestLiveConnection,
    required this.onNodeDragUpdate,
    required this.onNodeInteractionEnded,
    required this.onNodeInteractionStarted,
    required this.onRemoveContact,
    required this.incomingWaveBuilder,
  });

  @override
  State<OrbitContactNode> createState() => _OrbitContactNodeState();
}

class _OrbitContactNodeState extends State<OrbitContactNode> with SingleTickerProviderStateMixin {
  double _radiusOffset = 0.0;
  late AnimationController _snapController;
  Animation<double>? _snapAnimation;
  
  bool _isValidDrag = false;
  bool _isLockedForCall = false;
  double _initialFingerDistanceToCenter = 0.0;
  double _initialRadiusOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _snapController.addListener(() {
      if (_snapAnimation != null) {
        setState(() {
          _radiusOffset = _snapAnimation!.value;
        });
        widget.onNodeDragUpdate(widget.index, _radiusOffset);
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _snapBackToOrbit() {
    _snapAnimation = Tween<double>(begin: _radiusOffset, end: 0.0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutBack)
    );
    _snapController.forward(from: 0.0).then((_) {
      widget.onNodeInteractionEnded(widget.index);
    });
  }

  String _formatName(String fullName) {
    if (fullName == "Davet Et") {
      return fullName;
    }
    List<String> parts = fullName.trim().split(' ');
    if (fullName.length <= 10) {
      return fullName;
    }
    if (parts.length > 1) {
      return "${parts[0]} ${parts[parts.length - 1][0]}.";
    }
    return fullName.substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    double startAngle = -0.35 * math.pi;
    double angle = startAngle - (widget.index * widget.itemSpacingAngle) + widget.scrollOffset;

    double baseOpacity = 1.0;
    
    if (widget.isMenuExpanded) {
      baseOpacity = 0.1;
    } else {
      if (angle > -0.1 * math.pi || angle < -1.8 * math.pi) {
        baseOpacity = 0.0;
      }

      if (widget.showSearchField) {
        if (widget.searchQuery.isEmpty) {
          baseOpacity = 0.3;
        } else {
          bool isMatch = widget.contact['name'].toLowerCase().contains(widget.searchQuery.toLowerCase());
          baseOpacity = isMatch ? 1.0 : 0.1;
        }
      }
    }

    double fadeOpacity = 1.0;
    double fadeDistance = 40.0;
    double tempX = widget.menuX + widget.orbitRadius * math.cos(angle);
    if (widget.isLeftHanded) {
      tempX = widget.menuX - widget.orbitRadius * math.cos(angle);
    }

    if (!widget.isLeftHanded) {
      double dist = (widget.menuX + widget.orbitRadius - 15) - tempX;
      if (dist <= 0) {
        fadeOpacity = 0.0;
      } else if (dist < fadeDistance) {
        fadeOpacity = dist / fadeDistance;
      }
    } else {
      double dist = tempX - (widget.menuX - widget.orbitRadius + 15);
      if (dist <= 0) {
        fadeOpacity = 0.0;
      } else if (dist < fadeDistance) {
        fadeOpacity = dist / fadeDistance;
      }
    }

    double finalOpacity = (baseOpacity * fadeOpacity).clamp(0.0, 1.0);
    bool isInteractable = finalOpacity > 0.2 && !widget.isMenuExpanded;

    bool showLaser = false;
    Color laserColor = Colors.cyanAccent;
    bool isMatch = widget.showSearchField && widget.contact['name'].toLowerCase().contains(widget.searchQuery.toLowerCase());
    bool isActive = (widget.index == widget.activeIndex) && !widget.showSearchField;
    bool isEmptySlot = widget.contact['isEmpty'] == true;

    if (widget.anyLiveActive && isActive && !isEmptySlot) {
      showLaser = true; 
      laserColor = Colors.redAccent;
    } else if (!widget.anyLiveActive && isActive && widget.showConnectionArrows && !isEmptySlot) {
      showLaser = true; 
      laserColor = Colors.cyanAccent;
    }

    double effectiveRadius = widget.orbitRadius + _radiusOffset;
    double currentRadius = 400.0 - (widget.animVal * (400.0 - effectiveRadius));
    double currentAngle = angle + ((1.0 - widget.animVal) * math.pi);
    
    double animXOffset = currentRadius * math.cos(currentAngle);
    double animYOffset = currentRadius * math.sin(currentAngle);
    if (widget.isLeftHanded) {
      animXOffset = -animXOffset;
    }
    
    double animGlobalAngle = math.atan2(animYOffset, animXOffset);
    bool isBeingPulled = _radiusOffset < -20;

    Widget nodeContent = Container(
      width: 100, height: 100,
      color: Colors.transparent, 
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            // Noktayı çizecek olan motor burası! 
            painter: CurvedTextPainter(
              text: _formatName(widget.contact['name']).toUpperCase(),
              radius: 46,
              color: isEmptySlot ? Colors.white30 : ((widget.showSearchField && isMatch && widget.searchQuery.isNotEmpty) ? Colors.orangeAccent : (widget.isLive ? Colors.greenAccent : (isActive ? Colors.cyanAccent : Colors.white70))),
              statusColor: widget.statusColor, // Rengi buraya gönderiyoruz
              baseAngle: animGlobalAngle,
            ),
          ),
          
          if (isEmptySlot)
            Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2), color: Colors.white.withValues(alpha: 0.05)), child: const Icon(Icons.person_add_alt_1, color: Colors.white54, size: 24))
          else
            Stack(
              alignment: Alignment.center,
              children: [
                if (widget.currentlyPlayingQueueItemSender == widget.contact['name'])
                  ...List.generate(3, (i) => widget.incomingWaveBuilder(i)),
                  
                OrbitContactAvatar(
                  contact: widget.contact, isActive: isActive, isMatch: isMatch, isLive: widget.isLive, showSearchField: widget.showSearchField, unreadCount: widget.unreadCount, userName: widget.userName, myCustomColor: widget.myCustomColor,statusColor: widget.statusColor,
                ),
                
                if (isBeingPulled)
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: Colors.black.withValues(alpha: 0.6),
                      border: Border.all(color: Colors.greenAccent, width: 2)
                    ),
                    child: const Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 28),
                  ),
              ],
            ),
            
          if (showLaser && _radiusOffset == 0.0) 
            Positioned.fill(child: Transform.rotate(angle: animGlobalAngle + math.pi, child: Padding(padding: const EdgeInsets.only(left: 35.0), child: Align(alignment: Alignment.centerLeft, child: ConnectionArrows(color: laserColor))))),
        ],
      ),
    );

    return AnimatedPositioned(
      duration: _radiusOffset == 0.0 ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.easeOutCubic,
      left: widget.menuX + animXOffset - 50,
      top: widget.menuY + animYOffset - 50,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: finalOpacity * widget.animVal.clamp(0.0, 1.0),
        child: IgnorePointer(
          ignoring: !isInteractable, 
          child: Transform.scale(
            scale: 1.1,
            child: (isEmptySlot || widget.showSearchField) 
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () { 
                    if (isEmptySlot) { 
                      widget.onOpenContacts(); 
                    } else if (widget.showSearchField) { 
                      widget.onSearchedPersonSelected(); 
                    } 
                  },
                  child: nodeContent,
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.onPersonSelected();
                    if (widget.index != widget.activeIndex) {
                      try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ }
                    }
                  },
                  
                  onPanStart: (details) {
                    _isValidDrag = false;
                    if (widget.index != widget.activeIndex) {
                      return;
                    }

                    double hitX = details.localPosition.dx - 50.0;
                    double hitY = details.localPosition.dy - 50.0;
                    double distFromWidgetCenter = math.sqrt(hitX * hitX + hitY * hitY);
                    if (distFromWidgetCenter > 35.0) {
                      return;
                    } 

                    _isValidDrag = true;
                    _isLockedForCall = false;
                    _snapController.stop();
                    
                    double dxToMic = details.globalPosition.dx - widget.menuX;
                    double dyToMic = details.globalPosition.dy - widget.menuY;
                    _initialFingerDistanceToCenter = math.sqrt(dxToMic * dxToMic + dyToMic * dyToMic);
                    _initialRadiusOffset = _radiusOffset;

                    widget.onNodeInteractionStarted(widget.index);
                    try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ }
                  },
                  onPanUpdate: (details) {
                    if (!_isValidDrag || widget.index != widget.activeIndex) {
                      return;
                    }

                    double dxToMic = details.globalPosition.dx - widget.menuX;
                    double dyToMic = details.globalPosition.dy - widget.menuY;
                    double currentFingerDistanceToCenter = math.sqrt(dxToMic * dxToMic + dyToMic * dyToMic);

                    double radialDelta = currentFingerDistanceToCenter - _initialFingerDistanceToCenter;
                    double theoreticalOffset = _initialRadiusOffset + radialDelta;

                    bool isNowLocked = theoreticalOffset <= -70.0 || currentFingerDistanceToCenter <= 45.0;

                    if (isNowLocked && !_isLockedForCall) {
                      _isLockedForCall = true; 
                      try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ }
                    } else if (!isNowLocked && _isLockedForCall) {
                      _isLockedForCall = false; 
                      try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ }
                    }

                    setState(() {
                      if (_isLockedForCall) {
                        _radiusOffset = -widget.orbitRadius; 
                      } else {
                        _radiusOffset = theoreticalOffset.clamp(-widget.orbitRadius, 10.0);
                      }
                    });

                    widget.onNodeDragUpdate(widget.index, _radiusOffset);
                  },
                  onPanEnd: (details) {
                    if (!_isValidDrag || widget.index != widget.activeIndex) {
                      return;
                    }

                    if (_isLockedForCall) {
                      widget.onRequestLiveConnection();
                      try { HapticFeedback.heavyImpact(); } catch(_) { /* ignore */ }
                    }

                    _snapBackToOrbit();
                    _isLockedForCall = false;
                    _isValidDrag = false;
                  },
                  child: nodeContent,
                ),
          ),
        ),
      ),
    );
  }
}