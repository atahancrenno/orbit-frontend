import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart'; // Ekledik
import '../constants/legal_texts.dart'; // Ekledik

class SettingsBottomSheet extends StatefulWidget {
  final String userName;
  final String? userAvatarPath;
  final Color customAvatarColor;
  final ValueChanged<Color> onCustomAvatarColorChanged;
  final String myStatus;
  final ValueChanged<String> onUserNameChanged;
  
  final Future<String?> Function() onPickFromGallery;
  final Future<String?> Function() onPickFromCamera;
  final VoidCallback onRemoveAvatar;

  final ValueChanged<String> onStatusChanged;
  final bool isLeftHanded;
  final ValueChanged<bool> onLeftHandedChanged;
  final String selectedLiveAnimation;
  final List<String> animationOptions;
  final ValueChanged<String> onLiveAnimationChanged;
  final bool isBackgroundTransparent;
  final ValueChanged<bool> onBackgroundTransparentChanged;
  final bool isCircularMessageStyle;
  final ValueChanged<bool> onCircularMessageStyleChanged;
  
  final bool hapticEnabled;
  final ValueChanged<bool> onHapticChanged;
  
  final bool ratchetEnabled;
  final ValueChanged<bool> onRatchetChanged;

  final bool useSpeaker;
  final ValueChanged<bool> onSpeakerChanged;
  final int selfDestructSeconds;
  final ValueChanged<int> onSelfDestructChanged;
  final String liveAudioPermission;
  final ValueChanged<String> onLivePermissionChanged;
  
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final bool messageNotificationsEnabled;
  final ValueChanged<bool> onMessageNotificationsChanged;
  final bool callNotificationsEnabled;
  final ValueChanged<bool> onCallNotificationsChanged;

  final String callRingtone;
  final ValueChanged<String> onRingtoneChanged;

  final int deleteFilterDays;
  final ValueChanged<int> onDeleteFilterDaysChanged;
  final ValueChanged<int> onClearOldMessages;
  final String? customBackgroundImagePath;
  final Future<String?> Function() onPickBackground;
  final VoidCallback onRemoveBackground;
  final VoidCallback onClosed;

  const SettingsBottomSheet({
    super.key, required this.userName, this.userAvatarPath, required this.customAvatarColor, required this.onCustomAvatarColorChanged, required this.myStatus, required this.onUserNameChanged, required this.onPickFromGallery, required this.onPickFromCamera, required this.onRemoveAvatar, required this.onStatusChanged, required this.isLeftHanded, required this.onLeftHandedChanged, required this.selectedLiveAnimation, required this.animationOptions, required this.onLiveAnimationChanged, required this.isBackgroundTransparent, required this.onBackgroundTransparentChanged, required this.isCircularMessageStyle, required this.onCircularMessageStyleChanged, required this.hapticEnabled, required this.onHapticChanged, required this.ratchetEnabled, required this.onRatchetChanged, required this.useSpeaker, required this.onSpeakerChanged, required this.selfDestructSeconds, required this.onSelfDestructChanged, required this.liveAudioPermission, required this.onLivePermissionChanged, required this.notificationsEnabled, required this.onNotificationsChanged, required this.messageNotificationsEnabled, required this.onMessageNotificationsChanged, required this.callNotificationsEnabled, required this.onCallNotificationsChanged, required this.callRingtone, required this.onRingtoneChanged, required this.deleteFilterDays, required this.onDeleteFilterDaysChanged, required this.onClearOldMessages, this.customBackgroundImagePath, required this.onPickBackground, required this.onRemoveBackground, required this.onClosed,
  });

  static void show({
    required BuildContext context, required String userName, String? userAvatarPath, required Color customAvatarColor, required ValueChanged<Color> onCustomAvatarColorChanged, required String myStatus, required ValueChanged<String> onUserNameChanged, required Future<String?> Function() onPickFromGallery, required Future<String?> Function() onPickFromCamera, required VoidCallback onRemoveAvatar, required ValueChanged<String> onStatusChanged, required bool isLeftHanded, required ValueChanged<bool> onLeftHandedChanged, required String selectedLiveAnimation, required List<String> animationOptions, required ValueChanged<String> onLiveAnimationChanged, required bool isBackgroundTransparent, required ValueChanged<bool> onBackgroundTransparentChanged, required bool isCircularMessageStyle, required ValueChanged<bool> onCircularMessageStyleChanged, required bool hapticEnabled, required ValueChanged<bool> onHapticChanged, required bool ratchetEnabled, required ValueChanged<bool> onRatchetChanged, required bool useSpeaker, required ValueChanged<bool> onSpeakerChanged, required int selfDestructSeconds, required ValueChanged<int> onSelfDestructChanged, required String liveAudioPermission, required ValueChanged<String> onLivePermissionChanged, required bool notificationsEnabled, required ValueChanged<bool> onNotificationsChanged, required bool messageNotificationsEnabled, required ValueChanged<bool> onMessageNotificationsChanged, required bool callNotificationsEnabled, required ValueChanged<bool> onCallNotificationsChanged, required String callRingtone, required ValueChanged<String> onRingtoneChanged, required int deleteFilterDays, required ValueChanged<int> onDeleteFilterDaysChanged, required ValueChanged<int> onClearOldMessages, String? customBackgroundImagePath, required Future<String?> Function() onPickBackground, required VoidCallback onRemoveBackground, required VoidCallback onClosed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => SettingsBottomSheet(
        userName: userName, userAvatarPath: userAvatarPath, customAvatarColor: customAvatarColor, onCustomAvatarColorChanged: onCustomAvatarColorChanged, myStatus: myStatus, onUserNameChanged: onUserNameChanged, onPickFromGallery: onPickFromGallery, onPickFromCamera: onPickFromCamera, onRemoveAvatar: onRemoveAvatar, onStatusChanged: onStatusChanged, isLeftHanded: isLeftHanded, onLeftHandedChanged: onLeftHandedChanged, selectedLiveAnimation: selectedLiveAnimation, animationOptions: animationOptions, onLiveAnimationChanged: onLiveAnimationChanged, isBackgroundTransparent: isBackgroundTransparent, onBackgroundTransparentChanged: onBackgroundTransparentChanged, isCircularMessageStyle: isCircularMessageStyle, onCircularMessageStyleChanged: onCircularMessageStyleChanged, hapticEnabled: hapticEnabled, onHapticChanged: onHapticChanged, ratchetEnabled: ratchetEnabled, onRatchetChanged: onRatchetChanged, useSpeaker: useSpeaker, onSpeakerChanged: onSpeakerChanged, selfDestructSeconds: selfDestructSeconds, onSelfDestructChanged: onSelfDestructChanged, liveAudioPermission: liveAudioPermission, onLivePermissionChanged: onLivePermissionChanged, notificationsEnabled: notificationsEnabled, onNotificationsChanged: onNotificationsChanged, messageNotificationsEnabled: messageNotificationsEnabled, onMessageNotificationsChanged: onMessageNotificationsChanged, callNotificationsEnabled: callNotificationsEnabled, onCallNotificationsChanged: onCallNotificationsChanged, callRingtone: callRingtone, onRingtoneChanged: onRingtoneChanged, deleteFilterDays: deleteFilterDays, onDeleteFilterDaysChanged: onDeleteFilterDaysChanged, onClearOldMessages: onClearOldMessages, customBackgroundImagePath: customBackgroundImagePath, onPickBackground: onPickBackground, onRemoveBackground: onRemoveBackground, onClosed: onClosed,
      ),
    ).whenComplete(onClosed);
  }

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  final AudioPlayer _previewPlayer = AudioPlayer(); 
  String? _expandedSection; 
  late TextEditingController _nameController;

  String? _currentAvatarPath;
  late Color _currentAvatarColor;
  late String _currentStatus;
  late bool _isLeftHanded;
  late bool _isCircularMessageStyle;
  late String _selectedLiveAnimation;
  late bool _useSpeaker;
  late bool _hapticEnabled;
  late bool _ratchetEnabled; 
  late int _selfDestructSeconds;
  late String _liveAudioPermission;
  late int _deleteFilterDays;
  late bool _notificationsEnabled;
  late bool _messageNotificationsEnabled;
  late bool _callNotificationsEnabled;
  late String _callRingtone; 
  
  // 🟢 6 DİL MOTORU DEĞİŞKENLERİ
  String _lang = 'tr';
  final List<Map<String, String>> _availableLangs = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
  ];

  final List<Color> _avatarColors = [
    Colors.blueGrey.shade800, Colors.cyanAccent.shade700, Colors.blueAccent, 
    Colors.purpleAccent, Colors.pinkAccent, Colors.redAccent,
    Colors.orangeAccent, Colors.greenAccent.shade700, Colors.tealAccent.shade700
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _nameController = TextEditingController(text: widget.userName);
    
    _currentAvatarPath = widget.userAvatarPath;
    _currentAvatarColor = widget.customAvatarColor;
    _currentStatus = widget.myStatus;
    _isLeftHanded = widget.isLeftHanded;
    _isCircularMessageStyle = widget.isCircularMessageStyle;
    _selectedLiveAnimation = widget.selectedLiveAnimation;
    _useSpeaker = widget.useSpeaker;
    _hapticEnabled = widget.hapticEnabled;
    _ratchetEnabled = widget.ratchetEnabled; 
    _selfDestructSeconds = widget.selfDestructSeconds;
    _liveAudioPermission = widget.liveAudioPermission;
    _deleteFilterDays = widget.deleteFilterDays;
    
    _notificationsEnabled = widget.notificationsEnabled;
    _messageNotificationsEnabled = widget.messageNotificationsEnabled;
    _callNotificationsEnabled = widget.callNotificationsEnabled;
    _callRingtone = widget.callRingtone; 
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = prefs.getString('app_lang') ?? 'tr';
    });
  }
  
  Future<void> _changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = langCode;
    });
    await prefs.setString('app_lang', langCode);
  }

  // 🟢 HIZLI ÇEVİRİ SÖZLÜĞÜ (AYARLAR İÇİN TAM ÇEVİRİ)
  String _t(String key) {
    const Map<String, Map<String, String>> dict = {
      'title': {'tr': 'Orbit Sistem Ayarları', 'en': 'Orbit System Settings', 'de': 'Orbit Systemeinstellungen', 'ru': 'Системные настройки Orbit', 'es': 'Configuración del sistema Orbit', 'ar': 'إعدادات نظام Orbit'},
      'lang': {'tr': 'Uygulama Dili', 'en': 'App Language', 'de': 'App-Sprache', 'ru': 'Язык приложения', 'es': 'Idioma de la aplicación', 'ar': 'لغة التطبيق'},
      'prof': {'tr': 'Profil ve Durum', 'en': 'Profile & Status', 'de': 'Profil & Status', 'ru': 'Профиль и статус', 'es': 'Perfil y estado', 'ar': 'الملف الشخصi والحالة'},
      'app': {'tr': 'Görünüm ve Arayüz', 'en': 'Appearance & UI', 'de': 'Erscheinungsbild & UI', 'ru': 'Внешний вид и интерфейс', 'es': 'Apariencia e interfaz de usuario', 'ar': 'المظهر وواجهة المستخدم'},
      'aud': {'tr': 'Ses ve Donanım', 'en': 'Audio & Hardware', 'de': 'Audio & Hardware', 'ru': 'Аудио и оборудование', 'es': 'Audio y Hardware', 'ar': 'الصوت والأجهزة'},
      'priv': {'tr': 'Gizlilik ve Güvenlik', 'en': 'Privacy & Security', 'de': 'Datenschutz & Sicherheit', 'ru': 'Конфиденциальность и безопасность', 'es': 'Privacidad y seguridad', 'ar': 'الخصوصية والأمان'},
      'perm': {'tr': 'İzinler ve Yasal', 'en': 'Permissions & Legal', 'de': 'Berechtigungen & Rechtliches', 'ru': 'Разрешения и правовые вопросы', 'es': 'Permisos y legalidad', 'ar': 'الأذونات والقانونية'},
      'notif': {'tr': 'Bildirimler', 'en': 'Notifications', 'de': 'Benachrichtigungen', 'ru': 'Уведомления', 'es': 'Notificaciones', 'ar': 'الإشعارات'},
      'stor': {'tr': 'Depolama ve Veri', 'en': 'Storage & Data', 'de': 'Speicher & Daten', 'ru': 'Хранилище и данные', 'es': 'Almacenamiento y datos', 'ar': 'التخزين والبيانات'},
      'acc': {'tr': 'Hesap Yönetimi', 'en': 'Account Management', 'de': 'Kontoverwaltung', 'ru': 'Управление аккаuntom', 'es': 'Gestión de cuentas', 'ar': 'إدارة الحساب'},
      
      // Profil
      'cam': {'tr': 'Kameradan Çek', 'en': 'Take Photo', 'de': 'Foto machen', 'ru': 'Сделать фото', 'es': 'Tomar foto', 'ar': 'التقاط صورة'},
      'gal': {'tr': 'Galeriden Seç', 'en': 'Choose from Gallery', 'de': 'Aus Galerie wählen', 'ru': 'Выбрать из галереи', 'es': 'Elegir de la galería', 'ar': 'اختر من المعرض'},
      'del_pic': {'tr': 'Fotoğrafı Sil', 'en': 'Remove Photo', 'de': 'Foto löschen', 'ru': 'Удалить фото', 'es': 'Eliminar foto', 'ar': 'إزالة الصورة'},
      'prof_col': {'tr': 'Profil Renginizi Seçin', 'en': 'Choose Profile Color', 'de': 'Profilfarbe wählen', 'ru': 'Выберите цвет профиля', 'es': 'Elige el color del perfil', 'ar': 'اختر لون الملف الشخصi'},
      'name': {'tr': 'Görünen Ad', 'en': 'Display Name', 'de': 'Anzeigename', 'ru': 'Отображаемое имя', 'es': 'Nombre para mostrar', 'ar': 'الاسم المعروض'},
      'status': {'tr': 'Durum', 'en': 'Status', 'de': 'Status', 'ru': 'Статус', 'es': 'Estado', 'ar': 'الحالة'},
      'st_av': {'tr': 'Müsait', 'en': 'Available', 'de': 'Verfügbar', 'ru': 'В сети', 'es': 'Disponible', 'ar': 'متاح'},
      'st_bu': {'tr': 'Meşgul', 'en': 'Busy', 'de': 'Beschäftigt', 'ru': 'Занят', 'es': 'Ocupado', 'ar': 'مشغول'},
      'st_aw': {'tr': 'Uzakta', 'en': 'Away', 'de': 'Abwesend', 'ru': 'Нет на месте', 'es': 'Ausente', 'ar': 'بعيد'},

      // Arayüz
      'lh_mode': {'tr': 'Sol El Modu', 'en': 'Left Hand Mode', 'de': 'Linkshänder-Modus', 'ru': 'Режим левой руки', 'es': 'Modo para zurdos', 'ar': 'وضع اليد اليسرى'},
      'lh_desc': {'tr': 'Arayüzü sol ele göre optimize eder', 'en': 'Optimizes UI for left-handed use', 'de': 'Optimiert die Benutzeroberfläche für Linkshänder', 'ru': 'Оптимизирует интерфейс для левшей', 'es': 'Optimiza la interfaz para uso con la mano izquierda', 'ar': 'يحسن واجهة المستخدم للاستخدام باليد اليسرى'},
      'circ_msg': {'tr': 'Dairesel Mesaj Balonları', 'en': 'Circular Message Bubbles', 'de': 'Runde Nachrichtenblasen', 'ru': 'Круглые облачки сообщений', 'es': 'Burbujas de mensajes circulares', 'ar': 'فقاعات رسائل دائرية'},
      'circ_desc': {'tr': 'Klasik hap tasarımı yerine çembersel', 'en': 'Circular shapes instead of pill design', 'de': 'Runde Formen anstelle von Pillendesign', 'ru': 'Круглые формы вместо дизайна в виде таблеток', 'es': 'Formas circulares en lugar de diseño de píldora', 'ar': 'أشكال دائرية بدلاً من tasarım الكبسولة'},
      'anim_live': {'tr': 'Yayın Animasyonu', 'en': 'Broadcast Animation', 'de': 'Broadcast-Animation', 'ru': 'Анимация трансляции', 'es': 'Animación de transmisión', 'ar': 'رسوم متحركة للبث'},

      // Ses & Donanım
      'speaker': {'tr': 'Hoparlörü Kullan', 'en': 'Use Speaker', 'de': 'Lautsprecher verwenden', 'ru': 'Использовать динамик', 'es': 'Usar altavoz', 'ar': 'استخدم مكبر الصوت'},
      'speaker_desc': {'tr': 'Sesleri ahize yerine dışarı verir', 'en': 'Play sounds through the loudspeaker', 'de': 'Spielt Töne über den Lautsprecher ab', 'ru': 'Воспроизведение звука через динамик', 'es': 'Reproducir sonidos a través del altavoz', 'ar': 'تشغيل الأصوات عبر مكبر الصوت'},
      'haptic': {'tr': 'Titreşim Geri Bildirim', 'en': 'Haptic Feedback', 'de': 'Haptisches Feedback', 'ru': 'Тактильная обратная связь', 'es': 'Retroalimentación háptica', 'ar': 'ردود الفعل اللمسية'},
      'haptic_desc': {'tr': 'Tuşlara basıldığında cihaz titrer', 'en': 'Vibrate on button press', 'de': 'Vibriert beim Tastendruck', 'ru': 'Вибрация при нажатии кнопок', 'es': 'Vibrar al pulsar el botón', 'ar': 'اهتزاز عند الضغط على الزر'},
      'ratchet': {'tr': 'Yörünge Çark Hissi (Çıkrık)', 'en': 'Orbit Ratchet Effect', 'de': 'Orbit Ratscheneffekt', 'ru': 'Эффект храповика', 'es': 'Efecto de trinquete de órbita', 'ar': 'تأثير السقاطة المدارية'},
      'ratchet_desc': {'tr': 'Yörüngeyi çevirirken mekanik dişli titreşimi verir', 'en': 'Mechanical gear feedback when scrolling orbit', 'de': 'Mechanisches Zahnrad-Feedback beim Scrollen der Umlaufbahn', 'ru': 'Механическая обратная связь при прокрутке орбиты', 'es': 'Retroalimentación de engranaje mecánico al desplazar la órbita', 'ar': 'ردود فعل التروس الميكanيكية عند تمرير المدار'},

      // Gizlilik
      'del_unsav': {'tr': 'Kaydedilmeyen Sesleri Sil', 'en': 'Delete Unsaved Audio', 'de': 'Nicht gespeichertes Audio löschen', 'ru': 'Удалить несохраненное аудио', 'es': 'Eliminar audio no guardado', 'ar': 'حذف الصوت غير المحفوظ'},
      'del_10s': {'tr': '10 Saniye Sonra', 'en': 'After 10 Seconds', 'de': 'Nach 10 Sekunden', 'ru': 'Через 10 секунд', 'es': 'Después de 10 segundos', 'ar': 'بعد 10 ثواني'},
      'del_30s': {'tr': '30 Saniye Sonra', 'en': 'After 30 Seconds', 'de': 'Nach 30 Sekunden', 'ru': 'Через 30 секунд', 'es': 'Después de 30 segundos', 'ar': 'بعد 30 ثانية'},
      'del_60s': {'tr': '1 Dakika Sonra', 'en': 'After 1 Minute', 'de': 'Nach 1 Minute', 'ru': 'Через 1 минуту', 'es': 'Después de 1 minuto', 'ar': 'بعد دقيقة واحدة'},
      'del_never': {'tr': 'Asla Silme', 'en': 'Never Delete', 'de': 'Nie löschen', 'ru': 'Никогда не удалять', 'es': 'Nunca eliminar', 'ar': 'عدم الحذف أبدًا'},
      'who_conn': {'tr': 'Kimler Canlı Bağlanabilir?', 'en': 'Who can connect live?', 'de': 'Wer kann sich live verbinden?', 'ru': 'Кто может подключиться в прямом эфире?', 'es': '¿Кто puede conectarse en vivo?', 'ar': 'من يمكنه الاتصال المباشر؟'},
      'who_all': {'tr': 'Herkes', 'en': 'Everyone', 'de': 'Jeder', 'ru': 'Все', 'es': 'Todos', 'ar': 'الجميع'},
      'who_cont': {'tr': 'Sadece Kişilerim', 'en': 'My Contacts Only', 'de': 'Nur meine Kontakte', 'ru': 'Только мои контакты', 'es': 'Solo mis contactos', 'ar': 'جهات الاتصال الخاصة بي فقط'},
      'who_none': {'tr': 'Hiç Kimse (Kapalı)', 'en': 'Nobody (Closed)', 'de': 'Niemand (Geschlossen)', 'ru': 'Никто (Закрыто)', 'es': 'Nadie (Cerrado)', 'ar': 'لا أحد (مغلق)'},

      // İzinler & Yasal (GÜNCELLENDİ)
      'perm_warn': {'tr': 'Eğer kişileriniz Orbit\'te görünmüyorsa veya arama yapamıyorsanız, telefonunuzun kendi ayarlarından gerekli izinleri vermeniz gerekmektedir.', 'en': 'If your contacts are not visible or you cannot make calls, you need to grant permissions from your phone\'s settings.', 'de': 'Wenn Ihre Kontakte nicht sichtbar sind oder Sie keine Anrufe tätigen können, müssen Sie Berechtigungen in den Einstellungen Ihres Telefons erteilen.', 'ru': 'Если ваши контакты не видны или вы не можете совершать звонки, вам необходимо предоставить разрешения в настройках вашего телефона.', 'es': 'Si sus contactos no están visibles o no puede realizar llamadas, debe otorgar permisos en la configuración de su teléfono.', 'ar': 'إذا كانت جهات الاتصال الخاصة بك غير مرئية أو لا يمكنك إجراء مكالمات ، فأنت بحاجة إلى منح أذونات من إعدادات هاتفك.'},
      'btn_perm': {'tr': 'Sistem İzin Ayarları', 'en': 'System Permission Settings', 'de': 'Systemberechtigungseinstellungen', 'ru': 'Системные настройки разрешений', 'es': 'Configuración de permisos del sistema', 'ar': 'إعدادات إذن النظام'},
      'legal_docs': {'tr': 'Yasal Dokümanlar', 'en': 'Legal Documents', 'de': 'Rechtliche Dokumente', 'ru': 'Юридические документы', 'es': 'Documentos legales', 'ar': 'الوثائق القانونية'},
      'view_terms': {'tr': 'Hizmet Şartlarını Görüntüle', 'en': 'View Terms of Service', 'de': 'Nutzungsbedingungen anzeigen', 'ru': 'Просмотреть условия обслуживания', 'es': 'Ver términos de servicio', 'ar': 'عرض شروط الخدمة'},
      'view_privacy': {'tr': 'KVKK / Gizlilik Politikasını Görüntüle', 'en': 'View Privacy Policy', 'de': 'Datenschutzerklärung anzeigen', 'ru': 'Просмотреть политику конфиденциальности', 'es': 'Ver política de privacidad', 'ar': 'عرض سياسة الخصوصية'},
      'legal_app': {'tr': 'Yasal Onay', 'en': 'Legal Approval', 'de': 'Rechtliche Genehmigung', 'ru': 'Юридическое одобрение', 'es': 'Aprobación legal', 'ar': 'الموافقة القانونية'},
      'legal_status': {'tr': 'Bu cihazda yasal şartlar onaylanmıştır.', 'en': 'Legal terms are approved on this device.', 'de': 'Die rechtlichen Bedingungen sind auf diesem Gerät genehmigt.', 'ru': 'Юридические условия одобрены на этом устройстве.', 'es': 'Los términos legales están aprobados en este dispositivo.', 'ar': 'تمت الموافقة على الشروط القانونية على هذا الجهاز.'},

      // Bildirimler
      'notif_all': {'tr': 'Tüm Bildirimler', 'en': 'All Notifications', 'de': 'Alle Benachrichtigungen', 'ru': 'Все уведомления', 'es': 'Todas las notificaciones', 'ar': 'كل الإشعارات'},
      'notif_all_d': {'tr': 'Orbit\'ten gelen tüm bildirimleri açar veya kapatır', 'en': 'Enable or disable all notifications from Orbit', 'de': 'Aktivieren oder deaktivieren Sie alle Benachrichtigungen von Orbit', 'ru': 'Включить или отключить все уведомления от Orbit', 'es': 'Habilite o deshabilite todas las notificaciones de Orbit', 'ar': 'تمكين أو تعطيل كافة الإشعارات من المدار'},
      'notif_msg': {'tr': 'Sesli Mesaj Bildirimleri', 'en': 'Voice Message Notifications', 'de': 'Sprachnachrichtenbenachrichtigungen', 'ru': 'Уведомления о голосовых сообщениях', 'es': 'Notificaciones de mensajes de voz', 'ar': 'إشعارات الرسائل الصوتية'},
      'notif_msg_d': {'tr': 'Biri size telsiz mesajı bıraktığında', 'en': 'When someone leaves a PTT message', 'de': 'Wenn jemand eine PTT-Nachricht hinterlässt', 'ru': 'Когда кто-то оставляет PTT-сообщение', 'es': 'Cuando alguien deja un mensaje PTT', 'ar': 'عندما يترك شخص ما رسالة اضغط لتتحدث'},
      'notif_call': {'tr': 'Canlı Arama Bildirimleri', 'en': 'Live Call Notifications', 'de': 'Live-Anrufbenachrichtigungen', 'ru': 'Уведомления о прямых звонках', 'es': 'Notificaciones de llamadas en vivo', 'ar': 'إشعارات المكالمات المباشرة'},
      'notif_call_d': {'tr': 'Biri sizinle canlı bağlantı kurmak istediğinde', 'en': 'When someone wants to connect live', 'de': 'Wenn sich jemand live verbinden möchte', 'ru': 'Когда кто-то хочет подключиться в прямом эфире', 'es': 'Cuando alguien quiere conectarse en vivo', 'ar': 'عندما يريد شخص ما الاتصال على الهواء مباشرة'},
      'ringtone': {'tr': 'Canlı Arama Zil Sesi', 'en': 'Live Call Ringtone', 'de': 'Live-Anruf-Klingelton', 'ru': 'Мелодия прямого звонка', 'es': 'Tono de llamada en vivo', 'ar': 'نغمة رنين المكالمات المباشرة'},
      'ring_sys': {'tr': 'Standart (Telefonun Sesi)', 'en': 'Standard (System Default)', 'de': 'Standard (Systemvorgabe)', 'ru': 'Стандартный (системный)', 'es': 'Estándar (predeterminado del sistema)', 'ar': 'قياسي (افتراضي للنظام)'},
      'ring_r1': {'tr': 'Telsiz Sesi 1', 'en': 'Radio Sound 1', 'de': 'Funkgeräusch 1', 'ru': 'Звук радио 1', 'es': 'Sonido de radio 1', 'ar': 'صوت راديو 1'},
      'ring_r2': {'tr': 'Telsiz Sesi 2', 'en': 'Radio Sound 2', 'de': 'Funkgeräusch 2', 'ru': 'Звук радио 2', 'es': 'Sonido de radio 2', 'ar': 'صوت رادyo 2'},
      'ring_r3': {'tr': 'Telsiz Sesi 3', 'en': 'Radio Sound 3', 'de': 'Funkgeräusch 3', 'ru': 'Звук радио 3', 'es': 'Sonido de radio 3', 'ar': 'صوت راديو 3'},
      'ring_e1': {'tr': 'Acil Durum 1', 'en': 'Emergency 1', 'de': 'Notfall 1', 'ru': 'Экстренная ситуация 1', 'es': 'Emergencia 1', 'ar': 'طوارئ 1'},
      'ring_e2': {'tr': 'Acil Durum 2', 'en': 'Emergency 2', 'de': 'Notfall 2', 'ru': 'Экстренная ситуация 2', 'es': 'Emergencia 2', 'ar': 'طوارئ 2'},
      'ring_al': {'tr': 'Alarm Sesi', 'en': 'Alarm Sound', 'de': 'Alarmton', 'ru': 'Звук будильника', 'es': 'Sonido de alarma', 'ar': 'صوت إنذار'},

      // Depolama
      'del_older': {'tr': 'Şu süreden eskileri sil:', 'en': 'Delete older than:', 'de': 'Älter löschen als:', 'ru': 'Удалить старше:', 'es': 'Eliminar más antiguos que:', 'ar': 'حذف أقدم من:'},
      'days_30': {'tr': '30 Gün', 'en': '30 Days', 'de': '30 Tage', 'ru': '30 дней', 'es': '30 Días', 'ar': '30 يوم'},
      'days_60': {'tr': '60 Gün', 'en': '60 Days', 'de': '60 Tage', 'ru': '60 дней', 'es': '60 Días', 'ar': '60 يوم'},
      'days_90': {'tr': '90 Gün', 'en': '90 Days', 'de': '90 Tage', 'ru': '90 дней', 'es': '90 Días', 'ar': '90 يوم'},
      'btn_clear': {'tr': 'Temizle', 'en': 'Clear', 'de': 'Klar', 'ru': 'Очистить', 'es': 'Limpiar', 'ar': 'مسح'},
      'stor_desc': {'tr': 'Cihazda tutulan kayıtlı ses dosyalarının boyutunu azaltmak için seçtiğiniz günden daha eski dosyaları topluca silebilirsiniz.', 'en': 'You can mass delete files older than the selected days to reduce the storage size of saved audio files on the device.', 'de': 'Sie können massenhaft löschen Dateien, die älter sind als die ausgewählten Tage, um die Speichergröße der gespeicherten Audiodateien auf dem Gerät zu reduzieren.', 'ru': 'Вы можете массово удалить файлы старше выбранных дней, чтобы уменьшить размер хранилища сохраненных аудиофайлов на устройстве.', 'es': 'Puede eliminar en masa los archivos más antiguos que los días seleccionados para reducir el tamaño de almacenamiento de los archivos de audio guardados en el dispositivo.', 'ar': 'يمكنك حذف الملفات الأقدم من الأيام المحددة بشكل جماعي لتقليل حجم تخزين الملفات الصوتية المحفوظة على الجهاز.'},

      // Hesap Yönetimi (DÜZELTİLDİ)
      'logout': {'tr': 'Çıkış Yap', 'en': 'Log Out', 'de': 'Abmelden', 'ru': 'Выйти', 'es': 'Cerrar sesión', 'ar': 'تسجيل الخروج'},
      'logout_q': {'tr': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?', 'en': 'Are you sure you want to log out of your account?', 'de': 'Sind Sie sicher, dass Sie sich von Ihrem Konto abmelden möchten?', 'ru': 'Вы уверены, что хотите выйти из своей учетной записи?', 'es': '¿Estás seguro de que quieres cerrar sesión en tu cuenta?', 'ar': 'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'},
      'cancel': {'tr': 'İptal', 'en': 'Cancel', 'de': 'Abbrechen', 'ru': 'Отмена', 'es': 'Cancelar', 'ar': 'إلغاء'},
      'del_acc': {'tr': 'Hesabımı Sil', 'en': 'Delete My Account', 'de': 'Mein Konto löschen', 'ru': 'Удалить мой аккаунт', 'es': 'Eliminar mi cuenta', 'ar': 'حذف حسابي'},
      'del_warn': {'tr': 'Hesabınızı sildiğinizde, veritabanındaki tüm profiliniz kalıcı olarak silinir ve bu işlem geri alınamaz.', 'en': 'When you delete your account, your entire profile in the database will be permanently deleted and this cannot be undone.', 'de': 'Wenn Sie Ihr Konto löschen, wird Ihr gesamtes Profil in der Datenbank dauerhaft gelöscht und kann nicht rückgängig gemacht werden.', 'ru': 'При удалении аккаунта весь ваш профиль в базе данных будет навсегда удален, ve это действие нельзя отменить.', 'es': 'Cuando eliminas tu cuenta, todo tu perfil en la base de datos se eliminará permanentemente ve bu işlem geri alınamaz.', 'ar': 'عند حذف حسابك ، سيتم حذف ملفك الشخصi بالكامل في قاعدة البيانات نهائيًا ولا يمكن التراجع عن هذا الإجراء.'},
      'del_acc_q': {'tr': 'Bu işlem GERİ ALINAMAZ. Profiliniz ve veritabanındaki tüm kayıtlarınız kalıcı olarak silinecek. Emin misiniz?', 'en': 'This action CANNOT BE UNDONE. Your profile and all records in the database will be permanently deleted. Are you sure?', 'de': 'Diese Aktion kann NICHT rückgängig gemacht werden. Ihr Profil und alle Datensätze in der Datenbank werden dauerhaft gelöscht. Sind Sie sicher?', 'ru': 'Это действие НЕВОЗМОЖНО ОТМЕНИТЬ. Ваш профиль ve все записи в базе данных будут навсегда удалены. Вы уверены?', 'es': 'Esta acción NO SE PUEDE DESHACER. Su perfil ve todos los registros en la base de datos se eliminarán de forma permanente. ¿Estás seguro?', 'ar': 'لا يمكن التراجع عن هذا الإجراء. سيتم حذف ملفك الشخصi وجميع السجلات في قاعدة البيانات بشكل دائم. هل أنت متأكد؟'},
      'give_up': {'tr': 'Vazgeç', 'en': 'Give Up', 'de': 'Aufgeben', 'ru': 'Сдаваться', 'es': 'Renunciar', 'ar': 'تخلى'},
      'yes_del': {'tr': 'Evet, Kalıcı Olarak Sil', 'en': 'Yes, Delete Permanently', 'de': 'Ja, dauerhaft löschen', 'ru': 'Да, удалить навсегда', 'es': 'Sí, eliminar permanentemente', 'ar': 'نعم ، احذف نهائيًا'},
    };
    return dict[key]?[_lang] ?? dict[key]?['en'] ?? key;
  }

  @override
  void dispose() {
    _previewPlayer.dispose(); 
    _nameController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) {
      return "";
    }
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return "${parts[0][0]}.${parts[parts.length - 1][0]}".toUpperCase();
  }

  void _toggleSection(String sectionName) {
    setState(() {
      _expandedSection = _expandedSection == sectionName ? null : sectionName;
    });
  }

  Widget _buildGlassmorphismContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 1.5)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    bool isExpanded = _expandedSection == title;
    return GestureDetector(
      onTap: () => _toggleSection(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isExpanded ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isExpanded ? Colors.white : Colors.white70,
                  fontSize: 16,
                  fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isExpanded ? color : Colors.white30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent({required String title, required Widget child}) {
    bool isExpanded = _expandedSection == title;
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity, height: 0),
      secondChild: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.black.withValues(alpha: 0.3),
        child: child,
      ),
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      sizeCurve: Curves.easeInOut,
    );
  }

  Widget _buildLanguageContent() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _availableLangs.map((langMap) {
        bool isSelected = _lang == langMap['code'];
        return GestureDetector(
          onTap: () => _changeLanguage(langMap['code']!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellowAccent.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? Colors.yellowAccent : Colors.white30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // 🟢 Menü adları ve bayrakları her dilde aynı yönde (LTR) kalsın
              textDirection: TextDirection.ltr, 
              children: [
                Text(langMap['flag']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(langMap['name']!, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext ctx) {
                return Directionality(
                  textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  child: Container(
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                    ),
                    child: SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.cyanAccent, size: 20)),
                            title: Text(_t('cam'), style: const TextStyle(color: Colors.white, fontSize: 15)),
                            onTap: () async {
                              Navigator.pop(ctx);
                              String? newPath = await widget.onPickFromCamera();
                              if (newPath != null) setState(() => _currentAvatarPath = newPath);
                            },
                          ),
                          ListTile(
                            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.photo_library, color: Colors.cyanAccent, size: 20)),
                            title: Text(_t('gal'), style: const TextStyle(color: Colors.white, fontSize: 15)),
                            onTap: () async {
                              Navigator.pop(ctx);
                              String? newPath = await widget.onPickFromGallery();
                              if (newPath != null) setState(() => _currentAvatarPath = newPath);
                            },
                          ),
                          if (_currentAvatarPath != null) ...[
                            Divider(color: Colors.white.withValues(alpha: 0.1), indent: 20, endIndent: 20),
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
                              title: Text(_t('del_pic'), style: const TextStyle(color: Colors.redAccent, fontSize: 15)),
                              onTap: () {
                                Navigator.pop(ctx);
                                widget.onRemoveAvatar();
                                setState(() => _currentAvatarPath = null);
                              },
                            ),
                          ],
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentAvatarPath != null ? Colors.transparent : _currentAvatarColor,
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  image: _currentAvatarPath != null 
                      ? DecorationImage(image: FileImage(File(_currentAvatarPath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _currentAvatarPath == null 
                    ? Center(
                        child: Text(
                          _getInitials(_nameController.text),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ) 
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                child: const Icon(Icons.camera_alt, size: 12, color: Colors.black),
              )
            ],
          ),
        ),
        
        if (_currentAvatarPath == null) ...[
          const SizedBox(height: 15),
          Text(_t('prof_col'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _avatarColors.length,
              itemBuilder: (context, index) {
                Color color = _avatarColors[index];
                bool isSelected = _currentAvatarColor == color;
                return GestureDetector(
                  onTap: () {
                    widget.onCustomAvatarColorChanged(color); 
                    setState(() { _currentAvatarColor = color; });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 35,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: isSelected ? 2.5 : 0),
                      boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)] : [],
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: _t('name'),
            labelStyle: const TextStyle(color: Colors.cyanAccent),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
          onChanged: widget.onUserNameChanged,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _currentStatus,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          decoration: InputDecoration(labelText: _t('status'), labelStyle: const TextStyle(color: Colors.white54)),
          items: [
            DropdownMenuItem(value: "available", child: Text(_t('st_av'))),
            DropdownMenuItem(value: "busy", child: Text(_t('st_bu'))),
            DropdownMenuItem(value: "away", child: Text(_t('st_aw'))),
          ],
          onChanged: (val) { 
            if (val != null) {
              setState(() => _currentStatus = val);
              widget.onStatusChanged(val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceContent() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(_t('lh_mode'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('lh_desc'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _isLeftHanded,
          activeThumbColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() => _isLeftHanded = val);
            widget.onLeftHandedChanged(val);
          },
        ),
        SwitchListTile(
          title: Text(_t('circ_msg'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('circ_desc'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _isCircularMessageStyle,
          activeThumbColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() => _isCircularMessageStyle = val);
            widget.onCircularMessageStyleChanged(val);
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _selectedLiveAnimation,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          decoration: InputDecoration(labelText: _t('anim_live'), labelStyle: const TextStyle(color: Colors.white54)),
          items: widget.animationOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) { 
            if (val != null) {
              setState(() => _selectedLiveAnimation = val);
              widget.onLiveAnimationChanged(val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAudioContent() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(_t('speaker'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('speaker_desc'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _useSpeaker,
          activeThumbColor: Colors.orangeAccent,
          onChanged: (val) {
            setState(() => _useSpeaker = val);
            widget.onSpeakerChanged(val);
          },
        ),
        SwitchListTile(
          title: Text(_t('haptic'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('haptic_desc'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _hapticEnabled,
          activeThumbColor: Colors.orangeAccent,
          onChanged: (val) {
            setState(() {
               _hapticEnabled = val;
               if (!val) _ratchetEnabled = false; 
            });
            widget.onHapticChanged(val);
            if (!val) widget.onRatchetChanged(false);
          },
        ),
        SwitchListTile(
          title: Text(_t('ratchet'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('ratchet_desc'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _ratchetEnabled,
          activeThumbColor: Colors.orangeAccent,
          onChanged: _hapticEnabled ? (val) { 
            setState(() => _ratchetEnabled = val);
            widget.onRatchetChanged(val);
          } : null, 
        ),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selfDestructSeconds,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          decoration: InputDecoration(labelText: _t('del_unsav'), labelStyle: const TextStyle(color: Colors.white54)),
          items: [
            DropdownMenuItem(value: 10, child: Text(_t('del_10s'))),
            DropdownMenuItem(value: 30, child: Text(_t('del_30s'))),
            DropdownMenuItem(value: 60, child: Text(_t('del_60s'))),
            DropdownMenuItem(value: -1, child: Text(_t('del_never'))),
          ],
          onChanged: (val) { 
            if (val != null) {
              setState(() => _selfDestructSeconds = val);
              widget.onSelfDestructChanged(val);
            }
          },
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _liveAudioPermission,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          decoration: InputDecoration(labelText: _t('who_conn'), labelStyle: const TextStyle(color: Colors.white54)),
          items: [
            DropdownMenuItem(value: "Herkes", child: Text(_t('who_all'))),
            DropdownMenuItem(value: "Kişilerim", child: Text(_t('who_cont'))),
            DropdownMenuItem(value: "Hiç Kimse", child: Text(_t('who_none'))),
          ],
          onChanged: (val) { 
            if (val != null) {
              setState(() => _liveAudioPermission = val);
              widget.onLivePermissionChanged(val);
            }
          },
        ),
      ],
    );
  }

  // 🟢 YENİLENEN: İZİNLER VE YASAL BÖLÜMÜ
  void _showAyarlarLegalDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(_t(type == 'terms' ? 'view_terms' : 'view_privacy'), style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Html(
                data: LegalTexts.getHtml(type, _lang),
                style: {
                  "body": Style(color: Colors.white70, fontSize: FontSize(13)),
                  "h1": Style(color: Colors.cyanAccent, fontSize: FontSize(18), fontWeight: FontWeight.bold),
                  "strong": Style(color: Colors.white),
                },
              ),
            ),
          ),
          actions: [ TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t('cancel'), style: const TextStyle(color: Colors.cyanAccent))) ],
        ),
      ),
    );
  }

  Widget _buildPermissionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sistem İzinleri
        Text(_t('perm_warn'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.settings_applications, size: 20),
            label: Text(_t('btn_perm'), style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2), foregroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { openAppSettings(); },
          ),
        ),
        
        const SizedBox(height: 25),
        const Divider(color: Colors.white24),
        const SizedBox(height: 15),

        // Yasal Dokümanlar
        Text(_t('legal_docs'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description, color: Colors.cyanAccent),
          title: Text(_t('view_terms'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
          onTap: () => _showAyarlarLegalDialog('terms'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.gavel, color: Colors.cyanAccent),
          title: Text(_t('view_privacy'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
          onTap: () => _showAyarlarLegalDialog('privacy'),
        ),
        
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2))),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('legal_app'), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_t('legal_status'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsContent() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(_t('notif_all'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(_t('notif_all_d'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _notificationsEnabled,
          activeThumbColor: Colors.blueAccent,
          onChanged: (val) {
            setState(() {
              _notificationsEnabled = val;
              if (!val) {
                _messageNotificationsEnabled = false;
                _callNotificationsEnabled = false;
              }
            });
            widget.onNotificationsChanged(val);
            if (!val) {
              widget.onMessageNotificationsChanged(false);
              widget.onCallNotificationsChanged(false);
            }
          },
        ),
        const Divider(color: Colors.white24),
        SwitchListTile(
          title: Text(_t('notif_msg'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('notif_msg_d'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _messageNotificationsEnabled,
          activeThumbColor: Colors.blueAccent,
          onChanged: _notificationsEnabled ? (val) {
            setState(() => _messageNotificationsEnabled = val);
            widget.onMessageNotificationsChanged(val);
          } : null,
        ),
        SwitchListTile(
          title: Text(_t('notif_call'), style: const TextStyle(color: Colors.white)),
          subtitle: Text(_t('notif_call_d'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          value: _callNotificationsEnabled,
          activeThumbColor: Colors.blueAccent,
          onChanged: _notificationsEnabled ? (val) {
            setState(() => _callNotificationsEnabled = val);
            widget.onCallNotificationsChanged(val);
          } : null,
        ),
        const Divider(color: Colors.white24),
        
        DropdownButtonFormField<String>(
          initialValue: _callRingtone,
          dropdownColor: Colors.grey.shade900,
          style: const TextStyle(color: Colors.white),
          isExpanded: true,
          decoration: InputDecoration(labelText: _t('ringtone'), labelStyle: const TextStyle(color: Colors.cyanAccent)),
          items: [
            DropdownMenuItem(value: "", child: Text(_t('ring_sys'))),
            DropdownMenuItem(value: "call_1", child: Text(_t('ring_r1'))),
            DropdownMenuItem(value: "call_2", child: Text(_t('ring_r2'))),
            DropdownMenuItem(value: "call_3", child: Text(_t('ring_r3'))),
            DropdownMenuItem(value: "call_4", child: Text(_t('ring_e1'))),
            DropdownMenuItem(value: "call_5", child: Text(_t('ring_e2'))),
            DropdownMenuItem(value: "call_6", child: Text(_t('ring_al'))),
          ],
          onChanged: _notificationsEnabled ? (val) async {
            if (val != null) {
              setState(() => _callRingtone = val);
              widget.onRingtoneChanged(val);
              
              if (val.isNotEmpty) {
                await _previewPlayer.stop(); 
                await _previewPlayer.play(AssetSource('sounds/$val.wav')); 
              } else {
                await _previewPlayer.stop(); 
              }
            }
          } : null,
        ),
      ],
    );
  }

  Widget _buildStorageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: _deleteFilterDays,
                dropdownColor: Colors.grey.shade900,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _t('del_older'),
                  labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
                items: [
                  DropdownMenuItem(value: 30, child: Text(_t('days_30'))),
                  DropdownMenuItem(value: 60, child: Text(_t('days_60'))),
                  DropdownMenuItem(value: 90, child: Text(_t('days_90'))),
                ],
                onChanged: (val) { 
                  if (val != null) {
                    setState(() => _deleteFilterDays = val);
                    widget.onDeleteFilterDaysChanged(val);
                  }
                },
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                widget.onClearOldMessages(_deleteFilterDays);
                Navigator.pop(context); 
              },
              icon: const Icon(Icons.delete_sweep, size: 16),
              label: Text(_t('btn_clear')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.2), foregroundColor: Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(_t('stor_desc'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildAccountManagementContent() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: Text(_t('logout'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            onPressed: () => _showSignOutDialog(context),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: Text(_t('del_acc'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              shadowColor: Colors.redAccent.withValues(alpha: 0.5),
            ),
            onPressed: () => _showDeleteAccountDialog(context),
          ),
        ),
        const SizedBox(height: 10),
        Text(_t('del_warn'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white24)),
          title: Text(_t('logout'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(_t('logout_q'), style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text(_t('cancel'), style: const TextStyle(color: Colors.white54))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2), foregroundColor: Colors.cyanAccent, elevation: 0),
              onPressed: () async {
                Navigator.pop(ctx); 
                Navigator.pop(context); 
                widget.onClosed();  
                await FirebaseAuth.instance.signOut(); 
              }, 
              child: Text(_t('logout'))
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5))),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(_t('del_acc'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(_t('del_acc_q'), style: const TextStyle(color: Colors.white70, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text(_t('give_up'), style: const TextStyle(color: Colors.white54))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.shade700, foregroundColor: Colors.white, elevation: 0),
              onPressed: () async {
                Navigator.pop(ctx); 
                Navigator.pop(context); 
                widget.onClosed();  
                
                try {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
                  }
                  await FirebaseAuth.instance.currentUser?.delete();
                } catch (e) {
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güvenlik nedeniyle lütfen çıkış yapıp tekrar giriş yaptıktan sonra hesabınızı silin."), backgroundColor: Colors.orange));
                     await FirebaseAuth.instance.signOut();
                  }
                }
              }, 
              child: Text(_t('yes_del'))
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextDirection layoutDirection = _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: layoutDirection,
      child: _buildGlassmorphismContainer(
        child: DraggableScrollableSheet(
          initialChildSize: 0.75, 
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
                ),
                
                Text(_t('title'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, letterSpacing: 1.2)),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSectionHeader(_t('lang'), Icons.language, Colors.yellowAccent),
                      _buildSectionContent(title: _t('lang'), child: _buildLanguageContent()),

                      _buildSectionHeader(_t('prof'), Icons.person_outline, Colors.cyanAccent),
                      _buildSectionContent(title: _t('prof'), child: _buildProfileContent()),

                      _buildSectionHeader(_t('app'), Icons.palette_outlined, Colors.purpleAccent),
                      _buildSectionContent(title: _t('app'), child: _buildAppearanceContent()),

                      _buildSectionHeader(_t('aud'), Icons.headset_mic_outlined, Colors.orangeAccent),
                      _buildSectionContent(title: _t('aud'), child: _buildAudioContent()),

                      _buildSectionHeader(_t('priv'), Icons.lock_outline, Colors.greenAccent),
                      _buildSectionContent(title: _t('priv'), child: _buildPrivacyContent()),

                      _buildSectionHeader(_t('perm'), Icons.verified_user_outlined, Colors.tealAccent),
                      _buildSectionContent(title: _t('perm'), child: _buildPermissionsContent()),
                      
                      _buildSectionHeader(_t('notif'), Icons.notifications_active_outlined, Colors.blueAccent),
                      _buildSectionContent(title: _t('notif'), child: _buildNotificationsContent()),

                      _buildSectionHeader(_t('stor'), Icons.storage_outlined, Colors.redAccent),
                      _buildSectionContent(title: _t('stor'), child: _buildStorageContent()),
                      
                      _buildSectionHeader(_t('acc'), Icons.manage_accounts, Colors.grey.shade400),
                      _buildSectionContent(title: _t('acc'), child: _buildAccountManagementContent()),
                      
                      const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}