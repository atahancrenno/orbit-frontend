// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
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
import 'orbit_plus_screen.dart';

// 🟢 GOOGLE ADMOB IMPORTU
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum UserStatus { available, busy, away, offline }
enum SubOrbitType { none, effects, emojis, nudge }

class OrbitMainScreen extends StatefulWidget {
  const OrbitMainScreen({super.key});
  @override
  State<OrbitMainScreen> createState() => _OrbitMainScreenState();
}

class _OrbitMainScreenState extends State<OrbitMainScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
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

  double _scrollOffset = 0.0;
  int activeIndex = -1;
  bool _showConnectionArrows = false;
  Timer? _arrowsTimer;
  Timer? _outgoingCallTimer;
  Timer? _incomingRingTimer;
  Timer? _vibrationTimer;

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
  double _subOrbitScrollOffset = 0.0;

  final ScrollController _activeMenuScrollController = ScrollController();
  final ScrollController _mainMenuScrollController = ScrollController();

  String _currentLang = 'tr';

  // 🟢 ÖDÜLLÜ REKLAM DEĞİŞKENLERİ
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  String _t(String key) {
    const Map<String, Map<String, String>> dict = {
      'invite': {'tr': 'Davet Et', 'en': 'Invite', 'de': 'Einladen', 'ru': 'Пригласить', 'es': 'Invitar', 'ar': 'دعوة'},
      'search': {'tr': 'Arama', 'en': 'Search', 'de': 'Suche', 'ru': 'Поиск', 'es': 'Buscar', 'ar': 'بحث'},
      'saved': {'tr': 'Kayıtlılar', 'en': 'Saved', 'de': 'Gespeichert', 'ru': 'Сохраненные', 'es': 'Guardados', 'ar': 'المحفوظات'},
      'add_contact': {'tr': 'Kişi Ekle', 'en': 'Add Contact', 'de': 'Kontakt +', 'ru': 'Добавить', 'es': 'Añadir', 'ar': 'إضافة جهة اتصال'},
      'settings': {'tr': 'Ayarlar', 'en': 'Settings', 'de': 'Einstellungen', 'ru': 'Настройки', 'es': 'Ajustes', 'ar': 'الإعدادات'},
      'nudge_grp': {'tr': 'Grubu Dürt', 'en': 'Nudge Group', 'de': 'Gruppe anstupsen', 'ru': 'Торкнуть группу', 'es': 'Dar toque', 'ar': 'نكز المجموعة'},
      'send_react': {'tr': 'Tepki Gönder', 'en': 'Send Reaction', 'de': 'Reaktion senden', 'ru': 'Отпр. реакцию', 'es': 'Enviar reacción', 'ar': 'إرسال تفاعل'},
      'voice_fx': {'tr': 'Ses Efekti', 'en': 'Voice Effect', 'de': 'Spracheffekt', 'ru': 'Голос. эффект', 'es': 'Efecto de voz', 'ar': 'تأثير الصوت'},
      'roger': {'tr': 'Anlaşıldı', 'en': 'Got it', 'de': 'Verstanden', 'ru': 'Понятно', 'es': 'Entendido', 'ar': 'مفهوم'},
      'filter': {'tr': 'Okunmamışları Filtrele', 'en': 'Filter Unread', 'de': 'Ungelesene filtern', 'ru': 'Фильтр', 'es': 'Filtrar no leídos', 'ar': 'تصفية غير المقروءة'},
      'unmute': {'tr': 'Sesi Aç', 'en': 'Unmute', 'de': 'Ton an', 'ru': 'Вкл. звук', 'es': 'Activar sonido', 'ar': 'إلغاء كتم الصوت'},
      'mute': {'tr': 'Sessize Al', 'en': 'Mute', 'de': 'Stummschalten', 'ru': 'Выкл. звук', 'es': 'Silenciar', 'ar': 'كتم الصوت'},
      'unblock': {'tr': 'Engeli Kaldır', 'en': 'Unblock', 'de': 'Entblocken', 'ru': 'Разблокировать', 'es': 'Desbloquear', 'ar': 'إلغاء الحظر'},
      'block': {'tr': 'Engelle', 'en': 'Block', 'de': 'Blockieren', 'ru': 'Заблокировать', 'es': 'Bloquear', 'ar': 'حظر'},
      'rm_orbit': {'tr': 'Yörüngeden Çıkar', 'en': 'Remove from Orbit', 'de': 'Aus Orbit entfernen', 'ru': 'Удалить с орбиты', 'es': 'Quitar de órbita', 'ar': 'إزالة من المدار'},
      'disconnect': {'tr': 'Bağlantıyı Kes', 'en': 'Disconnect', 'de': 'Trennen', 'ru': 'Отключиться', 'es': 'Desconectar', 'ar': 'قطع الاتصال'},
      'cancel': {'tr': 'İptal Et', 'en': 'Cancel', 'de': 'Abbrechen', 'ru': 'Отмена', 'es': 'Cancelar', 'ar': 'إلغاء'},
      'offline': {'tr': 'Çevrimdışı', 'en': 'Offline', 'de': 'Offline', 'ru': 'Не в сети', 'es': 'Desconectado', 'ar': 'غير متصل'},
      'online': {'tr': 'Çevrimiçi', 'en': 'Online', 'de': 'Online', 'ru': 'В сети', 'es': 'En línea', 'ar': 'متصل'},
      'is_spk': {'tr': 'konuşuyor...', 'en': 'is speaking...', 'de': 'spricht...', 'ru': 'говорит...', 'es': 'está hablando...', 'ar': 'يتحدث...'},
      'replying': {'tr': 'Yanıtlanıyor: ', 'en': 'Replying: ', 'de': 'Antworten: ', 'ru': 'Отвечает: ', 'es': 'Respondiendo: ', 'ar': 'يتم الرد: '},
      'choose_fx': {'tr': 'SES EFEKTİ SEÇ', 'en': 'CHOOSE VOICE EFFECT', 'de': 'SPRACHEFFEKT WÄHLEN', 'ru': 'ВЫБРАТЬ ГОЛОСОВОЙ ЭФФЕКТ', 'es': 'ELEGIR EFECTO DE VOZ', 'ar': 'اختر تأثير الصوت'},
      'send_re_title': {'tr': 'TEPKİ GÖNDER', 'en': 'SEND REACTION', 'de': 'REAKTION SENDEN', 'ru': 'ОТПРАВИТЬ РЕАКЦИЮ', 'es': 'ENVIAR REACCIÓN', 'ar': 'إرسال تفاعل'},
      'nudge_grp_title': {'tr': 'GRUBUNU DÜRT', 'en': 'NUDGE GROUP', 'de': 'GRUPPE ANSTUPSEN', 'ru': 'ТОРКНУТЬ ГРУППУ', 'es': 'DAR TOQUE AL GRUPO', 'ar': 'نكز المجموعة'},
      'nudge_all': {'tr': 'TÜMÜNÜ\nDÜRT', 'en': 'NUDGE\nALL', 'de': 'ALLE\nANSTUPSEN', 'ru': 'ТОРКНУТЬ\nВСЕХ', 'es': 'TOCAR A\nTODOS', 'ar': 'نكز\nالجميع'},
      'unknown': {'tr': 'Bilinmeyen', 'en': 'Unknown', 'de': 'Unbekannt', 'ru': 'Неизвестный', 'es': 'Desconocido', 'ar': 'غير معروف'},
      'is_busy': {'tr': 'şu an meşgul.', 'en': 'is busy right now.', 'de': 'ist gerade beschäftigt.', 'ru': 'сейчас занят.', 'es': 'está ocupado ahora.', 'ar': 'مشغول الآن.'},
      'calling': {'tr': 'aranıyor...', 'en': 'calling...', 'de': 'ruft an...', 'ru': 'звонок...', 'es': 'llamando...', 'ar': 'يتصل...'},
      'call_not_ans': {'tr': 'Davet isteği yanıtlanmadı.', 'en': 'Call request not answered.', 'de': 'Anrufanfrage nicht beantwortet.', 'ru': 'На звонок не ответили.', 'es': 'Llamada no respondida.', 'ar': 'لم يتم الرد على طلب المكالمة.'},
      'call_canc': {'tr': 'Arama iptal edildi.', 'en': 'Call cancelled.', 'de': 'Anruf abgebrochen.', 'ru': 'Звонок отменен.', 'es': 'Llamada cancelada.', 'ar': 'تم إلغاء المكالمة.'},
      'roger_sent': {'tr': 'Anlaşıldı gönderildi ✅', 'en': 'Message acknowledged ✅', 'de': 'Verstanden gesendet ✅', 'ru': 'Принято отправлено ✅', 'es': 'Recibido enviado ✅', 'ar': 'تم إرسال علم ✅'},
      'all_nudged': {'tr': 'Tüm grup dürtüldü!', 'en': 'Whole group nudged!', 'de': 'Ganze Gruppe angestupst!', 'ru': 'Вся группа торкнута!', 'es': '¡Todo el grupo tocado!', 'ar': 'تم نكز المجموعة بأكملها!'},
      'sent_react': {'tr': 'sana bir tepki gönderdi.', 'en': 'sent you a reaction.', 'de': 'hat dir eine Reaktion gesendet.', 'ru': 'отправил(а) вам реакцию.', 'es': 'te envió una reacción.', 'ar': 'أرسل لك تفاعلاً.'},
      'attention': {'tr': 'DİKKAT! telsize çağırıyor!', 'en': 'ATTENTION! calling you to voice chat!', 'de': 'ACHTUNG! ruft dich an!', 'ru': 'ВНИМАНИЕ! вызывает вас!', 'es': '¡ATENCIÓN! te llama al chat de voz!', 'ar': 'انتباه! يدعوك للمحادثة الصوتية!'},
      'new_msg': {'tr': 'yeni mesaj gönderdi.', 'en': 'sent a new message.', 'de': 'hat eine neue Nachricht gesendet.', 'ru': 'отправил(а) новое сообщение.', 'es': 'envió un nuevo mensaje.', 'ar': 'أرسل رسالة جديدة.'},
      'not_answering': {'tr': 'cevap vermiyor.', 'en': 'is not answering.', 'de': 'antwortet nicht.', 'ru': 'не отвечает.', 'es': 'no contesta.', 'ar': 'لا يرد.'},
      'reject_busy': {'tr': 'çağrıyı reddetti veya meşgul.', 'en': 'rejected the call or is busy.', 'de': 'hat den Anruf abgelehnt oder ist beschäftigt.', 'ru': 'отклонил звонок или занят.', 'es': 'rechazó la llamada o está ocupado.', 'ar': 'رفض المكالمة أو مشغول.'},
      'disconnected': {'tr': 'bağlantıyı kopardı.', 'en': 'disconnected.', 'de': 'hat die Verbindung getrennt.', 'ru': 'отключился.', 'es': 'se desconectó.', 'ar': 'قطع الاتصال.'},
      'accepted_call': {'tr': 'çağrısını kabul etti!', 'en': 'accepted the call!', 'de': 'hat den Anruf angenommen!', 'ru': 'принял вызов!', 'es': '¡aceptó la llamada!', 'ar': 'قبل مكالمة!'},
      'missed_call': {'tr': 'Cevapsız çağrı:', 'en': 'Missed call:', 'de': 'Verpasster Anruf:', 'ru': 'Пропущенный звонок:', 'es': 'Llamada perdida:', 'ar': 'مكالمة فائتة:'},
      'del_warn': {'tr': 'adlı kişiyi yörüngeden çıkarmak istediğine emin misin?', 'en': 'are you sure you want to remove this user from your orbit?', 'de': 'sind Sie sicher, dass Sie diesen Benutzer entfernen möchten?', 'ru': 'вы уверены, что хотите удалить этого пользователя с орбиты?', 'es': '¿seguro que quieres quitar a este usuario de tu órbita?', 'ar': 'هل أنت متأكد أنك تريد إزالة هذا المستخدم من مدارك؟'},
      'del_btn': {'tr': 'SİL', 'en': 'DELETE', 'de': 'LÖSCHEN', 'ru': 'УДАЛИТЬ', 'es': 'ELIMINAR', 'ar': 'حذف'},
      'removed': {'tr': 'orbitten çıkartıldı.', 'en': 'removed from orbit.', 'de': 'aus dem Orbit entfernt.', 'ru': 'удален с орбиты.', 'es': 'eliminado de la órbita.', 'ar': 'تمت إزالته من المدار.'},
      'Normal': {'tr': 'Normal', 'en': 'Normal', 'de': 'Normal', 'ru': 'Нормальный', 'es': 'Normal', 'ar': 'عادي'},
      'Askeri': {'tr': 'Megafon', 'en': 'Megaphone', 'de': 'Megafon', 'ru': 'Военный', 'es': 'Megáfono', 'ar': 'مكبر الصوت'},
      'Megafon': {'tr': 'Stadyum', 'en': 'Stadium', 'de': 'Stadion', 'ru': 'Рупор', 'es': 'Estadio', 'ar': 'ملعب'},
      'Anonim': {'tr': 'Anonim', 'en': 'Anonymous', 'de': 'Anonym', 'ru': 'Аноним', 'es': 'Anónimo', 'ar': 'مجهول'},
      'Helyum': {'tr': 'Helyum', 'en': 'Helium', 'de': 'Helium', 'ru': 'Гелий', 'es': 'Helio', 'ar': 'هيليوم'},
      'Robot': {'tr': 'Robot', 'en': 'Robot', 'de': 'Roboter', 'ru': 'Робот', 'es': 'Robot', 'ar': 'روبوت'},
      'Uzaylı': {'tr': 'Uzaylı', 'en': 'Alien', 'de': 'Alien', 'ru': 'Инопланетянин', 'es': 'Extraterrestre', 'ar': 'كائن فضائي'},
      'Mağara': {'tr': 'Mağara', 'en': 'Cave', 'de': 'Höhle', 'ru': 'Пещера', 'es': 'Cueva', 'ar': 'كهف'},
      'Canavar': {'tr': 'Canavar', 'en': 'Monster', 'de': 'Monster', 'ru': 'Монстр', 'es': 'Monstruo', 'ar': 'وحش'},
      'Radyo': {'tr': 'Radyo', 'en': 'Radio', 'de': 'Radio', 'ru': 'Радио', 'es': 'Radio', 'ar': 'راديو'},
      'search_orbit': {'tr': 'Orbitte Ara...', 'en': 'Search Orbit...', 'de': 'Suchen...', 'ru': 'Поиск...', 'es': 'Buscar...', 'ar': 'البحث في المدار...'},
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
    {"name": "Mağara", "icon": Icons.waves, "color": Colors.indigoAccent},
    {"name": "Canavar", "icon": Icons.coronavirus, "color": Colors.redAccent},
    {"name": "Radyo", "icon": Icons.speaker, "color": Colors.orangeAccent},
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

  // 🟢 1. DÜRTME LİMİTİ (Max 5, Reklamla Yenilenir)
  Future<void> _handleNudgeWithLimit(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    int nudgesLeft = prefs.getInt('nudge_limit') ?? 5;

    if (nudgesLeft > 0) {
      String phone = item['phone'];
      SocketService().sendNudge(phone, _currentUserPhone!, _userName);
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
    setState(() => _activeSubOrbit = SubOrbitType.none);
  }

  // 🟢 2. YÖRÜNGEDEN ÇIKARMA LİMİTİ (Max 5 Değişim)
  Future<bool> _checkRemovalLimit() async {
    final prefs = await SharedPreferences.getInstance();
    int removalCount = prefs.getInt('orbit_removal_count') ?? 0;

    if (removalCount >= 5) {
      _showLimitDialog("Değişim Limiti Doldu", "Ücretsiz sürümde yörüngeden en fazla 5 kişi çıkarabilirsiniz. Sınırları kaldırmak için Orbit Plus'a geçin veya reklam izleyerek +3 hak kazanın.", true, () async {
        final p = await SharedPreferences.getInstance();
        await p.setInt('orbit_removal_count', 2); // 3 hak vermiş olduk (5 - 3 = 2)
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("+3 yeni silme/değişim hakkı eklendi!")));
      });
      return false; // Silme işlemine izin verme
    }
    await prefs.setInt('orbit_removal_count', removalCount + 1);
    return true; // İzin ver
  }

  // 🟢 3. YÖRÜNGEYE EKLEME LİMİTİ (Max 12 Kapasite - Zırhlı Kontrol)
  Future<bool> _checkAdditionLimit() async {
    // Hafızadan kullanıcının Plus durumunu çek
    final prefs = await SharedPreferences.getInstance();
    bool isPlusUser = prefs.getBool('is_orbit_plus') ?? false;

    int currentContactCount = allContacts.where((c) => c['isEmpty'] != true).length;

    // Eğer 12 sınırına dayanmışsa VE kullanıcı Plus DEĞİLSE
    if (currentContactCount >= 12 && !isPlusUser) {
      _showLimitDialog("Yörünge Doldu", "Yörüngene en fazla 12 kişi veya grup ekleyebilirsin. Kapasiteyi tamamen kaldırmak için Orbit Plus'a geç!", false, null);
      return false;
    }
    
    return true; // Limit aşılmadıysa veya kullanıcı Plus ise izin ver
  }

  // 🟢 4. ORTAK LİMİT DİYALOG EKRANI
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrbitPlusScreen()));
            },
            child: const Text("Plus'a Geç", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRewardedAdGeneric(VoidCallback? onReward) {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        if (onReward != null) onReward();
        _isAdLoaded = false;
        _loadRewardedAd();
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
      if (isGroupNode) {
        List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
        for (var m in members) {
          SocketService().sendReaction(m.toString(), _currentUserPhone!, emoji);
        }
      } else {
        String targetPhone = allContacts[activeIndex]['phone'];
        SocketService().sendReaction(targetPhone, _currentUserPhone!, emoji);
      }
    }

    setState(() {
      _recentEmojis.remove(emoji);
      _recentEmojis.insert(0, emoji);
      if (_recentEmojis.length > 4) {
        _recentEmojis = _recentEmojis.sublist(0, 4);
      }
    });
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

  void _onSubItemTapped(Map<String, dynamic> item) {
    if (hapticEnabled) {
      try { HapticFeedback.selectionClick(); } catch (_) {}
    }

    if (_activeSubOrbit == SubOrbitType.effects) {
      _handleEffectSelection(item['name']);
    } else if (_activeSubOrbit == SubOrbitType.emojis) {
      _handleEmojiSelection(item['emoji']);
    } else if (_activeSubOrbit == SubOrbitType.nudge) {
      _handleNudgeWithLimit(item); // 🟢 LİMİTLİ DÜRTME EKLENDİ
    }

    if (_activeSubOrbit != SubOrbitType.nudge) {
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
    if (_isProcessingLiveQueue || _liveAudioQueue.isEmpty) {
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
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Google Test ID
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

  @override
  void initState() {
    super.initState();
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
    _liveTimers[contactPhone] = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        if (isRecording || _whoIsSpeaking == contactPhone || _isCurrentlyPlayingOrRecording || _liveAudioQueue.isNotEmpty) {
          _resetLiveTimeoutForContact(contactPhone);
          return;
        }
        setState(() {
          _activeLiveContacts.remove(contactPhone);
          _liveTimers.remove(contactPhone);
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
          } else {
            if (_whoIsSpeaking == callerId) {
              _whoIsSpeaking = null;
            }
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
        int idx = allContacts.indexWhere((c) => c['phone'] == callerId);
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
        int idx = allContacts.indexWhere((c) => c['phone'] == senderId);
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
      if (!mounted) {
        return;
      }
      if (_blockedContacts.contains(senderId)) {
        return;
      }
      for (int i = 0; i < 5; i++) {
        if (hapticEnabled) { try { HapticFeedback.vibrate(); } catch (_) {} }
        await Future.delayed(const Duration(milliseconds: 400));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String txt = _t('attention');
        String p1 = '${txt.split('!')[0]}!';
        String p2 = txt.substring(p1.length).trim();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.vibration, color: Colors.orangeAccent), const SizedBox(width: 10), Expanded(child: Text("$p1 $senderName $p2", style: const TextStyle(fontWeight: FontWeight.bold)))]), backgroundColor: Colors.deepOrange.shade900, behavior: SnackBarBehavior.floating));
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

    _callRingtone = prefs.getString('call_ringtone') ?? "";
    _ratchetEnabled = prefs.getBool('ratchet_enabled') ?? true;

    if (_currentUserPhone != null && _currentUserPhone!.isNotEmpty) {
      SocketService().initConnection(_currentUserPhone!);
      _isSocketStarted = true;
    }

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
      final response = await http.get(Uri.parse('http://192.168.1.7:3000/api/users'));
      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
        List<Map<String, dynamic>> fetchedContacts = [];
        for (var u in users) {
          String phone = u['phone']?.toString().replaceAll(RegExp(r'[^\d+]'), '') ?? "";
          if (_currentUserPhone != null && phone == _currentUserPhone) {
            continue;
          }
          String contactName = _localContactsMap.containsKey(phone) ? _localContactsMap[phone]! : (u['name'] != null && u['name'] != "Bilinmeyen Kullanıcı" ? u['name'] : phone);
          UserStatus statusEnum = (math.Random().nextBool()) ? UserStatus.available : UserStatus.offline;
          fetchedContacts.add({"name": contactName, "isGroup": false, "status": statusEnum, "uid": u['_id'], "phone": phone});
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
        for (int i = fetchedContacts.length; i < 7; i++) {
          fetchedContacts.add({"name": "Davet Et", "isEmpty": true});
        }
        if (mounted) {
          setState(() {
            originalContacts = fetchedContacts;
            if (isSearching) {
              _handleSearch(_searchController.text);
            } else {
              allContacts = List.from(originalContacts);
            }
          });
          _sortOrbitContactsByRecent();
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchPendingMessages() async {
    if (_currentUserPhone == null) {
      return;
    }
    try {
      final response = await http.get(Uri.parse('http://192.168.1.7:3000/api/messages/pending/$_currentUserPhone'));
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
      // ignore
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
    final status = await ph.Permission.contacts.status;
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
    _pulseController.dispose();
    _breatheController.dispose();
    _entranceController.dispose();
    _vibrationTimer?.cancel();
    _historyPlayer.dispose();
    _audioRecorder.dispose();
    _searchController.dispose();
    _hapticAcceptPulseController.dispose();
    _hapticRejectPulseController.dispose();
    _hapticTerminatePulseController.dispose();
    _notificationDebounceTimer?.cancel();
    _activeMenuScrollController.dispose();
    _mainMenuScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _appState = state;
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
      await _historyPlayer.stop();
      final session = await AudioSession.instance;
      session.setActive(false).catchError((_) => false);
      setState(() { msg.isPlaying = false; _isCurrentlyPlayingOrRecording = false; _currentlyPlayingMessage = null; });
    }
  }

  void _startRecording({bool isChunkContinue = false}) {
    if ((isRecording && !isChunkContinue) || activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) {
      return;
    }
    if (hapticEnabled && !isChunkContinue) {
      try { HapticFeedback.mediumImpact(); } catch (_) { /* ignore */ }
    }
    _recordTimer?.cancel(); _amplitudeTimer?.cancel(); _micDebounceTimer?.cancel();

    if (!isChunkContinue) {
      setState(() { isRecording = true; _isCurrentlyPlayingOrRecording = true; _recordDuration = 0; _dragOffset = 0.0; _dragVerticalOffset = 0.0; _isCancelled = false; });
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
      setState(() { isRecording = false; _audioLevel.value = 0.0; });
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
          var uri = Uri.parse('http://192.168.1.7:3000/api/upload');
          var request = http.MultipartRequest('POST', uri);
          request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
          request.fields['voiceEffect'] = _selectedVoiceEffect;

          var response = await request.send();
          if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var jsonResponse = jsonDecode(responseData);
            String audioUrl = jsonResponse['fileUrl'];

            if (_activeLiveContacts.isNotEmpty) {
              for(var target in _activeLiveContacts) {
                SocketService().sendAudio(target, audioUrl, newMsg.id);
                _resetLiveTimeoutForContact(target);
              }
            } else if (!isGroup) {
              SocketService().sendAudio(allContacts[activeIndex]['phone'], audioUrl, newMsg.id);
            }
          }
        } catch (e) { /* ignore */ }
      }
    }

    if (isChunk && isRecording) {
      _startRecording(isChunkContinue: true);
    } else {
      setState(() { _dragOffset = 0.0; _dragVerticalOffset = 0.0; _isCancelled = false; _replyingToMessage = null; });
    }
  }

  void _updateRecordingPointer(PointerMoveEvent event) {
    if (!isRecording) {
      return;
    }
    bool isLive = _activeLiveContacts.isNotEmpty;
    setState(() {
      double moveDelta = event.localDelta.dx;
      if (_isLeftHanded) {
        _dragOffset += moveDelta; _dragOffset = _dragOffset.clamp(0.0, 150.0);
      } else {
        _dragOffset += moveDelta; _dragOffset = _dragOffset.clamp(-150.0, 0.0);
      }

      if (isLive && event.localDelta.dy > 0) {
        _dragVerticalOffset += event.localDelta.dy;
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

  // 🟢 EFEKT KİLİT VE REKLAM YÖNETİMİ
  Future<void> _handleEffectSelection(String effectName) async {
    if (effectName == 'Normal') {
      setState(() { _selectedVoiceEffect = effectName; });
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
            "Bu ajan frekansını 1 saat boyunca sınırsız kullanmak için kısa bir veri aktarımı (Reklam) izlemeniz gerekiyor.",
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
              label: const Text('Kilidi Aç'),
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
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
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
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
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
    
    // 🟢 LİMİT KONTROLÜ
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

  @override
  Widget build(BuildContext context) {
    TextDirection layoutDirection = _currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

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
                    double menuY = screenHeight - 280.0;
                    double itemSpacingAngle = 0.25 * math.pi;
                    double maxScroll = (allContacts.length * itemSpacingAngle) - (4 * itemSpacingAngle);
                    if (maxScroll < 0) {
                      maxScroll = 0;
                    }

                    String activeContactName = activeIndex != -1 ? allContacts[activeIndex]['name'] : "";
                    bool isGroup = activeIndex != -1 ? (allContacts[activeIndex]['isGroup'] ?? false) : false;

                    bool isCurrentlyLive = false;

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
                        },

                        child: Stack(
                          children: [
                            if (_customBackgroundImagePath != null)
                              Positioned.fill(child: Image.file(File(_customBackgroundImagePath!), fit: BoxFit.cover))
                            else if (!isBackgroundTransparent)
                              Container(color: Colors.black)
                            else
                              Positioned.fill(child: Container(color: Colors.black)),

                            if (_customBackgroundImagePath != null || isBackgroundTransparent)
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

                            // 🟢 ORBIT PLUS ANA EKRAN BUTONU
                            Positioned(
                              top: 50,
                              right: 20,
                              child: SafeArea(
                                child: GestureDetector(
                                  onTap: () {
                                    if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) {} }
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const OrbitPlusScreen()));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)],
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.stars, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text("Orbit Plus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
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
                                    Text(activeContactName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.5, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1))])),
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
                                      Text(allContacts[activeIndex]['status'] == UserStatus.offline ? _t('offline') : _t('online'), style: TextStyle(color: allContacts[activeIndex]['status'] == UserStatus.offline ? Colors.redAccent : Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],

                                    if (isCurrentlyLive) ...[
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: _endLiveConnection,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 1.5)),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.phone_disabled, size: 18, color: Colors.redAccent),
                                                const SizedBox(width: 8),
                                                Text(_t('disconnect'), style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold))
                                              ]
                                          ),
                                        ),
                                      ),
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

                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              right: !_isLeftHanded ? 8.0 : null,
                              left: _isLeftHanded ? 8.0 : null,
                              top: menuY - 40,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: (activeIndex == -1 || allContacts[activeIndex]['isEmpty'] == true) && !showSearchField ? 1.0 : 0.0,
                                child: IgnorePointer(
                                  ignoring: activeIndex != -1 || showSearchField,
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
                                        height: _isMenuExpanded ? 240 : 0,
                                        alignment: !_isLeftHanded ? Alignment.topRight : Alignment.topLeft,
                                        child: RawScrollbar(
                                          controller: _mainMenuScrollController,
                                          thumbVisibility: true,
                                          thumbColor: Colors.cyanAccent.withValues(alpha: 0.4),
                                          radius: const Radius.circular(20),
                                          thickness: 4,
                                          crossAxisMargin: 0,
                                          child: SingleChildScrollView(
                                            controller: _mainMenuScrollController,
                                            physics: const BouncingScrollPhysics(),
                                            child: Padding(
                                              padding: EdgeInsets.only(right: !_isLeftHanded ? 12.0 : 0.0, left: _isLeftHanded ? 12.0 : 0.0),
                                              child: Column(
                                                crossAxisAlignment: !_isLeftHanded ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 15),
                                                  _buildLabeledMenuBtn(Icons.search, Colors.cyanAccent, _t('search'), () {
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
                                                  }),
                                                  _buildLabeledMenuBtn(Icons.bookmark, _isArchiveMode ? Colors.orangeAccent : Colors.orangeAccent, _t('saved'), () {
                                                    _toggleArchiveMode();
                                                  }),
                                                  _buildLabeledMenuBtn(Icons.person_add, Colors.greenAccent, _t('add_contact'), () {
                                                    setState(() => _isMenuExpanded = false);
                                                    _openContacts();
                                                  }),
                                                  _buildLabeledMenuBtn(Icons.settings, Colors.grey, _t('settings'), () {
                                                    setState(() => _isMenuExpanded = false);
                                                    _openSettings();
                                                  }),
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

                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              right: !_isLeftHanded ? 8.0 : null,
                              left: _isLeftHanded ? 8.0 : null,
                              top: menuY - 40,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: 1.0,
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
                                      height: _isActiveMenuExpanded ? 260.0 : 0.0,
                                      alignment: !_isLeftHanded ? Alignment.topRight : Alignment.topLeft,
                                      child: RawScrollbar(
                                        controller: _activeMenuScrollController,
                                        thumbVisibility: true,
                                        thumbColor: Colors.cyanAccent.withValues(alpha: 0.4),
                                        radius: const Radius.circular(20),
                                        thickness: 4,
                                        crossAxisMargin: 0,
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
                                                  _buildLabeledMenuBtn(Icons.touch_app, Colors.orangeAccent, _t('nudge_grp'), () {
                                                    setState(() => _isActiveMenuExpanded = false);
                                                    _openSubOrbit(SubOrbitType.nudge);
                                                  }),

                                                _buildLabeledMenuBtn(Icons.add_reaction, Colors.pinkAccent, _t('send_react'), () {
                                                  setState(() => _isActiveMenuExpanded = false);
                                                  _openSubOrbit(SubOrbitType.emojis);
                                                }),

                                                _buildLabeledMenuBtn(Icons.graphic_eq, Colors.cyanAccent, _t('voice_fx'), () {
                                                  setState(() => _isActiveMenuExpanded = false);
                                                  _openSubOrbit(SubOrbitType.effects);
                                                }),

                                                _buildLabeledMenuBtn(Icons.thumb_up, Colors.greenAccent, _t('roger'), () {
                                                  setState(() => _isActiveMenuExpanded = false);
                                                  _triggerReaction("👍");
                                                  if (hapticEnabled) { try { HapticFeedback.selectionClick(); } catch (_) { /* ignore */ } }
                                                  if (isGroup) {
                                                    List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
                                                    for (var m in members) {
                                                      SocketService().sendRogerThat(m.toString(), _currentUserPhone!, _userName);
                                                    }
                                                  } else {
                                                    SocketService().sendRogerThat(allContacts[activeIndex]['phone'], _currentUserPhone!, _userName);
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('roger_sent'))));
                                                }),

                                                _buildLabeledMenuBtn(_showOnlyUnread ? Icons.filter_list_off : Icons.filter_list, Colors.amber, _t('filter'), () {
                                                  setState(() {
                                                    _showOnlyUnread = !_showOnlyUnread;
                                                    _isActiveMenuExpanded = false;
                                                  });
                                                  if (hapticEnabled) { try { HapticFeedback.lightImpact(); } catch (_) { /* ignore */ } }
                                                }),

                                                _buildLabeledMenuBtn(_mutedContacts.contains(activeContactName) ? Icons.volume_off : Icons.volume_up, Colors.purpleAccent, _mutedContacts.contains(activeContactName) ? _t('unmute') : _t('mute'), () {
                                                  setState(() {
                                                    if (_mutedContacts.contains(activeContactName)) {
                                                      _mutedContacts.remove(activeContactName);
                                                    } else {
                                                      _mutedContacts.add(activeContactName);
                                                    }
                                                    _isActiveMenuExpanded = false;
                                                  });
                                                }),

                                                _buildLabeledMenuBtn(_blockedContacts.contains(activeContactName) ? Icons.block : Icons.check_circle_outline, Colors.deepOrange, _blockedContacts.contains(activeContactName) ? _t('unblock') : _t('block'), () {
                                                  setState(() {
                                                    if (_blockedContacts.contains(activeContactName)) {
                                                      _blockedContacts.remove(activeContactName);
                                                    } else {
                                                      _blockedContacts.add(activeContactName);
                                                      if (isCurrentlyLive) { _endLiveConnection(); }
                                                    }
                                                    _isActiveMenuExpanded = false;
                                                  });
                                                }),

                                                _buildLabeledMenuBtn(Icons.delete_outline, Colors.redAccent, _t('rm_orbit'), () {
                                                  setState(() => _isActiveMenuExpanded = false);
                                                  _promptDeleteActiveContact();
                                                }),
                                                const SizedBox(height: 12),
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

                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, left: !_isLeftHanded ? 30.0 : null, right: _isLeftHanded ? 30.0 : null, top: menuY - 270,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300), opacity: (showSearchField || activeIndex == -1 || _replyingToMessage == null) ? 0.0 : 1.0,
                                child: IgnorePointer(
                                  ignoring: showSearchField || activeIndex == -1 || _replyingToMessage == null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.blueGrey.shade900.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5))),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.reply, size: 12, color: Colors.blueAccent), const SizedBox(width: 6),
                                        Text("${_t('replying')}${_formatDuration(_replyingToMessage?.durationInSeconds ?? 0)}", style: const TextStyle(fontSize: 10, color: Colors.white70)), const SizedBox(width: 8),
                                        GestureDetector(onTap: () => setState(() => _replyingToMessage = null), child: const Icon(Icons.close, size: 12, color: Colors.white54))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: !(_isIncomingCallActive || isRecording),
                                child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: (_isIncomingCallActive || isRecording) ? 0.75 : 0.0,
                                    child: Container(color: Colors.black)
                                ),
                              ),
                            ),

                            Positioned(
                              left: menuX - 162.5, top: menuY - 162.5,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: (showSearchField || anyMenuExpanded) ? 0.15 : 1.0,
                                child: Transform.scale(
                                  scale: 1.1,
                                  child: IgnorePointer(
                                      ignoring: showSearchField || anyMenuExpanded,
                                      child: OrbitPttArea(
                                        isIncomingCallActive: _isIncomingCallActive,
                                        isRecording: isRecording, isCancelled: _isCancelled, isWaitingForLiveApproval: isWaitingForLiveApproval, isLive: anyLiveActive, isLeftHanded: _isLeftHanded, dragOffset: _dragOffset, dragVerticalOffset: _dragVerticalOffset, pttSlideOffset: _pttSlideOffset, hapticRejectPulseController: _hapticRejectPulseController, hapticAcceptPulseController: _hapticAcceptPulseController, entranceController: _entranceController, pulseController: _pulseController, audioLevel: _audioLevel, recordDurationText: _formatDuration(_recordDuration),
                                        isNodeBeingPulledInward: _interactionNodeIndex != -1 && _interactionNodeOffset <= -50,
                                        onPointerDown: isWaitingForLiveApproval ? (_) {} : (_) { if (!_isIncomingCallActive) _startRecording(); },
                                        onPointerMove: (details) { if (_isIncomingCallActive) { setState(() { _pttSlideOffset += details.delta.dx; _pttSlideOffset = _pttSlideOffset.clamp(-100.0, 100.0); }); } else { _updateRecordingPointer(details); } },
                                        onPointerUp: (_) {
                                          if (_isIncomingCallActive) {
                                            if (_pttSlideOffset > 70) {
                                              _acceptIncomingCall();
                                            } else if (_pttSlideOffset < -70) {
                                              _rejectIncomingCall();
                                            } else {
                                              setState(() { _pttSlideOffset = 0.0; });
                                            }
                                          } else {
                                            _stopRecording();
                                          }
                                        },
                                        onPointerCancel: (_) { if (_isIncomingCallActive) { setState(() { _pttSlideOffset = 0.0; }); } else { _stopRecording(); } },
                                        onTapCancelCall: () { if (isWaitingForLiveApproval) _cancelOutgoingCall(); },
                                        buildCallingWave: (index) {
                                          return AnimatedBuilder(
                                              animation: _breatheController,
                                              builder: (context, child) {
                                                double sizeMultiplier = 1.0 + (_breatheController.value * (0.3 + (index * 0.2)));
                                                return Container(width: 117 * sizeMultiplier, height: 117 * sizeMultiplier, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withValues(alpha: (0.3 - (_breatheController.value * 0.2)).clamp(0.0, 1.0)), width: 2.0)));
                                              }
                                          );
                                        },
                                        buildRealWave: (index) {
                                          return ValueListenableBuilder<double>(
                                            valueListenable: _audioLevel,
                                            builder: (context, level, child) {
                                              double sizeMultiplier = 1.0 + (level * (1.2 + (index * 0.4)));
                                              return TweenAnimationBuilder(
                                                key: ValueKey(index), tween: Tween(begin: 1.0, end: sizeMultiplier), duration: const Duration(milliseconds: 100),
                                                builder: (context, double val, _) { return Container(width: 117 * val, height: 117 * val, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent.withValues(alpha: (0.4 - (level * 0.2)).clamp(0.1, 1.0)), width: 2 + (level * 2)))); },
                                              );
                                            },
                                          );
                                        },
                                      )
                                  ),
                                ),
                              ),
                            ),

                            if (_activeSubOrbit != SubOrbitType.none)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => setState(() => _activeSubOrbit = SubOrbitType.none),
                                  onVerticalDragUpdate: (details) {
                                    setState(() {
                                      double maxSubScroll = (_getSubOrbitItems().length * itemSpacingAngle) - (4 * itemSpacingAngle);
                                      if (maxSubScroll < 0) {
                                        maxSubScroll = 0;
                                      }
                                      _subOrbitScrollOffset -= details.delta.dy * 0.005;
                                      if (_subOrbitScrollOffset < -0.2) {
                                        _subOrbitScrollOffset = -0.2;
                                      }
                                      if (_subOrbitScrollOffset > maxSubScroll) {
                                        _subOrbitScrollOffset = maxSubScroll;
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: menuY - 140,
                                            left: 0, right: 0,
                                            child: Center(
                                              child: Text(
                                                _activeSubOrbit == SubOrbitType.effects ? _t('choose_fx') :
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
                                                onTap: () {
                                                  if (hapticEnabled) { try { HapticFeedback.heavyImpact(); } catch (_) { /* ignore */ } }
                                                  List<dynamic> members = allContacts[activeIndex]['members'] ?? [];
                                                  for(var m in members) {
                                                    SocketService().sendNudge(m.toString(), _currentUserPhone!, _userName);
                                                  }
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('all_nudged'))));
                                                  setState(() => _activeSubOrbit = SubOrbitType.none);
                                                },
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