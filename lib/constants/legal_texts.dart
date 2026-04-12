class LegalTexts {
  static const Map<String, Map<String, String>> texts = {
    // HİZMET ŞARTLARI (TERMS OF SERVICE)
    'terms': {
      'tr': '''# Orbit Hizmet Şartları
Son Güncelleme: 1 Ocak 2024

Orbit PTT Network uygulamasına hoş geldiniz. Bu uygulamayı kullanarak aşağıdaki şartları kabul etmiş sayılırsınız:

1. KULLANIM LİSANSI: Orbit, size kişisel, devredilemez ve sınırlı bir kullanım lisansı sunar.
2. HESAP GÜVENLİĞİ: Hesabınızın ve doğrulama kodunuzun güvenliğinden siz sorumlusunuz.
3. YASAKLI FAALİYETLER: Uygulamayı yasa dışı amaçlarla veya başkalarına zarar verecek şekilde kullanamazsınız.
4. HİZMET DEĞİŞİKLİKLERİ: Orbit, hizmet özelliklerini önceden haber vermeksizin değiştirme hakkını saklı tutar.

Detaylı bilgi için lütfen web sitemizi ziyaret edin.''',
      
      'en': '''# Orbit Terms of Service
Last Updated: January 1, 2024

Welcome to Orbit PTT Network. By using this application, you agree to the following terms:

1. USER LICENSE: Orbit grants you a personal, non-transferable, and limited license to use the app.
2. ACCOUNT SECURITY: You are responsible for the security of your account and verification code.
3. PROHIBITED ACTIVITIES: You may not use the application for illegal purposes or in a way that harms others.
4. SERVICE CHANGES: Orbit reserves the right to change service features without prior notice.

For detailed information, please visit our website.''',
    },

    // KVKK / GDPR (PRIVACY POLICY)
    'privacy': {
      'tr': '''# KVKK ve Gizlilik Politikası
Son Güncelleme: 1 Ocak 2024

Orbit olarak kişisel verilerinizin güvenliğine önem veriyoruz.

1. TOPLANAN VERİLER: Sadece telefon numaranız ve profil bilgileriniz (ad, fotoğraf) işlenir. Ses iletimleri anlıktır ve kaydedilmez (Ayarlardaki self-destruct özelliği hariç).
2. VERİ İŞLEME AMACI: Hizmetin sağlanması, doğrulanması ve teknik destek için.
3. VERİ PAYLAŞIMI: Verileriniz yasal zorunluluklar haricinde üçüncü taraflarla paylaşılmaz.
4. HAKLARINIZ: Verilerinize erişme, düzeltme veya silme hakkına sahipsiniz.

Sorularınız için privacy@orbitptt.com adresinden bize ulaşabilirsiniz.''',

      'en': '''# GDPR and Privacy Policy
Last Updated: January 1, 2024

At Orbit, we value the security of your personal data.

1. DATA COLLECTED: Only your phone number and profile information (name, photo) are processed. Audio transmissions are instant and not recorded (except for the self-destruct feature in Settings).
2. PURPOSE OF PROCESSING: To provide service, verification, and technical support.
3. DATA SHARING: Your data is not shared with third parties except for legal obligations.
4. YOUR RIGHTS: You have the right to access, correct, or delete your data.

For your questions, please contact us at privacy@orbitptt.com.''',
    }
  };

  static String getHtml(String type, String lang) {
    String markdown = texts[type]?[lang] ?? texts[type]?['en'] ?? '';
    
    // 🟢 DÜZELTME: Dart dilinde Regex gruplarını ($1, $2) string içinde kullanmak için replaceAllMapped kullanılır.
    return markdown
        .replaceAllMapped(RegExp(r'^# (.*)$', multiLine: true), (match) => '<h1>${match[1]}</h1>')
        .replaceAllMapped(RegExp(r'^(\d+)\. (.*)$', multiLine: true), (match) => '<p><strong>${match[1]}.</strong> ${match[2]}</p>')
        .replaceAll('\n', '<br>');
  }
}