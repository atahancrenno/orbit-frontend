import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Tıklanabilir metinler (RichText) için eklendi
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'login_screen.dart';
import '../constants/legal_texts.dart';

class LegalOnboardingScreen extends StatefulWidget {
  const LegalOnboardingScreen({super.key});

  @override
  State<LegalOnboardingScreen> createState() => _LegalOnboardingScreenState();
}

class _LegalOnboardingScreenState extends State<LegalOnboardingScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  String _currentLang = 'tr';

  // 🟢 ÇEVİRİ SÖZLÜĞÜ (Linkli metinler için ikiye bölündü)
  final Map<String, Map<String, String>> _texts = {
    'title': {'tr': 'Orbit\'e Hoş Geldiniz', 'en': 'Welcome to Orbit'},
    'desc': {'tr': 'Yörüngeye katılmadan önce yasal şartları onaylamanız gerekmektedir.', 'en': 'You must accept the legal terms before joining the orbit.'},
    
    // Hizmet Şartları Bölümü
    'terms_link': {'tr': 'Hizmet Şartlarını', 'en': 'Terms of Service'},
    'terms_rest': {'tr': ' kabul ediyorum.', 'en': ' I accept.'},
    
    // Gizlilik Politikası Bölümü
    'privacy_link': {'tr': 'KVKK ve Gizlilik Politikasını', 'en': 'Privacy Policy'},
    'privacy_rest': {'tr': ' okudum, onaylıyorum.', 'en': ' I have read and approve.'},
    
    'start': {'tr': 'BAŞLAT', 'en': 'START'},
    'close': {'tr': 'Kapat', 'en': 'Close'},
  };

  String _t(String key) => _texts[key]?[_currentLang] ?? _texts[key]?['en'] ?? key;

  @override
  void initState() {
    super.initState();
    _loadLang();
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _currentLang = prefs.getString('app_lang') ?? 'tr'; });
  }

  void _showLegalDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent, width: 1)),
        title: Text(_t(type == 'terms' ? 'terms_link' : 'privacy_link'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Html(
              data: LegalTexts.getHtml(type, _currentLang),
              style: {
                "body": Style(color: Colors.white70, fontSize: FontSize(13)),
                "h1": Style(color: Colors.cyanAccent, fontSize: FontSize(18), fontWeight: FontWeight.bold),
                "strong": Style(color: Colors.white),
              },
            ),
          ),
        ),
        actions: [ 
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text(_t('close'), style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))
          ) 
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    if (_termsAccepted && _privacyAccepted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('legal_accepted', true);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Logo Alanı
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.15), blurRadius: 50)], 
                  image: const DecorationImage(image: AssetImage('assets/images/logo.png'), fit: BoxFit.contain)
                )
              ),
              const SizedBox(height: 30),
              Text(_t('title'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 15),
              Text(_t('desc'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 40),

              // 🟢 YENİ: Hizmet Şartları Onay Kutusu ve Linkli Metin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (val) => setState(() => _termsAccepted = val!),
                    activeColor: Colors.cyanAccent,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _t('terms_link'),
                              style: const TextStyle(
                                color: Colors.cyanAccent, 
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () => _showLegalDialog('terms'),
                            ),
                            TextSpan(
                              text: _t('terms_rest'),
                              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // 🟢 YENİ: Gizlilik Politikası Onay Kutusu ve Linkli Metin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _privacyAccepted,
                    onChanged: (val) => setState(() => _privacyAccepted = val!),
                    activeColor: Colors.cyanAccent,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _t('privacy_link'),
                              style: const TextStyle(
                                color: Colors.cyanAccent, 
                                fontSize: 14, 
                                fontWeight: FontWeight.bold, 
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () => _showLegalDialog('privacy'),
                            ),
                            TextSpan(
                              text: _t('privacy_rest'),
                              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Başlat Butonu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_termsAccepted && _privacyAccepted) ? Colors.cyanAccent : Colors.grey.shade800, 
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: (_termsAccepted && _privacyAccepted) ? _completeOnboarding : null,
                  child: Text(_t('start'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}