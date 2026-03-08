import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui'; 
import 'dart:io'; 
import 'package:record/record.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:flutter_overlay_window/flutter_overlay_window.dart'; 
import 'package:audio_session/audio_session.dart';

import '../models/audio_message.dart';
import '../utils/painters.dart';
import '../widgets/connection_arrows.dart'; 

import '../widgets/saved_messages_sheet.dart';
import '../widgets/contacts_bottom_sheet.dart';
import '../widgets/settings_bottom_sheet.dart';
import '../widgets/orbit_message_bubbles.dart';
import '../widgets/orbit_menu_grid.dart';
import 'package:orbit_ptt/services/socket_service.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory; 

import '../services/overlay_service.dart';
import '../services/live_activity_service.dart';

enum UserStatus { available, busy, away }

class OrbitMainScreen extends StatefulWidget {
  const OrbitMainScreen({super.key});
  @override
  State<OrbitMainScreen> createState() => _OrbitMainScreenState();
}

class _OrbitMainScreenState extends State<OrbitMainScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> baseContacts = [
    {"name": "Ayşe Yılmaz", "isGroup": false, "status": UserStatus.available},
    {"name": "user_atahan", "isGroup": false, "status": UserStatus.available},
    {"name": "Proje Ekibi", "isGroup": true, "status": UserStatus.available},
    {"name": "Mehmet Karasoy", "isGroup": false, "status": UserStatus.busy},
  ];
  
  late List<Map<String, dynamic>> allContacts;

  String _userName = "Atahan S.";
  String? _userAvatarPath;
  String _myStatus = "available";
  bool _useSpeaker = true;
  String _liveAudioPermission = "Herkes";

  bool isSearching = false;
  bool showSearchField = false;
  bool isBackgroundTransparent = true; 
  bool isCircularMessageStyle = false; 
  bool _isLeftHanded = false; 
  bool _isSettingsOpen = false;
  bool hapticEnabled = true;
  int selfDestructSeconds = 30; 
  int deleteFilterDays = 30; 
  String selectedLiveAnimation = "Radar"; 
  List<String> animationOptions = ["Mini Ekolayzır", "Radar", "Nabız", "Nefes"];
  String? _customBackgroundImagePath;
  
  double _scrollOffset = 0.0;
  int activeIndex = -1; 
  bool _showConnectionArrows = false;
  Timer? _arrowsTimer;
  
  final Set<String> _activeLiveContacts = {}; 
  final Map<String, Timer> _liveTimers = {}; 
  bool isWaitingForLiveApproval = false; 
  int _liveDuration = 0; 
  Timer? _liveDurationTimer;
  Timer? _backgroundLiveTimeoutTimer; 
  bool _isCurrentlyPlayingOrRecording = false; 
  String? _currentlyPlayingQueueItemSender; 
  bool _showOnlyUnread = false; 

  late AnimationController _pulseController;
  late AnimationController _breatheController;
  late AnimationController _dangerPulseController; 
  late AnimationController _entranceController;

  final List<String> _activeLiveGroupMembers = []; 
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _amplitudeTimer;
  final ValueNotifier<double> _audioLevel = ValueNotifier(0.0);
  
  final ValueNotifier<double> _incomingAudioLevel = ValueNotifier(0.0);
  Timer? _incomingAmplitudeTimer;

  final AudioPlayer _historyPlayer = AudioPlayer();
  AudioMessage? _currentlyPlayingMessage;
  
  bool isRecording = false; 
  int _recordDuration = 0; 
  Timer? _recordTimer;
  double _dragOffset = 0.0;
  bool _isCancelled = false;

  Timer? _micDebounceTimer; 

  final List<AudioMessage> _allMessages = []; 
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  AudioMessage? _replyingToMessage;

  List<AudioMessage> get _activeMessages {
    if (activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) return []; 
    String currentContact = allContacts[activeIndex]['name'];
    var messages = _allMessages.where((msg) => msg.contactName == currentContact).toList();
    if (_showOnlyUnread) {
      messages = messages.where((msg) => !msg.isMe && !msg.isRead).toList();
    }
    return messages;
  }

  @override
  void initState() {
    super.initState();

    AudioSession.instance.then((session) async {
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord, 
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker, 
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
      ));
    });

    allContacts = List.from(baseContacts);
    int maxSlots = 7;
    for (int i = allContacts.length; i < maxSlots; i++) {
       allContacts.add({"name": "Davet Et", "isEmpty": true});
    }

    _initMicrophone(); 

    _historyPlayer.onPositionChanged.listen((Duration p) {
      if (mounted && _currentlyPlayingMessage != null) {
        int totalMs = _currentlyPlayingMessage!.durationInSeconds * 1000;
        if (totalMs > 0) {
          setState(() {
            _currentlyPlayingMessage!.playProgress = p.inMilliseconds / totalMs;
          });
        }
      }
    });

    _historyPlayer.onPlayerComplete.listen((_) async {
      if (mounted && _currentlyPlayingMessage != null) {
        setState(() {
          _currentlyPlayingMessage!.isPlaying = false;
          _currentlyPlayingMessage!.playProgress = 0.0;
          _isCurrentlyPlayingOrRecording = false; 
          
          if (!_currentlyPlayingMessage!.isMe && !_currentlyPlayingMessage!.isSaved && !_currentlyPlayingMessage!.isDeleted && !_currentlyPlayingMessage!.isPendingDeletion) {
             _startDeletionCountdown(_currentlyPlayingMessage!);
          }
          _currentlyPlayingMessage = null;
        });
      }
      final session = await AudioSession.instance;
      await session.setActive(false);
    });
    
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _breatheController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _dangerPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _entranceController.forward();
        if (hapticEnabled) HapticFeedback.heavyImpact();
      }
    });

    if (Platform.isAndroid) {
      try {
        FlutterOverlayWindow.overlayListener.listen((event) {
          if (event == "MIC_DOWN") _startRecording();
          else if (event == "MIC_UP") _stopRecording(); 
        });
      } catch (e) {
        debugPrint("Overlay dinleyici hatası: $e");
      }
    }

    SocketService().onAudioRead = (messageId) {
      if (mounted) {
        final idx = _allMessages.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          setState(() {
            final msg = _allMessages[idx];
            msg.isRead = true; 
            final now = DateTime.now();
            msg.readTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
            
            if (!msg.isSaved && !msg.isDeleted && !msg.isPendingDeletion) {
              _startDeletionCountdown(msg);
            }
          });
        }
      }
    };

    SocketService().onCallReceived = (callerId) {
      if (mounted) {
        int idx = allContacts.indexWhere((c) => c['name'] == callerId);
        if (idx == -1) {
           setState(() {
             allContacts.insert(0, {"name": callerId, "isGroup": false, "status": UserStatus.available});
           });
        }
        
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: "CallDialog",
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
              child: FadeTransition(
                opacity: animation,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: Material(
                        color: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40), 
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65), 
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 2)
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: 45, height: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.6), width: 2),
                                    ),
                                    child: const Icon(Icons.graphic_eq, color: Colors.cyanAccent, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(callerId, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                        const SizedBox(height: 2),
                                        Text("Canlı telsiz bağlantısı...", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      SocketService().rejectCall(callerId);
                                    },
                                    child: Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withValues(alpha: 0.15), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.7), width: 2)),
                                      child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      SocketService().acceptCall(callerId);
                                      setState(() {
                                        activeIndex = allContacts.indexWhere((c) => c['name'] == callerId);
                                        _activeLiveContacts.add(callerId);
                                        _resetLiveTimeoutForContact(callerId);
                                      });
                                    },
                                    child: Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withValues(alpha: 0.2), border: Border.all(color: Colors.greenAccent.shade400, width: 2)),
                                      child: const Icon(Icons.check, color: Colors.greenAccent, size: 22),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    };

    SocketService().onCallAccepted = (targetId) {
      if (context.mounted) { 
        setState(() {
          _activeLiveContacts.add(targetId);
          _resetLiveTimeoutForContact(targetId);
          isWaitingForLiveApproval = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$targetId telsiz çağrısını kabul etti!"), backgroundColor: Colors.green.shade800));
      }
    };

    SocketService().onCallRejected = (targetId) {
      if (context.mounted) { 
        setState(() {
          isWaitingForLiveApproval = false;
          _activeLiveContacts.remove(targetId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$targetId çağrıyı reddetti."), backgroundColor: Colors.red.shade800));
      }
    };

    SocketService().onAudioPlayed = (senderId, filePath, messageId) {
      if (context.mounted) { 
        final now = DateTime.now();
        String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        
        bool isLive = _activeLiveContacts.contains(senderId);

        setState(() {
          if (isLive) {
            _isCurrentlyPlayingOrRecording = true;
            _currentlyPlayingQueueItemSender = senderId;
            
            SocketService().playLiveAudio(filePath); 

            _allMessages.insert(0, AudioMessage(
              id: messageId, 
              contactName: senderId,
              isMe: false, 
              durationInSeconds: 5, 
              time: timeStr,
              isRead: true, 
              isLiveMessage: true, 
              audioFilePath: filePath,
            ));

            _incomingAmplitudeTimer?.cancel();
            _incomingAmplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
              if (mounted) {
                _incomingAudioLevel.value = 0.2 + (math.Random().nextDouble() * 0.8); 
              }
            });

            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                _incomingAmplitudeTimer?.cancel();
                _incomingAudioLevel.value = 0.0;
                setState(() {
                  _isCurrentlyPlayingOrRecording = false;
                  _currentlyPlayingQueueItemSender = null;
                });
              }
            });
          } else {
            _allMessages.insert(0, AudioMessage(
              id: messageId, 
              contactName: senderId,
              isMe: false, 
              durationInSeconds: 5, 
              time: timeStr,
              isRead: false, 
              isLiveMessage: false, 
              audioFilePath: filePath,
            ));
            
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.voicemail, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text("$senderId yeni bir sesli mesaj gönderdi.", style: const TextStyle(color: Colors.white)),
                ],
              ),
              backgroundColor: Colors.grey.shade900,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ));
          }
        });
      }
    };
  }

  Future<String?> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _initMicrophone() async {
    await Permission.microphone.request();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _amplitudeTimer?.cancel();
    _recordTimer?.cancel();
    _micDebounceTimer?.cancel(); 
    _backgroundLiveTimeoutTimer?.cancel(); 
    _liveDurationTimer?.cancel();
    _arrowsTimer?.cancel();
    for (var timer in _liveTimers.values) { timer.cancel(); }
    _audioRecorder.dispose(); 
    _pulseController.dispose();
    _breatheController.dispose();
    _dangerPulseController.dispose();
    _entranceController.dispose();
    _incomingAmplitudeTimer?.cancel(); 
    _historyPlayer.dispose();
    super.dispose();
  }

  void _resetLiveTimeoutForContact(String contactName) {
    _liveTimers[contactName]?.cancel(); 
    _liveTimers[contactName] = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _activeLiveContacts.remove(contactName);
          _liveTimers.remove(contactName);
          if (_activeLiveContacts.isEmpty) {
            _liveDurationTimer?.cancel();
            _liveDuration = 0;
          }
        });
      }
    });
  }

  void _triggerConnectionArrows() {
    setState(() { _showConnectionArrows = true; });
    _arrowsTimer?.cancel();
    _arrowsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() { _showConnectionArrows = false; });
      }
    });
  }

  void _requestLiveConnection(int index) {
    String name = allContacts[index]['name'];
    if (allContacts[index]['status'] == UserStatus.busy && !allContacts[index]['isGroup']) return;
    
    SocketService().startCall(name);
    
    setState(() {
      activeIndex = index;
      isWaitingForLiveApproval = true;
      _replyingToMessage = null; 
    });
    _triggerConnectionArrows();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_activeLiveContacts.contains(name)) {
         setState(() {
          isWaitingForLiveApproval = false;
          if (_activeLiveContacts.length == 1) {
            _liveDuration = 0; 
            _liveDurationTimer?.cancel();
            _liveDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (mounted && _activeLiveContacts.isNotEmpty) {
                setState(() => _liveDuration++);
              } else {
                timer.cancel();
              }
            });
          }
        });
      }
    });
  }

  void _onPersonSelected(int index) {
    if (allContacts[index]['isEmpty'] == true) {
       _openContacts(initialIndex: 1); 
       return;
    }
    setState(() {
      activeIndex = index; 
      _replyingToMessage = null; 
      _closeSearchMode(); 
    });
    _triggerConnectionArrows();
  }

  void _startRecording() {
    if (isRecording || activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) return; 

    setState(() {
      isRecording = true;
      _isCurrentlyPlayingOrRecording = true; 
      _recordDuration = 0;
      _dragOffset = 0.0;
      _isCancelled = false;
    });
    
    if (hapticEnabled) HapticFeedback.lightImpact();
    
    String currentTarget = allContacts[activeIndex]['name'];
    if (_activeLiveContacts.contains(currentTarget)) {
      _resetLiveTimeoutForContact(currentTarget); 
    }

    _micDebounceTimer?.cancel();
    _micDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
       
       try {
         if (await _audioRecorder.hasPermission()) {
           
           if (await _audioRecorder.isRecording()) {
             await _audioRecorder.stop();
           }

           if (_currentlyPlayingMessage != null) {
              await _historyPlayer.stop(); 
              final session = await AudioSession.instance;
              await session.setActive(false); 
              setState(() {
                _currentlyPlayingMessage!.isPlaying = false; 
                _currentlyPlayingMessage = null;
                _isCurrentlyPlayingOrRecording = false; 
              });
           }
           await SocketService().stopAudio(); 

           final Directory tempDir = await getTemporaryDirectory();
           final String tempPath = '${tempDir.path}/my_orbit_record_${DateTime.now().millisecondsSinceEpoch}.wav';

           await _audioRecorder.start(
             const RecordConfig(
               encoder: AudioEncoder.wav, 
               sampleRate: 16000,         
               numChannels: 1,            
             ), 
             path: tempPath
           );

           if (!mounted) return;

           _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) async {
             try {
               if (isRecording && await _audioRecorder.isRecording()) {
                  final amplitude = await _audioRecorder.getAmplitude();
                  double normalized = (amplitude.current + 60) / 60; 
                  if (mounted) setState(() => _audioLevel.value = normalized.clamp(0.0, 1.0)); 
               }
             } catch(e) {}
           });

           _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
             if (mounted) setState(() => _recordDuration++);
           });
         }
       } catch (e) {
         debugPrint("Kayıt Hatası: $e");
         if (mounted) {
           setState(() {
             isRecording = false;
             _isCurrentlyPlayingOrRecording = false;
           });
         }
       }
    });
  }

  void _updateRecordingDrag(LongPressMoveUpdateDetails details) {
    if (!isRecording) return;
    setState(() {
      if (_isLeftHanded) {
        _dragOffset = details.localPosition.dx.clamp(0.0, 150.0); 
        _isCancelled = _dragOffset > 100;
      } else {
        _dragOffset = details.localPosition.dx.clamp(-150.0, 0.0); 
        _isCancelled = _dragOffset < -100;
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return; 

    _micDebounceTimer?.cancel();

    setState(() {
      isRecording = false; 
      _audioLevel.value = 0.0; 
    });
    
    _amplitudeTimer?.cancel();
    _recordTimer?.cancel();
    
    String? path;
    try {
      if (await _audioRecorder.isRecording()) {
         path = await _audioRecorder.stop();
      }
    } catch(e){}

    setState(() {
      _isCurrentlyPlayingOrRecording = false; 
    });

    if (_isCancelled) {
      if (hapticEnabled) HapticFeedback.heavyImpact();
    } else if (path != null) {
      
      final audioFile = File(path);
      if (audioFile.existsSync() && audioFile.lengthSync() > 100) {
          
          if (hapticEnabled) HapticFeedback.lightImpact();
          
          final now = DateTime.now();
          String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          
          final newMsg = AudioMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            contactName: allContacts[activeIndex]['name'],
            isMe: true,
            durationInSeconds: _recordDuration,
            time: timeStr,
            isRead: _activeLiveContacts.contains(allContacts[activeIndex]['name']), 
            isLiveMessage: _activeLiveContacts.contains(allContacts[activeIndex]['name']), 
            repliedToMessageId: _replyingToMessage?.id, 
            audioFilePath: path,
          );
          
          setState(() { _allMessages.insert(0, newMsg); });
          
          try {
            final List<int> audioBytes = await audioFile.readAsBytes();
            final String base64Audio = base64Encode(audioBytes);
            
            SocketService().sendAudio(newMsg.contactName, base64Audio, newMsg.id);
            
            if (_activeLiveContacts.contains(newMsg.contactName)) {
              _resetLiveTimeoutForContact(newMsg.contactName); 
            }
          } catch (e) {
            debugPrint("❌ Gönderme hatası: $e");
          }
      }
    }
    
    setState(() {
      _dragOffset = 0.0;
      _isCancelled = false;
      _replyingToMessage = null; 
    });
  }

  Future<void> _playMessage(AudioMessage msg) async {
    if (msg.isPlaying) {
      await _historyPlayer.stop(); 
      final session = await AudioSession.instance;
      await session.setActive(false); 
      
      setState(() {
        msg.isPlaying = false;
        _isCurrentlyPlayingOrRecording = false;
        _currentlyPlayingMessage = null;
      });
      return; 
    }

    if (_isCurrentlyPlayingOrRecording) return; 
    
    if (msg.audioFilePath == null || !File(msg.audioFilePath!).existsSync()) {
      if (context.mounted) { 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Bu mesajın ses dosyası bulunamadı."), backgroundColor: Colors.orange));
      }
      return;
    }

    setState(() {
      _isCurrentlyPlayingOrRecording = true; 
      msg.isPlaying = true;
      _currentlyPlayingMessage = msg; 
      
      if (!msg.isMe && !msg.isRead) {
         msg.isRead = true;
         final now = DateTime.now();
         msg.readTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
         
         SocketService().sendAudioRead(msg.contactName, msg.id);
      }
    });

    try {
      await _historyPlayer.stop(); 

      final session = await AudioSession.instance;
      await session.setActive(true);

      await _historyPlayer.setVolume(1.0); 
      await _historyPlayer.setPlaybackRate(msg.playbackSpeed); 
      await _historyPlayer.setSource(DeviceFileSource(msg.audioFilePath!)); 
      
      if (msg.playProgress > 0.0 && msg.playProgress < 1.0) {
          int seekMs = (msg.durationInSeconds * 1000 * msg.playProgress).round();
          await _historyPlayer.seek(Duration(milliseconds: seekMs)); 
      }
      
      await _historyPlayer.resume(); 

    } catch (e) {
      debugPrint("Geçmiş mesaj çalınamadı: $e");
      await _historyPlayer.stop(); 
      
      final session = await AudioSession.instance;
      await session.setActive(false); 
      
      setState(() { 
        msg.isPlaying = false; 
        _isCurrentlyPlayingOrRecording = false; 
        _currentlyPlayingMessage = null;
      });
    }
  }

  void _startDeletionCountdown(AudioMessage msg) {
    if (msg.isPendingDeletion || selfDestructSeconds == -1) return; 
    if (selfDestructSeconds == 0) { 
      setState(() => msg.isDeleted = true); 
      return; 
    }
    setState(() {
      msg.isPendingDeletion = true;
      msg.deletionSecondsRemaining = selfDestructSeconds; 
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || msg.isSaved || msg.isDeleted) {
        timer.cancel();
        if (mounted && msg.isSaved) {
          setState(() => msg.isPendingDeletion = false);
        }
        return;
      }
      setState(() => msg.deletionSecondsRemaining--);
      if (msg.deletionSecondsRemaining <= 0) {
        timer.cancel();
        setState(() {
          msg.isDeleted = true;
          msg.isPendingDeletion = false;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _handleSearch(String query) => setState(() => isSearching = query.isNotEmpty);

  void _closeSearchMode() {
    if (showSearchField) {
      setState(() {
        isSearching = false;
        showSearchField = false;
        _searchController.clear();
        _focusNode.unfocus(); 
      });
    }
  }

  void _onSearchedPersonSelected(Map<String, dynamic> person) {
    setState(() {
      allContacts.remove(person);
      allContacts.insert(0, person);
      _onPersonSelected(0);
      _scrollOffset = 0.0; 
    });
  }

  String formatName(String fullName) {
    List<String> parts = fullName.trim().split(' ');
    if (fullName.length <= 10) return fullName;
    if (parts.length > 1) return "${parts[0]} ${parts[parts.length - 1][0]}.";
    return fullName.substring(0, 10);
  }

 String getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return "${parts[0][0]}.${parts[parts.length - 1][0]}".toUpperCase();
  }

  Color _getStatusColor(UserStatus s) {
    switch(s) {
      case UserStatus.available: return Colors.greenAccent;
      case UserStatus.busy: return Colors.redAccent;
      case UserStatus.away: return Colors.orangeAccent;
    }
  }

  String _getStatusText(UserStatus s) {
    switch(s) {
      case UserStatus.available: return "Müsait";
      case UserStatus.busy: return "Meşgul";
      case UserStatus.away: return "Uzakta";
    }
  }

  void _openSavedMessages() {
    SavedMessagesSheet.show(
      context: context,
      savedMessages: _allMessages.where((msg) => msg.isSaved && !msg.isDeleted).toList(),
      formatDuration: _formatDuration,
      onUnsave: (msg) {
        setState(() {
          msg.isSaved = false;
          msg.isDeleted = true;
        });
      },
    );
  }

  void _openContacts({int initialIndex = 0}) {
    ContactsBottomSheet.show(context, initialIndex: initialIndex);
  }

  void _openSettings() {
    setState(() => _isSettingsOpen = true);
    SettingsBottomSheet.show(
      context: context,
      userName: _userName,
      userAvatarPath: _userAvatarPath,
      myStatus: _myStatus,
      onUserNameChanged: (val) => setState(() => _userName = val),
      onPickAvatar: _pickImageFromGallery,
      onStatusChanged: (val) => setState(() => _myStatus = val),
      isLeftHanded: _isLeftHanded,
      onLeftHandedChanged: (val) => setState(() => _isLeftHanded = val),
      selectedLiveAnimation: selectedLiveAnimation,
      animationOptions: animationOptions,
      onLiveAnimationChanged: (val) => setState(() => selectedLiveAnimation = val),
      isBackgroundTransparent: isBackgroundTransparent,
      onBackgroundTransparentChanged: (val) => setState(() => isBackgroundTransparent = val),
      isCircularMessageStyle: isCircularMessageStyle,
      onCircularMessageStyleChanged: (val) => setState(() => isCircularMessageStyle = val),
      hapticEnabled: hapticEnabled,
      onHapticChanged: (val) => setState(() => hapticEnabled = val),
      useSpeaker: _useSpeaker,
      onSpeakerChanged: (val) => setState(() => _useSpeaker = val),
      selfDestructSeconds: selfDestructSeconds,
      onSelfDestructChanged: (val) => setState(() => selfDestructSeconds = val),
      liveAudioPermission: _liveAudioPermission,
      onLivePermissionChanged: (val) => setState(() => _liveAudioPermission = val),
      deleteFilterDays: deleteFilterDays,
      onDeleteFilterDaysChanged: (val) => setState(() => deleteFilterDays = val),
      onClearOldMessages: (days) {
        final limitDate = DateTime.now().subtract(Duration(days: days));
        setState(() {
          _allMessages.removeWhere((m) => m.isSaved && m.createdAt.isBefore(limitDate));
        });
      },
      customBackgroundImagePath: _customBackgroundImagePath,
      onPickBackground: _pickImageFromGallery,
      onRemoveBackground: () {
        setState(() {
          _customBackgroundImagePath = null;
          isBackgroundTransparent = true;
        });
      },
      onClosed: () => setState(() => _isSettingsOpen = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;
            double orbitRadius = 105.0; 
            double menuX = screenWidth / 2; 
            double menuY = screenHeight - 280.0;
            double itemSpacingAngle = 0.25 * math.pi;
            double maxScroll = (allContacts.length * itemSpacingAngle) - (4 * itemSpacingAngle);
            if (maxScroll < 0) maxScroll = 0;

            String activeContactName = activeIndex != -1 ? allContacts[activeIndex]['name'] : "";
            bool isGroup = activeIndex != -1 ? (allContacts[activeIndex]['isGroup'] ?? false) : false;
            bool anyLiveActive = _activeLiveContacts.isNotEmpty;

            return GestureDetector(
              onTap: () {
                if (showSearchField) {
                  _closeSearchMode();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              onVerticalDragUpdate: (details) {
                if (!showSearchField) {
                  setState(() {
                    double delta = details.delta.dy * 0.005;
                    _scrollOffset -= delta;
                    if (_scrollOffset < -0.2) _scrollOffset = -0.2;
                    if (_scrollOffset > maxScroll) _scrollOffset = maxScroll;
                  });
                }
              },
              child: Stack(
                children: [
                  if (_customBackgroundImagePath != null) Positioned.fill(child: Image.file(File(_customBackgroundImagePath!), fit: BoxFit.cover))
                  else if (!isBackgroundTransparent) Container(color: Colors.black) 
                  else Positioned.fill(child: Container(color: Colors.black)),

                  if (_customBackgroundImagePath != null || isBackgroundTransparent)
                    Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), child: Container(color: Colors.black.withValues(alpha: 0.4)))),

                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !(_isSettingsOpen || showSearchField), 
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: (_isSettingsOpen || showSearchField) ? 12.0 : 0.0), 
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        builder: (context, blurValue, child) {
                          if (blurValue == 0.0) return const SizedBox.shrink(); 
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                            child: Container(color: Colors.black.withValues(alpha: (blurValue / 12.0) * (showSearchField ? 0.6 : 0.4))),
                          );
                        },
                      ),
                    ),
                  ),

                  Scaffold(
                    backgroundColor: Colors.transparent, 
                    resizeToAvoidBottomInset: false, 

                    body: Stack(
                      children: [
                        if (_currentlyPlayingQueueItemSender != null && !showSearchField)
                          Positioned(
                            top: 100, left: 20, right: 20,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.8), width: 1.5),
                                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 15)]
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.volume_up, color: Colors.cyanAccent, size: 18), const SizedBox(width: 8),
                                    Text("$_currentlyPlayingQueueItemSender dinleniyor...", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      
                        if (activeIndex != -1 && !showSearchField && allContacts[activeIndex]['isEmpty'] != true) 
                          Positioned(
                            top: 50, left: 0, right: 0,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _activeLiveContacts.contains(activeContactName) ? Colors.greenAccent : Colors.white12, width: _activeLiveContacts.contains(activeContactName) ? 1.0 : 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(isGroup ? Icons.groups : Icons.person, size: 12, color: _activeLiveContacts.contains(activeContactName) ? Colors.greenAccent : Colors.cyanAccent),
                                      const SizedBox(width: 6),
                                      Text(
                                        _activeLiveContacts.contains(activeContactName) ? "$activeContactName (Canlı)" : activeContactName,
                                        style: TextStyle(color: _activeLiveContacts.contains(activeContactName) ? Colors.greenAccent : Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                                      ),
                                      if (!isGroup && !_activeLiveContacts.contains(activeContactName)) ...[
                                        const SizedBox(width: 10),
                                        Icon(Icons.circle, color: _getStatusColor(allContacts[activeIndex]['status']), size: 8), const SizedBox(width: 4),
                                        Text(_getStatusText(allContacts[activeIndex]['status']), style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                      ]
                                    ],
                                  ),
                                ),
                                if (isGroup && _activeLiveContacts.contains(activeContactName) && _activeLiveGroupMembers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _activeLiveGroupMembers.map((member) => Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5), width: 0.5), borderRadius: BorderRadius.circular(10)),
                                          child: Row(children: [const Icon(Icons.circle, color: Colors.greenAccent, size: 6), const SizedBox(width: 4), Text(member, style: const TextStyle(fontSize: 9, color: Colors.greenAccent))]),
                                        )).toList(),
                                    ),
                                  )
                              ],
                            ),
                          ),

                        if (activeIndex != -1 && !showSearchField && allContacts[activeIndex]['isEmpty'] != true) 
                          Positioned(
                            top: (isGroup && _activeLiveContacts.contains(activeContactName)) ? 110 : 90, left: 10, right: 10, bottom: screenHeight - menuY + 130, 
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.15, 0.85, 1.0], 
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: _buildChatArea(),
                            ),
                          ),

                        ...List.generate(allContacts.length, (index) {
                          double startAngle = -0.35 * math.pi; 
                          double angle = startAngle - (index * itemSpacingAngle) + _scrollOffset;
                          double xOffset = orbitRadius * math.cos(angle);
                          double yOffset = orbitRadius * math.sin(angle);
                          if (_isLeftHanded) xOffset = -xOffset; 
                          double globalAngle = math.atan2(yOffset, xOffset);

                          return _buildOrbitalItem(
                            index: index,
                            centerX: menuX,
                            centerY: menuY,
                            radius: orbitRadius, 
                            spacing: itemSpacingAngle,
                            data: allContacts[index],
                            globalAngle: globalAngle, 
                          );
                        }).reversed, 

                        OrbitMenuGrid(
                          isLeftHanded: _isLeftHanded,
                          showSearchField: showSearchField,
                          menuX: menuX, menuY: menuY, orbitRadius: orbitRadius, screenWidth: screenWidth,
                          onToggleHand: () { },
                          onSearchTap: () {
                            setState(() {
                              showSearchField = !showSearchField;
                              if (!showSearchField) { _closeSearchMode(); } 
                              else { 
                                Future.delayed(const Duration(milliseconds: 150), () { 
                                  if (context.mounted) {
                                    FocusScope.of(context).requestFocus(_focusNode); 
                                  }
                                }); 
                              }
                            });
                          },
                          onBookmarkTap: _openSavedMessages,
                          onSettingsTap: _openSettings,
                          onContactAddTap: _openContacts,
                        ),

                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          left: _isLeftHanded ? menuX + 60 : menuX - 180, top: menuY - 140, 
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: (showSearchField || activeIndex == -1 || _replyingToMessage == null) ? 0.0 : 1.0, 
                            child: IgnorePointer(
                              ignoring: showSearchField || activeIndex == -1 || _replyingToMessage == null, 
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.blueGrey.shade900.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.reply, size: 12, color: Colors.blueAccent), const SizedBox(width: 6),
                                    Text("Yanıtlanıyor: ${_formatDuration(_replyingToMessage?.durationInSeconds ?? 0)}", style: const TextStyle(fontSize: 10, color: Colors.white70)), const SizedBox(width: 8),
                                    GestureDetector(onTap: () => setState(() => _replyingToMessage = null), child: const Icon(Icons.close, size: 12, color: Colors.white54))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: menuX - 162.5, top: menuY - 162.5,  
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: showSearchField ? 0.3 : 1.0, 
                            child: IgnorePointer(ignoring: showSearchField, child: _buildPTTButtonAndHelpers()),
                          ),
                        ),
                        
                        if (anyLiveActive && !showSearchField)
                          Positioned(
                            bottom: 40, left: 0, right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3), width: 1),
                                  boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.1), blurRadius: 10)]
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildLiveAnimation(), const SizedBox(width: 12),
                                    AnimatedBuilder(
                                      animation: _breatheController,
                                      builder: (context, child) {
                                        double opacity = selectedLiveAnimation == "Nefes" ? 0.5 + (_breatheController.value * 0.5) : 1.0;
                                        return Text(
                                          "CANLI  ${_formatDuration(_liveDuration)}",
                                          style: TextStyle(
                                            color: Colors.greenAccent.withValues(alpha: opacity), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0,
                                            shadows: selectedLiveAnimation == "Nefes" ? [Shadow(color: Colors.greenAccent, blurRadius: 10 * _breatheController.value)] : [],
                                          ),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        Positioned(
                          top: menuY - 220, left: _isLeftHanded ? null : 30, right: _isLeftHanded ? 30 : null,
                          child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: showSearchField ? _buildNeonSearchField() : const SizedBox.shrink()),
                        ),
                        if (!showSearchField)
                          Positioned(
                            top: 60, left: 30, right: 30, 
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("4:40", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white)), 
                                    Text("Active", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // 🟢 DÜZELTİLMİŞ: 5 SANİYE SONRA TAMAMEN KAYBOLAN HAYALET OK 🟢
                        if (!showSearchField)
                          Positioned(
                            left: !_isLeftHanded ? 20.0 : null, 
                            right: _isLeftHanded ? 20.0 : null, 
                            top: menuY - 150, 
                            child: GhostHandToggle(
                              isLeftHanded: _isLeftHanded,
                              onToggle: () {
                                setState(() { _isLeftHanded = !_isLeftHanded; });
                                if (hapticEnabled) HapticFeedback.selectionClick();
                              },
                            ),
                          ),

                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildPTTButtonAndHelpers() {
    return SizedBox(
      width: 325, height: 325,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isRecording)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              left: _isLeftHanded ? null : 20 + _dragOffset, 
              right: _isLeftHanded ? 20 - _dragOffset : null, 
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isCancelled ? 0.0 : (1.0 - (_dragOffset.abs() / 100)).clamp(0.0, 1.0),
                child: Row(
                  children: [
                    if (!_isLeftHanded) const Icon(Icons.chevron_left, color: Colors.white54),
                    const Text(" İptal demek için kaydır ", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    if (_isLeftHanded) const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
          if (isRecording && _isCancelled) const Positioned(top: 50, child: Icon(Icons.delete, color: Colors.redAccent, size: 30)),
          Transform.translate(
            offset: Offset(_dragOffset, 0), 
            child: GestureDetector(
              behavior: HitTestBehavior.opaque, 
              onLongPressStart: (_) => _startRecording(),
              onLongPressMoveUpdate: _updateRecordingDrag,
              onLongPressEnd: (_) => _stopRecording(),
              onLongPressCancel: () => _stopRecording(),
              onTap: () {
                 if (context.mounted) { 
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kaydetmek için mikrofona basılı tutun."), duration: Duration(seconds: 1)));
                 }
              },
              child: SizedBox(
                width: 130, height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isRecording && !_isCancelled) ...List.generate(3, (i) => _buildRealWave(i)),
                    
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _entranceController,
                        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut), 
                      ),
                      child: SizedBox(
                        width: 117, height: 117,
                        child: ValueListenableBuilder<double>(
                          valueListenable: _audioLevel,
                          builder: (context, level, child) {
                            return CustomPaint(
                              painter: NeonRingPainter(innerColor: Colors.cyanAccent, outerColor: Colors.redAccent.shade200, isRecording: isRecording, isLeftHanded: _isLeftHanded, audioLevel: level),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_isCancelled ? Icons.delete_outline : (isRecording ? Icons.graphic_eq : Icons.mic), size: isRecording ? 30 : 45, color: Colors.white),
                                    if (isRecording && !_isCancelled) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(_formatDuration(_recordDuration), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0))),
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
        ],
      ),
    );
  }

  Widget _buildRealWave(int index) {
    return ValueListenableBuilder<double>(
      valueListenable: _audioLevel,
      builder: (context, level, child) {
        double sizeMultiplier = 1.0 + (level * (1.2 + (index * 0.4)));
        return TweenAnimationBuilder(
          key: ValueKey(index), 
          tween: Tween(begin: 1.0, end: sizeMultiplier),
          duration: const Duration(milliseconds: 100), 
          builder: (context, double val, _) {
            return Container(
              width: 117 * val, height: 117 * val,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent.withValues(alpha: (0.4 - (level * 0.2)).clamp(0.1, 1.0)), width: 2 + (level * 2)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIncomingWave(int index) {
    return ValueListenableBuilder<double>(
      valueListenable: _incomingAudioLevel,
      builder: (context, level, child) {
        double sizeMultiplier = 1.0 + (level * (0.6 + (index * 0.3)));
        return TweenAnimationBuilder(
          key: ValueKey("incoming_$index"), 
          tween: Tween(begin: 1.0, end: sizeMultiplier),
          duration: const Duration(milliseconds: 100), 
          builder: (context, double val, _) {
            return Container(
              width: 60 * val, height: 60 * val,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: (0.6 - (level * 0.3)).clamp(0.0, 1.0)), 
                  width: 1.5 + (level * 2)
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLiveAnimation() {
    switch (selectedLiveAnimation) {
      case "Mini Ekolayzır":
        return ValueListenableBuilder<double>(
          valueListenable: _audioLevel,
          builder: (context, level, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (index) {
                double barHeight = 4.0 + (level * 15.0 * (math.Random().nextDouble() + 0.5));
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100), margin: const EdgeInsets.symmetric(horizontal: 2), width: 3, height: barHeight.clamp(4.0, 20.0),
                  decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 4)]),
                );
              }),
            );
          },
        );
      case "Radar":
        return SizedBox(
          width: 24, height: 24,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 24 * _pulseController.value, height: 24 * _pulseController.value,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent.withValues(alpha: 1.0 - _pulseController.value), width: 1.5)),
                  ),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent)),
                ],
              );
            }
          ),
        );
      case "Nabız":
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.greenAccent.withValues(alpha: _pulseController.value > 0.5 ? 1.0 : 0.3),
                boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: _pulseController.value), blurRadius: 6)],
              ),
            );
          }
        );
      case "Nefes":
      default:
        return const Icon(Icons.graphic_eq, color: Colors.greenAccent, size: 16);
    }
  }

  Widget _buildNeonSearchField() {
    return GestureDetector(
      onTap: () {}, 
      child: Container(
        width: 250, height: 50,
        decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1),
            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)
          ]
        ),
        child: Center(
          child: TextField(
            controller: _searchController, focusNode: _focusNode, autofocus: true, cursorColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 1.0),
            decoration: InputDecoration(
              hintText: "Orbitte Ara...", hintStyle: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.4), fontStyle: FontStyle.italic), border: InputBorder.none,
              prefixIcon: const Icon(Icons.saved_search, color: Colors.cyanAccent, size: 22),
              suffixIcon: _searchController.text.isNotEmpty ? GestureDetector(onTap: () { _searchController.clear(); _handleSearch(""); }, child: const Icon(Icons.cancel, color: Colors.cyanAccent, size: 18)) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            onChanged: _handleSearch,
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    List<AudioMessage> currentMessages = _activeMessages;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0, bottom: 8.0, right: 15.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showOnlyUnread = !_showOnlyUnread; 
                });
                if (hapticEnabled) {
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _showOnlyUnread ? Colors.redAccent.withValues(alpha: 0.2) : Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _showOnlyUnread ? Colors.redAccent : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showOnlyUnread ? Icons.filter_alt : Icons.filter_alt_outlined, 
                      size: 14, 
                      color: _showOnlyUnread ? Colors.redAccent : Colors.white54
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showOnlyUnread ? "Tümünü Göster" : "Okunmayanları Süz", 
                      style: TextStyle(fontSize: 10, color: _showOnlyUnread ? Colors.redAccent : Colors.white54)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            reverse: true, 
            itemCount: currentMessages.length,
            padding: const EdgeInsets.only(bottom: 10), 
            itemBuilder: (context, index) {
              final msg = currentMessages[index];
              return GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.primaryDelta! > 3) { 
                    setState(() => _replyingToMessage = msg); 
                    HapticFeedback.selectionClick(); 
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: msg.isLiveMessage 
                    ? OrbitMessageBubbles.buildLiveLogView(msg, _formatDuration(msg.durationInSeconds)) 
                    : (isCircularMessageStyle ? _buildCircularMessageStyle(msg) : _buildPillMessageStyle(msg)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPillMessageStyle(AudioMessage msg) {
    if (msg.isDeleted) return OrbitMessageBubbles.buildDeletedMessageView(msg);
    Color baseColor = msg.isPendingDeletion && !msg.isSaved ? Colors.redAccent : (msg.isMe ? Colors.cyanAccent : Colors.greenAccent);

    bool isPaused = msg.playProgress > 0.0 && msg.playProgress < 1.0 && !msg.isPlaying;
    Color playIconColor = isPaused ? Colors.orangeAccent : Colors.white;
    Color buttonBorderColor = isPaused ? Colors.orangeAccent : baseColor.withValues(alpha: 0.5);

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!msg.isMe && msg.senderName != null) Padding(padding: const EdgeInsets.only(left: 12, bottom: 4), child: Text(msg.senderName!, style: TextStyle(color: baseColor, fontSize: 11, fontWeight: FontWeight.bold))),
          if (msg.repliedToMessageId != null)
            Container(
               margin: const EdgeInsets.only(bottom: 4, left: 12, right: 12), padding: const EdgeInsets.all(4),
               decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4), border: Border(left: BorderSide(color: baseColor, width: 2))),
               child: const Text("Yanıtlanan Ses", style: TextStyle(fontSize: 9, color: Colors.white54, fontStyle: FontStyle.italic)),
            ),

          AnimatedBuilder(
            animation: _dangerPulseController,
            builder: (context, child) {
              double borderAlpha = (msg.isPendingDeletion && !msg.isSaved) ? 0.5 + (_dangerPulseController.value * 0.5) : 0.8;
              double blurRadius = (msg.isPendingDeletion && !msg.isSaved) ? 5 + (_dangerPulseController.value * 15) : 10;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), width: 150, 
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65), 
                  border: Border.all(color: baseColor.withValues(alpha: borderAlpha), width: 1.0),
                  boxShadow: [BoxShadow(color: baseColor.withValues(alpha: 0.3), blurRadius: blurRadius, spreadRadius: 1)],
                  borderRadius: BorderRadius.circular(20), 
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _playMessage(msg),
                          child: Container(
                            width: 28, height: 28, 
                            decoration: BoxDecoration(shape: BoxShape.circle, color: baseColor.withValues(alpha: 0.2), border: Border.all(color: buttonBorderColor)),
                            child: Icon(msg.isPlaying ? Icons.pause : Icons.play_arrow, size: 16, color: playIconColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  SizedBox(
                                    width: double.infinity, height: 16, 
                                    child: CustomPaint(painter: SmoothWaveformPainter(progress: msg.playProgress, isPlaying: msg.isPlaying, activeColor: isPaused ? Colors.orangeAccent : baseColor, time: DateTime.now().millisecondsSinceEpoch / 150)),
                                  ),
                                  Positioned(
                                    left: ((80) * msg.playProgress).clamp(0, double.infinity),
                                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)])),
                                  )
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(_formatDuration(msg.durationInSeconds), style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                               onTap: () {
                                 setState(() {
                                   if (msg.playbackSpeed == 1.0) {
                                     msg.playbackSpeed = 1.5;
                                   } else if (msg.playbackSpeed == 1.5) {
                                     msg.playbackSpeed = 2.0;
                                   } else {
                                     msg.playbackSpeed = 1.0;
                                   }
                                 });
                               },
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                 decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                 child: Text("${msg.playbackSpeed}x", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                               ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                if (!msg.isSaved) { 
                                  setState(() { msg.isSaved = true; msg.isPendingDeletion = false; }); 
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      backgroundColor: Colors.grey.shade900,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Text("Kaydı Sil", style: TextStyle(color: Colors.white, fontSize: 16)),
                                      content: const Text("Bu kayıtlı ses dosyasını tamamen silmek istiyor musunuz?", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
                                        TextButton(
                                          onPressed: () { 
                                            Navigator.pop(c); 
                                            setState(() { msg.isSaved = false; msg.isDeleted = true; }); 
                                          },
                                          child: const Text("Evet, Sil", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Icon(msg.isSaved ? Icons.bookmark : Icons.bookmark_border, size: 14, color: msg.isSaved ? Colors.orangeAccent : (msg.isPendingDeletion ? Colors.redAccent : Colors.white70)),
                            ),
                          ],
                        )
                      ],
                    ),
                    if (msg.isPendingDeletion && !msg.isSaved)
                      Positioned(
                        bottom: -6, left: 0, right: 0,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: msg.deletionSecondsRemaining / selfDestructSeconds, end: (msg.deletionSecondsRemaining - 1) / selfDestructSeconds),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft, widthFactor: value.clamp(0.0, 1.0),
                              child: Container(height: 2, decoration: BoxDecoration(color: Colors.redAccent, boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 4)])),
                            );
                          },
                        ),
                      ),
                    if (msg.isPendingDeletion && !msg.isSaved)
                      Positioned(
                        top: -12, left: 15, 
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delete_outline, color: Colors.redAccent, size: 10), const SizedBox(width: 2),
                              Text("${msg.deletionSecondsRemaining}s", style: const TextStyle(fontSize: 9, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
          ),
          
          Padding(
            padding: EdgeInsets.only(top: 4, right: msg.isMe ? 8.0 : 0, left: msg.isMe ? 0 : 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.isRead && msg.readTime != null ? "${msg.time} • Dinlendi" : msg.time,
                  style: TextStyle(
                    fontSize: 11, 
                    color: msg.isRead ? Colors.cyanAccent.withValues(alpha: 0.8) : Colors.white54,
                    fontWeight: FontWeight.w500
                  ),
                ),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.check, 
                    size: 18, 
                    color: msg.isRead ? Colors.blueAccent.shade200 : Colors.white54,
                  ),
                ]
              ],
            ),
          ),
          
          if (msg.showTranscription && !msg.isPendingDeletion)
            Container(
               margin: const EdgeInsets.only(top: 4, bottom: 6, left: 8, right: 8), padding: const EdgeInsets.all(8), width: 150, 
               decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
               child: Text(msg.transcriptionText, style: const TextStyle(fontSize: 9, color: Colors.white70, fontStyle: FontStyle.italic)),
            )
        ],
      ),
    );
  }

  Widget _buildCircularMessageStyle(AudioMessage msg) {
    if (msg.isDeleted) return OrbitMessageBubbles.buildDeletedMessageView(msg);
    Color baseColor = msg.isPendingDeletion && !msg.isSaved ? Colors.redAccent : (msg.isMe ? Colors.cyanAccent : Colors.greenAccent);
    
    bool isPaused = msg.playProgress > 0.0 && msg.playProgress < 1.0 && !msg.isPlaying;
    Color playIconColor = isPaused ? Colors.orangeAccent : Colors.white;

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!msg.isMe && msg.senderName != null) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(msg.senderName!, style: TextStyle(color: baseColor, fontSize: 10, fontWeight: FontWeight.bold))),
            SizedBox(
              width: 90, height: 90, 
              child: AnimatedBuilder(
                animation: _dangerPulseController,
                builder: (context, child) {
                  double borderAlpha = (msg.isPendingDeletion && !msg.isSaved) ? 0.5 + (_dangerPulseController.value * 0.5) : 0.6;
                  double blurRadius = (msg.isPendingDeletion && !msg.isSaved) ? 5 + (_dangerPulseController.value * 15) : 10;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 75, height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.6),
                          border: Border.all(color: isPaused ? Colors.orangeAccent : baseColor.withValues(alpha: borderAlpha), width: 1.0),
                          boxShadow: [BoxShadow(color: baseColor.withValues(alpha: 0.2), blurRadius: blurRadius, spreadRadius: 1)]
                        ),
                      ),
                      SizedBox(
                        width: 75, height: 75,
                        child: CircularProgressIndicator(
                          value: (msg.isPendingDeletion && !msg.isSaved) ? (msg.deletionSecondsRemaining / selfDestructSeconds) : (msg.playProgress > 0 ? msg.playProgress : 1.0), 
                          strokeWidth: 2, color: isPaused ? Colors.orangeAccent : baseColor, backgroundColor: Colors.transparent
                        ),
                      ),
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.8), border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(60, 60),
                              painter: CircularWaveformPainter(progress: msg.playProgress, isPlaying: msg.isPlaying, activeColor: isPaused ? Colors.orangeAccent : baseColor, inactiveColor: Colors.white24, time: DateTime.now().millisecondsSinceEpoch / 150),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 6), 
                                GestureDetector(
                                  onTap: () => _playMessage(msg),
                                  child: Icon(msg.isPlaying ? Icons.pause : Icons.play_arrow, size: 20, color: playIconColor),
                                ),
                                Text(_formatDuration(msg.durationInSeconds), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (msg.isPendingDeletion && !msg.isSaved)
                        Positioned(
                          top: -5, left: -5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_outline, color: Colors.redAccent, size: 10), const SizedBox(width: 2),
                                Text("${msg.deletionSecondsRemaining}s", style: const TextStyle(fontSize: 9, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        right: -5, top: 15,
                        child: GestureDetector(
                           onTap: () {
                             setState(() {
                               if (msg.playbackSpeed == 1.0) {
                                 msg.playbackSpeed = 1.5;
                               } else if (msg.playbackSpeed == 1.5) {
                                 msg.playbackSpeed = 2.0;
                               } else {
                                 msg.playbackSpeed = 1.0;
                               }
                             });
                           },
                           child: Container(
                             padding: const EdgeInsets.all(4),
                             decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueGrey.shade900, border: Border.all(color: Colors.white24)),
                             child: Text("${msg.playbackSpeed}x", style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white)),
                           ),
                        ),
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (!msg.isSaved) { 
                              setState(() { msg.isSaved = true; msg.isPendingDeletion = false; }); 
                            } else {
                              showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                  backgroundColor: Colors.grey.shade900,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text("Kaydı Sil", style: TextStyle(color: Colors.white, fontSize: 16)),
                                  content: const Text("Bu kayıtlı ses dosyasını tamamen silmek istiyor musunuz?", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
                                    TextButton(
                                      onPressed: () { 
                                        Navigator.pop(c); 
                                        setState(() { msg.isSaved = false; msg.isDeleted = true; }); 
                                      },
                                      child: const Text("Evet, Sil", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade900, child: Icon(msg.isSaved ? Icons.bookmark : Icons.bookmark_border, size: 10, color: msg.isSaved ? Colors.orangeAccent : (msg.isPendingDeletion ? Colors.redAccent : Colors.white70))),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.isRead && msg.readTime != null ? "${msg.time} • Dinlendi" : msg.time,
                    style: TextStyle(
                      fontSize: 11, 
                      color: msg.isRead ? Colors.cyanAccent.withValues(alpha: 0.8) : Colors.white54,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  if (msg.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      msg.isRead ? Icons.done_all : Icons.check,
                      size: 18,
                      color: msg.isRead ? Colors.blueAccent.shade200 : Colors.white54,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getUnreadCount(String contactName) {
    return _allMessages.where((msg) => msg.contactName == contactName && !msg.isMe && !msg.isRead).length;
  }

  Widget _buildOrbitalItem({required int index, required double centerX, required double centerY, required double radius, required double spacing, required Map<String, dynamic> data, required double globalAngle}) {
    bool isMatch = true;
    if (showSearchField && _searchController.text.isNotEmpty) {
      isMatch = data['name'].toLowerCase().contains(_searchController.text.toLowerCase());
    }
    bool isActive = (index == activeIndex) && !showSearchField;
    bool isLive = _activeLiveContacts.contains(data['name']); 
    bool anyLiveActive = _activeLiveContacts.isNotEmpty;
    bool isEmptySlot = data['isEmpty'] == true;

    double startAngle = -0.35 * math.pi; 
    double angle = startAngle - (index * spacing) + _scrollOffset;

    double baseOpacity = 1.0;
    if (angle > -0.1 * math.pi || angle < -1.8 * math.pi) baseOpacity = 0.0;
    if (showSearchField) {
       if (_searchController.text.isEmpty) {
         baseOpacity = 0.3; 
       } else {
         baseOpacity = isMatch ? 1.0 : 0.1;
       }
    }

    double fadeOpacity = 1.0;
    double fadeDistance = 40.0; 
    double tempX = centerX + radius * math.cos(angle);
    if (_isLeftHanded) tempX = centerX - radius * math.cos(angle);

    if (!_isLeftHanded) {
      double dist = (centerX + radius - 15) - tempX; 
      if (dist <= 0) {
        fadeOpacity = 0.0; 
      } else if (dist < fadeDistance) {
        fadeOpacity = dist / fadeDistance; 
      }
    } else {
      double dist = tempX - (centerX - radius + 15);
      if (dist <= 0) {
        fadeOpacity = 0.0; 
      } else if (dist < fadeDistance) {
        fadeOpacity = dist / fadeDistance; 
      }
    }

    double finalOpacity = baseOpacity * fadeOpacity;
    if (finalOpacity < 0.0) finalOpacity = 0.0;
    if (finalOpacity > 1.0) finalOpacity = 1.0;

    bool showLaser = false;
    Color laserColor = Colors.cyanAccent;
    if (anyLiveActive && isActive && !isEmptySlot) { 
      showLaser = true; 
      laserColor = Colors.redAccent; 
    } else if (!anyLiveActive && isActive && _showConnectionArrows && !isEmptySlot) { 
      showLaser = true; 
      laserColor = Colors.cyanAccent; 
    }

    double animVal = CurvedAnimation(
      parent: _entranceController, 
      curve: Interval(
        (0.2 + (index * 0.08)).clamp(0.0, 1.0),
        (0.8 + (index * 0.05)).clamp(0.0, 1.0),
        curve: Curves.elasticOut 
      )
    ).value;

    double currentRadius = 400.0 - (animVal * (400.0 - radius));
    double currentAngle = angle + ((1.0 - animVal) * math.pi); 
    
    double animXOffset = currentRadius * math.cos(currentAngle);
    double animYOffset = currentRadius * math.sin(currentAngle);
    if (_isLeftHanded) animXOffset = -animXOffset;
    double animGlobalAngle = math.atan2(animYOffset, animXOffset);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOutCubic,
      left: centerX + animXOffset - 50, 
      top: centerY + animYOffset - 50,
      child: GestureDetector(
        onTap: () {
          if (isEmptySlot) {
            _openContacts();
          } else if (showSearchField) {
            _onSearchedPersonSelected(data);
          } else {
            _onPersonSelected(index);
          }
        },
        onLongPress: () { 
          if (!showSearchField && !isEmptySlot) _requestLiveConnection(index); 
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: finalOpacity * animVal.clamp(0.0, 1.0), 
          child: SizedBox(
            width: 100, height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: CurvedTextPainter(
                    text: formatName(data['name']).toUpperCase(),
                    radius: 46, 
                    color: isEmptySlot ? Colors.white30 : ((showSearchField && isMatch && _searchController.text.isNotEmpty) ? Colors.orangeAccent : (isLive ? Colors.greenAccent : (isActive ? Colors.cyanAccent : Colors.white70))), 
                    statusColor: (data['isGroup'] == true || isEmptySlot) ? null : _getStatusColor(data['status']), 
                    baseAngle: animGlobalAngle, 
                  ),
                ),
                
                if (isEmptySlot)
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2), color: Colors.white.withValues(alpha: 0.05)),
                    child: const Icon(Icons.person_add_alt_1, color: Colors.white54, size: 24),
                  )
                else
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_currentlyPlayingQueueItemSender == data['name'])
                        ...List.generate(3, (i) => _buildIncomingWave(i)),
                        
                      _buildAvatar(data, isActive, isMatch, isLive),
                    ],
                  ),
                  
                if (showLaser) Positioned.fill(child: Transform.rotate(angle: animGlobalAngle + math.pi, child: Padding(padding: const EdgeInsets.only(left: 35.0), child: Align(alignment: Alignment.centerLeft, child: ConnectionArrows(color: laserColor))))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> item, bool isActive, bool isMatch, bool isLive) {
    bool isGroup = item['isGroup'] ?? false;
    Color ringColor;
    Color innerColor;
    if (isLive) { 
      ringColor = Colors.greenAccent; 
      innerColor = Colors.black.withValues(alpha: 0.9); 
    } else if (isActive) { 
      ringColor = Colors.cyanAccent; 
      innerColor = Colors.black.withValues(alpha: 0.9); 
    } else if (showSearchField && _searchController.text.isNotEmpty && isMatch) { 
      ringColor = Colors.orangeAccent; 
      innerColor = Colors.black.withValues(alpha: 0.9); 
    } else {
      ringColor = Colors.white30; 
      if (isGroup) {
        innerColor = Colors.deepPurpleAccent.withValues(alpha: 0.8);
      } else {
         if (item['status'] == UserStatus.busy) {
           innerColor = Colors.orangeAccent.shade400.withValues(alpha: 0.9);
         } else if (item['status'] == UserStatus.available) {
           innerColor = Colors.blueGrey.shade600;
         } else {
           innerColor = Colors.grey.shade800;
         }
      }
    }

    int unreadCount = _getUnreadCount(item['name']); 

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60, height: 60, 
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: (isActive || isLive) ? 5.0 : 4.0),
            color: Colors.transparent, 
            boxShadow: [ if (isActive || isLive) BoxShadow(color: ringColor.withValues(alpha: 0.5), blurRadius: 10) ],
          ),
          padding: const EdgeInsets.all(7.0), 
          child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: innerColor), child: Center(child: isGroup ? const Icon(Icons.groups, size: 22, color: Colors.white) : Text(getInitials(item['name']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)))),
        ),
        
        if (unreadCount > 0)
          Positioned(
            top: -2, right: -2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.redAccent, shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 6)]
              ),
              child: Text(
                unreadCount > 9 ? "9+" : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

// 🟢 İŞTE YENİ 5 SANİYELİK ZAMANLAYICILI "HAYALET OK (GHOST ARROW)" WIDGET'IMIZ 🟢
class GhostHandToggle extends StatefulWidget {
  final bool isLeftHanded;
  final VoidCallback onToggle;

  const GhostHandToggle({Key? key, required this.isLeftHanded, required this.onToggle}) : super(key: key);

  @override
  State<GhostHandToggle> createState() => _GhostHandToggleState();
}

class _GhostHandToggleState extends State<GhostHandToggle> {
  bool _isInteracting = false;
  bool _isInitiallyVisible = true;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    _startFadeTimer(); // Widget ekrana çizilir çizilmez 5 saniyelik zamanlayıcı başlar
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isInitiallyVisible = false; // 5 saniye sonra hayalet moduna geç
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dokunma (Tap) ve Sürükleme (Pan) kontrolleri aktif
      behavior: HitTestBehavior.opaque, // Görünmez (0.01 opacity) olsa bile dokunmaları yakalar!
      onPanDown: (_) {
        setState(() => _isInteracting = true);
        _fadeTimer?.cancel(); // Dokunulduğu an zamanlayıcıyı durdur
      },
      onPanCancel: () {
        setState(() => _isInteracting = false);
        _startFadeTimer();
      },
      onPanEnd: (_) {
        setState(() => _isInteracting = false);
        _startFadeTimer();
      },
      onTapDown: (_) {
        setState(() => _isInteracting = true);
        _fadeTimer?.cancel();
      },
      onTapUp: (_) {
        setState(() => _isInteracting = false);
        widget.onToggle(); // Tıklanınca el değiştirme fonksiyonunu tetikle
        setState(() => _isInitiallyVisible = true); // Geçiş yapıldıktan sonra 5 saniyeliğine tekrar görünür olsun
        _startFadeTimer();
      },
      onTapCancel: () {
        setState(() => _isInteracting = false);
        _startFadeTimer();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500), // Yumuşak bir kayboluş animasyonu
        // 🟢 İŞTE ZEKİ GÖRÜNÜRLÜK: 
        // Eğer parmak üzerindeyse -> Parlak (0.6)
        // Eğer ilk açılışsa ve 5 sn geçmediyse -> Silik Hayalet (0.10)
        // Eğer 5 sn geçip kimse dokunmadıysa -> Tamamen Kaybolur (0.01) [0.0 yapmadık çünkü dokunma algılayıcısını bozabilir]
        opacity: _isInteracting ? 0.6 : (_isInitiallyVisible ? 0.10 : 0.01), 
        child: Container(
          width: 30, // 🟢 Genişlik 30 piksele düşürüldü
          height: 300, 
          color: Colors.transparent, 
          child: CustomPaint(
            painter: _GhostArrowPainter(isLeftHanded: widget.isLeftHanded),
          ),
        ),
      ),
    );
  }
}

// 🟢 150 DERECELİK 30 PİKSEL GENİŞLİĞİNDE BEYAZ OK TASARIMCISI 🟢
class _GhostArrowPainter extends CustomPainter {
  final bool isLeftHanded;

  _GhostArrowPainter({required this.isLeftHanded});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0 // Göz yormaması ve daha zarif durması için inceltildi
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Genişlik 30'a düştüğü için start ve apex noktaları da otomatik daralmış oldu
    double startX = isLeftHanded ? 0.0 : size.width;
    double apexX = isLeftHanded ? size.width : 0.0;
    double midY = size.height / 2;

    path.moveTo(startX, midY - 110); 
    path.lineTo(apexX, midY); 
    path.lineTo(startX, midY + 110);

    // Hafif neon efekti
    canvas.drawPath(path, paint..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3));
    canvas.drawPath(path, paint..maskFilter = null);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}