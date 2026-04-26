import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'orbit_main_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  String _errorMessage = "";

  String _verificationId = "";
  
  // 🟢 DİL SEÇENEĞİ
  String _currentLang = 'tr'; 

  // 🟢 12 DİLLİ TAM SET
  final Map<String, String> _langNames = {
    'tr': '🇹🇷 TR',
    'en': '🇬🇧 EN',
    'es': '🇪🇸 ES',
    'ar': '🇸🇦 AR',
    'de': '🇩🇪 DE',
    'ru': '🇷🇺 RU',
    'fr': '🇫🇷 FR',
    'it': '🇮🇹 IT',
    'nl': '🇳🇱 NL',
    'az': '🇦🇿 AZ',
    'zh': '🇨🇳 ZH',
    'hi': '🇮🇳 HI'
  };

  final Map<String, Map<String, String>> _texts = {
    'sec_lock': {'tr': 'Güvenlik Kilidi Devrede', 'en': 'Security Lock Active', 'es': 'Bloqueo de seguridad activo', 'ar': 'قفل الأمان نشط', 'de': 'Sicherheitssperre aktiv', 'ru': 'Блокировка безопасности активна'},
    'enter_code': {'tr': 'Lütfen onay kodunu girin.', 'en': 'Please enter the confirmation code.', 'es': 'Introduzca el código de confirmación.', 'ar': 'الرجاء إدخال رمز التأكيد.', 'de': 'Bitte Bestätigungscode eingeben.', 'ru': 'Введите код подтверждения.'},
    'connect_network': {'tr': 'Güvenli telsiz ağına bağlanın.', 'en': 'Connect to the secure PTT network.', 'es': 'Conéctese a la red PTT segura.', 'ar': 'اتصل بشبكة PTT الآمنة.', 'de': 'Verbinden Sie sich mit dem sicheren PTT-Netzwerk.', 'ru': 'Подключитесь к безопасной сети PTT.'},
    'too_many_attempts': {'tr': 'Çok fazla hatalı giriş yaptınız.', 'en': 'Too many incorrect attempts.', 'es': 'Demasiados intentos incorrectos.', 'ar': 'محاولات خاطئة كثيرة جدًا.', 'de': 'Zu viele fehlerhafte Versuche.', 'ru': 'Слишком много неверных попыток.'},
    'try_again_after': {'tr': 'Lütfen şu tarihten sonra tekrar deneyin:\n\n', 'en': 'Please try again after:\n\n', 'es': 'Inténtelo de nuevo después de:\n\n', 'ar': 'يرجى المحاولة مرة أخرى بعد:\n\n', 'de': 'Bitte versuchen Sie es erneut nach:\n\n', 'ru': 'Пожалуйста, повторите попытку после:\n\n'},
    'valid_phone': {'tr': 'Geçerli bir telefon numarası girin.', 'en': 'Enter a valid phone number.', 'es': 'Introduzca un número de teléfono válido.', 'ar': 'أدخل رقم هاتف صالح.', 'de': 'Geben Sie eine gültige Telefonnummer ein.', 'ru': 'Введите действительный номер телефона.'},
    'invalid_format': {'tr': 'Geçersiz telefon numarası formatı.', 'en': 'Invalid phone number format.', 'es': 'Formato de teléfono no válido.', 'ar': 'تنسيق رقم الهاتف غير صالح.', 'de': 'Ungültiges Telefonnummernformat.', 'ru': 'Неверный формат номера телефона.'},
    'too_many_requests': {'tr': 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.', 'en': 'Too many attempts. Please try again later.', 'es': 'Demasiados intentos. Inténtelo de nuevo más tarde.', 'ar': 'محاولات كثيرة جدًا. يرجى المحاولة مرة أخرى لاحقًا.', 'de': 'Zu viele Versuche. Bitte versuchen Sie es später erneut.', 'ru': 'Слишком много попыток. Пожалуйста, повторите позже.'},
    'sms_failed': {'tr': 'SMS gönderilemedi: ', 'en': 'Failed to send SMS: ', 'es': 'Error al enviar SMS: ', 'ar': 'فشل إرسال رسالة قصيرة: ', 'de': 'SMS konnte nicht gesendet werden: ', 'ru': 'Не удалось отправить SMS: '},
    'unexpected_error': {'tr': 'Beklenmeyen bir hata oluştu.', 'en': 'An unexpected error occurred.', 'es': 'Ocurrió un error inesperado.', 'ar': 'حدث خطأ غير متوقع.', 'de': 'Ein unerwarteter Fehler ist aufgetreten.', 'ru': 'Произошла непредвиденная ошибка.'},
    'enter_6_digit': {'tr': 'Lütfen 6 haneli kodu girin.', 'en': 'Please enter the 6-digit code.', 'es': 'Introduzca el código de 6 dígitos.', 'ar': 'الرجاء إدخال الرمز المكون من 6 أرقام.', 'de': 'Bitte geben Sie den 6-stelligen Code ein.', 'ru': 'Пожалуйста, введите 6-значный код.'},
    'invalid_code_attempts': {'tr': 'Hatalı kod. Kalan deneme: ', 'en': 'Invalid code. Attempts left: ', 'es': 'Código no válido. Intentos restantes: ', 'ar': 'رمز غير صالح. المحاولات المتبقية: ', 'de': 'Falscher Code. Verbleibende Versuche: ', 'ru': 'Неверный код. Осталось попыток: '},
    'verification_failed': {'tr': 'Doğrulama başarısız oldu.', 'en': 'Verification failed.', 'es': 'Verificación fallida.', 'ar': 'فشل التحقق.', 'de': 'Überprüfung fehlgeschlagen.', 'ru': 'Ошибка проверки.'},
    'server_rejected': {'tr': 'Sunucu bileti reddetti.', 'en': 'Server rejected the ticket.', 'es': 'El servidor rechazó el ticket.', 'ar': 'رفض الخادم التذكرة.', 'de': 'Server hat das Ticket abgelehnt.', 'ru': 'Сервер отклонил билет.'},
    'system_login_failed': {'tr': 'Sisteme giriş yapılamadı.', 'en': 'System login failed.', 'es': 'Fallo al iniciar sesión en el sistema.', 'ar': 'فشل تسجيل الدخول إلى النظام.', 'de': 'Systemanmeldung fehlgeschlagen.', 'ru': 'Не удалось войти в систему.'},
    'send_code': {'tr': 'Kod Gönder', 'en': 'Send Code', 'es': 'Enviar código', 'ar': 'إرسال الرمز', 'de': 'Code senden', 'ru': 'Отправить код'},
    'code_sent_to': {'tr': 'Kod şu numaraya gönderildi:', 'en': 'Code sent to:', 'es': 'Código enviado a:', 'ar': 'تم إرسال الرمز إلى:', 'de': 'Code gesendet an:', 'ru': 'Код отправлен на:'},
    'edit_number': {'tr': 'Numarayı Düzenle', 'en': 'Edit Number', 'es': 'Editar número', 'ar': 'تعديل الرقم', 'de': 'Nummer bearbeiten', 'ru': "Изменить номер"},
    'login': {'tr': 'Giriş Yap', 'en': 'Login', 'es': 'Iniciar sesión', 'ar': 'تسجيل الدخول', 'de': 'Anmelden', 'ru': 'Войти'},
    'resend_code': {'tr': 'Kodu Tekrar Gönder', 'en': 'Resend Code', 'es': 'Reenviar código', 'ar': 'إعادة إرسال الرمز', 'de': 'Code erneut senden', 'ru': 'Отправить код еще раз'},
    'resend_in': {'tr': 'Yeni kod için kalan süre: ', 'en': 'Resend code in: ', 'es': 'Reenviar código en: ', 'ar': 'إعادة إرسال الرمز خلال: ', 'de': 'Code erneut senden in: ', 'ru': 'Отправить код повторно через: '}
  };

  String _t(String key) {
    return _texts[key]?[_currentLang] ?? _texts[key]?['en'] ?? key;
  }

  String _selectedCountryCode = "+90";
  String _selectedFlag = "🇹🇷"; 
  final List<Map<String, String>> _countryList = [
    {"code": "+90", "flag": "🇹🇷"},
    {"code": "+1", "flag": "🇺🇸"},
    {"code": "+44", "flag": "🇬🇧"},
    {"code": "+49", "flag": "🇩🇪"},
    {"code": "+33", "flag": "🇫🇷"},
    {"code": "+39", "flag": "🇮🇹"},
    {"code": "+34", "flag": "🇪🇸"},
    {"code": "+31", "flag": "🇳🇱"},
    {"code": "+7", "flag": "🇷🇺"},
    {"code": "+994", "flag": "🇦🇿"},
  ];

  Timer? _countdownTimer;
  int _secondsRemaining = 120; 
  bool _canResend = false;

  int _attemptCount = 0;
  DateTime? _blockUntil;
  bool _isBlocked = false;

  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference(); 
    _autoDetectCountry();
    _loadSecurityData();

    _logoAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeOutBack));
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeIn));
    _logoAnimationController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('app_lang') ?? 'tr';
    });
  }
  
  Future<void> _setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = langCode;
      _errorMessage = ""; 
    });
    await prefs.setString('app_lang', langCode);
  }

  void _autoDetectCountry() {
    try {
      String locale = Platform.localeName;
      String detectedCode = "+90";
      
      if (locale.endsWith('US') || locale.endsWith('CA')) {
        detectedCode = "+1";
      } else if (locale.endsWith('GB')) {
        detectedCode = "+44";
      } else if (locale.endsWith('DE')) {
        detectedCode = "+49";
      } else if (locale.endsWith('FR')) {
        detectedCode = "+33";
      } else if (locale.endsWith('ES')) {
        detectedCode = "+34";
      } else if (locale.endsWith('RU')) {
        detectedCode = "+7";
      } else if (locale.endsWith('AZ')) {
        detectedCode = "+994";
      }
      
      var match = _countryList.firstWhere((c) => c['code'] == detectedCode, orElse: () => _countryList[0]);
      _selectedCountryCode = match['code']!;
      _selectedFlag = match['flag']!;
    } catch (e) {
      _selectedCountryCode = "+90";
      _selectedFlag = "🇹🇷";
    }
  }

  Future<void> _loadSecurityData() async {
    final prefs = await SharedPreferences.getInstance();
    _attemptCount = prefs.getInt('otp_attempts') ?? 0;
    String? blockTimeString = prefs.getString('block_until');
    if (blockTimeString != null) {
      _blockUntil = DateTime.parse(blockTimeString);
      if (DateTime.now().isBefore(_blockUntil!)) {
        if (mounted) {
          setState(() { _isBlocked = true; });
        }
        _checkBlockExpiration();
      } else {
        _resetSecurityData();
      }
    }
  }

  Future<void> _recordAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    _attemptCount++;
    await prefs.setInt('otp_attempts', _attemptCount);
    if (_attemptCount >= 3) {
      _blockUntil = DateTime.now().add(const Duration(hours: 24));
      await prefs.setString('block_until', _blockUntil!.toIso8601String());
      if (mounted) {
        setState(() { _isBlocked = true; _isOtpSent = false; _errorMessage = ""; });
      }
      _checkBlockExpiration();
    }
  }

  Future<void> _resetSecurityData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp_attempts');
    await prefs.remove('block_until');
    if (mounted) {
      setState(() { _attemptCount = 0; _blockUntil = null; _isBlocked = false; });
    }
  }

  void _checkBlockExpiration() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_blockUntil != null && DateTime.now().isAfter(_blockUntil!)) {
        timer.cancel();
        _resetSecurityData();
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  void _startCountdown() {
    _secondsRemaining = 120;
    _canResend = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else { 
            _canResend = true; 
            timer.cancel(); 
          }
        });
      }
    });
  }

  String _formatTime(int seconds) => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  
  String _formatDate(DateTime date) {
    if (_currentLang == 'tr') {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} Saat ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _requestOtp() async {
   debugPrint ("🚀 DİKKAT: 'Kod Gönder' butonuna basıldı!");

    if (_isBlocked) {
      debugPrint("🛑 HATA: Sistem bloke edilmiş durumda.");
      return;
    }
    
    String rawPhone = _phoneController.text.trim().replaceAll(' ', '');
    debugPrint("📱 Kullanıcının girdiği ham numara: $rawPhone");

    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1);
      debugPrint("✂️ Baştaki sıfır temizlendi. Yeni numara: $rawPhone");
    }

    if (rawPhone.isEmpty || rawPhone.length < 9) { 
      debugPrint("🛑 HATA: Numara çok kısa! Ekrana hata yazdırılıyor.");
      setState(() => _errorMessage = _t('valid_phone')); 
      return; 
    }
    
    setState(() { _isLoading = true; _errorMessage = ""; });
    
    final fullPhone = "$_selectedCountryCode$rawPhone";
    debugPrint("🔥 Firebase'e Gönderilen Tam Numara: $fullPhone");

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("✅ Otomatik Doğrulama Başarılı! (SMS okundu)");
          await _signInWithFirebase(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("❌ FIREBASE HATASI PATLADI! Kod: ${e.code} - Mesaj: ${e.message}");
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (e.code == 'invalid-phone-number') {
                _errorMessage = _t('invalid_format');
              } else if (e.code == 'too-many-requests') {
                _errorMessage = _t('too_many_requests');
              } else {
                _errorMessage = '${_t('sms_failed')}${e.message}';
              }
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("📨 BAŞARILI! KOD GÖNDERİLDİ! Doğrulama ID alındı.");
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isOtpSent = true;
              _isLoading = false;
            });
            _startCountdown();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("⏱️ Otomatik yakalama zaman aşımı (Beklenen bir durum).");
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint("💥 BEKLENMEYEN UYGULAMA HATASI: $e");
      if (mounted) {
        setState(() { _errorMessage = _t('unexpected_error'); _isLoading = false; });
      }
    }
  }

  Future<void> _verifyOtp() async {
    debugPrint("🎯 DİKKAT: 'Giriş Yap' (Kodu Doğrula) butonuna basıldı!");
    if (_isBlocked) return;
    
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) { 
      setState(() => _errorMessage = _t('enter_6_digit')); 
      return; 
    }

    setState(() { _isLoading = true; _errorMessage = ""; });

    try {
      debugPrint("🔐 Kod Firebase'e gönderiliyor...");
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await _signInWithFirebase(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ KOD DOĞRULAMA HATASI: ${e.code}");
      await _recordAttempt();
      if (!_isBlocked && mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.code == 'invalid-verification-code' 
              ? "${_t('invalid_code_attempts')}${3 - _attemptCount}" 
              : _t('verification_failed');
        });
      }
    }
  }

  // 🛡️ [GÜMRÜK KÖPRÜSÜ]: Firebase onayından sonra DigitalOcean'dan Giriş Kartı (JWT) Alma
  Future<void> _signInWithFirebase(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        debugPrint("✅ FIREBASE GİRİŞİ BAŞARILI! Backend'e bilet onayı için gidiliyor...");
        await _resetSecurityData();
        
        String? idToken = await firebaseUser.getIdToken();
        String phoneNumber = firebaseUser.phoneNumber ?? "";

        if (idToken != null) {
          final response = await http.post(
            Uri.parse('http://188.166.101.147:3005/api/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'idToken': idToken}),
          );

          if (response.statusCode == 200) {
            debugPrint("🛂 BACKEND ONAYLADI! Bilet alındı, ana ekrana geçiliyor.");
            final data = json.decode(response.body);
            final String jwtToken = data['token']; 
            
            // 💾 DİKKAT: Ana ekranın (orbit_main_screen) aradığı bilet hafızaya kaydediliyor
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_phone', phoneNumber);
            await prefs.setString('auth_token', jwtToken); 
            
            if (!mounted) return;
            
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OrbitMainScreen()));
          } else {
            debugPrint("🛑 BACKEND REDDETTİ! Durum Kodu: ${response.statusCode}");
            if (mounted) {
              setState(() { _isLoading = false; _errorMessage = _t('server_rejected'); });
            }
            await FirebaseAuth.instance.signOut();
          }
        }
      }
    } catch (e) {
      debugPrint("💥 SİSTEME GİRİŞ HATASI (Firebase Sign-in): $e");
      if (mounted) {
        setState(() { _isLoading = false; _errorMessage = _t('system_login_failed'); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextDirection layoutDirection = _currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: layoutDirection,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // 🟢 ANA İÇERİK
              Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 60), 
                                  
                                  AnimatedBuilder(
                                    animation: _logoAnimationController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _logoOpacityAnimation.value,
                                        child: Transform.scale(
                                          scale: _logoScaleAnimation.value,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 120, height: 120,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 50, spreadRadius: 10)],
                                                  image: const DecorationImage(
                                                    image: AssetImage('assets/images/logo.png'), 
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              const Text("ORBIT", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 8.0)),
                                              const SizedBox(height: 4),
                                              Text("PTT NETWORK", style: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4.0)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  ),
                                  
                                  const SizedBox(height: 40),

                                  Text(
                                    _isBlocked ? _t('sec_lock') : _isOtpSent ? _t('enter_code') : _t('connect_network'),
                                    style: TextStyle(color: _isBlocked ? Colors.redAccent : Colors.cyanAccent, fontStyle: FontStyle.italic, fontSize: 14),
                                  ),
                                  const SizedBox(height: 30),

                                  if (_isBlocked && _blockUntil != null) ...[
                                    const Icon(Icons.lock_clock, color: Colors.redAccent, size: 60),
                                    const SizedBox(height: 20),
                                    Text(_t('too_many_attempts'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${_t('try_again_after')}${_formatDate(_blockUntil!)}", 
                                      textAlign: TextAlign.center, 
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)
                                    ),
                                  ]
                                  else ...[
                                    if (_errorMessage.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                        child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                                      ),

                                    if (!_isOtpSent) ...[
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.only(
                                                topLeft: layoutDirection == TextDirection.ltr ? const Radius.circular(15) : Radius.zero,
                                                bottomLeft: layoutDirection == TextDirection.ltr ? const Radius.circular(15) : Radius.zero,
                                                topRight: layoutDirection == TextDirection.rtl ? const Radius.circular(15) : Radius.zero,
                                                bottomRight: layoutDirection == TextDirection.rtl ? const Radius.circular(15) : Radius.zero,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _selectedCountryCode,
                                                dropdownColor: Colors.blueGrey.shade900,
                                                icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent, size: 20),
                                                isDense: true,
                                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                                items: _countryList.map((country) {
                                                  return DropdownMenuItem<String>(
                                                    value: country['code'],
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      textDirection: TextDirection.ltr, 
                                                      children: [
                                                        Text(country['flag']!, style: const TextStyle(fontSize: 20)),
                                                        const SizedBox(width: 6),
                                                        Text(country['code']!),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    setState(() {
                                                      _selectedCountryCode = newValue;
                                                      _selectedFlag = _countryList.firstWhere((c) => c['code'] == newValue)['flag']!;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 11,
                                              autofocus: true, 
                                              textDirection: TextDirection.ltr, 
                                              textAlign: layoutDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                              style: const TextStyle(color: Colors.white, fontSize: 18),
                                              decoration: InputDecoration(
                                                counterText: "",
                                                hintText: "5XX XXX XX XX",
                                                hintStyle: const TextStyle(color: Colors.white30),
                                                filled: true,
                                                fillColor: Colors.white.withValues(alpha: 0.05),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topRight: layoutDirection == TextDirection.ltr ? const Radius.circular(15) : Radius.zero,
                                                    bottomRight: layoutDirection == TextDirection.ltr ? const Radius.circular(15) : Radius.zero,
                                                    topLeft: layoutDirection == TextDirection.rtl ? const Radius.circular(15) : Radius.zero,
                                                    bottomLeft: layoutDirection == TextDirection.rtl ? const Radius.circular(15) : Radius.zero,
                                                  ), 
                                                  borderSide: BorderSide.none
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    if (_isOtpSent) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3))),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(_t('code_sent_to'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Directionality(
                                                  textDirection: TextDirection.ltr,
                                                  child: Text("$_selectedFlag $_selectedCountryCode ${_phoneController.text}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.cyanAccent), 
                                              tooltip: _t('edit_number'),
                                              onPressed: () { _countdownTimer?.cancel(); setState(() { _isOtpSent = false; _otpController.clear(); }); },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      TextField(
                                        controller: _otpController, keyboardType: TextInputType.number, textAlign: TextAlign.center, autofocus: true, 
                                        textDirection: TextDirection.ltr, 
                                        style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10), maxLength: 6,
                                        decoration: InputDecoration(counterText: "", hintText: "••••••", hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 10), filled: true, fillColor: Colors.white.withValues(alpha: 0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
                                      ),
                                    ],
                                  ],
                                  
                                  const SizedBox(height: 20), 
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🟢 SABİT AKSİYON ALANI
                  if (!_isBlocked)
                    Container(
                      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 10),
                      color: Colors.black, 
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isOtpSent)
                            SizedBox(
                              width: double.infinity, height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2), foregroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: const BorderSide(color: Colors.cyanAccent, width: 1)),
                                onPressed: _isLoading ? null : _requestOtp,
                                child: _isLoading 
                                    ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)) 
                                    : Text(_t('send_code'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity, height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                onPressed: _isLoading ? null : _verifyOtp,
                                child: _isLoading 
                                    ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                                    : Text(_t('login'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ),
                            ),

                          if (_isOtpSent) ...[
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _canResend
                                    ? TextButton.icon(icon: const Icon(Icons.refresh, color: Colors.cyanAccent, size: 18), onPressed: _requestOtp, label: Text(_t('resend_code'), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)))
                                    : Text("${_t('resend_in')}${_formatTime(_secondsRemaining)}", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),

              // 🟢 DİL SEÇİMİ POPUP
              Positioned(
                top: 10,
                right: layoutDirection == TextDirection.ltr ? 20 : null,
                left: layoutDirection == TextDirection.rtl ? 20 : null,
                child: PopupMenuButton<String>(
                  color: Colors.blueGrey.shade900,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.cyanAccent)),
                  onSelected: _setLanguage,
                  itemBuilder: (BuildContext context) {
                    return _langNames.entries.map((entry) {
                      return PopupMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value, style: TextStyle(color: _currentLang == entry.key ? Colors.cyanAccent : Colors.white, fontWeight: _currentLang == entry.key ? FontWeight.bold : FontWeight.normal)),
                      );
                    }).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, color: Colors.cyanAccent.withValues(alpha: 0.8), size: 16),
                        const SizedBox(width: 6),
                        Text(_langNames[_currentLang]!, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}