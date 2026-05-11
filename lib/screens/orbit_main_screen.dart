// ignore_for_file: prefer_final_fields, curly_braces_in_flow_control_structures, deprecated_member_use, use_build_context_synchronously, unnecessary_non_null_assertion

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; 
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:collection';
import 'package:record/record.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:image_picker/image_picker.dart';
import 'package:audio_session/audio_session.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/audio_message.dart';
import '../widgets/contacts_bottom_sheet.dart';
import '../widgets/settings_bottom_sheet.dart';

import '../widgets/orbit_chat_list.dart';
import '../widgets/ghost_hand_toggle.dart';
import '../widgets/orbit_search_field.dart';
import '../widgets/orbit_contact_node.dart';
import '../widgets/orbit_ptt_area.dart';
import '../widgets/orbit_sub_item_node.dart';

import 'package:orbit_ptt/services/socket_service.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory;
import '../services/notification_service.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/subscription_service.dart';

enum UserStatus { available, busy, away, offline }
enum SubOrbitType { none, effects, emojis, nudge, background }

class OrbitMainScreen extends StatefulWidget {
  const OrbitMainScreen({super.key});
  @override
  State<OrbitMainScreen> createState() => _OrbitMainScreenState();
}

class _OrbitMainScreenState extends State<OrbitMainScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final SocketService _socketService = SocketService();
  String? _currentUserPhone;
  bool _isSocketStarted = false;
  AppLifecycleState _appState = AppLifecycleState.resumed;

  String? _pendingCallerId;
  String? _pendingCallerName;
  String? _whoIsSpeaking;
  bool _isCallDialogOpen = false;
  bool _isHandlingPendingCall = false;

  late List<Map<String, dynamic>> allContacts;
  late List<Map<String, dynamic>> originalContacts;
  Map<String, String> _localContactsMap = {};

  String _userName = "User";
  String? _userAvatarPath;
  Color _myCustomColor = Colors.blueGrey.shade800;
  String _myStatus = "available";
  bool _useSpeaker = true;
  String _liveAudioPermission = "Herkes";

  bool _notificationsEnabled = true;
  bool _messageNotificationsEnabled = true;
  bool _callNotificationsEnabled = true;
  bool _ratchetEnabled = true;

  String _callRingtone = "";

  bool isSearching = false;
  bool showSearchField = false;

  bool _isMenuExpanded = false;
  bool _isActiveMenuExpanded = false;
  bool _isArchiveMode = false;

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
  
  Color? _globalBgColor;
  Map<String, Color> _contactBackgrounds = {};

  double _scrollOffset = 0.0;
  double _subOrbitScrollOffset = 0.0;
  
  late AnimationController _scrollPhysicsController;
  late AnimationController _subScrollPhysicsController;

  double _subRatchetAccumulator = 0.0;
  int _lastSubRatchetTime = 0;
  double _lastSubDragAngle = 0.0;
  bool _isValidSubOrbitDrag = false;

  int activeIndex = -1;
  bool _showConnectionArrows = false;
  Timer? _arrowsTimer;
  Timer? _outgoingCallTimer;
  Timer? _incomingRingTimer;
  Timer? _vibrationTimer;
  Timer? _ghostSpeakerTimer; 

  int _interactionNodeIndex = -1;
  double _interactionNodeOffset = 0.0;

  bool _isValidOrbitDrag = false;
  double _lastDragAngle = 0.0;
  double _ratchetAccumulator = 0.0;
  int _lastRatchetTime = 0;

  final Set<String> _activeLiveContacts = {};
  final Map<String, Timer> _liveTimers = {};
  final Set<String> _mutedContacts = {};
  final Set<String> _blockedContacts = {};

  bool isWaitingForLiveApproval = false;
  int _liveDuration = 0;
  Timer? _liveDurationTimer;
  bool _isCurrentlyPlayingOrRecording = false;
  String? _currentlyPlayingQueueItemSender;
  bool _showOnlyUnread = false;

  late AnimationController _pulseController;
  late AnimationController _breatheController;
  late AnimationController _entranceController;
  late AnimationController _hapticAcceptPulseController;
  late AnimationController _hapticRejectPulseController;
  late AnimationController _hapticTerminatePulseController;

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
  double _dragVerticalOffset = 0.0;
  bool _isCancelled = false;
  
  String? _lockedDragAxis; 

  Timer? _micDebounceTimer;
  DateTime? _recordingStartTime;

  final List<AudioMessage> _allMessages = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  AudioMessage? _replyingToMessage;

  bool _isIncomingCallActive = false;
  double _pttSlideOffset = 0.0;

  final Queue<AudioMessage> _liveAudioQueue = Queue<AudioMessage>();
  bool _isProcessingLiveQueue = false;
  Timer? _notificationDebounceTimer;

  SubOrbitType _activeSubOrbit = SubOrbitType.none;

  final ScrollController _activeMenuScrollController = ScrollController();
  final ScrollController _mainMenuScrollController = ScrollController();

  String _currentLang = 'tr';

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdPlaying = false; 

  bool _isActionInProgress = false;

  bool _isPremiumUser = false;
  int _dailyPushCount = 0;
  int _dailyPushLimit = 5;
  String _lastPushDate = "";

  // 🛠️ YENİ: Emoji veya Nudge'ları Veritabanına (Geçmişe) Eklemek İçin Merkezi Fonksiyon
  void _logInteraction({required String contactIdentifier, required bool isMe, String? senderName, String? emoji, bool isNudge = false}) {
    final now = DateTime.now();
    String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final newMsg = AudioMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(1000).toString(),
      contactName: contactIdentifier,
      senderName: senderName ?? (isMe ? _userName : _localContactsMap[contactIdentifier] ?? contactIdentifier),
      isMe: isMe,
      durationInSeconds: 0,
      time: timeStr,
      isRead: true, // Reaksiyonlar direkt okundu sayılır
      isLiveMessage: false,
      emoji: emoji,
      isNudge: isNudge,
    );
    
    if (mounted) {
      setState(() {
        _allMessages.insert(0, newMsg);
        _sortOrbitContactsByRecent();
        
        // Ses mesajlarında olduğu gibi bunların da zamanla silinmesini başlat
        if (selfDestructSeconds > 0) {
            _startDeletionCountdown(newMsg);
        }
      });
    }
  }

  void _runSafeAction(VoidCallback action) {
    if (_isActionInProgress) return; 
    
    setState(() => _isActionInProgress = true);
    action();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isActionInProgress = false);
    });
  }

  String _t(String key) {
    const Map<String, Map<String, String>> dict = {
      'invite': {'tr': 'Davet Et', 'en': 'Invite'},
      'search': {'tr': 'Arama', 'en': 'Search'},
      'saved': {'tr': 'Kayıtlılar', 'en': 'Saved'},
      'add_contact': {'tr': 'Kişi Ekle', 'en': 'Add Contact'},
      'settings': {'tr': 'Ayarlar', 'en': 'Settings'},
      'nudge_grp': {'tr': 'Grubu Dürt', 'en': 'Nudge Group'},
      'send_react': {'tr': 'Tepki Gönder', 'en': 'Send Reaction'},
      'voice_fx': {'tr': 'Ses Efekti', 'en': 'Voice Effect'},
      
      'bg_color': {'tr': 'Arka Plan', 'en': 'Background'},
      'choose_bg': {'tr': 'ARKA PLAN SEÇ', 'en': 'CHOOSE BACKGROUND'},

      'roger': {'tr': 'Anlaşıldı', 'en': 'Got it'},
      'filter': {'tr': 'Okunmamışları Filtrele', 'en': 'Filter Unread'},
      'unmute': {'tr': 'Sesi Aç', 'en': 'Unmute'},
      'mute': {'tr': 'Sessize Al', 'en': 'Mute'},
      'unblock': {'tr': 'Engeli Kaldır', 'en': 'Unblock'},
      'block': {'tr': 'Engelle', 'en': 'Block'},
      'rm_orbit': {'tr': 'Yörüngeden Çıkar', 'en': 'Remove from Orbit'},
      'disconnect': {'tr': 'Bağlantıyı Kes', 'en': 'Disconnect'},
      'cancel': {'tr': 'İptal Et', 'en': 'Cancel'},
      'offline': {'tr': 'Çevrimdışı', 'en': 'Offline'},
      'online': {'tr': 'Çevrimiçi', 'en': 'Online'},
      'is_spk': {'tr': 'konuşuyor...', 'en': 'is speaking...'},
      'replying': {'tr': 'Yanıtlanıyor: ', 'en': 'Replying: '},
      
      'choose_fx': {'tr': 'SES EFEKTİ SEÇ', 'en': 'CHOOSE VOICE EFFECT'},
      'send_re_title': {'tr': 'EMOJİ SEÇ', 'en': 'CHOOSE EMOJI'},
      
      'nudge_grp_title': {'tr': 'GRUBUNU DÜRT', 'en': 'NUDGE GROUP'},
      'nudge_all': {'tr': 'TÜMÜNÜ\nDÜRT', 'en': 'NUDGE\nALL'},
      'unknown': {'tr': 'Bilinmeyen', 'en': 'Unknown'},
      'is_busy': {'tr': 'şu an meşgul.', 'en': 'is busy right now.'},
      'calling': {'tr': 'aranıyor...', 'en': 'calling...'},
      'call_not_ans': {'tr': 'Davet isteği yanıtlanmadı.', 'en': 'Call request not answered.'},
      'call_canc': {'tr': 'Arama iptal edildi.', 'en': 'Call cancelled.'},
      'roger_sent': {'tr': 'Anlaşıldı gönderildi ✅', 'en': 'Message acknowledged ✅'},
      'all_nudged': {'tr': 'Tüm grup dürtüldü!', 'en': 'Whole group nudged!'},
      'sent_react': {'tr': 'sana bir tepki gönderdi.', 'en': 'sent you a reaction.'},
      'attention': {'tr': 'DİKKAT! telsize çağırıyor!', 'en': 'ATTENTION! calling you to voice chat!'},
      'nudge_alert': {'tr': 'seni dürttü! 👉', 'en': 'nudged you! 👉'},
      'new_msg': {'tr': 'yeni mesaj gönderdi.', 'en': 'sent a new message.'},
      'not_answering': {'tr': 'cevap vermiyor.', 'en': 'is not answering.'},
      'reject_busy': {'tr': 'çağrıyı reddetti veya meşgul.', 'en': 'rejected the call or is busy.'},
      'disconnected': {'tr': 'bağlantıyı kopardı.', 'en': 'disconnected.'},
      'accepted_call': {'tr': 'çağrısını kabul etti!', 'en': 'accepted the call!'},
      'missed_call': {'tr': 'Cevapsız çağrı:', 'en': 'Missed call:'},
      'del_warn': {'tr': 'adlı kişiyi yörüngeden çıkarmak istediğine emin misin?', 'en': 'are you sure you want to remove this user from your orbit?'},
      'del_btn': {'tr': 'SİL', 'en': 'DELETE'},
      'removed': {'tr': 'orbitten çıkartıldı.', 'en': 'removed from orbit.'},
      'Normal': {'tr': 'Normal', 'en': 'Normal'},
      'Askeri': {'tr': 'Megafon', 'en': 'Megaphone'},
      'Megafon': {'tr': 'Stadyum', 'en': 'Stadium'},
      'Anonim': {'tr': 'Anonim', 'en': 'Anonymous'},
      'Helyum': {'tr': 'Helyum', 'en': 'Helium'},
      'Robot': {'tr': 'Robot', 'en': 'Robot'},
      'Uzaylı': {'tr': 'Uzaylı', 'en': 'Alien'},
      'Kilitli Özellik': {'tr': 'Kilitli Özellik', 'en': 'Locked Feature'},
      'Canavar': {'tr': 'Canavar', 'en': 'Monster'},
      'Radyo': {'tr': 'Radyo', 'en': 'Radio'},
      'search_orbit': {'tr': 'Orbitte Ara...', 'en': 'Search Orbit...'},
    };
    return dict[key]?[_currentLang] ?? dict[key]?['en'] ?? key;
  }

  String _selectedVoiceEffect = "Normal";
  final List<Map<String, dynamic>> _voiceEffects = [
    {"name": "Normal", "icon": Icons.mic, "color": Colors.white},
    {"name": "Megafon", "icon": Icons.campaign, "color": Colors.amber},
    {"name": "Stadyum", "icon": Icons.surround_sound, "color": Colors.greenAccent},
    {"name": "Anonim", "icon": Icons.person_off, "color": Colors.purpleAccent},
    {"name": "Helyum", "icon": Icons.child_care, "color": Colors.pinkAccent},
    {"name": "Robot", "icon": Icons.smart_toy, "color": Colors.blueAccent},
    {"name": "Uzaylı", "icon": Icons.flutter_dash, "color": Colors.tealAccent},
    {"name": "Kilitli Özellik", "icon": Icons.waves, "color": Colors.indigoAccent},
    {"name": "Canavar", "icon": Icons.coronavirus, "color": Colors.redAccent},
    {"name": "Radyo", "icon": Icons.speaker, "color": Colors.orangeAccent},
  ];

  final List<Map<String, dynamic>> _bgColorsList = [
    {"name": "Cihazdan Fotoğraf Seç", "color": Colors.white, "bgValue": null, "icon": Icons.add_photo_alternate, "isGallery": true}, 
    {"name": "Varsayılan (Kaldır)", "color": Colors.transparent, "bgValue": null, "icon": Icons.layers_clear},
    {"name": "Klasik Siyah", "color": Colors.white30, "bgValue": Colors.black, "icon": Icons.wallpaper},
    {"name": "Saf Gri", "color": Colors.grey, "bgValue": Colors.grey.shade800, "icon": Icons.wallpaper},
    {"name": "Pastel Mavi", "color": const Color(0xFF90B4CE), "bgValue": const Color(0xFF90B4CE), "icon": Icons.water_drop},
    {"name": "Pastel Yeşil", "color": const Color(0xFFA3C9A8), "bgValue": const Color(0xFFA3C9A8), "icon": Icons.forest},
    {"name": "Pastel Kırmızı", "color": const Color(0xFFE5989B), "bgValue": const Color(0xFFE5989B), "icon": Icons.local_fire_department},
    {"name": "Pastel Mor", "color": const Color(0xFFB5A6C4), "bgValue": const Color(0xFFB5A6C4), "icon": Icons.nightlight_round},
    {"name": "Pastel Turuncu", "color": const Color(0xFFF3B562), "bgValue": const Color(0xFFF3B562), "icon": Icons.brightness_high},
  ];

  final List<FlyingEmoji> _flyingEmojis = [];
  List<String> _recentEmojis = ['🔥', '👏', '😂', '🫡'];
  final List<String> _allEmojis = [
    '😂', '🤣', '😊', '🥳', '😎', '🤩', '🎈',
    '🫡', '👍', '👏', '💯', '✅', '🤝', '💪', '👑',
    '🔥', '🚀', '⚡', '🎉', '🤯', '🎯', '💎', '✨',
    '❤️', '🧡', '😍', '🥺', '🫂', '🕊️',
    '👀', '😱', '🧐', '🤨', '🤔', '😶',
    '👎', '😤', '🤬', '❌', '🚫', '🙄', '💀',
    '😢', '😭', '💔', '🥶', '😴', '🚑'
  ];

  bool _checkBatteryLimitSync() {
    if (_isPremiumUser) return true; 

    String today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (_lastPushDate != today) {
      _dailyPushCount = 0;
      _dailyPushLimit = 5;
      _lastPushDate = today;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('last_push_date', today);
        prefs.setInt('daily_push_count', 0);
        prefs.setInt('daily_push_limit', 5);
      });
    }

    if (_dailyPushCount < _dailyPushLimit) {
      _dailyPushCount++;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('daily_push_count', _dailyPushCount);
      });
      return true; 
    } else {
      if (_dailyPushLimit == 5) {
        _showBatteryDialog(
          title: "Telsiz Bataryası Bitti",
          content: "Konuşmaya kaldığın yerden devam etmek istiyorsan, kısa bir reklam izle ve anında 30 ses gönderim hakkı kazan.",
          newLimit: 35,
          successMessage: "Telsiz Şarj Edildi! +30 Hak eklendi. ⚡"
        );
      } else if (_dailyPushLimit == 35) {
        _showBatteryDialog(
          title: "Batarya Kritik Seviyede",
          content: "Günlük kullanım limitine yaklaşıyorsun. Devam etmek istersen bir reklam daha izle ve 10 ses gönderim hakkı daha kazan.",
          newLimit: 45,
          successMessage: "Yedek Batarya Devrede! +10 Hak eklendi. 🔋"
        );
      } else {
        _showBatteryPaywallDialog();
      }
      return false; 
    }
  }

  void _showBatteryDialog({required String title, required String content, required int newLimit, required String successMessage}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blueGrey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent)),
        title: Row(
          children: [
            const Icon(Icons.battery_alert, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white30)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Reklam İzle', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              _showRewardedAdGeneric(() async {
                final p = await SharedPreferences.getInstance();
                setState(() { _dailyPushLimit = newLimit; });
                await p.setInt('daily_push_limit', newLimit);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Colors.greenAccent));
                }
              });
            },
          )
        ],
      ),
    );
  }

  void _showBatteryPaywallDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blueGrey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.amber)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.amber),
            SizedBox(width: 10),
            Expanded(child: Text("Günlük Limit Doldu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        content: const Text("Tüm ücretsiz ses gönderim haklarını kullandın. Sınırsızca konuşmak, tüm ses efektlerini kullanmak ve kesintisiz iletişim için Orbit Plus'a geç.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white30)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            icon: const Icon(Icons.stars, size: 18),
            label: const Text('Plus\'a Geç', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              SubscriptionService.showPaywall(context);
            },
          )
        ],
      ),
    );
  }

  Future<void> _handleNudgeWithLimit(Map<String, dynamic> item) async {
    bool isPremium = await SubscriptionService.isPremium();
    final prefs = await SharedPreferences.getInstance();
    
    if (isPremium) {
      String phone = item['phone'];
      SocketService().sendNudge(phone, _currentUserPhone!, _userName);
      _logInteraction(contactIdentifier: item['name'], isMe: true, isNudge: true); // 🟢 LOG
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} dürtüldü! ⚡")));
    } else {
      int nudgesLeft = prefs.getInt('nudge_limit') ?? 5;
      if (nudgesLeft > 0) {
        String phone = item['phone'];
        SocketService().sendNudge(phone, _currentUserPhone!, _userName);
        _logInteraction(contactIdentifier: item['name'], isMe: true, isNudge: true); // 🟢 LOG
        await prefs.setInt('nudge_limit', nudgesLeft - 1);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} dürtüldü! (Kalan hak: ${nudgesLeft - 1})")));
      } else {
        _showLimitDialog("Dürtme Hakkınız Bitti", "Günlük dürtme limitine ulaştınız. Orbit Plus ile sınırsız dürtme yapabilir veya bir reklam izleyerek +5 hak daha kazanabilirsiniz.", true, () async {
          final p = await SharedPreferences.getInstance();
          await p.setInt('nudge_limit', 5);
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("5 yeni dürtme hakkı eklendi!")));
        });
      }
    }
    setState(() => _activeSubOrbit = SubOrbitType.none);
  }

  Future<void> _handleDoubleTapNudge(int index) async {
    if (activeIndex == -1 || allContacts[index]['isEmpty'] == true) return;
    
    Map<String, dynamic> item = allContacts[index];
    bool isPremium = await SubscriptionService.isPremium();
    final prefs = await SharedPreferences.getInstance();
    
    void sendToTarget(String phone) {
      SocketService().sendNudge(phone, _currentUserPhone!, _userName);
    }

    Future<void> executeNudge() async {
      String contactIdentifier = item['isGroup'] == true ? item['name'] : item['phone'];
      if (item['isGroup'] == true) {
        List<dynamic> members = item['members'] ?? [];
        for (var m in members) {
          sendToTarget(m.toString());
        }
      } else {
        sendToTarget(item['phone']);
      }
      
      _logInteraction(contactIdentifier: contactIdentifier, isMe: true, isNudge: true); // 🟢 LOG
      
      if (hapticEnabled) { 
        try { 
          HapticFeedback.heavyImpact(); 
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact(); 
        } catch (_) {} 
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} dürtüldü! ⚡"), backgroundColor: Colors.orange));
    }

    if (isPremium) {
      await executeNudge();
    } else {
      int nudgesLeft = prefs.getInt('nudge_limit') ?? 5;
      if (nudgesLeft > 0) {
        await executeNudge();
        await prefs.setInt('nudge_limit', nudgesLeft - 1);
      } else {
        _showLimitDialog("Dürtme Hakkınız Bitti", "Günlük dürtme limitine ulaştınız. Orbit Plus ile sınırsız dürtme yapabilir veya reklam izleyerek +5 hak kazanabilirsiniz.", true, () async {
          final p = await SharedPreferences.getInstance();
          await p.setInt('nudge_limit', 5);
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("5 yeni dürtme hakkı eklendi!")));
        });
      }
    }
  }

  Future<bool> _checkRemovalLimit() async {
    bool isPremium = await SubscriptionService.isPremium();
    if (isPremium) return true;

    final prefs = await SharedPreferences.getInstance();
    int removalCount = prefs.getInt('orbit_removal_count') ?? 0;

    if (removalCount >= 5) {
      _showLimitDialog("Değişim Limiti Doldu", "Ücretsiz sürümde yörüngeden en fazla 5 kişi çıkarabilirsiniz. Sınırları kaldırmak için Orbit Plus'a geçin veya reklam izleyerek +3 hak kazanın.", true, () async {
        final p = await SharedPreferences.getInstance();
        await p.setInt('orbit_removal_count', 2);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("+3 yeni silme/değişim hakkı eklendi!")));
      });
      return false; 
    }
    await prefs.setInt('orbit_removal_count', removalCount + 1);
    return true;
  }

  Future<bool> _checkAdditionLimit() async {
    bool isPremium = await SubscriptionService.isPremium();
    int currentContactCount = allContacts.where((c) => c['isEmpty'] != true).length;

    if (currentContactCount >= 12 && !isPremium) {
      _showLimitDialog("Yörünge Doldu", "Yörüngene en fazla 12 kişi veya grup ekleyebilirsin. Kapasiteyi tamamen kaldırmak için Orbit Plus'a geç!", false, null);
      return false;
    }
    return true;
  }

  void _showLimitDialog(String title, String content, bool showAdButton, VoidCallback? onAdWatched) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Row(children: [const Icon(Icons.stars, color: Colors.amber), const SizedBox(width: 10), Text(title, style: const TextStyle(color: Colors.white))]),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
          if (showAdButton)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              onPressed: () {
                Navigator.pop(ctx);
                _showRewardedAdGeneric(onAdWatched);
              },
              child: const Text("Reklam İzle", style: TextStyle(color: Colors.black)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(ctx);
              SubscriptionService.showPaywall(context);
            },
            child: const Text("Plus'a Geç", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRewardedAdGeneric(VoidCallback? onReward) {
    if (_isAdLoaded && _rewardedAd != null) {
      
      setState(() { _isAdPlaying = true; }); 

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          setState(() { _isAdPlaying = false; }); 
          _processLiveQueue(); 
          _isAdLoaded = false;
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('🛑 Reklam gösterilirken kilitlendi: $error');
          ad.dispose();
          setState(() { _isAdPlaying = false; }); 
          _processLiveQueue(); 
          _isAdLoaded = false;
          _loadRewardedAd();
          if (onReward != null) onReward();
        },
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          if (onReward != null) onReward();
        });
      });
    } else {
      if (onReward != null) onReward();
      _loadRewardedAd(); 
    }
  }

  List<AudioMessage> get _activeMessages {
    if (activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) {
      return [];
    }
    String currentContactIdentifier = allContacts[activeIndex]['isGroup'] == true
        ? allContacts[activeIndex]['name']
        : allContacts[activeIndex]['phone'];

    var messages = _allMessages.where((msg) => msg.contactName == currentContactIdentifier).toList();

    if (_isArchiveMode) {
      messages = messages.where((msg) => msg.isSaved && !msg.isDeleted).toList();
    } else if (_showOnlyUnread) {
      messages = messages.where((msg) => !msg.isMe && !msg.isRead).toList();
    }
    return messages;
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _triggerReaction(String emoji, {String? senderName}) {
    if (!mounted) {
      return;
    }
    final double randomOffset = (math.Random().nextDouble() * 120) - 60;
    final newEmoji = FlyingEmoji(
      id: DateTime.now().microsecondsSinceEpoch.toString() + math.Random().nextInt(1000).toString(),
      emoji: emoji,
      startX: (MediaQuery.of(context).size.width / 2) + randomOffset,
      senderName: senderName,
    );

    setState(() {
      _flyingEmojis.add(newEmoji);
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _flyingEmojis.removeWhere((e) => e.id == newEmoji.id);
        });
      }
    });
  }

  void _handleEmojiSelection(String emoji) {
    _triggerReaction(emoji);
    if (hapticEnabled) {
      try { HapticFeedback.selectionClick(); } catch (_) {}
    }

    if (activeIndex != -1) {
      bool isGroupNode = allContacts[activeIndex]['isGroup'] == true;
      String contactIdentifier = isGroupNode ? allContacts[activeIndex]['name'] : allContacts[activeIndex]['phone'];
      
      if (isGroupNode) {
        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
        for (var m in members) {
          SocketService().sendReaction(m.toString(), _currentUserPhone!, emoji);
        }
      } else {
        SocketService().sendReaction(contactIdentifier, _currentUserPhone!, emoji);
      }
      
      _logInteraction(contactIdentifier: contactIdentifier, isMe: true, emoji: emoji); // 🟢 LOG
    }

    setState(() {
      _recentEmojis.remove(emoji);
      _recentEmojis.insert(0, emoji);
      if (_recentEmojis.length > 4) {
        _recentEmojis = _recentEmojis.sublist(0, 4);
      }
    });
  }

  void _handleBackgroundSelection(Color? color) async {
    if (activeIndex != -1) {
      String identifier = allContacts[activeIndex]['isGroup'] == true ? allContacts[activeIndex]['name'] : allContacts[activeIndex]['phone'];
      
      setState(() {
        if (color == null) {
          _contactBackgrounds.remove(identifier);
        } else {
          _contactBackgrounds[identifier] = color;
        }
        _activeSubOrbit = SubOrbitType.none;
      });
      
      final prefs = await SharedPreferences.getInstance();
      if (color == null) {
        await prefs.remove('bg_$identifier');
      } else {
        await prefs.setInt('bg_$identifier', color.value);
      }
      if (hapticEnabled) { try { HapticFeedback.lightImpact(); } catch (_) {} }
    }
  }

  List<Map<String, dynamic>> _getSubOrbitItems() {
    if (_activeSubOrbit == SubOrbitType.effects) {
      return _voiceEffects.map((fx) => {
        "name": fx["name"],
        "translatedName": _t(fx["name"]),
        "icon": fx["icon"],
        "color": fx["color"]
      }).toList();
    }

    if (_activeSubOrbit == SubOrbitType.background) {
      return _bgColorsList;
    }

    if (_activeSubOrbit == SubOrbitType.emojis) {
      List<String> sortedEmojis = List.from(_recentEmojis);
      for (var e in _allEmojis) {
        if (!sortedEmojis.contains(e)) {
          sortedEmojis.add(e);
        }
      }
      return sortedEmojis.map((e) => {"name": "Tepki", "emoji": e, "color": Colors.pinkAccent}).toList();
    }

    if (_activeSubOrbit == SubOrbitType.nudge && activeIndex != -1) {
      bool isGroup = allContacts[activeIndex]['isGroup'] == true;
      if (isGroup) {
        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
        return members.map((m) {
          String phone = m.toString();
          String name = _localContactsMap[phone] ?? phone;
          return {"name": name, "icon": Icons.touch_app, "color": Colors.orangeAccent, "phone": phone};
        }).toList();
      }
    }
    return [];
  }

  void _openSubOrbit(SubOrbitType type) {
    if (hapticEnabled) {
      try { HapticFeedback.mediumImpact(); } catch (_) {}
    }
    setState(() {
      _activeSubOrbit = type;
      _subOrbitScrollOffset = 0.0;
      if (showSearchField) {
        _closeSearchMode();
      }
    });
  }

  void _onSubItemTapped(Map<String, dynamic> item) async {
    if (hapticEnabled) {
      try { HapticFeedback.selectionClick(); } catch (_) {}
    }

    if (item['isGallery'] == true) {
        String? path = await _pickImage(ImageSource.gallery, isBackground: true);
        if (path != null) {
            setState(() {
                _activeSubOrbit = SubOrbitType.none;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Arka plan kaydedildi!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
        return;
    }

    if (_activeSubOrbit == SubOrbitType.effects) {
      _handleEffectSelection(item['name']);
    } else if (_activeSubOrbit == SubOrbitType.background) {
      _handleBackgroundSelection(item['bgValue']); 
    } else if (_activeSubOrbit == SubOrbitType.emojis) {
      _handleEmojiSelection(item['emoji']);
    } else if (_activeSubOrbit == SubOrbitType.nudge) {
      _handleNudgeWithLimit(item); 
    }

    if (_activeSubOrbit != SubOrbitType.nudge && _activeSubOrbit != SubOrbitType.background) {
      setState(() => _activeSubOrbit = SubOrbitType.none);
    }
  }

  void _sortOrbitContactsByRecent() {
    if (!mounted) {
      return;
    }
    DateTime getLatestInteraction(Map<String, dynamic> contact) {
      if (contact['isEmpty'] == true) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      String identifier = contact['isGroup'] == true ? contact['name'] : contact['phone'];
      var messages = _allMessages.where((m) => m.contactName == identifier).toList();
      if (messages.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      int? timestamp = int.tryParse(messages.first.id.replaceAll(RegExp(r'[^0-9]'), ''));
      return DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0);
    }
    originalContacts.sort((a, b) {
      if (a['isEmpty'] == true && b['isEmpty'] != true) return 1;
      if (b['isEmpty'] == true && a['isEmpty'] != true) return -1;
      if (a['isEmpty'] == true && b['isEmpty'] == true) return 0;
      DateTime timeA = getLatestInteraction(a);
      DateTime timeB = getLatestInteraction(b);
      if (timeA.millisecondsSinceEpoch == 0 && timeB.millisecondsSinceEpoch == 0) {
        return (a['name'] ?? "").compareTo(b['name'] ?? "");
      }
      return timeB.compareTo(timeA);
    });
    setState(() {
      if (!isSearching && !_isArchiveMode) {
        allContacts = List.from(originalContacts);
      }
    });
  }

  void _startLiveTimerIfNeeded() {
    if (_liveDurationTimer != null && _liveDurationTimer!.isActive) {
      return;
    }
    _liveDuration = 0;
    _liveDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _activeLiveContacts.isNotEmpty) {
        setState(() => _liveDuration++);
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => _liveDuration = 0);
        }
      }
    });
  }

  Future<void> _processLiveQueue() async {
    if (_isProcessingLiveQueue || _liveAudioQueue.isEmpty || _isAdPlaying) {
      return;
    }
    _isProcessingLiveQueue = true;
    final msg = _liveAudioQueue.removeFirst();
    if (!mounted) {
      return;
    }
    setState(() {
      _isCurrentlyPlayingOrRecording = true;
      _currentlyPlayingQueueItemSender = msg.senderName;
    });
    _incomingAmplitudeTimer?.cancel();
    _incomingAmplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _incomingAudioLevel.value = 0.2 + (math.Random().nextDouble() * 0.8);
      }
    });
    try {
      final session = await AudioSession.instance;
      await session.setActive(true).catchError((e) { return false; });
      await _historyPlayer.setVolume(1.0);
      if (msg.audioFilePath != null && File(msg.audioFilePath!).existsSync()) {
        await _historyPlayer.setSource(DeviceFileSource(msg.audioFilePath!));
        await _historyPlayer.resume();
        await _historyPlayer.onPlayerComplete.first;
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint("Kuyruk Hatası: $e");
    }
    _incomingAmplitudeTimer?.cancel();
    if (mounted) {
      _incomingAudioLevel.value = 0.0;
    }
    if (mounted) {
      setState(() {
        _isCurrentlyPlayingOrRecording = false;
        _currentlyPlayingQueueItemSender = null;
      });
    }
    _isProcessingLiveQueue = false;
    if (_liveAudioQueue.isNotEmpty) {
      _processLiveQueue();
    }
  }

  void _handleFCMMessage(RemoteMessage message) {
    String? callerId;
    String? displayName;
    if (message.data.containsKey('callerId')) {
      callerId = message.data['callerId']?.toString().replaceAll(RegExp(r'[^\d+]'), '');
    } else if (message.notification?.body != null) {
      String body = message.notification!.body!;
      if (body.contains("canlı bağlantı istiyor") || body.contains("live connection")) {
        displayName = body.replaceAll("📞 ", "").replaceAll(" canlı bağlantı istiyor...", "").replaceAll(" is requesting live connection...", "").trim();
        var contact = originalContacts.firstWhere((c) => c['name'] == displayName, orElse: () => <String, dynamic>{});
        if (contact.isNotEmpty && contact.containsKey('phone')) {
          callerId = contact['phone'].replaceAll(RegExp(r'[^\d+]'), '');
        } else {
          callerId = displayName.replaceAll(RegExp(r'[^\d+]'), '');
        }
      }
    }
    if (callerId != null) {
      _pendingCallerId = callerId;
      _pendingCallerName = displayName ?? callerId;
    }
  }

  void _loadRewardedAd() {
    String adUnitId = 'ca-app-pub-9581158996653882/9399937355';

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          debugPrint('🎯 Ödüllü Reklam Mermiye Sürüldü!');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          debugPrint('🛑 Reklam Yüklenemedi: $error');
        },
      ),
    );
  }

  // 🛠️ YENİ: FİZİKSEL SES KISMA TUŞU (DONANIMSAL PTT) ENTEGRASYONU
  bool _handleKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown || event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
      if (event is KeyDownEvent) {
        if (!isRecording && !_isIncomingCallActive && activeIndex != -1 && allContacts[activeIndex]['isEmpty'] != true) {
          _startRecording();
        }
      } else if (event is KeyUpEvent) {
        if (isRecording) {
          _stopRecording();
        }
      }
      return true; 
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent); // 🟢 Donanım tuşu dinleyicisi
    
    _loadRewardedAd();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);
    allContacts = List.generate(7, (index) => {"name": "Davet Et", "isEmpty": true});
    originalContacts = List.from(allContacts);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _breatheController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _hapticAcceptPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _hapticRejectPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _hapticTerminatePulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _scrollPhysicsController = AnimationController.unbounded(vsync: this);
    _scrollPhysicsController.addListener(() {
      setState(() {
        _scrollOffset = _scrollPhysicsController.value;
      });
    });

    _subScrollPhysicsController = AnimationController.unbounded(vsync: this);
    _subScrollPhysicsController.addListener(() {
      setState(() {
        double delta = (_subScrollPhysicsController.value - _lastPhysicsSubValue).abs();
        _lastPhysicsSubValue = _subScrollPhysicsController.value;
        _subOrbitScrollOffset = _subScrollPhysicsController.value;

        if (_ratchetEnabled && delta > 0.0) {
          _subRatchetAccumulator += delta;
          double threshold = Platform.isAndroid ? 0.08 : 0.06;
          int debounceTime = Platform.isAndroid ? 60 : 40;
          if (_subRatchetAccumulator >= threshold) {
            _subRatchetAccumulator -= threshold;
            int now = DateTime.now().millisecondsSinceEpoch;
            if (now - _lastSubRatchetTime > debounceTime) {
              _lastSubRatchetTime = now;
              if (hapticEnabled) {
                try {
                  if (Platform.isAndroid) HapticFeedback.vibrate();
                  else HapticFeedback.selectionClick();
                } catch (_) {}
              }
            }
          }
        }
      });
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleFCMMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleFCMMessage(message);
      if (_appState == AppLifecycleState.resumed && _pendingCallerId != null) {
        _handlePendingCallRequest(_pendingCallerId!, _pendingCallerName ?? _pendingCallerId!);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) { _secureStarter(); });

    AudioSession.instance.then((session) async {
      await session.configure(const AudioSessionConfiguration.speech());
      
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          debugPrint("📞 DİKKAT: NATIVE TELEFON ARAMASI GELDİ!");
          if (isRecording) { _stopRecording(); }
          if (mounted) {
            setState(() {
              _whoIsSpeaking = null;
              _isCurrentlyPlayingOrRecording = false;
            });
          }
        }
      });
    }).catchError((e) {
      debugPrint("AudioSession yapılandırma hatası: $e");
    });

    _historyPlayer.onPositionChanged.listen((Duration p) {
      if (mounted && _currentlyPlayingMessage != null && !_isProcessingLiveQueue) {
        int totalMs = _currentlyPlayingMessage!.durationInSeconds * 1000;
        if (totalMs > 0) {
          setState(() { _currentlyPlayingMessage!.playProgress = p.inMilliseconds / totalMs; });
        }
      }
    });

    _historyPlayer.onPlayerComplete.listen((_) async {
      if (mounted && _currentlyPlayingMessage != null && !_isProcessingLiveQueue) {
        setState(() {
          _currentlyPlayingMessage!.isPlaying = false;
          _currentlyPlayingMessage!.playProgress = 0.0;
          _isCurrentlyPlayingOrRecording = false;
          if (!_currentlyPlayingMessage!.isMe && !_currentlyPlayingMessage!.isSaved && !_currentlyPlayingMessage!.isDeleted && !_currentlyPlayingMessage!.isPendingDeletion) {
            _startDeletionCountdown(_currentlyPlayingMessage!);
          }
          _currentlyPlayingMessage = null;
        });
        final session = await AudioSession.instance;
        session.setActive(false).catchError((_) => false);
      }
    });

    _setupSocketListeners();
  }

  double _lastPhysicsSubValue = 0.0;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentLang = prefs.getString('app_lang') ?? 'tr';
      });
    }
  }

  void _resetLiveTimeoutForContact(String contactPhone) {
    _liveTimers[contactPhone]?.cancel();
    _liveTimers[contactPhone] = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        if (isRecording || _whoIsSpeaking == contactPhone || _isCurrentlyPlayingOrRecording || _liveAudioQueue.isNotEmpty) {
          _resetLiveTimeoutForContact(contactPhone);
          return;
        }
        
        _incomingAmplitudeTimer?.cancel();
        _incomingAudioLevel.value = 0.0;
        
        setState(() {
          _activeLiveContacts.remove(contactPhone);
          _liveTimers.remove(contactPhone);
          if (_activeLiveContacts.isEmpty) {
            _liveDurationTimer?.cancel();
            _liveDuration = 0;
            _whoIsSpeaking = null;
            _isCurrentlyPlayingOrRecording = false; 
          }
        });
        
        String name = _localContactsMap[contactPhone] ?? contactPhone;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              const Icon(Icons.signal_wifi_bad, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text("$name ile iletişim koptu."),
            ],
          ),
          backgroundColor: Colors.orange.shade900,
          duration: const Duration(seconds: 3),
        ));
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

  void _setupSocketListeners() {
    SocketService().onAudioRead = (messageId, readerId, readerName, isLiveRead) {
      if (mounted) {
        final idx = _allMessages.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          setState(() {
            final msg = _allMessages[idx];
            String currentType = isLiveRead ? "live" : "history";
            String safeName = readerName ?? _localContactsMap[readerId] ?? readerId;
            msg.listenedBy[safeName] = currentType;
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

    SocketService().onUserSpeaking = (callerId, isSpeaking) {
      if (mounted) {
        setState(() {
          if (isSpeaking) {
            _whoIsSpeaking = callerId;
            _resetLiveTimeoutForContact(callerId);
            
            _ghostSpeakerTimer?.cancel();
            _ghostSpeakerTimer = Timer(const Duration(seconds: 45), () {
               if (mounted && _whoIsSpeaking == callerId) {
                  setState(() => _whoIsSpeaking = null);
               }
            });
          } else {
            _whoIsSpeaking = null;
            _ghostSpeakerTimer?.cancel();
          }
        });
      }
    };

    SocketService().onCallMissed = (callerId) {
      if (mounted) {
        _incomingRingTimer?.cancel();
        _vibrationTimer?.cancel();
        setState(() {
          _pendingCallerId = null;
          _pendingCallerName = null;
          _isHandlingPendingCall = false;
          _isIncomingCallActive = false;
          _whoIsSpeaking = null; 
        });
        _closeCallDialogSafely();
        try { NotificationService().cancelCallNotification(); } catch (_) {}
        String displayName = _localContactsMap[callerId] ?? callerId;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$displayName ${_t('call_canc').toLowerCase()}"), backgroundColor: Colors.orange.shade800));
      }
    };

    SocketService().onCallReceived = (callerId) async {
      if (mounted) {
        if (_blockedContacts.contains(callerId)) {
          SocketService().rejectCall(callerId);
          return;
        }
        if (_isCallDialogOpen || _isHandlingPendingCall) {
          return;
        }
        int idx = allContacts.indexWhere((c) {
          if (c['isEmpty'] == true) return false;
          String existingPhone = (c['phone'] ?? '').toString().replaceAll('+90', '').replaceAll(RegExp(r'[^\d]'), '');
          String incomingPhone = callerId.replaceAll('+90', '').replaceAll(RegExp(r'[^\d]'), '');
          return existingPhone == incomingPhone;
        });

        if (idx == -1) {
          setState(() {
            String displayName = _localContactsMap[callerId] ?? callerId;
            int emptyIdx = allContacts.lastIndexWhere((c) => c['isEmpty'] == true);
            if (emptyIdx != -1) {
              allContacts[emptyIdx] = {"name": displayName, "phone": callerId, "isGroup": false, "status": UserStatus.available};
            } else {
              allContacts.insert(0, {"name": displayName, "phone": callerId, "isGroup": false, "status": UserStatus.available});
            }
          });
        }
        String displayName = _localContactsMap[callerId] ?? callerId;
        _pendingCallerId = callerId;
        _pendingCallerName = displayName;
        _incomingRingTimer?.cancel();
        _vibrationTimer?.cancel();
        _incomingRingTimer = Timer(const Duration(seconds: 30), () {
          if (mounted) {
            _closeCallDialogSafely();
            SocketService().rejectCall(callerId);
            try { NotificationService().cancelCallNotification(); } catch (_) {}
            _vibrationTimer?.cancel();
            setState(() {
              _pendingCallerId = null;
              _pendingCallerName = null;
              _isHandlingPendingCall = false;
              _isIncomingCallActive = false;
              _whoIsSpeaking = null; 
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_t('missed_call')} $displayName"), backgroundColor: Colors.orange.shade800));
          }
        });
        if (_appState != AppLifecycleState.resumed) {
          if (_notificationsEnabled && _callNotificationsEnabled) {
            try { NotificationService().showCallNotification(callerId, displayName, soundName: _callRingtone.isNotEmpty ? _callRingtone : null); } catch (_) {}
          }
        } else {
          _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
            try { if (hapticEnabled) HapticFeedback.vibrate(); } catch (_) {}
          });
          setState(() { _isIncomingCallActive = true; });
        }
      }
    };

    SocketService().onCallAccepted = (targetId) async {
      _outgoingCallTimer?.cancel();
      try { NotificationService().cancelCallNotification(); } catch (_) {}
      AudioSession.instance.then((session) { session.setActive(true).catchError((_) => false); });
      if (!mounted) {
        return;
      }
      setState(() {
        _activeLiveContacts.add(targetId);
        _resetLiveTimeoutForContact(targetId);
        if (activeIndex != -1 && allContacts[activeIndex]['isGroup'] == true) {
          String memberName = _localContactsMap[targetId] ?? targetId;
          String initials = _getInitials(memberName);
          if (!_activeLiveGroupMembers.contains(initials)) {
            _activeLiveGroupMembers.add(initials);
          }
        }
        isWaitingForLiveApproval = false;
        _isIncomingCallActive = false;
        _startLiveTimerIfNeeded();
      });
      String displayName = _localContactsMap[targetId] ?? targetId;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$displayName ${_t('accepted_call')}"), backgroundColor: Colors.green.shade800));
    };

    SocketService().onCallRejected = (targetId) {
      if (mounted) {
        _outgoingCallTimer?.cancel();
        try { NotificationService().cancelCallNotification(); } catch (_) {}
        bool wasLive = _activeLiveContacts.contains(targetId);
        setState(() {
          _activeLiveContacts.remove(targetId);
          _liveTimers[targetId]?.cancel();
          _liveTimers.remove(targetId);
          String memberName = _localContactsMap[targetId] ?? targetId;
          String initials = _getInitials(memberName);
          _activeLiveGroupMembers.remove(initials);
          if (_activeLiveContacts.isEmpty) {
            isWaitingForLiveApproval = false;
            _isIncomingCallActive = false;
            _liveDurationTimer?.cancel();
            _liveDuration = 0;
            _whoIsSpeaking = null; 
          }
        });
        String displayName = _localContactsMap[targetId] ?? targetId;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (wasLive) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.phone_disabled, color: Colors.white, size: 18), const SizedBox(width: 8), Text("$displayName ${_t('disconnected')}")]), backgroundColor: Colors.orange.shade800));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$displayName ${_t('reject_busy')}"), backgroundColor: Colors.red.shade800));
        }
      }
    };

    SocketService().onCallTimeout = (targetId) {
      if (mounted) {
        setState(() {
          _activeLiveContacts.remove(targetId);
          if (_activeLiveContacts.isEmpty) {
            isWaitingForLiveApproval = false;
            _isIncomingCallActive = false;
            _whoIsSpeaking = null; 
          }
        });
        try { NotificationService().cancelCallNotification(); } catch (_) {}
        String displayName = _localContactsMap[targetId] ?? targetId;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$displayName ${_t('not_answering')}"), backgroundColor: Colors.orange.shade800));
      }
    };

    SocketService().onAudioPlayed = (senderId, audioUrl, messageId) async {
      if (!mounted) {
        return;
      }
      if (_blockedContacts.contains(senderId)) {
        return;
      }
      final now = DateTime.now();
      String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      bool isLive = _activeLiveContacts.contains(senderId);
      String displayName = _localContactsMap[senderId] ?? senderId;
      String messageContactName = senderId;
      if (activeIndex != -1 && allContacts[activeIndex]['isGroup'] == true) {
        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
        if (members.contains(senderId)) {
          messageContactName = allContacts[activeIndex]['name'];
        }
      } else {
        int idx = allContacts.indexWhere((c) {
          if (c['isEmpty'] == true) return false;
          String existingPhone = (c['phone'] ?? '').toString().replaceAll('+90', '').replaceAll(RegExp(r'[^\d]'), '');
          String incomingPhone = senderId.replaceAll('+90', '').replaceAll(RegExp(r'[^\d]'), '');
          return existingPhone == incomingPhone;
        });

        if (idx == -1) {
          int emptyIdx = allContacts.lastIndexWhere((c) => c['isEmpty'] == true);
          if (emptyIdx != -1) {
            allContacts[emptyIdx] = {"name": displayName, "phone": senderId, "isGroup": false, "status": UserStatus.available};
          }
        }
      }
      String localFilePath = audioUrl;
      if (audioUrl.startsWith('http')) {
        try {
          final directory = await getTemporaryDirectory();
          localFilePath = '${directory.path}/orbit_live_$messageId.m4a';
          File file = File(localFilePath);
          if (!file.existsSync()) {
            final fileResponse = await http.get(Uri.parse(audioUrl));
            await file.writeAsBytes(fileResponse.bodyBytes);
          }
        } catch (e) {
          debugPrint("🚨 İNDİRME HATASI onAudioPlayed: $e");
          return;
        }
      }
      if (!mounted) {
        return;
      }
      final newMsg = AudioMessage(id: messageId, contactName: messageContactName, senderName: displayName, isMe: false, durationInSeconds: 0, time: timeStr, isRead: isLive, isLiveMessage: isLive, audioFilePath: localFilePath);
      setState(() {
        _allMessages.insert(0, newMsg);
        _sortOrbitContactsByRecent();
        if (isLive) {
          _liveAudioQueue.add(newMsg);
          _processLiveQueue();
          SocketService().sendAudioRead(messageContactName, messageId, true, _userName);
        }
      });
      if (!isLive) {
        if (!_mutedContacts.contains(messageContactName)) {
          if (hapticEnabled) { try { HapticFeedback.lightImpact(); } catch (_) {} }
          if (_notificationsEnabled && _messageNotificationsEnabled) {
            _notificationDebounceTimer?.cancel();
            _notificationDebounceTimer = Timer(const Duration(seconds: 1), () { try { NotificationService().showMessageNotification(displayName); } catch (_) {} });
          }
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.voicemail, color: Colors.redAccent), const SizedBox(width: 10), Text("$displayName ${_t('new_msg')}", style: const TextStyle(color: Colors.white))]), backgroundColor: Colors.grey.shade900, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)));
        }
      }
    };

    SocketService().onNudgeReceived = (senderId, senderName) async {
      if (!mounted) return;
      if (_blockedContacts.contains(senderId)) return;
      
      bool isGroup = activeIndex != -1 && allContacts[activeIndex]['isGroup'] == true;
      String messageContactName = isGroup ? allContacts[activeIndex]['name'] : senderId; 
      
      _logInteraction(contactIdentifier: messageContactName, isMe: false, senderName: senderName, isNudge: true); // 🟢 LOG
      
      if (_appState != AppLifecycleState.resumed) {
        if (_notificationsEnabled) {
          try { 
            NotificationService().showMessageNotification("$senderName seni dürttü! 👉"); 
          } catch (_) {}
        }
      }

      for (int i = 0; i < 5; i++) {
        if (hapticEnabled) { try { HapticFeedback.vibrate(); } catch (_) {} }
        await Future.delayed(const Duration(milliseconds: 400));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String txt = _t('nudge_alert');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.touch_app, color: Colors.amber), 
                const SizedBox(width: 10), 
                Expanded(
                  child: Text(
                    "$senderName $txt", 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  )
                )
              ]
            ), 
            backgroundColor: Colors.deepOrange.shade900, 
            behavior: SnackBarBehavior.floating
          )
        );
      }
    };

    SocketService().onRogerThatReceived = (senderId, senderName) async {
      if (!mounted) {
        return;
      }
      if (_blockedContacts.contains(senderId)) {
        return;
      }

      String sName = senderName;
      if (sName.isEmpty) {
        sName = _localContactsMap[senderId] ?? senderId;
      }

      bool isGroup = activeIndex != -1 && allContacts[activeIndex]['isGroup'] == true;
      String messageContactName = isGroup ? allContacts[activeIndex]['name'] : senderId;

      _logInteraction(contactIdentifier: messageContactName, isMe: false, senderName: sName, emoji: "👍"); // 🟢 LOG
      _triggerReaction("👍", senderName: isGroup ? sName : null);

      if (hapticEnabled) {
        try { HapticFeedback.selectionClick(); } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 150));
        try { HapticFeedback.selectionClick(); } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.thumb_up, color: Colors.greenAccent), const SizedBox(width: 10), Text("$sName: ${_t('roger')}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]), backgroundColor: Colors.green.shade900, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
      }
    };

    SocketService().onReactionReceived = (senderId, emoji) {
      if (!mounted) {
        return;
      }
      if (_blockedContacts.contains(senderId)) {
        return;
      }

      String senderName = _localContactsMap[senderId] ?? senderId;
      bool isGroup = activeIndex != -1 && allContacts[activeIndex]['isGroup'] == true;
      String messageContactName = isGroup ? allContacts[activeIndex]['name'] : senderId;

      _logInteraction(contactIdentifier: messageContactName, isMe: false, senderName: senderName, emoji: emoji); // 🟢 LOG
      _triggerReaction(emoji, senderName: isGroup ? senderName : null);

      if (hapticEnabled) { try { HapticFeedback.lightImpact(); } catch (_) {} }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text("$senderName ${_t('sent_react')}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
              ]
          ),
          backgroundColor: Colors.pink.shade900,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2)
      ));
    };
  }

  void _handlePendingCallRequest(String callerId, String callerName) {
    if (_isCallDialogOpen || _isHandlingPendingCall) {
      return;
    }
    _isHandlingPendingCall = true;
    try { NotificationService().cancelCallNotification(); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 500), () {
      _isHandlingPendingCall = false;
      if (mounted && !_isCallDialogOpen) {
        _vibrationTimer?.cancel();
        _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (timer) { if (hapticEnabled) { try { HapticFeedback.vibrate(); } catch (_) {} } });
        setState(() { _isIncomingCallActive = true; _pendingCallerId = callerId; _pendingCallerName = callerName; });
      }
    });
  }

  void _closeCallDialogSafely() {
    if (_isCallDialogOpen) {
      if (Navigator.of(context, rootNavigator: true).canPop()) { Navigator.of(context, rootNavigator: true).pop(); }
      _isCallDialogOpen = false;
    }
  }

  Future<void> _loadOrbitFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cached = prefs.getString('cached_orbit');
    if (cached != null && cached.isNotEmpty) {
      try {
        List<dynamic> decoded = jsonDecode(cached);
        List<Map<String, dynamic>> loaded = [];
        for (var item in decoded) {
          String name = item['name'] ?? '';
          if (name.toLowerCase().contains('gizli ajan') || name.toLowerCase().contains('test')) continue;
          
          UserStatus s = UserStatus.offline;
          if (item['status'] == 'UserStatus.available') s = UserStatus.available;
          else if (item['status'] == 'UserStatus.busy') s = UserStatus.busy;
          else if (item['status'] == 'UserStatus.away') s = UserStatus.away;

          loaded.add({
            'name': name,
            'phone': item['phone'],
            'isGroup': item['isGroup'],
            'uid': item['uid'],
            'status': s,
            'isEmpty': item['isEmpty'],
          });
        }
        if (loaded.isNotEmpty && mounted) {
          setState(() {
            originalContacts = loaded;
            allContacts = List.from(originalContacts);
          });
        }
      } catch (e) { debugPrint("Cache error: $e"); }
    }
  }

  Future<void> _saveOrbitToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(originalContacts.map((c) => {
      'name': c['name'],
      'phone': c['phone'],
      'isGroup': c['isGroup'],
      'uid': c['uid'],
      'status': c['status'].toString(),
      'isEmpty': c['isEmpty'],
    }).toList());
    await prefs.setString('cached_orbit', jsonStr);
  }

  Future<void> _secureStarter() async {
    await _loadLanguage();
    if (mounted) {
      _entranceController.forward();
      if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) {} }
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      await _initializeData();
      try { await NotificationService().checkForLaunchNotification(); } catch (_) {}
      if (_pendingCallerId != null) {
        _handlePendingCallRequest(_pendingCallerId!, _pendingCallerName ?? _pendingCallerId!);
      }
    }
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    _isPremiumUser = await SubscriptionService.isPremium();

    String today = DateTime.now().toIso8601String().substring(0, 10);
    _lastPushDate = prefs.getString('last_push_date') ?? "";
    
    if (_lastPushDate != today) {
      _dailyPushCount = 0;
      _dailyPushLimit = 5;
      await prefs.setString('last_push_date', today);
      await prefs.setInt('daily_push_count', 0);
      await prefs.setInt('daily_push_limit', 5);
    } else {
      _dailyPushCount = prefs.getInt('daily_push_count') ?? 0;
      _dailyPushLimit = prefs.getInt('daily_push_limit') ?? 5;
    }

    String? rawPhonePref = prefs.getString('user_phone');
    if (rawPhonePref != null && rawPhonePref.isNotEmpty) {
      String normalized = rawPhonePref.replaceAll(RegExp(r'[^\d+]'), '');
      if (normalized.startsWith('00')) {
        normalized = '+${normalized.substring(2)}';
      } else if (normalized.startsWith('0')) {
        normalized = '${_getDeviceCountryCode()}${normalized.substring(1)}';
      } else if (!normalized.startsWith('+')) {
        normalized = '${_getDeviceCountryCode()}$normalized';
      }
      _currentUserPhone = normalized;
    }

    String? savedToken = prefs.getString('auth_token');

    _callRingtone = prefs.getString('call_ringtone') ?? "";
    _ratchetEnabled = prefs.getBool('ratchet_enabled') ?? true;

    int? globalColorVal = prefs.getInt('global_bg_color');
    if (globalColorVal != null) {
      _globalBgColor = Color(globalColorVal);
    }

    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('bg_')) {
        String phone = key.substring(3);
        int? colorVal = prefs.getInt(key);
        if (colorVal != null) {
          _contactBackgrounds[phone] = Color(colorVal);
        }
      }
    }

    if (_currentUserPhone != null && _currentUserPhone!.isNotEmpty && savedToken != null) {
      await _socketService.initConnection(_currentUserPhone!, savedToken);
      _isSocketStarted = true;

      try {
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          debugPrint("📲 BİLDİRİM ADRESİ ALINDI: $fcmToken");
          _socketService.socket.emit('register', {
            'userId': _currentUserPhone,
            'fcmToken': fcmToken
          });
        }
      } catch (e) {
        debugPrint("🚨 FCM Token Alınamadı: $e");
      }

      _socketService.onUserStatusChanged = (userId, status) {
        if (!mounted) return;
        setState(() {
          for (var contact in originalContacts) {
            if (contact['phone'] == userId || contact['uid'] == userId) {
              if (status == 'online' || status == 'available') {
                contact['status'] = UserStatus.available;
              } else if (status == 'offline') {
                contact['status'] = UserStatus.offline;
              } else if (status == 'busy') {
                contact['status'] = UserStatus.busy;
              }
            }
          }
          if (!isSearching) {
            allContacts = List.from(originalContacts);
          }
        });
      };
    } else {
      debugPrint("⚠️ Telsiz başlatılamadı: Telefon veya Token eksik!");
    }
    
    await _loadOrbitFromCache(); 
    _fetchUsersFromOurAPI(); 
    _fetchPendingMessages();

    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        try {
          await ph.Permission.microphone.request().timeout(const Duration(seconds: 5));
        } catch (e) { debugPrint("Mikrofon izni hatası: $e"); }

        try {
          await _syncLocalContacts().timeout(const Duration(seconds: 5));
        } catch (e) { debugPrint("Rehber izni hatası: $e"); }
      }
    });
  }

  Future<void> _fetchUsersFromOurAPI() async {
    if (!mounted) {
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse('https://orbit-talk.com/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
        List<Map<String, dynamic>> fetchedContacts = [];
        
        for (var u in users) {
          String phone = u['phone']?.toString().replaceAll(RegExp(r'[^\d+]'), '') ?? "";
          if (_currentUserPhone != null && phone == _currentUserPhone) {
            continue;
          }
          
          String rawName = u['name']?.toString() ?? "";
          if (rawName.toLowerCase().contains('gizli ajan') || rawName.toLowerCase().contains('test')) {
            continue; 
          }

          String contactName = _localContactsMap.containsKey(phone) ? _localContactsMap[phone]! : (rawName != "" && rawName != "Bilinmeyen Kullanıcı" ? rawName : phone);
          String rawStatus = u['status']?.toString().toLowerCase() ?? 'offline';
          UserStatus statusEnum = UserStatus.offline;
          
          if (rawStatus == 'online' || rawStatus == 'available') {
            statusEnum = UserStatus.available;
          } else if (rawStatus == 'busy') {
            statusEnum = UserStatus.busy;
          } else if (rawStatus == 'away') {
            statusEnum = UserStatus.away;
          }

          fetchedContacts.add({
            "name": contactName, 
            "isGroup": false, 
            "status": statusEnum, 
            "uid": u['_id'], 
            "phone": phone,
            "isEmpty": false 
          });
        }
        
        var seenPhones = <String>{};
        var uniqueContacts = <Map<String, dynamic>>[];
        
        for (var c in fetchedContacts) {
          if (!seenPhones.contains(c['phone'])) {
            seenPhones.add(c['phone']);
            uniqueContacts.add(c);
          }
        }
        fetchedContacts = uniqueContacts;

        List<Map<String, dynamic>> mergedContacts = [];
        for (var localContact in originalContacts) {
            if (localContact['isEmpty'] == true) continue;
            
            var apiMatchIndex = fetchedContacts.indexWhere((apiContact) => apiContact['phone'] == localContact['phone']);
            
            if (apiMatchIndex != -1) {
                localContact['status'] = fetchedContacts[apiMatchIndex]['status'];
                fetchedContacts.removeAt(apiMatchIndex); 
            }
            mergedContacts.add(localContact);
        }
        
        for (int i = mergedContacts.length; i < 7; i++) {
          mergedContacts.add({"name": "Davet Et", "isEmpty": true});
        }
        
        if (mounted) {
          setState(() {
            originalContacts = mergedContacts;
            if (isSearching) {
              _handleSearch(_searchController.text);
            } else {
              allContacts = List.from(originalContacts);
            }
          });
          _sortOrbitContactsByRecent();
          _saveOrbitToCache(); 
        }
      } else {
        debugPrint("🛑 Rehber çekme hatası: Sunucu reddetti. Kod: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("💥 Rehber çekme Exception: $e");
    }
  }

  Future<void> _fetchPendingMessages() async {
    if (_currentUserPhone == null) {
      return;
    }
    try {
      final response = await http.get(Uri.parse('https://orbit-talk.com/api/messages/pending/$_currentUserPhone'));
      if (response.statusCode == 200) {
        List<dynamic> pendingMsgs = jsonDecode(response.body);
        if (pendingMsgs.isEmpty) {
          return;
        }
        for (var msg in pendingMsgs) {
          String senderPhone = msg['senderPhone'];
          String messageId = msg['messageId'];
          String audioUrl = msg['tempFileUrl'] ?? "";
          if (audioUrl.isEmpty) {
            continue;
          }
          String timeStr = "";
          if (msg['createdAt'] != null) {
            DateTime createdAt = DateTime.parse(msg['createdAt']).toLocal();
            timeStr = "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";
          } else {
            final now = DateTime.now();
            timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          }
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/orbit_pending_$messageId.m4a';
          File file = File(filePath);
          if (!file.existsSync()) {
            final fileResponse = await http.get(Uri.parse(audioUrl));
            await file.writeAsBytes(fileResponse.bodyBytes);
          }
          String displayName = _localContactsMap[senderPhone] ?? senderPhone;
          String messageContactName = senderPhone;
          int idx = allContacts.indexWhere((c) => c['phone'] == senderPhone && c['isGroup'] != true);
          if (idx == -1) {
            int emptyIdx = allContacts.lastIndexWhere((c) => c['isEmpty'] == true);
            if (emptyIdx != -1) {
              allContacts[emptyIdx] = {"name": displayName, "phone": senderPhone, "isGroup": false, "status": UserStatus.offline};
            }
          }
          final newMsg = AudioMessage(id: messageId, contactName: messageContactName, senderName: displayName, isMe: false, durationInSeconds: 0, time: timeStr, isRead: false, isLiveMessage: false, audioFilePath: filePath);
          if (mounted) {
            setState(() {
              if (!_allMessages.any((m) => m.id == messageId)) {
                _allMessages.insert(0, newMsg);
              }
            });
          }
        }
        if (mounted) {
          _sortOrbitContactsByRecent();
          if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) {} }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("📦 ${pendingMsgs.length} yeni mesaj indirildi."), backgroundColor: Colors.green.shade800));
        }
      }
    } catch (e) {
      debugPrint("🚨 Bekleyen Mesajlar Çekilemedi: $e");
    }
  }

  String _getDeviceCountryCode() {
    try {
      String localeName = Platform.localeName.replaceAll('-', '_');
      if (localeName.contains('_')) {
        String countryIso = localeName.split('_').last.toUpperCase();
        switch (countryIso) {
          case 'US': case 'CA': return '+1'; case 'GB': return '+44'; case 'DE': return '+49';
          case 'FR': return '+33'; case 'IT': return '+39'; case 'ES': return '+34';
          case 'NL': return '+31'; case 'RU': case 'KZ': return '+7'; case 'AZ': return '+994';
          default: return '+90';
        }
      }
    } catch (e) {
      // ignore
    }
    return '+90';
  }

  Future<void> _syncLocalContacts() async {
    var status = await ph.Permission.contacts.status;
    
    if (!status.isGranted) {
      status = await ph.Permission.contacts.request();
    }

    if (status.isGranted) {
      final contacts = await FlutterContacts.getAll(properties: {ContactProperty.name, ContactProperty.phone});
      Map<String, String> tempMap = {};
      String defaultCountryCode = _getDeviceCountryCode();
      for (var c in contacts) {
        if (c.phones.isNotEmpty) {
          String rawPhone = c.phones.first.number;
          String normalized = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');

          if (normalized.startsWith('00')) {
            normalized = '+${normalized.substring(2)}';
          } else if (normalized.startsWith('0')) {
            normalized = '$defaultCountryCode${normalized.substring(1)}';
          } else if (!normalized.startsWith('+')) {
            normalized = '$defaultCountryCode$normalized';
          }

          final dName = c.displayName;
          String name = (dName != null && dName.isNotEmpty) ? dName : _t('unknown');
          tempMap[normalized] = name;
        }
      }
      if (mounted) {
        setState(() {
          _localContactsMap = tempMap;
          for (var contact in originalContacts) {
            if (contact['isEmpty'] != true && _localContactsMap.containsKey(contact['phone'])) {
              contact['name'] = _localContactsMap[contact['phone']];
            }
          }
          allContacts = List.from(originalContacts);
        });
      }
    } else {
      debugPrint("⚠️ Komutanım, kullanıcı rehber iznini reddetti.");
    }
  }

  
  String _getInitials(String name) {
    if (name.trim().isEmpty) {
      return "";
    }
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) {
      return "";
    }
    if (parts.length == 1) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return "${parts[0][0]}.${parts.last[0]}".toUpperCase();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent); // 🟢 Temizlik
    _pulseController.dispose();
    _breatheController.dispose();
    _entranceController.dispose();
    _vibrationTimer?.cancel();
    _ghostSpeakerTimer?.cancel();
    _historyPlayer.dispose();
    _audioRecorder.dispose();
    _searchController.dispose();
    _hapticAcceptPulseController.dispose();
    _hapticRejectPulseController.dispose();
    _hapticTerminatePulseController.dispose();
    _notificationDebounceTimer?.cancel();
    _activeMenuScrollController.dispose();
    _mainMenuScrollController.dispose();
    
    _scrollPhysicsController.dispose();
    _subScrollPhysicsController.dispose();
    
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _appState = state;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (isRecording) {
        _stopRecording();
      }
      if (mounted) {
        setState(() {
          _whoIsSpeaking = null; 
        });
      }
    }

    if (state == AppLifecycleState.resumed) {
      try {
        if (_isSocketStarted && SocketService().socket.disconnected) {
          SocketService().socket.connect();
        }
      } catch (_) { /* ignore */ }

      if (_pendingCallerId != null) {
        _handlePendingCallRequest(_pendingCallerId!, _pendingCallerName ?? _pendingCallerId!);
      }
      if (_activeLiveContacts.isNotEmpty) {
        if (!_pulseController.isAnimating) {
          _pulseController.repeat();
        }
        if (!_breatheController.isAnimating) {
          _breatheController.repeat(reverse: true);
        }
      }
      _fetchPendingMessages();
    }
  }

  Future<String?> _pickImage(ImageSource source, {bool isBackground = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isBackground) {
            _customBackgroundImagePath = image.path;
          } else {
            _userAvatarPath = image.path;
          }
        });
        return image.path;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  void _removeAvatar() {
    setState(() { _userAvatarPath = null; });
  }

  void _startDeletionCountdown(AudioMessage msg) {
    if (msg.isPendingDeletion || selfDestructSeconds == -1) {
      return;
    }
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
        setState(() { msg.isDeleted = true; msg.isPendingDeletion = false; });
      }
    });
  }

  Future<void> _playMessage(AudioMessage msg) async {
    if (msg.isPlaying) {
      await _historyPlayer.stop();
      final session = await AudioSession.instance;
      session.setActive(false).catchError((_) => false);
      setState(() { msg.isPlaying = false; _isCurrentlyPlayingOrRecording = false; _currentlyPlayingMessage = null; });
      return;
    }
    if (_isCurrentlyPlayingOrRecording || _isProcessingLiveQueue) {
      return;
    }

    if (msg.audioFilePath == null || !File(msg.audioFilePath!).existsSync()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Audio file not found"), backgroundColor: Colors.orange));
      }
      return;
    }
    setState(() {
      _isCurrentlyPlayingOrRecording = true; msg.isPlaying = true; _currentlyPlayingMessage = msg;
      if (!msg.isMe && !msg.isRead) {
        msg.isRead = true;
        final now = DateTime.now();
        msg.readTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        SocketService().sendAudioRead(msg.contactName, msg.id, false, _userName);
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
      debugPrint("🚨 Çalma Hatası (_playMessage): $e");
      await _historyPlayer.stop();
      final session = await AudioSession.instance;
      session.setActive(false).catchError((_) => false);
      setState(() { msg.isPlaying = false; _isCurrentlyPlayingOrRecording = false; _currentlyPlayingMessage = null; });
    }
  }

  void _startRecording({bool isChunkContinue = false}) {
    if (!isChunkContinue) {
      if (!_checkBatteryLimitSync()) return; 
    }
    
    if ((isRecording && !isChunkContinue) || activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) {
      return;
    }
    if (hapticEnabled && !isChunkContinue) {
      try { HapticFeedback.mediumImpact(); } catch (_) { /* ignore */ }
    }
    _recordTimer?.cancel(); _amplitudeTimer?.cancel(); _micDebounceTimer?.cancel();

    if (!isChunkContinue) {
      setState(() { 
        isRecording = true; 
        _isCurrentlyPlayingOrRecording = true; 
        _recordDuration = 0; 
        _dragOffset = 0.0; 
        _dragVerticalOffset = 0.0; 
        _isCancelled = false; 
        _lockedDragAxis = null; 
      });
      if (_activeLiveContacts.isNotEmpty) {
        for (var target in _activeLiveContacts) {
          SocketService().sendSpeakingState(target, true);
        }
      }
    } else {
      setState(() => _recordDuration = 0);
    }

    bool isGroup = allContacts[activeIndex]['isGroup'] == true;
    if (isGroup) {
      List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
      for (var m in members) {
        if (_activeLiveContacts.contains(m)) {
          _resetLiveTimeoutForContact(m.toString());
        }
      }
    } else {
      String currentTargetPhone = allContacts[activeIndex]['phone'];
      if (_activeLiveContacts.contains(currentTargetPhone)) {
        _resetLiveTimeoutForContact(currentTargetPhone);
      }
    }

    _micDebounceTimer = Timer(const Duration(milliseconds: 10), () async {
      try {
        if (await _audioRecorder.hasPermission()) {
          if (await _audioRecorder.isRecording()) {
            await _audioRecorder.stop();
          }
          if (_currentlyPlayingMessage != null && !_isProcessingLiveQueue) {
            await _historyPlayer.stop();
            final session = await AudioSession.instance;
            session.setActive(false).catchError((_) => false);
            setState(() { _currentlyPlayingMessage!.isPlaying = false; _currentlyPlayingMessage = null; _isCurrentlyPlayingOrRecording = false; });
          }
          await SocketService().stopAudio();
          final Directory tempDir = await getTemporaryDirectory();
          final String tempPath = '${tempDir.path}/my_orbit_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100, bitRate: 64000, numChannels: 1), path: tempPath);
          _recordingStartTime = DateTime.now();
          if (!mounted) {
            return;
          }

          _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) async {
            try {
              if (isRecording && await _audioRecorder.isRecording()) {
                final amplitude = await _audioRecorder.getAmplitude();
                double normalized = (amplitude.current + 60) / 60;
                if (mounted) {
                  setState(() => _audioLevel.value = normalized.clamp(0.0, 1.0));
                }
              }
            } catch (_) { /* ignore */ }
          });

          _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted) {
              setState(() => _recordDuration++);
              if (_recordDuration >= 60) {
                _stopRecording(isChunk: true);
              }
            }
          });
        }
      } catch (e) {
        debugPrint("🚨 Mikrofon Hatası: $e");
        if (mounted) {
          setState(() { isRecording = false; _isCurrentlyPlayingOrRecording = false; });
        }
      }
    });
  }

  Future<void> _stopRecording({bool isChunk = false}) async {
    if (!isRecording && !isChunk) {
      return;
    }
    _micDebounceTimer?.cancel(); _amplitudeTimer?.cancel(); _recordTimer?.cancel();

    if (!isChunk) {
      setState(() { 
        isRecording = false; 
        _audioLevel.value = 0.0; 
      });
      if (_activeLiveContacts.isNotEmpty) {
        for (var target in _activeLiveContacts) {
          SocketService().sendSpeakingState(target, false);
        }
      }
    }

    String? path;
    try {
      if (await _audioRecorder.isRecording()) {
        if (_recordingStartTime != null) {
          final int elapsed = DateTime.now().difference(_recordingStartTime!).inMilliseconds;
          if (elapsed < 600) {
            await Future.delayed(Duration(milliseconds: 600 - elapsed));
          }
        }
        path = await _audioRecorder.stop();
      }
    } catch (_) { /* ignore */ }

    setState(() { _isCurrentlyPlayingOrRecording = _isProcessingLiveQueue; });

    if (_isCancelled && !isChunk) {
      if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ } }
    } else if (path != null) {
      final audioFile = File(path);
      if (audioFile.existsSync() && audioFile.lengthSync() > 100) {
        if (hapticEnabled && !isChunk) { try { HapticFeedback.lightImpact(); } catch (_) { /* ignore */ } }
        final now = DateTime.now();
        String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        bool isGroup = allContacts[activeIndex]['isGroup'] == true;
        String contactIdentifier = isGroup ? allContacts[activeIndex]['name'] : allContacts[activeIndex]['phone'];

        final newMsg = AudioMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString() + (isChunk ? "_chunk" : ""),
          contactName: contactIdentifier, isMe: true, durationInSeconds: _recordDuration, time: timeStr,
          isRead: _activeLiveContacts.isNotEmpty, isLiveMessage: _activeLiveContacts.isNotEmpty, repliedToMessageId: _replyingToMessage?.id, audioFilePath: path,
          voiceEffect: _selectedVoiceEffect,
        );

        setState(() { _allMessages.insert(0, newMsg); _sortOrbitContactsByRecent(); });

        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token') ?? '';

          var uri = Uri.parse('https://orbit-talk.com/api/upload');
          var request = http.MultipartRequest('POST', uri);
          
          request.headers['Authorization'] = 'Bearer $token';

          request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
          request.fields['voiceEffect'] = _selectedVoiceEffect;

          debugPrint("📡 SES SUNUCUYA YÜKLENİYOR... URI: $uri");

          var response = await request.send();
          var responseData = await response.stream.bytesToString();

          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint("✅ SES BAŞARIYLA YÜKLENDİ: $responseData");
            var jsonResponse = jsonDecode(responseData);
            String audioUrl = jsonResponse['fileUrl'] ?? jsonResponse['url'] ?? '';

            if (_activeLiveContacts.isNotEmpty) {
              for(var target in _activeLiveContacts) {
                SocketService().sendAudio(target, audioUrl, newMsg.id);
                _resetLiveTimeoutForContact(target);
              }
            } else if (!isGroup) {
              SocketService().sendAudio(allContacts[activeIndex]['phone'], audioUrl, newMsg.id);
            }
          } else {
            debugPrint("🚨 SUNUCU YÜKLEMEYİ REDDETTİ! Code: ${response.statusCode} | Body: $responseData");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sunucu Hatası: ${response.statusCode}"), backgroundColor: Colors.red));
            }
          }
        } catch (e) { 
          debugPrint("🚨 AĞ/BAĞLANTI ÇÖKTÜ: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bağlantı Hatası!"), backgroundColor: Colors.orange));
          }
        }
      }
    }

    if (isChunk && isRecording) {
      _startRecording(isChunkContinue: true);
    } else {
      setState(() { 
        _dragOffset = 0.0; 
        _dragVerticalOffset = 0.0; 
        _isCancelled = false; 
        _replyingToMessage = null; 
        _lockedDragAxis = null; 
      });
    }
  }

  void _updateRecordingPointer(PointerMoveEvent event) {
    if (!isRecording) {
      return;
    }
    bool isLive = _activeLiveContacts.isNotEmpty;
    setState(() {
      if (_lockedDragAxis == null) {
        if (event.localDelta.dx.abs() > 1.5 && event.localDelta.dx.abs() > event.localDelta.dy.abs()) {
          _lockedDragAxis = 'horizontal';
        } else if (event.localDelta.dy.abs() > 1.5 && event.localDelta.dy.abs() > event.localDelta.dx.abs()) {
          _lockedDragAxis = 'vertical';
        }
      }

      if (_lockedDragAxis == 'horizontal') {
        double moveDelta = event.localDelta.dx;
        if (_isLeftHanded) {
          _dragOffset += moveDelta; _dragOffset = _dragOffset.clamp(0.0, 150.0);
        } else {
          _dragOffset += moveDelta; _dragOffset = _dragOffset.clamp(-150.0, 0.0);
        }
        _dragVerticalOffset = 0.0; 
      } 
      else if (_lockedDragAxis == 'vertical' && isLive) {
        if (event.localDelta.dy > 0) {
          _dragVerticalOffset += event.localDelta.dy;
        }
        _dragOffset = 0.0; 
      }

      if (isLive && _dragVerticalOffset > 130 && !_isCancelled) {
        _isCancelled = true;
        _endLiveConnection();
        if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ } }
      }
      else if ((_isLeftHanded && _dragOffset > 100) || (!_isLeftHanded && _dragOffset < -100)) {
        _isCancelled = true;
      }
    });
  }

  void _endLiveConnection() {
    _incomingAmplitudeTimer?.cancel();
    _incomingAudioLevel.value = 0.0;

    if (activeIndex != -1) {
      bool isGroup = allContacts[activeIndex]['isGroup'] == true;
      String contactName = allContacts[activeIndex]['name'];
      if (isGroup) {
        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
        for (var m in members) {
          String phone = m.toString();
          if (_activeLiveContacts.contains(phone)) {
            SocketService().rejectCall(phone);
            _activeLiveContacts.remove(phone);
            _liveTimers[phone]?.cancel();
            _liveTimers.remove(phone);
          }
        }
        _activeLiveGroupMembers.clear();
      } else {
        String contactPhone = allContacts[activeIndex]['phone'];
        if (_activeLiveContacts.contains(contactPhone)) {
          SocketService().rejectCall(contactPhone);
          _activeLiveContacts.remove(contactPhone);
          _liveTimers[contactPhone]?.cancel();
          _liveTimers.remove(contactPhone);
        }
      }

      setState(() {
        if (_activeLiveContacts.isEmpty) {
          _liveDurationTimer?.cancel();
          _liveDuration = 0;
          _whoIsSpeaking = null; 
        }
      });
      if (hapticEnabled) {
        try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.phone_disabled, color: Colors.white, size: 18), const SizedBox(width: 8), Text("$contactName ${_t('disconnected')}")]), backgroundColor: Colors.red.shade800, duration: const Duration(seconds: 2)));
      }
    }
  }

  void _requestLiveConnection(int index) {
    if (!_checkBatteryLimitSync()) return;
    try {
      String name = allContacts[index]['name'] ?? _t('unknown');
      bool isGroup = allContacts[index]['isGroup'] == true;

      if (isGroup) {
        List<dynamic> members = allContacts[index]['members'] ?? [];
        if (members.isEmpty) {
          return;
        }
        for (var m in members) {
          SocketService().startCall(m.toString());
        }
      } else {
        String phone = allContacts[index]['phone'] ?? "";
        if (phone.isEmpty) {
          return;
        }
        if (allContacts[index]['status'] == UserStatus.busy) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name ${_t('is_busy')}"), backgroundColor: Colors.orange));
          return;
        }
        SocketService().startCall(phone);
      }

      setState(() { activeIndex = index; isWaitingForLiveApproval = true; _replyingToMessage = null; });
      _triggerConnectionArrows();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)), const SizedBox(width: 12), Text("$name ${_t('calling')}", style: const TextStyle(color: Colors.white))]), backgroundColor: Colors.black87, duration: const Duration(seconds: 30)));

      _outgoingCallTimer?.cancel();
      _outgoingCallTimer = Timer(const Duration(seconds: 30), () {
        if (mounted && isWaitingForLiveApproval) {
          if (isGroup) {
            List<dynamic> members = allContacts[index]['members'] ?? [];
            for (var m in members) { SocketService().cancelCall(m.toString()); }
          } else {
            SocketService().cancelCall(allContacts[index]['phone']);
          }
          setState(() { isWaitingForLiveApproval = false; });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('call_not_ans')), backgroundColor: Colors.red.shade800));
        }
      });
    } catch (e) {
      // ignore
    }
  }

  void _cancelOutgoingCall() {
    if (activeIndex != -1 && isWaitingForLiveApproval) {
      bool isGroup = allContacts[activeIndex]['isGroup'] == true;
      if (isGroup) {
        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
        for (var m in members) { SocketService().cancelCall(m.toString()); }
      } else {
        String phone = allContacts[activeIndex]['phone'];
        SocketService().cancelCall(phone);
      }
      _outgoingCallTimer?.cancel();
      setState(() { isWaitingForLiveApproval = false; });
      if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ } }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('call_canc')), backgroundColor: Colors.orange, duration: const Duration(seconds: 2)));
    }
  }

  void _onPersonSelected(int index) {
    if (allContacts[index]['isEmpty'] == true) {
      if (!_isArchiveMode) {
        _openContacts(initialIndex: index);
      }
      return;
    }
    setState(() {
      activeIndex = index;
      _replyingToMessage = null;
      _isActiveMenuExpanded = false;
      _closeSearchMode();
    });
    _triggerConnectionArrows();
  }

  void _handleSearch(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        allContacts = List.from(originalContacts);
      } else {
        List<Map<String, dynamic>> matched = []; List<Map<String, dynamic>> unmatched = [];
        for (var contact in originalContacts) {
          if (contact['name'] != "Davet Et" && contact['name'].toLowerCase().contains(query.toLowerCase())) {
            matched.add(contact);
          } else {
            unmatched.add(contact);
          }
        }
        allContacts = [...matched, ...unmatched];
        if (matched.isNotEmpty) { activeIndex = 0; _scrollOffset = 0.0; }
      }
    });
  }

  void _closeSearchMode() {
    if (showSearchField) {
      setState(() {
        isSearching = false;
        showSearchField = false;
        _isActiveMenuExpanded = false;
        _searchController.clear();
        _focusNode.unfocus();
        allContacts = List.from(originalContacts);
      });
    }
  }

  void _onSearchedPersonSelected(Map<String, dynamic> person) {
    setState(() { originalContacts.remove(person); originalContacts.insert(0, person); allContacts = List.from(originalContacts); _onPersonSelected(0); _scrollOffset = 0.0; });
  }

  void _toggleArchiveMode() {
    if (hapticEnabled) {
      try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ }
    }
    setState(() {
      if (_isArchiveMode) {
        _isArchiveMode = false;
        allContacts = List.from(originalContacts);
        activeIndex = -1;
      } else {
        _isArchiveMode = true;
        activeIndex = -1;

        var savedMsgs = _allMessages.where((m) => m.isSaved && !m.isDeleted).toList();
        savedMsgs.sort((a, b) {
          int timeA = int.tryParse(a.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          int timeB = int.tryParse(b.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return timeB.compareTo(timeA);
        });

        List<String> uniqueNames = [];
        for (var m in savedMsgs) {
          if (!uniqueNames.contains(m.contactName)) {
            uniqueNames.add(m.contactName);
          }
        }

        List<Map<String, dynamic>> archiveContacts = [];
        for (var name in uniqueNames) {
          var originalContact = originalContacts.firstWhere(
                  (c) => c['name'] == name || c['phone'] == name,
              orElse: () => {"name": name, "phone": name, "isGroup": false, "status": UserStatus.offline}
          );
          archiveContacts.add(originalContact);
        }

        while(archiveContacts.length < 7) {
          archiveContacts.add({"name": "Davet Et", "isEmpty": true});
        }
        allContacts = archiveContacts;
      }
      _isMenuExpanded = false;
      _isActiveMenuExpanded = false;
    });
  }

  Future<void> _openContacts({int initialIndex = 0}) async {
    bool canAdd = await _checkAdditionLimit();
    if (!canAdd) return;
    if (!mounted) return;

    final Map<String, dynamic>? selectedContact = await ContactsBottomSheet.show(context, initialIndex: 0);
    if (selectedContact != null && mounted) {
      
      // 🛠️ YENİ ZIRH: ÇİFT KAYIT (KOPYA KİŞİ) KONTROLÜ
      if (selectedContact['isGroup'] != true) {
        String newPhone = (selectedContact['phone'] ?? '').toString().replaceAll(RegExp(r'[^\d]'), '');
        
        bool isDuplicate = allContacts.any((c) {
          if (c['isEmpty'] == true || c['isGroup'] == true) return false;
          String existingPhone = (c['phone'] ?? '').toString().replaceAll(RegExp(r'[^\d]'), '');
          return existingPhone == newPhone;
        });

        if (isDuplicate) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text("${selectedContact['name']} zaten yörüngende ekli!")),
                ],
              ),
              backgroundColor: Colors.orange.shade900,
            )
          );
          return; // Aynı kişiyse eklemeyi iptal et ve çık!
        }
      }

      setState(() {
        if (allContacts[initialIndex]['isEmpty'] == true) {
          allContacts[initialIndex] = selectedContact;
          originalContacts[initialIndex] = selectedContact;
        } else {
          int emptyIdx = allContacts.lastIndexWhere((c) => c['isEmpty'] == true);
          if (emptyIdx != -1) {
            allContacts[emptyIdx] = selectedContact;
            originalContacts[emptyIdx] = selectedContact;
          }
        }
      });
      _saveOrbitToCache(); 
    }
  }

  void _openSettings() {
    setState(() => _isSettingsOpen = true);
    SettingsBottomSheet.show(
      context: context, userName: _userName, userAvatarPath: _userAvatarPath, customAvatarColor: _myCustomColor, onCustomAvatarColorChanged: (val) => setState(() => _myCustomColor = val), myStatus: _myStatus,
      onUserNameChanged: (val) { setState(() => _userName = val); }, onPickFromGallery: () => _pickImage(ImageSource.gallery), onPickFromCamera: () => _pickImage(ImageSource.camera), onRemoveAvatar: _removeAvatar, onStatusChanged: (val) { setState(() => _myStatus = val); },
      isLeftHanded: _isLeftHanded, onLeftHandedChanged: (val) => setState(() => _isLeftHanded = val), selectedLiveAnimation: selectedLiveAnimation, animationOptions: animationOptions, onLiveAnimationChanged: (val) => setState(() => selectedLiveAnimation = val),
      isBackgroundTransparent: isBackgroundTransparent, onBackgroundTransparentChanged: (val) => setState(() => isBackgroundTransparent = val), isCircularMessageStyle: isCircularMessageStyle, onCircularMessageStyleChanged: (val) => setState(() => isCircularMessageStyle = val),
      hapticEnabled: hapticEnabled, onHapticChanged: (val) => setState(() => hapticEnabled = val), useSpeaker: _useSpeaker, onSpeakerChanged: (val) => setState(() => _useSpeaker = val),

      ratchetEnabled: _ratchetEnabled,
      onRatchetChanged: (val) async {
        setState(() => _ratchetEnabled = val);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('ratchet_enabled', val);
      },

      selfDestructSeconds: selfDestructSeconds, onSelfDestructChanged: (val) => setState(() => selfDestructSeconds = val), liveAudioPermission: _liveAudioPermission, onLivePermissionChanged: (val) => setState(() => _liveAudioPermission = val),
      notificationsEnabled: _notificationsEnabled, onNotificationsChanged: (val) => setState(() => _notificationsEnabled = val), messageNotificationsEnabled: _messageNotificationsEnabled, onMessageNotificationsChanged: (val) => setState(() => _messageNotificationsEnabled = val), callNotificationsEnabled: _callNotificationsEnabled, onCallNotificationsChanged: (val) => setState(() => _callNotificationsEnabled = val),
      callRingtone: _callRingtone,
      onRingtoneChanged: (val) async { setState(() => _callRingtone = val); final prefs = await SharedPreferences.getInstance(); prefs.setString('call_ringtone', val); },
      deleteFilterDays: deleteFilterDays, onDeleteFilterDaysChanged: (val) => setState(() => deleteFilterDays = val),
      onClearOldMessages: (days) { final limitDate = DateTime.now().subtract(Duration(days: days)); setState(() { _allMessages.removeWhere((m) => m.isSaved && m.createdAt.isBefore(limitDate)); }); },
      customBackgroundImagePath: _customBackgroundImagePath, onPickBackground: () => _pickImage(ImageSource.gallery, isBackground: true),
      onRemoveBackground: () { setState(() { _customBackgroundImagePath = null; isBackgroundTransparent = true; }); },
      
      globalBgColor: _globalBgColor,
      onGlobalBgColorChanged: (val) async {
        setState(() => _globalBgColor = val);
        final prefs = await SharedPreferences.getInstance();
        if (val == null) {
          await prefs.remove('global_bg_color');
        } else {
          await prefs.setInt('global_bg_color', val.toARGB32());
        }
      },
      
      onClosed: () {
        if (mounted) {
          setState(() { _isSettingsOpen = false; });
          _loadLanguage();
        }
      },
    );
  }

  void _acceptIncomingCall() {
    final currentCallerId = _pendingCallerId;
    if (currentCallerId == null) {
      setState(() { _pttSlideOffset = 0.0; _isIncomingCallActive = false; });
      return;
    }
    _incomingRingTimer?.cancel(); _vibrationTimer?.cancel();
    SocketService().acceptCall(currentCallerId);
    try { NotificationService().cancelCallNotification(); } catch (_) { /* ignore */ }

    Future.delayed(const Duration(milliseconds: 300), () async {
      final session = await AudioSession.instance;
      session.setActive(true).catchError((_) => false);
      if (mounted) {
        setState(() {
          int targetIdx = allContacts.indexWhere((c) => c['phone'] == currentCallerId);
          if (targetIdx != -1) {
            activeIndex = targetIdx;
          }
          _activeLiveContacts.add(currentCallerId); _resetLiveTimeoutForContact(currentCallerId);
          _isIncomingCallActive = false; _pttSlideOffset = 0.0;
          if (_pendingCallerId == currentCallerId) {
            _pendingCallerId = null;
            _pendingCallerName = null;
          }
          _startLiveTimerIfNeeded();
        });
      }
    });
  }

  void _rejectIncomingCall() {
    final currentCallerId = _pendingCallerId;
    if (currentCallerId == null) {
      setState(() { _pttSlideOffset = 0.0; _isIncomingCallActive = false; });
      return;
    }
    _incomingRingTimer?.cancel(); _vibrationTimer?.cancel();
    SocketService().rejectCall(currentCallerId);
    try { NotificationService().cancelCallNotification(); } catch (_) { /* ignore */ }
    setState(() { _isIncomingCallActive = false; _pttSlideOffset = 0.0; if (_pendingCallerId == currentCallerId) { _pendingCallerId = null; _pendingCallerName = null; } });
  }

  Future<void> _handleEffectSelection(String effectName) async {
    if (effectName.trim().toLowerCase() == 'normal') {
      setState(() { _selectedVoiceEffect = 'Normal'; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Normal sese dönüldü.")));
      return; 
    }

    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final unlockTimeStr = prefs.getString('unlock_$effectName');

    bool isUnlocked = false;
    if (unlockTimeStr != null) {
      final unlockTime = DateTime.parse(unlockTimeStr);
      if (DateTime.now().isBefore(unlockTime.add(const Duration(hours: 1)))) {
        isUnlocked = true;
      }
    }

    if (isUnlocked) {
      setState(() { _selectedVoiceEffect = effectName; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Efekt devrede!"), backgroundColor: Colors.greenAccent, duration: Duration(seconds: 1)));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.blueGrey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent)),
          title: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Text(effectName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Bu ses özelliğini 1 saat boyunca kullanmak için Reklam izlemeniz gerekiyor.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal', style: TextStyle(color: Colors.white30)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Reklam İzle'),
              onPressed: () {
                Navigator.pop(ctx);
                _showRewardedAdGeneric(() async {
                  final p = await SharedPreferences.getInstance();
                  await p.setString('unlock_$effectName', DateTime.now().toIso8601String());
                  if (mounted) {
                    setState(() { _selectedVoiceEffect = effectName; });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kilit açıldı!"), backgroundColor: Colors.greenAccent));
                  }
                });
              },
            )
          ],
        ),
      );
    }
  }

  Widget _buildLabeledMenuBtn(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: _isLeftHanded ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!_isLeftHanded) ...[
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold))),
              const SizedBox(width: 14),
            ],
            if (_isLeftHanded) const SizedBox(width: 3.5),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!_isLeftHanded) const SizedBox(width: 3.5),
            if (_isLeftHanded) ...[
              const SizedBox(width: 14),
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.left, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold))),
            ],
          ],
        ),
      ),
    );
  }

  void _promptDeleteActiveContact() async {
    if (activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) {
      return;
    }
    
    bool canRemove = await _checkRemovalLimit();
    if (!canRemove) return;

    int indexToDelete = activeIndex;
    String nameToDel = allContacts[indexToDelete]['name'];

    if(!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: _currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: Colors.blueGrey.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.redAccent, width: 1)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text(_t('rm_orbit'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text("$nameToDel ${_t('del_warn')}", style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_t('cancel'), style: const TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.2), foregroundColor: Colors.redAccent, elevation: 0),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    allContacts[indexToDelete] = {"name": "Davet Et", "isEmpty": true};
                    originalContacts[indexToDelete] = {"name": "Davet Et", "isEmpty": true};
                    if (activeIndex == indexToDelete) {
                      activeIndex = -1;
                    }
                  });
                  _saveOrbitToCache(); 
                  if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ } }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$nameToDel ${_t('removed')}"), backgroundColor: Colors.red.shade800));
                },
                child: Text(_t('del_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _runPhysicsSimulation(double velocity, AnimationController controller, double currentOffset, double maxScroll) {
    if (velocity.abs() < 100) return; 
    
    double direction = _isLeftHanded ? -1.0 : 1.0;
    double pixelsPerRadian = 300.0;
    double initialVelocity = (velocity / pixelsPerRadian) * direction;

    final simulation = FrictionSimulation(
      0.05, 
      currentOffset,
      initialVelocity,
    );

    controller.animateWith(simulation).whenComplete(() {
        double current = controller.value;
        if (current < -0.2) {
            controller.animateTo(-0.2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        } else if (current > maxScroll) {
            controller.animateTo(maxScroll, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
    });
  }


  @override
  Widget build(BuildContext context) {
    TextDirection layoutDirection = _currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    
    // 🛠️ AKTİF EFEKT VERİSİNİ BUL
    Map<String, dynamic> currentEffect = _voiceEffects.firstWhere((fx) => fx['name'] == _selectedVoiceEffect, orElse: () => _voiceEffects[0]);
    bool hasActiveEffect = _selectedVoiceEffect != 'Normal';

    return Directionality(
        textDirection: layoutDirection,
        child: AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = constraints.maxWidth;
                    final double screenHeight = constraints.maxHeight;
                    double orbitRadius = 105.0;
                    double menuX = screenWidth / 2;
                    double menuY = screenHeight - 300.0; 
                    double itemSpacingAngle = 0.25 * math.pi;
                    double maxScroll = (allContacts.length * itemSpacingAngle) - (4 * itemSpacingAngle);
                    if (maxScroll < 0) {
                      maxScroll = 0;
                    }
                    
                    double maxSubScroll = 0;
                    if (_activeSubOrbit != SubOrbitType.none) {
                        maxSubScroll = (_getSubOrbitItems().length * itemSpacingAngle) - (4 * itemSpacingAngle);
                        if (maxSubScroll < 0) maxSubScroll = 0;
                    }

                    String activeContactName = activeIndex != -1 ? allContacts[activeIndex]['name'] : "";
                    bool isGroup = activeIndex != -1 ? (allContacts[activeIndex]['isGroup'] ?? false) : false;

                    bool isCurrentlyLive = false;
                    
                    Color? activeBgColor;
                    if (activeIndex != -1 && allContacts[activeIndex]['isEmpty'] != true) {
                      String identifier = isGroup ? allContacts[activeIndex]['name'] : allContacts[activeIndex]['phone'];
                      activeBgColor = _contactBackgrounds[identifier];
                    }
                    
                    activeBgColor ??= _globalBgColor;

                    if (activeIndex != -1) {
                      if (isGroup) {
                        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
                        isCurrentlyLive = members.any((m) => _activeLiveContacts.contains(m.toString()));
                      } else {
                        isCurrentlyLive = _activeLiveContacts.contains(allContacts[activeIndex]['phone']);
                      }
                    }
                    bool anyLiveActive = _activeLiveContacts.isNotEmpty;
                    bool anyMenuExpanded = _isMenuExpanded || _isActiveMenuExpanded;

                    return Scaffold(
                      backgroundColor: Colors.black,
                      resizeToAvoidBottomInset: false,
                      body: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (showSearchField) {
                            _closeSearchMode();
                          } else if (anyMenuExpanded) {
                            setState(() {
                              _isMenuExpanded = false;
                              _isActiveMenuExpanded = false;
                            });
                          } else if (activeIndex != -1 && _activeSubOrbit == SubOrbitType.none) {
                            setState(() {
                              activeIndex = -1;
                              _isActiveMenuExpanded = false;
                              _replyingToMessage = null;
                            });
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        },

                        onPanStart: (details) {
                          if (showSearchField || _activeSubOrbit != SubOrbitType.none) {
                            return;
                          }
                          if (_interactionNodeIndex != -1) {
                            return;
                          }
                          
                          _scrollPhysicsController.stop(); 

                          double dx = details.localPosition.dx - menuX;
                          double dy = details.localPosition.dy - menuY;
                          double distance = math.sqrt(dx * dx + dy * dy);

                          if (distance >= 50.0 && distance <= 180.0) {
                            _isValidOrbitDrag = true;
                            _lastDragAngle = math.atan2(dy, dx);
                          } else {
                            _isValidOrbitDrag = false;
                          }
                        },
                        onPanUpdate: (details) {
                          if (!_isValidOrbitDrag || _interactionNodeIndex != -1) {
                            return;
                          }
                          if (showSearchField || _activeSubOrbit != SubOrbitType.none) {
                            return;
                          }

                          double dx = details.localPosition.dx - menuX;
                          double dy = details.localPosition.dy - menuY;
                          double currentAngle = math.atan2(dy, dx);

                          double deltaAngle = currentAngle - _lastDragAngle;

                          if (deltaAngle > math.pi) {
                            deltaAngle -= 2 * math.pi;
                          }
                          if (deltaAngle < -math.pi) {
                            deltaAngle += 2 * math.pi;
                          }

                          deltaAngle *= 0.5;

                          setState(() {
                            if (_isLeftHanded) {
                              _scrollOffset -= deltaAngle;
                            } else {
                              _scrollOffset += deltaAngle;
                            }

                            if (_scrollOffset < -0.2) {
                              _scrollOffset = -0.2;
                            }
                            if (_scrollOffset > maxScroll) {
                              _scrollOffset = maxScroll;
                            }

                            _lastDragAngle = currentAngle;

                            if (_ratchetEnabled) {
                              _ratchetAccumulator += deltaAngle.abs();

                              double threshold = Platform.isAndroid ? 0.20 : 0.15;
                              int debounceTime = Platform.isAndroid ? 120 : 80;

                              if (_ratchetAccumulator >= threshold) {
                                _ratchetAccumulator -= threshold;

                                int now = DateTime.now().millisecondsSinceEpoch;
                                if (now - _lastRatchetTime > debounceTime) {
                                  _lastRatchetTime = now;
                                  if (hapticEnabled) {
                                    try {
                                      if (Platform.isAndroid) {
                                        HapticFeedback.vibrate();
                                      } else {
                                        HapticFeedback.selectionClick();
                                      }
                                    } catch (_) { /* ignore */ }
                                  }
                                }
                              }
                            }
                          });
                        },
                        onPanEnd: (details) {
                          _isValidOrbitDrag = false;
                          _ratchetAccumulator = 0.0;
                          
                          if (showSearchField || _activeSubOrbit != SubOrbitType.none) return;
                          
                          double velocity = details.velocity.pixelsPerSecond.dx + details.velocity.pixelsPerSecond.dy;
                          _runPhysicsSimulation(velocity, _scrollPhysicsController, _scrollOffset, maxScroll);
                        },

                        child: Stack(
                          children: [
                            if (activeBgColor != null)
                              Positioned.fill(
                                child: Container(
                                  color: activeBgColor!.withValues(alpha: 1.0),
                                ),
                              )
                            else if (_customBackgroundImagePath != null)
                              Positioned.fill(child: Image.file(File(_customBackgroundImagePath!), fit: BoxFit.cover))
                            else if (!isBackgroundTransparent)
                              Positioned.fill(child: Container(color: Colors.black))
                            else
                              Positioned.fill(child: Container(color: Colors.black)),

                            if (activeBgColor == null && (_customBackgroundImagePath != null || isBackgroundTransparent))
                              Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), child: Container(color: Colors.black.withValues(alpha: 0.4)))),

                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: !(_isSettingsOpen || showSearchField || anyMenuExpanded),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: (_isSettingsOpen || showSearchField || anyMenuExpanded) ? 12.0 : 0.0), duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
                                  builder: (context, blurValue, child) {
                                    if (blurValue == 0.0) {
                                      return const SizedBox.shrink();
                                    }
                                    return BackdropFilter(filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue), child: Container(color: Colors.black.withValues(alpha: (blurValue / 12.0) * 0.6)));
                                  },
                                ),
                              ),
                            ),

                            Positioned(
                              top: 15,
                              right: 15,
                              child: SafeArea(
                                child: GestureDetector(
                                  onTap: () => _runSafeAction(() {
                                    if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) {} }
                                    SubscriptionService.showPaywall(context);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)],
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.stars, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text("Orbit Plus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (_currentlyPlayingQueueItemSender != null && !showSearchField)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, left: !_isLeftHanded ? 25.0 : null, right: _isLeftHanded ? 25.0 : null, top: menuY - 240,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 32, height: 32, child: AnimatedBuilder(animation: _pulseController, builder: (context, child) { return Stack(alignment: Alignment.center, children: [Container(width: 32 * _pulseController.value, height: 32 * _pulseController.value, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent.withValues(alpha: (1.0 - _pulseController.value) * 0.6))), Icon(Icons.headset_mic, color: Colors.cyanAccent, size: 20 + (_pulseController.value * 4))]); })),
                                    const SizedBox(width: 8),
                                    Text(_currentlyPlayingQueueItemSender!.split(' ').first, style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1)), Shadow(color: Colors.cyanAccent, blurRadius: 8)])),
                                  ],
                                ),
                              ),

                            if (_whoIsSpeaking != null && !showSearchField && _currentlyPlayingQueueItemSender == null)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, left: !_isLeftHanded ? 25.0 : null, right: _isLeftHanded ? 25.0 : null, top: menuY - 240,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 32, height: 32, child: AnimatedBuilder(animation: _pulseController, builder: (context, child) { return Stack(alignment: Alignment.center, children: [Container(width: 32 * _pulseController.value, height: 32 * _pulseController.value, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withValues(alpha: (1.0 - _pulseController.value) * 0.6))), const Icon(Icons.mic, color: Colors.redAccent, size: 20)]); })),
                                    const SizedBox(width: 8),
                                    Text("${_localContactsMap[_whoIsSpeaking] ?? _whoIsSpeaking} ${_t('is_spk')}", style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),

                            if (activeIndex != -1 && !showSearchField && allContacts[activeIndex]['isEmpty'] != true)
                              Positioned(
                                top: 60, left: 0, right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      activeContactName, 
                                      style: TextStyle(
                                        color: _blockedContacts.contains(activeContactName) ? Colors.white54 : Colors.white, 
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800, letterSpacing: 1.0, 
                                        shadows: const [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1))]
                                      )
                                    ),
                                    
                                    if (_blockedContacts.contains(activeContactName)) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade900.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.block, color: Colors.white, size: 14),
                                            SizedBox(width: 6),
                                            Text("Engellendi", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      if (isCurrentlyLive) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: Colors.redAccent.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5)
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 12, height: 12, child: AnimatedBuilder(animation: _pulseController, builder: (context, child) { return Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withValues(alpha: _pulseController.value))); })),
                                              const SizedBox(width: 6),
                                              Text(_formatDuration(_liveDuration), style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ] else if (allContacts[activeIndex]['status'] != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(allContacts[activeIndex]['status'] == UserStatus.offline ? _t('offline') : _t('online'), style: TextStyle(color: allContacts[activeIndex]['status'] == UserStatus.offline ? Colors.redAccent : Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                            if (_mutedContacts.contains(activeContactName)) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.volume_off, color: Colors.white54, size: 14),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),

                            ..._flyingEmojis.map((flying) {
                              return TweenAnimationBuilder<double>(
                                key: ValueKey(flying.id), tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(milliseconds: 2500), curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Positioned(
                                    left: flying.startX + math.sin(value * math.pi * 4) * 40, bottom: 150 + (value * 500),
                                    child: Opacity(
                                        opacity: (1.0 - value).clamp(0.0, 1.0),
                                        child: Transform.scale(
                                            scale: 1.0 + (value * 0.5),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(flying.emoji, style: const TextStyle(fontSize: 36)),
                                                  if (flying.senderName != null) ...[
                                                    const SizedBox(width: 8),
                                                    Text(
                                                        flying.senderName!,
                                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])
                                                    ),
                                                  ]
                                                ]
                                            )
                                        )
                                    ),
                                  );
                                },
                              );
                            }),

                            if (activeIndex != -1 && !showSearchField && allContacts[activeIndex]['isEmpty'] != true)
                              Positioned(
                                top: (isGroup && isCurrentlyLive) ? 140 : 120, left: 10, right: 10, bottom: screenHeight - menuY + 220,
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) { return const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.15, 0.85, 1.0]).createShader(bounds); },
                                  blendMode: BlendMode.dstIn,
                                  child: OrbitChatList(
                                    activeMessages: _activeMessages, isCircularMessageStyle: isCircularMessageStyle, hapticEnabled: hapticEnabled, selfDestructSeconds: selfDestructSeconds,
                                    onPlayMessage: _playMessage,
                                    onReplyMessage: (msg) { setState(() => _replyingToMessage = msg); if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ } } },
                                    onSaveToggle: (msg, save) { setState(() { msg.isSaved = save; if (save) { msg.isPendingDeletion = false; } }); },
                                    onDeleteMessage: (msg) { setState(() { msg.isSaved = false; msg.isDeleted = true; }); },
                                    formatDuration: _formatDuration,
                                    onReactToMessage: (msg, emoji) { _handleEmojiSelection(emoji); },
                                  ),
                                ),
                              ),

                            ...List.generate(allContacts.length, (index) {
                              bool nodeIsGroup = allContacts[index]['isGroup'] == true;
                              bool nodeIsLive = false;
                              if (nodeIsGroup) {
                                List<dynamic> m = allContacts[index]['members'] ?? [];
                                nodeIsLive = m.any((phone) => _activeLiveContacts.contains(phone.toString()));
                              } else {
                                nodeIsLive = _activeLiveContacts.contains(allContacts[index]['phone']);
                              }

                              double animVal = CurvedAnimation(parent: _entranceController, curve: Interval((0.2 + (index * 0.08)).clamp(0.0, 1.0), (0.8 + (index * 0.05)).clamp(0.0, 1.0), curve: Curves.elasticOut)).value;

                              int badgeCount = 0;
                              String contactIdentifier = allContacts[index]['isGroup'] == true ? (allContacts[index]['name'] ?? "") : (allContacts[index]['phone'] ?? "");
                              if (_isArchiveMode) {
                                badgeCount = _allMessages.where((msg) => msg.isSaved && !msg.isDeleted && msg.contactName == contactIdentifier).length;
                              } else {
                                badgeCount = _allMessages.where((msg) => msg.contactName == contactIdentifier && !msg.isMe && !msg.isRead).length;
                              }

                              Map<String, dynamic> displayContact = Map.from(allContacts[index]);
                              if (displayContact['isEmpty'] == true) {
                                displayContact['name'] = _t('invite');
                              }

                              return OrbitContactNode(
                                index: index,
                                contact: displayContact,
                                isBlocked: _blockedContacts.contains(displayContact['name'] ?? displayContact['phone']), 
                                itemSpacingAngle: itemSpacingAngle,
                                scrollOffset: _scrollOffset,
                                menuX: menuX,
                                menuY: menuY,
                                orbitRadius: orbitRadius,
                                isLeftHanded: _isLeftHanded,
                                showSearchField: showSearchField,
                                searchQuery: _searchController.text,
                                activeIndex: activeIndex,
                                isLive: nodeIsLive,
                                anyLiveActive: anyLiveActive,
                                showConnectionArrows: _showConnectionArrows,
                                currentlyPlayingQueueItemSender: _currentlyPlayingQueueItemSender,
                                userName: _userName,
                                myCustomColor: _myCustomColor,
                                statusColor: allContacts[index]['status'] == UserStatus.offline ? Colors.redAccent : null,
                                animVal: animVal,
                                unreadCount: badgeCount,
                                isMenuExpanded: anyMenuExpanded,
                                onOpenContacts: () => _openContacts(initialIndex: index),
                                onSearchedPersonSelected: () => _onSearchedPersonSelected(allContacts[index]),
                                onPersonSelected: () => _onPersonSelected(index),
                                onRequestLiveConnection: () => _requestLiveConnection(index),
                                onDoubleTap: () => _handleDoubleTapNudge(index),
                                onRemoveContact: () {},
                                onNodeDragUpdate: (idx, offset) {
                                  setState(() { _interactionNodeIndex = idx; _interactionNodeOffset = offset; });
                                },
                                onNodeInteractionEnded: (idx) {
                                  setState(() { _interactionNodeIndex = -1; _interactionNodeOffset = 0.0; });
                                },
                                onNodeInteractionStarted: (idx) { setState(() { _interactionNodeIndex = idx; _interactionNodeOffset = 0.0; }); },
                                incomingWaveBuilder: (i) {
                                  return ValueListenableBuilder<double>(
                                    valueListenable: _incomingAudioLevel,
                                    builder: (context, level, child) {
                                      double sizeMultiplier = 1.0 + (level * (0.6 + (i * 0.3)));
                                      return TweenAnimationBuilder(
                                        key: ValueKey("incoming_$i"), tween: Tween(begin: 1.0, end: sizeMultiplier), duration: const Duration(milliseconds: 100),
                                        builder: (context, double val, _) { return Container(width: 60 * val, height: 60 * val, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent.withValues(alpha: (0.6 - (level * 0.3)).clamp(0.0, 1.0)), width: 1.5 + (level * 2)))); },
                                      );
                                    },
                                  );
                                },
                              );
                            }).reversed,

                            // 🛠️ YENİ AKTİF EFEKT İKONU (ANA MENÜ BUTONUNUN ÜSTÜNDE)
                            if (hasActiveEffect && !showSearchField && activeIndex != -1 && allContacts[activeIndex]['isEmpty'] != true)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                right: !_isLeftHanded ? 12.0 : null,
                                left: _isLeftHanded ? 12.0 : null,
                                top: menuY - 195, 
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: anyMenuExpanded ? 0.0 : 1.0, // Menü açıkken gizle
                                  child: IgnorePointer(
                                    ignoring: anyMenuExpanded,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() { _selectedVoiceEffect = 'Normal'; });
                                        if (hapticEnabled) { try { HapticFeedback.lightImpact(); } catch (_) {} }
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ses efekti kapatıldı (Normal).")));
                                      },
                                      child: Container(
                                        width: 46, height: 46,
                                        decoration: BoxDecoration(
                                          color: currentEffect['color'].withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: currentEffect['color'], width: 1.5),
                                          boxShadow: [BoxShadow(color: currentEffect['color'].withValues(alpha: 0.3), blurRadius: 10)]
                                        ),
                                        child: Icon(currentEffect['icon'], color: currentEffect['color'], size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              right: !_isLeftHanded ? 8.0 : null,
                              left: _isLeftHanded ? 8.0 : null,
                              top: menuY - 130, 
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: (activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) && !showSearchField ? 1.0 : 0.0,
                                child: IgnorePointer(
                                  ignoring: activeIndex != -1 || showSearchField,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 170),
                                    child: Column(
                                      crossAxisAlignment: !_isLeftHanded ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: !_isLeftHanded ? 12.0 : 0.0, left: _isLeftHanded ? 12.0 : 0.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ } }
                                              setState(() => _isMenuExpanded = !_isMenuExpanded);
                                            },
                                            child: Container(
                                              width: 55, height: 55,
                                              decoration: BoxDecoration(
                                                  color: _isArchiveMode ? Colors.orangeAccent.withValues(alpha: 0.2) : Colors.white12,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: _isArchiveMode ? Colors.orangeAccent : Colors.white30, width: 2),
                                                  boxShadow: [if (_isArchiveMode) BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.4), blurRadius: 10)]
                                              ),
                                              child: Icon(_isMenuExpanded ? Icons.close : Icons.menu, color: _isArchiveMode ? Colors.orangeAccent : Colors.white, size: 28),
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOutCubic,
                                          height: _isMenuExpanded ? 300 : 0, 
                                          alignment: !_isLeftHanded ? Alignment.topRight : Alignment.topLeft,
                                          child: RawScrollbar(
                                            controller: _mainMenuScrollController,
                                            thumbVisibility: true,
                                            thumbColor: Colors.cyanAccent.withValues(alpha: 0.4),
                                            radius: const Radius.circular(20),
                                            thickness: 4,
                                            crossAxisMargin: 0,
                                            scrollbarOrientation: _isLeftHanded ? ScrollbarOrientation.left : ScrollbarOrientation.right,
                                            child: SingleChildScrollView(
                                              controller: _mainMenuScrollController,
                                              physics: const BouncingScrollPhysics(),
                                              child: Padding(
                                                padding: EdgeInsets.only(right: !_isLeftHanded ? 12.0 : 0.0, left: _isLeftHanded ? 12.0 : 0.0),
                                                child: Column(
                                                  crossAxisAlignment: !_isLeftHanded ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 15),
                                                    _buildLabeledMenuBtn(Icons.search, Colors.cyanAccent, _t('search'), () => _runSafeAction(() {
                                                      setState(() {
                                                        _isMenuExpanded = false;
                                                        showSearchField = !showSearchField;
                                                        if (!showSearchField) {
                                                          _closeSearchMode();
                                                        } else {
                                                          Future.delayed(const Duration(milliseconds: 150), () {
                                                            if (context.mounted) {
                                                              FocusScope.of(context).requestFocus(_focusNode);
                                                            }
                                                          });
                                                        }
                                                      });
                                                    })),
                                                    _buildLabeledMenuBtn(Icons.bookmark, _isArchiveMode ? Colors.orangeAccent : Colors.orangeAccent, _t('saved'), () => _runSafeAction(() {
                                                      _toggleArchiveMode();
                                                    })),
                                                    _buildLabeledMenuBtn(Icons.person_add, Colors.greenAccent, _t('add_contact'), () => _runSafeAction(() {
                                                      setState(() => _isMenuExpanded = false);
                                                      _openContacts();
                                                    })),
                                                    _buildLabeledMenuBtn(Icons.settings, Colors.grey, _t('settings'), () => _runSafeAction(() {
                                                      setState(() => _isMenuExpanded = false);
                                                      _openSettings();
                                                    })),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              right: !_isLeftHanded ? 8.0 : null,
                              left: _isLeftHanded ? 8.0 : null,
                              top: menuY - 130, 
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: (activeIndex != -1 && allContacts[activeIndex]['isEmpty'] != true) && !showSearchField ? 1.0 : 0.0,
                                child: IgnorePointer(
                                  ignoring: activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true || showSearchField,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 170),
                                    child: Column(
                                      crossAxisAlignment: !_isLeftHanded ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: !_isLeftHanded ? 12.0 : 0.0, left: _isLeftHanded ? 12.0 : 0.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ } }
                                              setState(() => _isActiveMenuExpanded = !_isActiveMenuExpanded);
                                            },
                                            child: Container(
                                              width: 55, height: 55,
                                              decoration: BoxDecoration(
                                                color: Colors.blueGrey.shade900.withValues(alpha: 0.6),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 2),
                                              ),
                                              child: Icon(_isActiveMenuExpanded ? Icons.close : Icons.more_vert, color: Colors.cyanAccent, size: 28),
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOutCubic,
                                          height: _isActiveMenuExpanded ? 360.0 : 0.0, 
                                          alignment: !_isLeftHanded ? Alignment.topRight : Alignment.topLeft,
                                          child: RawScrollbar(
                                            controller: _activeMenuScrollController,
                                            thumbVisibility: true,
                                            thumbColor: Colors.cyanAccent.withValues(alpha: 0.4),
                                            radius: const Radius.circular(20),
                                            thickness: 4,
                                            crossAxisMargin: 0,
                                            scrollbarOrientation: _isLeftHanded ? ScrollbarOrientation.left : ScrollbarOrientation.right,
                                            child: SingleChildScrollView(
                                              controller: _activeMenuScrollController,
                                              physics: const BouncingScrollPhysics(),
                                              child: Padding(
                                                padding: EdgeInsets.only(right: !_isLeftHanded ? 12.0 : 0.0, left: _isLeftHanded ? 12.0 : 0.0),
                                                child: Column(
                                                  crossAxisAlignment: !_isLeftHanded ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 15),

                                                    if (isGroup)
                                                      _buildLabeledMenuBtn(Icons.touch_app, Colors.orangeAccent, _t('nudge_grp'), () => _runSafeAction(() {
                                                        setState(() => _isActiveMenuExpanded = false);
                                                        _openSubOrbit(SubOrbitType.nudge);
                                                      })),

                                                    _buildLabeledMenuBtn(Icons.add_reaction, Colors.pinkAccent, "Emoji", () => _runSafeAction(() {
                                                      setState(() => _isActiveMenuExpanded = false);
                                                      _openSubOrbit(SubOrbitType.emojis);
                                                    })),

                                                    _buildLabeledMenuBtn(Icons.thumb_up, Colors.greenAccent, _t('roger'), () => _runSafeAction(() {
                                                      setState(() => _isActiveMenuExpanded = false);
                                                      _triggerReaction("👍");
                                                      if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ } }
                                                      
                                                      String contactIdentifier = allContacts[activeIndex]['name'] ?? allContacts[activeIndex]['phone'];
                                                      
                                                      if (isGroup) {
                                                        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
                                                        for (var m in members) {
                                                          SocketService().sendRogerThat(m.toString(), _currentUserPhone!, _userName);
                                                        }
                                                      } else {
                                                        SocketService().sendRogerThat(allContacts[activeIndex]['phone'], _currentUserPhone!, _userName);
                                                      }
                                                      
                                                      _logInteraction(contactIdentifier: contactIdentifier, isMe: true, emoji: "👍"); // 🟢 LOG
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('roger_sent'))));
                                                    })),

                                                    _buildLabeledMenuBtn(Icons.graphic_eq, Colors.cyanAccent, _t('voice_fx'), () => _runSafeAction(() {
                                                      setState(() => _isActiveMenuExpanded = false);
                                                      _openSubOrbit(SubOrbitType.effects);
                                                    })),

                                                    _buildLabeledMenuBtn(_mutedContacts.contains(activeContactName) ? Icons.volume_off : Icons.volume_up, Colors.purpleAccent, _mutedContacts.contains(activeContactName) ? _t('unmute') : _t('mute'), () => _runSafeAction(() {
                                                      setState(() {
                                                        if (_mutedContacts.contains(activeContactName)) {
                                                          _mutedContacts.remove(activeContactName);
                                                        } else {
                                                          _mutedContacts.add(activeContactName);
                                                          if (isCurrentlyLive) { _endLiveConnection(); }
                                                        }
                                                        _isActiveMenuExpanded = false;
                                                      });
                                                    })),

                                                    _buildLabeledMenuBtn(Icons.format_color_fill, Colors.tealAccent, _t('bg_color'), () => _runSafeAction(() {
                                                      setState(() => _isActiveMenuExpanded = false);
                                                      _openSubOrbit(SubOrbitType.background);
                                                    })),

                                                    _buildLabeledMenuBtn(_showOnlyUnread ? Icons.filter_list_off : Icons.filter_list, Colors.amber, _t('filter'), () => _runSafeAction(() {
                                                      setState(() {
                                                        _showOnlyUnread = !_showOnlyUnread;
                                                        _isActiveMenuExpanded = false;
                                                      });
                                                      if (hapticEnabled) { try { HapticFeedback.lightImpact(); } catch (_) { /* ignore */ } }
                                                    })),

                                                    _buildLabeledMenuBtn(_blockedContacts.contains(activeContactName) ? Icons.block : Icons.check_circle_outline, Colors.deepOrange, _blockedContacts.contains(activeContactName) ? _t('unblock') : _t('block'), () => _runSafeAction(() {
                                                      setState(() {
                                                        if (_blockedContacts.contains(activeContactName)) {
                                                          _blockedContacts.remove(activeContactName);
                                                        } else {
                                                          _blockedContacts.add(activeContactName);
                                                          if (isCurrentlyLive) { _endLiveConnection(); }
                                                        }
                                                        _isActiveMenuExpanded = false;
                                                      });
                                                    })),

                                                    _buildLabeledMenuBtn(Icons.delete_outline, Colors.redAccent, _t('rm_orbit'), () => _runSafeAction(() {
                                                      setState(() => _isActiveMenuExpanded = false);
                                                      _promptDeleteActiveContact();
                                                    })),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (_activeSubOrbit != SubOrbitType.none)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () {
                                      _subScrollPhysicsController.stop();
                                      setState(() => _activeSubOrbit = SubOrbitType.none);
                                  },
                                  onPanStart: (details) {
                                      _subScrollPhysicsController.stop(); 
                                      double dx = details.localPosition.dx - menuX;
                                      double dy = details.localPosition.dy - menuY;
                                      _lastSubDragAngle = math.atan2(dy, dx);
                                      _isValidSubOrbitDrag = true;
                                  },
                                  onPanUpdate: (details) {
                                    if (!_isValidSubOrbitDrag) return;
                                    double dx = details.localPosition.dx - menuX;
                                    double dy = details.localPosition.dy - menuY;
                                    double currentAngle = math.atan2(dy, dx);
                                    double deltaAngle = currentAngle - _lastSubDragAngle;

                                    if (deltaAngle > math.pi) deltaAngle -= 2 * math.pi;
                                    if (deltaAngle < -math.pi) deltaAngle += 2 * math.pi;

                                    deltaAngle *= 0.5;

                                    setState(() {
                                      if (_isLeftHanded) {
                                        _subOrbitScrollOffset -= deltaAngle;
                                      } else {
                                        _subOrbitScrollOffset += deltaAngle;
                                      }
                                      
                                      if (_subOrbitScrollOffset < -0.2) {
                                        _subOrbitScrollOffset = -0.2;
                                      }
                                      if (_subOrbitScrollOffset > maxSubScroll) {
                                        _subOrbitScrollOffset = maxSubScroll;
                                      }
                                      
                                      _lastSubDragAngle = currentAngle;

                                      if (_ratchetEnabled) {
                                        _subRatchetAccumulator += deltaAngle.abs();
                                        double threshold = Platform.isAndroid ? 0.20 : 0.15;
                                        int debounceTime = Platform.isAndroid ? 120 : 80;
                                        
                                        if (_subRatchetAccumulator >= threshold) {
                                          _subRatchetAccumulator -= threshold;
                                          int now = DateTime.now().millisecondsSinceEpoch;
                                          if (now - _lastSubRatchetTime > debounceTime) {
                                            _lastSubRatchetTime = now;
                                            if (hapticEnabled) {
                                              try {
                                                if (Platform.isAndroid) HapticFeedback.vibrate();
                                                else HapticFeedback.selectionClick();
                                              } catch (_) {}
                                            }
                                          }
                                        }
                                      }
                                    });
                                  },
                                  onPanEnd: (details) {
                                      _isValidSubOrbitDrag = false;
                                      double velocity = details.velocity.pixelsPerSecond.dx + details.velocity.pixelsPerSecond.dy;
                                      _runPhysicsSimulation(velocity, _subScrollPhysicsController, _subOrbitScrollOffset, maxSubScroll);
                                  },
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Stack(
                                        children: [
                                          
                                          Positioned(
                                            top: 100, 
                                            left: 0, right: 0,
                                            child: Center(
                                              child: Text(
                                                _activeSubOrbit == SubOrbitType.effects ? _t('choose_fx') :
                                                _activeSubOrbit == SubOrbitType.background ? _t('choose_bg') :
                                                _activeSubOrbit == SubOrbitType.emojis ? _t('send_re_title') : _t('nudge_grp_title'),
                                                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                                              ),
                                            ),
                                          ),
                                          
                                          ...List.generate(_getSubOrbitItems().length, (index) {
                                            final items = _getSubOrbitItems();
                                            return OrbitSubItemNode(
                                              index: index,
                                              item: items[index],
                                              itemSpacingAngle: itemSpacingAngle,
                                              scrollOffset: _subOrbitScrollOffset,
                                              menuX: menuX,
                                              menuY: menuY,
                                              orbitRadius: orbitRadius,
                                              isLeftHanded: _isLeftHanded,
                                              onTap: () => _onSubItemTapped(items[index]),
                                            );
                                          }).reversed,

                                          if (_activeSubOrbit == SubOrbitType.nudge)
                                            Positioned(
                                              left: menuX - 55, top: menuY - 55,
                                              child: GestureDetector(
                                                onTap: () => _runSafeAction(() {
                                                  if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ } }
                                                  
                                                  String contactIdentifier = allContacts[activeIndex]['name'] ?? allContacts[activeIndex]['phone'];
                                                  
                                                  List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
                                                  for(var m in members) {
                                                    SocketService().sendNudge(m.toString(), _currentUserPhone!, _userName);
                                                  }
                                                  
                                                  _logInteraction(contactIdentifier: contactIdentifier, isMe: true, isNudge: true); // 🟢 LOG
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('all_nudged'))));
                                                  setState(() => _activeSubOrbit = SubOrbitType.none);
                                                }),
                                                child: Container(
                                                  width: 110, height: 110,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.orange.withValues(alpha: 0.15),
                                                      border: Border.all(color: Colors.orangeAccent, width: 2),
                                                      boxShadow: [BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.3), blurRadius: 15)]
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(Icons.groups, color: Colors.orangeAccent, size: 32),
                                                      const SizedBox(height: 4),
                                                      Text(_t('nudge_all'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            if (showSearchField)
                              Positioned(
                                top: menuY - 250,
                                left: _isLeftHanded ? null : 30, right: _isLeftHanded ? 30 : null,
                                child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: OrbitSearchField(controller: _searchController, focusNode: _focusNode,hintText: _t('search_orbit'), onChanged: _handleSearch, onClear: () { _searchController.clear(); _handleSearch(""); })),
                              ),
                              
                            Positioned(
                              left: menuX - 162.5, 
                              top: menuY - 162.5,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: (showSearchField || anyMenuExpanded) ? 0.15 : 1.0,
                                child: Transform.scale(
                                  scale: 1.1,
                                  child: IgnorePointer(
                                    ignoring: showSearchField || anyMenuExpanded,
                                    child: OrbitPttArea(
                                      isIncomingCallActive: _isIncomingCallActive,
                                      isRecording: isRecording,
                                      isCancelled: _isCancelled,
                                      isWaitingForLiveApproval: isWaitingForLiveApproval,
                                      isLive: anyLiveActive,
                                      isLeftHanded: _isLeftHanded,
                                      dragOffset: _dragOffset,
                                      dragVerticalOffset: _dragVerticalOffset,
                                      pttSlideOffset: _pttSlideOffset,
                                      hapticRejectPulseController: _hapticRejectPulseController,
                                      hapticAcceptPulseController: _hapticAcceptPulseController,
                                      entranceController: _entranceController,
                                      pulseController: _pulseController,
                                      audioLevel: _audioLevel,
                                      recordDurationText: _formatDuration(_recordDuration),
                                      isNodeBeingPulledInward: _interactionNodeIndex != -1 && _interactionNodeOffset <= -50,
                                      onPointerDown: isWaitingForLiveApproval ? (_) {} : (_) { if (!_isIncomingCallActive) _startRecording(); },
                                      onPointerMove: (details) { 
                                        if (_isIncomingCallActive) { 
                                          setState(() { 
                                            _pttSlideOffset += details.delta.dx; 
                                            _pttSlideOffset = _pttSlideOffset.clamp(-100.0, 100.0); 
                                          }); 
                                        } else { 
                                          _updateRecordingPointer(details); 
                                        } 
                                      },
                                      onPointerUp: (_) {
                                        if (_isIncomingCallActive) {
                                          if (_pttSlideOffset > 70) { _acceptIncomingCall(); } 
                                          else if (_pttSlideOffset < -70) { _rejectIncomingCall(); } 
                                          else { setState(() { _pttSlideOffset = 0.0; }); }
                                        } else { 
                                          _stopRecording(); 
                                        }
                                      },
                                      onPointerCancel: (_) { 
                                        if (_isIncomingCallActive) { 
                                          setState(() { _pttSlideOffset = 0.0; }); 
                                        } else { 
                                          _stopRecording(); 
                                        } 
                                      },
                                      onTapCancelCall: () { if (isWaitingForLiveApproval) _cancelOutgoingCall(); },
                                      buildCallingWave: (index) {
                                        return AnimatedBuilder(
                                          animation: _breatheController,
                                          builder: (context, child) {
                                            double sizeMultiplier = 1.0 + (_breatheController.value * (0.3 + (index * 0.2)));
                                            return Container(
                                              width: 117 * sizeMultiplier, 
                                              height: 117 * sizeMultiplier, 
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle, 
                                                border: Border.all(
                                                  color: Colors.redAccent.withValues(alpha: (0.3 - (_breatheController.value * 0.2)).clamp(0.0, 1.0)), 
                                                  width: 2.0
                                                )
                                              )
                                            );
                                          }
                                        );
                                      },
                                      buildRealWave: (index) {
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
                                                  width: 117 * val, 
                                                  height: 117 * val, 
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle, 
                                                    border: Border.all(
                                                      color: Colors.redAccent.withValues(alpha: (0.4 - (level * 0.2)).clamp(0.1, 1.0)), 
                                                      width: 2 + (level * 2)
                                                    )
                                                  )
                                                ); 
                                              },
                                            );
                                          },
                                        );
                                      },
                                    )
                                  ),
                                ),
                              ),
                            ),

                            if (!showSearchField && _activeSubOrbit == SubOrbitType.none)
                              Positioned(
                                left: !_isLeftHanded ? 20.0 : null, right: _isLeftHanded ? 20.0 : null, top: menuY - 150,
                                child: GhostHandToggle(isLeftHanded: _isLeftHanded, onToggle: () {
                                  setState(() { _isLeftHanded = !_isLeftHanded; });
                                  if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ } }
                                },),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
              );
            }
        )
    );
  }
}

class FlyingEmoji {
  final String id;
  final String emoji;
  final double startX;
  final String? senderName;

  FlyingEmoji({
    required this.id,
    required this.emoji,
    required this.startX,
    this.senderName,
  });
}
