import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audio_message.dart';
import '../utils/painters.dart';
import 'orbit_message_bubbles.dart';

class OrbitChatList extends StatefulWidget {
  final List<AudioMessage> activeMessages;
  final bool isCircularMessageStyle;
  final bool hapticEnabled;
  final int selfDestructSeconds;
  final Function(AudioMessage) onPlayMessage;
  final Function(AudioMessage) onReplyMessage;
  final Function(AudioMessage, bool) onSaveToggle;
  final Function(AudioMessage) onDeleteMessage;
  final String Function(int) formatDuration;
  
  final void Function(AudioMessage, String) onReactToMessage;

  const OrbitChatList({
    super.key,
    required this.activeMessages,
    required this.isCircularMessageStyle,
    required this.hapticEnabled,
    required this.selfDestructSeconds,
    required this.onPlayMessage,
    required this.onReplyMessage,
    required this.onSaveToggle,
    required this.onDeleteMessage,
    required this.formatDuration,
    required this.onReactToMessage,
  });

  @override
  State<OrbitChatList> createState() => _OrbitChatListState();
}

class _OrbitChatListState extends State<OrbitChatList> with SingleTickerProviderStateMixin {
  late AnimationController _dangerPulseController;

  bool _selectionMode = false;
  final Set<String> _selectedMessageIds = {};
  
  String? _expandedMessageId; 
  
  // 🟢 YENİ: Boş ekran ipucunu bir kere gösterip kapatmak için değişken
  bool _hasSeenEmptyStateHint = false;

  @override
  void initState() {
    super.initState();
    _dangerPulseController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800)
    )..repeat(reverse: true);
    
    _checkEmptyStateHint(); // 🟢 YENİ
  }

  @override
  void dispose() {
    _dangerPulseController.dispose();
    super.dispose();
  }

  // 🟢 YENİ: Kullanıcı bu ipucunu daha önce görmüş mü kontrol et
  Future<void> _checkEmptyStateHint() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenEmptyStateHint = prefs.getBool('has_seen_empty_hint') ?? false;
    });
  }

  // 🟢 YENİ: Kullanıcı ipucuna tıklayınca bir daha gösterme
  Future<void> _dismissEmptyStateHint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_empty_hint', true);
    setState(() {
      _hasSeenEmptyStateHint = true;
    });
  }

  void _toggleSelection(AudioMessage msg) {
    setState(() {
      if (_selectedMessageIds.contains(msg.id)) {
        _selectedMessageIds.remove(msg.id);
        if (_selectedMessageIds.isEmpty) {
          _selectionMode = false; 
        }
      } else {
        _selectedMessageIds.add(msg.id);
      }
    });
    if (widget.hapticEnabled) HapticFeedback.lightImpact();
  }

  void _deleteSelectedMessages() {
    for (var msgId in _selectedMessageIds) {
      final msgIndex = widget.activeMessages.indexWhere((m) => m.id == msgId);
      if (msgIndex != -1) {
         widget.onDeleteMessage(widget.activeMessages[msgIndex]);
      }
    }
    setState(() {
      _selectedMessageIds.clear();
      _selectionMode = false;
    });
    if (widget.hapticEnabled) HapticFeedback.heavyImpact();
  }

  Widget _buildListeningRadar(AudioMessage msg) {
    if (!msg.isMe || msg.listenedBy.isEmpty) return const SizedBox.shrink();

    List<Widget> radarIcons = [];
    msg.listenedBy.forEach((listenerName, listenType) {
      bool isLive = listenType == "live";
      radarIcons.add(
        Container(
          margin: const EdgeInsets.only(right: 6, top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isLive ? Colors.greenAccent.withValues(alpha: 0.15) : Colors.blueGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLive ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white24,
              width: 0.5,
            )
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLive ? Icons.sensors : Icons.history, 
                size: 12,
                color: isLive ? Colors.greenAccent : Colors.cyanAccent,
              ),
              const SizedBox(width: 4),
              Text(
                msg.getInitials(listenerName), 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: isLive ? Colors.greenAccent : Colors.white70
                )
              ),
            ],
          ),
        )
      );
    });

    return Wrap(children: radarIcons);
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 YENİ: Liste boşsa ve kullanıcı henüz ipucunu kapatmadıysa göster
    if (widget.activeMessages.isEmpty && !_hasSeenEmptyStateHint) {
      return Center(
        child: GestureDetector(
          onTap: _dismissEmptyStateHint,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, color: Colors.cyanAccent, size: 48),
                const SizedBox(height: 16),
                const Text(
                  "Henüz mesaj yok.",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Konuşmak için radara basılı tut veya dikkatini çekmek için kişiye çift tıkla! ⚡",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "(Kapatmak için dokun)",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _selectionMode ? 60 : 0,
          color: Colors.blueGrey.shade900.withValues(alpha: 0.9),
          child: _selectionMode 
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedMessageIds.clear();
                        _selectionMode = false;
                      });
                    },
                  ),
                  Text("${_selectedMessageIds.length} Seçildi", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: _deleteSelectedMessages,
                  ),
                ],
              )
            : const SizedBox.shrink(),
        ),
        
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: widget.activeMessages.length,
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
            itemBuilder: (context, index) {
              final msg = widget.activeMessages[index];
              bool isSelected = _selectedMessageIds.contains(msg.id);
              
              bool isExpanded = _expandedMessageId == msg.id || msg.isPlaying;

              return GestureDetector(
                onLongPress: () {
                  if (!_selectionMode) {
                    setState(() {
                      _selectionMode = true;
                      _selectedMessageIds.add(msg.id);
                    });
                    if (widget.hapticEnabled) HapticFeedback.heavyImpact();
                  }
                },
                onTap: () {
                  if (_selectionMode) {
                    _toggleSelection(msg);
                  } else {
                    setState(() {
                      _expandedMessageId = isExpanded ? null : msg.id;
                    });
                    if (widget.hapticEnabled) HapticFeedback.selectionClick();
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (!_selectionMode && details.primaryDelta! > 3) {
                    widget.onReplyMessage(msg);
                    if (widget.hapticEnabled) HapticFeedback.selectionClick();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectionMode && !msg.isMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 10),
                          child: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Colors.cyanAccent : Colors.white54, size: 20),
                        ),
                      
                      Flexible(
                        child: _buildSmartMessageItem(msg, isExpanded),
                      ),

                      if (_selectionMode && msg.isMe)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 10),
                          child: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Colors.cyanAccent : Colors.white54, size: 20),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmartMessageItem(AudioMessage msg, bool isExpanded) {
    if (msg.isDeleted) return OrbitMessageBubbles.buildDeletedMessageView(msg);
    
    Color baseColor = msg.isPendingDeletion && !msg.isSaved 
        ? Colors.redAccent 
        : (msg.isLiveMessage 
            ? Colors.orangeAccent 
            : (msg.isMe ? Colors.cyanAccent : Colors.greenAccent)); 
            
    bool isPaused = msg.playProgress > 0.0 && msg.playProgress < 1.0 && !msg.isPlaying;
    Color playIconColor = isPaused ? Colors.orangeAccent : Colors.white;

    return Column(
      crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!msg.isMe && msg.senderName != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4), 
            child: Text(
              msg.isLiveMessage ? "📡 ${msg.senderName!}" : msg.senderName!, 
              style: TextStyle(color: baseColor, fontSize: 11, fontWeight: FontWeight.bold)
            )
          ),
          
        if (msg.repliedToMessageId != null)
          Container(
             margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4), border: Border(left: BorderSide(color: baseColor, width: 2))),
             child: const Text("Yanıt", style: TextStyle(fontSize: 10, color: Colors.white54, fontStyle: FontStyle.italic)),
          ),

        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isMe) _buildTimeAndTicks(msg), 
            
            if (msg.emoji != null || msg.isNudge) ...[
                GestureDetector(
                    onTap: () {
                        setState(() => _expandedMessageId = isExpanded ? null : msg.id);
                        if (widget.hapticEnabled) HapticFeedback.selectionClick();
                    },
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: msg.isNudge ? Colors.amber.withValues(alpha: 0.5) : baseColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                            children: [
                                if (msg.isNudge) 
                                    const Icon(Icons.touch_app, color: Colors.amber, size: 32)
                                else if (msg.emoji != null)
                                    Text(msg.emoji!, style: const TextStyle(fontSize: 32)),
                                    
                                const SizedBox(height: 4),
                                Text(
                                    msg.isNudge 
                                      ? (msg.isMe ? "Dürtme uyarısı gönderildi" : "Seni dürttü!") 
                                      : (msg.emoji == "👍" ? "Anlaşıldı" : "Tepki"),
                                    style: TextStyle(color: msg.isNudge ? Colors.amber : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)
                                )
                            ],
                        ),
                    ),
                )
            ] else ...[
                GestureDetector(
                  onTap: () {
                    if (msg.isLiveMessage) {
                      setState(() => _expandedMessageId = isExpanded ? null : msg.id);
                      if (widget.hapticEnabled) HapticFeedback.selectionClick();
                    } else {
                      if (!msg.isPlaying) {
                        setState(() => _expandedMessageId = msg.id);
                      }
                      widget.onPlayMessage(msg);
                      if (widget.hapticEnabled) HapticFeedback.lightImpact();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: msg.isLiveMessage ? null : (widget.isCircularMessageStyle ? 45 : 85),
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: msg.isLiveMessage ? const EdgeInsets.symmetric(horizontal: 14) : null,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(widget.isCircularMessageStyle ? 25 : 20),
                      border: Border.all(color: baseColor.withValues(alpha: 0.6), width: 1.5),
                      boxShadow: msg.isPlaying ? [BoxShadow(color: baseColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)] : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        if (msg.isLiveMessage) ...[
                          Icon(msg.isMe ? Icons.podcasts : Icons.sensors, size: 16, color: baseColor),
                          const SizedBox(width: 6),
                          Text(msg.isMe ? "Canlı Yayın" : "Canlı Dinlendi", style: TextStyle(color: baseColor.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.bold)),
                        ] else ...[
                          Icon(msg.isPlaying ? Icons.pause : Icons.play_arrow, size: 20, color: playIconColor),
                        ],
                        
                        if (!widget.isCircularMessageStyle && !msg.isLiveMessage) ...[
                          const SizedBox(width: 6),
                          Text(widget.formatDuration(msg.durationInSeconds), style: TextStyle(color: baseColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                ),
            ],
            
            if (msg.isMe) _buildTimeAndTicks(msg), 
          ],
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: isExpanded 
            ? _buildExpandedDetailsBox(msg, baseColor, isPaused)
            : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTimeAndTicks(AudioMessage msg) {
    return Column(
      crossAxisAlignment: msg.isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          msg.time,
          style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600),
        ),
        if (msg.isMe) ...[
          const SizedBox(height: 2),
          Icon(
            msg.isRead ? Icons.done_all : Icons.check,
            size: 14,
            color: msg.isRead ? Colors.blueAccent.shade200 : Colors.white38,
          ),
        ]
      ],
    );
  }
  
  Widget _buildReactionButton(AudioMessage msg, String emoji) {
    return GestureDetector(
      onTap: () {
        widget.onReactToMessage(msg, emoji);
        if (widget.hapticEnabled) {
          try { HapticFeedback.lightImpact(); } catch (_) {}
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 0.5)
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildExpandedDetailsBox(AudioMessage msg, Color baseColor, bool isPaused) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: msg.isMe ? 40 : 0, right: msg.isMe ? 0 : 40),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isLiveMessage && msg.emoji == null && !msg.isNudge) ...[
            Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      SizedBox(
                        width: double.infinity, height: 24,
                        child: CustomPaint(painter: SmoothWaveformPainter(progress: msg.playProgress, isPlaying: msg.isPlaying, activeColor: isPaused ? Colors.orangeAccent : baseColor, time: DateTime.now().millisecondsSinceEpoch / 150)),
                      ),
                      Positioned(
                        left: ((MediaQuery.of(context).size.width - 120) * msg.playProgress).clamp(0, double.infinity),
                        child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)])),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                   onTap: _selectionMode ? null : () {
                     setState(() {
                       if (msg.playbackSpeed == 1.0) {
                         msg.playbackSpeed = 1.5;
                       } else if (msg.playbackSpeed == 1.5) {
                         msg.playbackSpeed = 2.0;
                       } else {
                         msg.playbackSpeed = 1.0;
                       }
                     });
                     if (widget.hapticEnabled) {
                       try { HapticFeedback.selectionClick(); } catch (_) {}
                     }
                   },
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                     decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                     child: Text("${msg.playbackSpeed}x", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                   ),
                ),
              ],
            ),
          ] else if (msg.isLiveMessage) ...[
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Bu bir canlı yayın ileti kaydıdır. Ses sunucuda tutulmaz ve tekrar dinlenemez.", 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontStyle: FontStyle.italic)
                  )
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (!msg.isSaved) {
                    widget.onSaveToggle(msg, true);
                  } else {
                    widget.onDeleteMessage(msg); 
                  }
                  if (widget.hapticEnabled) {
                    try { HapticFeedback.lightImpact(); } catch (_) {}
                  }
                },
                child: Icon(msg.isSaved ? Icons.bookmark : Icons.bookmark_border, size: 18, color: msg.isSaved ? Colors.orangeAccent : Colors.white54),
              ),
              
              if (!msg.isMe && !msg.isLiveMessage && msg.emoji == null && !msg.isNudge) ...[
                const SizedBox(width: 16),
                _buildReactionButton(msg, "👍"),
                const SizedBox(width: 8),
                _buildReactionButton(msg, "❤️"),
              ],
              
              const SizedBox(width: 12),
              
              if (msg.isPendingDeletion && !msg.isSaved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_delete_outlined, color: Colors.redAccent, size: 12), const SizedBox(width: 4),
                      Text("${msg.deletionSecondsRemaining}s", style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
              const Spacer(),
              
              _buildListeningRadar(msg),
            ],
          ),

          if (msg.showTranscription && !msg.isPendingDeletion) ...[
            const SizedBox(height: 8),
            Container(
               padding: const EdgeInsets.all(8), width: double.infinity,
               decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
               child: Text(msg.transcriptionText, style: const TextStyle(fontSize: 11, color: Colors.white70, fontStyle: FontStyle.italic)),
            )
          ]
        ],
      ),
    );
  }
}
