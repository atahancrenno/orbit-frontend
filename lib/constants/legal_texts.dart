class LegalTexts {
  static String getHtml(String type, String langCode) {
    if (type == 'terms') {
      switch (langCode) {
        case 'tr': return _termsTr;
        case 'ar': return _termsAr;
        case 'es': return _termsEs;
        case 'de': return _termsDe;
        case 'ru': return _termsRu;
        case 'en':
        default: return _termsEn;
      }
    } else {
      switch (langCode) {
        case 'tr': return _privacyTr;
        case 'ar': return _privacyAr;
        case 'es': return _privacyEs;
        case 'de': return _privacyDe;
        case 'ru': return _privacyRu;
        case 'en':
        default: return _privacyEn;
      }
    }
  }

  // 🇬🇧 ENGLISH
  static const String _termsEn = r'''
<h1>ORBIT PTT - COMPREHENSIVE TERMS OF SERVICE AND END USER LICENSE AGREEMENT</h1>
<p><strong>Effective Date: May 6, 2026</strong></p>

<h2>1. Scope, Acceptance, and Applicability</h2>
<p>These Terms of Service and End User License Agreement ("Terms" or "Agreement") constitute a legally binding contract between you ("User", "you", or "your") and CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("Orbit PTT", "Orbit", "Company", "we", "us", or "our"). By downloading, installing, accessing, or using the Orbit PTT mobile application (the "App"), our websites, or any related services (collectively, the "Services"), you expressly acknowledge that you have read, understood, and agree to be bound by all of the terms and conditions contained herein. If you are using the Services on behalf of an entity or organization, you represent and warrant that you have the authority to bind that entity to these Terms. If you do not agree to these Terms in their entirety, you are strictly prohibited from using the Services and must immediately uninstall the App.</p>

<h2>2. NO EMERGENCY CALLS (CRITICAL WARNING)</h2>
<p><strong>ORBIT PTT IS NOT A REPLACEMENT FOR YOUR ORDINARY MOBILE OR FIXED-LINE TELEPHONE. THE APP DOES NOT ALLOW YOU TO MAKE EMERGENCY CALLS TO EMERGENCY SERVICES (E.G., 911, 112, 999, OR ANY OTHER APPLICABLE EMERGENCY NUMBERS WORLDWIDE).</strong> You must ensure that you have alternative communication arrangements available to make emergency calls if needed. Orbit PTT operates over Internet Protocol (IP) and relies entirely on your data connection. Under no circumstances shall Orbit PTT, its officers, directors, employees, or affiliates be held liable for any claim, damage, or loss arising from or relating to your inability to use the App to contact emergency services.</p>

<h2>3. Eligibility, Account Registration, and Security</h2>
<p>To use the Services, you must be at least 13 years of age (or 16 years of age if residing in the European Economic Area, UK, or Switzerland, unless parental consent is provided according to local law). By registering for an account, you represent that you meet these age requirements. You agree to provide accurate, current, and complete information during the registration process (including your phone number for SMS verification) and to update such information to keep it accurate. You are solely responsible for safeguarding the confidentiality of your account credentials and for all activities that occur under your account. You must notify us immediately of any unauthorized use or suspected security breach.</p>

<h2>4. Orbit Plus Subscriptions, Fees, and App Store Terms</h2>
<p>While the basic version of Orbit PTT is free, we offer premium features through an auto-renewing subscription service called "Orbit Plus".<br>
<strong>a. Billing and Auto-Renewal:</strong> Subscription fees are charged to your Apple App Store or Google Play Store account at the confirmation of purchase. Subscriptions automatically renew at the then-current price unless auto-renew is turned off at least 24 hours before the end of the current billing period.<br>
<strong>b. Cancellations and Refunds:</strong> You may manage or cancel your subscription at any time through your device's account settings. Orbit PTT does not process payments directly. Therefore, all refunds are strictly governed by the policies of Apple and Google. We do not provide refunds or credits for any partial-month subscription periods.<br>
<strong>c. App Store EULA:</strong> Your use of the App is additionally subject to the Usage Rules set forth in the Apple Media Services Terms and Conditions or the Google Play Terms of Service.</p>

<h2>5. User Generated Content (UGC) & Strict Zero Tolerance Policy</h2>
<p>Orbit PTT provides real-time voice communication and messaging capabilities. You retain all ownership rights to the audio, text, and images you transmit ("User Content"). However, by using the App, you grant us a worldwide, non-exclusive, royalty-free license to route, process, and temporarily store your User Content solely for the purpose of operating the Services.<br>
<strong>Zero Tolerance Policy:</strong> We maintain a <strong>STRICT ZERO TOLERANCE POLICY</strong> against objectionable content and abusive behavior. You agree NOT to transmit any content that:<br>
- Is unlawful, harassing, threatening, defamatory, obscene, pornographic, or invasive of another's privacy.<br>
- Promotes violence, terrorism, discrimination, or hate speech against any group.<br>
- Infringes upon any third-party intellectual property rights.<br>
<strong>Enforcement:</strong> The App includes built-in mechanisms to Block and Report abusive users. Upon receiving a report, our moderation team will review the claim. Any user found violating these rules will have their account permanently suspended within 24 hours, without prior notice or right to a refund.</p>

<h2>6. Acceptable Use and Prohibited Activities</h2>
<p>You agree not to engage in any of the following prohibited activities: (i) copying, distributing, or disclosing any part of the App in any medium; (ii) using any automated system, including "robots," "spiders," or "offline readers," to access the App; (iii) attempting to interfere with, compromise the system integrity or security, or decipher any transmissions to or from the servers running the App; (iv) taking any action that imposes an unreasonable load on our infrastructure; (v) reverse engineering, decompiling, or disassembling the App; (vi) bypassing the measures we may use to prevent or restrict access to the App.</p>

<h2>7. Disclaimer of Warranties</h2>
<p>THE SERVICES ARE PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS. ORBIT PTT EXPRESSLY DISCLAIMS ALL WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE SERVICES WILL BE UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. WE DO NOT GUARANTEE THE TIMELY DELIVERY OF ANY VOICE TRANSMISSION.</p>

<h2>8. Limitation of Liability and Indemnification</h2>
<p>TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL ORBIT PTT, ITS AFFILIATES, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE FOR ANY INDIRECT, PUNITIVE, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES, INCLUDING WITHOUT LIMITATION DAMAGES FOR LOSS OF PROFITS, GOODWILL, USE, DATA, OR OTHER INTANGIBLE LOSSES, ARISING OUT OF OR RELATING TO THE USE OF, OR INABILITY TO USE, THIS APP. IN NO EVENT SHALL OUR TOTAL LIABILITY EXCEED THE AMOUNT YOU PAID TO US IN THE SIX (6) MONTHS PRECEDING THE CLAIM.<br>
You agree to defend, indemnify, and hold harmless Orbit PTT from and against any and all claims, damages, obligations, losses, liabilities, costs, or debt, and expenses arising from your violation of any term of these Terms.</p>

<h2>9. Governing Law, Arbitration, and Jurisdiction</h2>
<p>These Terms shall be governed by the internal substantive laws of the Republic of Turkey, without respect to its conflict of laws principles. Any claim or dispute between you and Orbit PTT that arises in whole or in part from the Services shall be decided exclusively by the Courts and Execution Offices of Istanbul (Kadikoy/Anadolu), Turkey. You hereby consent to the personal jurisdiction of such courts.</p>

<h2>10. Modifications and Contact Information</h2>
<p>We reserve the right to modify these Terms at any time. Material changes will be communicated via in-app notifications. Continued use of the App following such changes constitutes your acceptance.<br>
If you have any questions, please contact us at: <strong>support@orbit-talk.com</strong>.</p>
''';
  static const String _privacyEn = r'''
<h1>ORBIT PTT - COMPREHENSIVE PRIVACY POLICY</h1>
<p><strong>Effective Date: May 6, 2026</strong></p>

<h2>1. Introduction</h2>
<p>CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("Orbit PTT", "we", "us", or "our") respoects your privacy. This Comprehensive Privacy Policy explains in detail how we collect, use, process, disclose, and protect your information when you use the Orbit PTT application and related services.</p>

<h2>2. Information We Collect and How We Collect It</h2>
<p><strong>a. Information You Provide:</strong> When you register, we collect your phone number for authentication purposes. You may also choose to provide a display name and profile picture.<br>
<strong>b. Microphone Access (Crucial):</strong> To provide our core Push-to-Talk functionality, the App requires access to your device's microphone. We ONLY access the microphone when you actively press and hold the PTT button. We absolutely DO NOT record, listen to, or monitor ambient background noise when the button is not pressed.<br>
<strong>c. Contacts and Address Book:</strong> With your explicit permission, we access your device's contact list to help you find and connect with other Orbit PTT users. To protect your privacy, we utilize secure cryptographic hashing. We do not upload or store your raw address book on our servers permanently. We only use hashed values to match phone numbers with existing registered users.<br>
<strong>d. Audio Data (Voice Messages):</strong> Real-time voice transmissions and recorded voice messages are temporarily cached on our servers solely to facilitate delivery to the intended recipient(s). Once delivered, or after a short system-defined expiration period, these audio files are permanently purged from our servers. We do not build databases of user voice recordings.<br>
<strong>e. Device and Usage Data:</strong> We automatically collect diagnostic and usage data, including IP addresses, device identifiers (e.g., IMEI, MAC, IDFA/AAID), operating system versions, and crash logs to maintain and improve app stability.</p>

<h2>3. How We Use Your Information</h2>
<p>We use the collected information to: (i) Provide, maintain, and improve the Services; (ii) Process and route your voice and text communications; (iii) Manage your account and subscriptions; (iv) Respond to customer support requests; (v) Monitor for fraudulent activity and enforce our Zero Tolerance UGC policy; and (vi) Serve personalized advertisements (for free users).</p>

<h2>4. Sharing with Third-Party Service Providers</h2>
<p>We do not sell your personal data. We share necessary data with trusted third parties under strict confidentiality agreements:<br>
- <strong>Google Firebase:</strong> For secure SMS authentication, real-time database management, and crash analytics.<br>
- <strong>Adapty:</strong> For managing "Orbit Plus" subscriptions. Adapty securely processes subscription states; we never see your raw credit card data.<br>
- <strong>Google AdMob:</strong> For serving advertisements in the free version. AdMob may collect and use advertising identifiers to show targeted ads. You can opt out of personalized ads via your iOS/Android system privacy settings.</p>

<h2>5. Data Security and International Transfers</h2>
<p>We implement robust, industry-standard physical, technical, and administrative security measures (including SSL/TLS encryption) to protect your data in transit and at rest. However, no method of transmission over the Internet is 100% secure. By using the App, you consent to the transfer and processing of your data on servers located outside of your country of residence, primarily within the EU or USA, in compliance with standard contractual clauses.</p>

<h2>6. Children's Privacy (COPPA Compliance)</h2>
<p>The Services are not directed to persons under 13 (or 16 in certain EEA countries). We do not knowingly collect personally identifiable information from children. If we become aware that a child has provided us with personal information without verifiable parental consent, we will take immediate steps to delete such information from our systems.</p>

<h2>7. Your Privacy Rights (GDPR, CCPA, KVKK)</h2>
<p>Depending on your jurisdiction, you have the right to: (i) Access the personal data we hold about you; (ii) Request corrections to inaccurate data; (iii) Withdraw consent for microphone or contact access via device settings; and (iv) <strong>Request Deletion:</strong> You can permanently delete your account and all associated data directly within the App's settings menu ("Delete Account").</p>

<h2>8. Contact the Data Protection Officer</h2>
<p>For any privacy-related inquiries, data requests, or concerns, please contact us at: <strong>support@orbit-talk.com</strong>.</p>
''';

  // 🇹🇷 TÜRKÇE
  static const String _termsTr = r'''
<h1>ORBIT PTT - KAPSAMLI KULLANIM ŞARTLARI VE SON KULLANICI LİSANS SÖZLEŞMESİ (EULA)</h1>
<p><strong>Yürürlük Tarihi: 6 Mayıs 2026</strong></p>

<h2>1. Kapsam, Kabul ve Uygulanabilirlik</h2>
<p>Bu Kullanım Şartları ve Son Kullanıcı Lisans Sözleşmesi ("Şartlar" veya "Sözleşme"), sizinle ("Kullanıcı" veya "Siz") CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("Orbit PTT", "Şirket", "biz" veya "bizim") arasında yasal olarak bağlayıcı bir sözleşmedir. Orbit PTT mobil uygulamasını ("Uygulama") veya ilgili hizmetleri (topluca "Hizmetler") indirerek, yükleyerek, erişerek veya kullanarak, burada yer alan tüm şart ve koşulları okuduğunuzu, anladığınızı ve bunlara bağlı kalmayı açıkça kabul etmiş olursunuz. Hizmetleri bir kurum adına kullanıyorsanız, o kurumu bu Şartlara bağlama yetkisine sahip olduğunuzu beyan edersiniz. Bu Şartların tamamını kabul etmiyorsanız, Hizmetleri kullanmanız kesinlikle yasaktır ve Uygulamayı derhal kaldırmalısınız.</p>

<h2>2. ACİL DURUM ARAMALARININ YAPILAMAMASI (KRİTİK UYARI)</h2>
<p><strong>ORBIT PTT, NORMAL CEP TELEFONUNUZUN VEYA SABİT HATLI TELEFONUNUZUN BİR ALTERNATİFİ DEĞİLDİR. UYGULAMA, ACİL DURUM SERVİSLERİNE (ÖRN. 112, 155, 911 VEYA DÜNYA ÇAPINDAKİ DİĞER ACİL NUMARALARA) ARAMA YAPMANIZA İZİN VERMEZ.</strong> Acil durum aramaları yapmak için alternatif iletişim yöntemlerine (normal GSM hattı vb.) sahip olduğunuzdan emin olmalısınız. Orbit PTT, İnternet Protokolü (IP) üzerinden çalışır ve tamamen veri bağlantınıza dayanır. Hiçbir koşulda Orbit PTT, yöneticileri, çalışanları veya bağlı kuruluşları, acil servislerle iletişim kuramamanızdan kaynaklanan hiçbir iddia, hasar veya kayıptan sorumlu tutulamaz.</p>

<h2>3. Uygunluk, Hesap Kaydı ve Güvenlik</h2>
<p>Hizmetleri kullanabilmek için en az 13 yaşında (veya yerel yasalara göre ebeveyn izni sağlanmadıkça Avrupa Ekonomik Alanı'nda 16 yaşında) olmalısınız. Kayıt olarak bu yaş gereksinimlerini karşıladığınızı beyan edersiniz. Kayıt işlemi sırasında (SMS doğrulaması için telefon numaranız dahil) doğru, güncel ve eksiksiz bilgi vermeyi ve bu bilgileri güncel tutmayı kabul edersiniz. Hesap bilgilerinizin gizliliğini korumaktan ve hesabınız altında gerçekleşen tüm faaliyetlerden tamamen siz sorumlusunuz. Herhangi bir yetkisiz kullanımı veya güvenlik ihlali şüphesini bize derhal bildirmelisiniz.</p>

<h2>4. Orbit Plus Abonelikleri, Ücretler ve Mağaza Şartları</h2>
<p>Orbit PTT'nin temel sürümü ücretsiz olmakla birlikte, "Orbit Plus" adlı otomatik yenilenen abonelik hizmeti aracılığıyla premium özellikler sunuyoruz.<br>
<strong>a. Faturalandırma ve Otomatik Yenileme:</strong> Abonelik ücretleri, satın alma onayı ile Apple App Store veya Google Play Store hesabınızdan tahsil edilir. Abonelikler, mevcut fatura döneminin bitiminden en az 24 saat önce otomatik yenileme kapatılmadıkça, o anki fiyat üzerinden otomatik olarak yenilenir.<br>
<strong>b. İptaller ve İadeler:</strong> Aboneliğinizi cihazınızın hesap ayarları üzerinden istediğiniz zaman yönetebilir veya iptal edebilirsiniz. Orbit PTT ödemeleri doğrudan işlemez; bu nedenle tüm iadeler kesinlikle Apple ve Google'ın politikalarına tabidir. Kısmi aylık kullanım dönemleri için iade yapmıyoruz.<br>
<strong>c. App Store EULA:</strong> Uygulamayı kullanımınız ayrıca Apple veya Google Play Hizmet Şartlarında belirtilen Kullanım Kurallarına da tabidir.</p>

<h2>5. Kullanıcı Tarafından Üretilen İçerik (UGC) ve Kesin Sıfır Tolerans Politikası</h2>
<p>İlettiğiniz ses, metin ve resimlerin ("Kullanıcı İçeriği") tüm mülkiyet hakları size aittir. Ancak, Uygulamayı kullanarak, Kullanıcı İçeriğinizi yalnızca Hizmetleri işletmek amacıyla yönlendirmemiz, işlememiz ve geçici olarak saklamamız için bize dünya çapında lisans vermiş olursunuz.<br>
<strong>Sıfır Tolerans Politikası:</strong> Rahatsız edici içeriklere ve istismar edici davranışlara karşı <strong>KESİN BİR SIFIR TOLERANS POLİTİKASI</strong> uygulamaktayız. Aşağıdaki özelliklere sahip hiçbir içeriği iletmeyeceğinizi kabul edersiniz:<br>
- Yasadışı, taciz edici, tehditkar, iftira niteliğinde, müstehcen, pornografik veya başkasının gizliliğini ihlal eden.<br>
- Herhangi bir gruba karşı şiddeti, terörizmi, ayrımcılığı veya nefret söylemini teşvik eden.<br>
- Üçüncü tarafların fikri mülkiyet haklarını ihlal eden.<br>
<strong>Yaptırım:</strong> Uygulama, istismar edici kullanıcıları Engellemek ve Rapor Etmek için yerleşik mekanizmalara sahiptir. Bir rapor alındığında, moderasyon ekibimiz iddiayı inceleyecektir. Bu kuralları ihlal ettiği tespit edilen herhangi bir kullanıcının hesabı 24 saat içinde, önceden haber verilmeksizin veya iade hakkı olmaksızın kalıcı olarak askıya alınacaktır.</p>

<h2>6. Kabul Edilebilir Kullanım ve Yasaklanmış Aktiviteler</h2>
<p>Aşağıdaki yasaklanmış faaliyetlerden hiçbirine katılmamayı kabul edersiniz: (i) Uygulamanın herhangi bir bölümünü kopyalamak, dağıtmak veya tersine mühendislik yapmak; (ii) "robotlar" veya "örümcekler" dahil olmak üzere otomatik sistemler kullanmak; (iii) sistem bütünlüğüne veya güvenliğine müdahale etmeye çalışmak; (iv) altyapımıza makul olmayan bir yük bindiren herhangi bir eylemde bulunmak.</p>

<h2>7. Garanti Reddi</h2>
<p>HİZMETLER "OLDUĞU GİBİ" VE "MEVCUT OLDUĞU GİBİ" ESASINA GÖRE SUNULMAKTADIR. ORBIT PTT, TİCARİ ELVERİŞLİLİK VEYA BELİRLİ BİR AMACA UYGUNLUK DAHİL OLMAK ÜZERE AÇIK VEYA ZIMNİ HİÇBİR GARANTİYİ AÇIKÇA REDDEDER. HİZMETLERİN KESİNTİSİZ, GÜVENLİ VEYA HATASIZ OLACAĞINI GARANTİ ETMİYORUZ. SES İLETİMLERİNİN ZAMANINDA TESLİM EDİLECEĞİNİ GARANTİ ETMİYORUZ.</p>

<h2>8. Sorumluluğun Sınırlandırılması ve Tazminat</h2>
<p>GEÇERLİ KANUNLARIN İZİN VERDİĞİ AZAMİ ÖLÇÜDE, HİÇBİR DURUMDA ORBIT PTT, YÖNETİCİLERİ VEYA ÇALIŞANLARI, UYGULAMAYI KULLANMANIZDAN KAYNAKLANAN KAR KAYBI, VERİ KAYBI VEYA DİĞER SOYUT KAYIPLAR DAHİL OLMAK ÜZERE DOLAYLI, CEZAİ VEYA TESADÜFİ ZARARLARDAN SORUMLU OLMAYACAKTIR. TOPLAM SORUMLULUĞUMUZ SON 6 AY İÇİNDE BİZE ÖDEDİĞİNİZ MİKTARI AŞAMAZ.<br>
Bu Şartları ihlal etmenizden kaynaklanan tüm iddia, zarar, borç ve masraflara karşı Orbit PTT'yi savunmayı ve zararlarını tazmin etmeyi kabul edersiniz.</p>

<h2>9. Uygulanacak Hukuk, Tahkim ve Yargı Yetkisi</h2>
<p>Bu Şartlar, kanunlar ihtilafı prensiplerine bakılmaksızın Türkiye Cumhuriyeti'nin iç maddi hukukuna tabi olacaktır. Sizinle Orbit PTT arasında Hizmetlerden kaynaklanan herhangi bir iddia veya ihtilaf, münhasıran Türkiye, İstanbul (Kadıköy/Anadolu) Mahkemeleri ve İcra Daireleri tarafından karara bağlanacaktır.</p>

<h2>10. İletişim Bilgileri</h2>
<p>Herhangi bir sorunuz varsa lütfen bizimle iletişime geçin: <strong>support@orbit-talk.com</strong>.</p>
''';
  static const String _privacyTr = r'''
<h1>ORBIT PTT - KAPSAMLI GİZLİLİK POLİTİKASI</h1>
<p><strong>Yürürlük Tarihi: 6 Mayıs 2026</strong></p>

<h2>1. Giriş</h2>
<p>CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("Orbit PTT", "biz" veya "bizim") gizliliğinize saygı duyar. Bu Kapsamlı Gizlilik Politikası, Orbit PTT uygulamasını kullandığınızda bilgilerinizi nasıl topladığımızı, kullandığımızı, işlediğimizi ve koruduğumuzu ayrıntılı olarak açıklar.</p>

<h2>2. Topladığımız Bilgiler ve Toplama Yöntemlerimiz</h2>
<p><strong>a. Sizin Sağladığınız Bilgiler:</strong> Kayıt olduğunuzda, kimlik doğrulama için telefon numaranızı toplarız. İsteğe bağlı olarak bir görünen ad ve profil resmi de sağlayabilirsiniz.<br>
<strong>b. Mikrofon Erişimi (Kritik):</strong> Temel Bas-Konuş işlevimizi sağlamak için Uygulama, cihazınızın mikrofonuna erişim gerektirir. Mikrofona SADECE siz aktif olarak PTT düğmesini basılı tuttuğunuzda erişiriz. Düğmeye basılmadığında ortam arka plan gürültüsünü KESİNLİKLE kaydetmez, dinlemez veya izlemeyiz.<br>
<strong>c. Kişiler ve Adres Defteri:</strong> Açık izninizle, diğer Orbit kullanıcılarıyla bağlantı kurmanıza yardımcı olmak için cihazınızın rehberine erişiriz. Gizliliğinizi korumak için güvenli kriptografik özetleme (hashing) kullanırız. Adres defterinizin ham halini sunucularımıza yüklemez veya kalıcı olarak saklamayız.<br>
<strong>d. Ses Verileri (Sesli Mesajlar):</strong> Gerçek zamanlı ses iletimleri ve kaydedilmiş sesli mesajlar, yalnızca alıcıya teslim edilmesini kolaylaştırmak için sunucularımızda geçici olarak önbelleğe alınır. Teslim edildikten veya kısa bir süre geçtikten sonra bu ses dosyaları sunucularımızdan kalıcı olarak temizlenir. Kullanıcı ses kayıtlarından oluşan veritabanları oluşturmuyoruz.<br>
<strong>e. Cihaz ve Kullanım Verileri:</strong> Uygulama kararlılığını korumak için IP adresleri, cihaz kimlikleri (örn. IMEI, MAC, IDFA), işletim sistemi sürümleri ve çökme günlükleri gibi teknik verileri otomatik olarak toplarız.</p>

<h2>3. Bilgilerinizi Nasıl Kullanıyoruz</h2>
<p>Toplanan bilgileri şu amaçlarla kullanırız: (i) Hizmetleri sağlamak; (ii) Ses ve metin iletişimlerinizi yönlendirmek; (iii) Hesabınızı yönetmek; (iv) Dolandırıcılık faaliyetlerini izlemek ve Sıfır Tolerans politikamızı uygulamak; (v) Ücretsiz kullanıcılara kişiselleştirilmiş reklamlar sunmak.</p>

<h2>4. Üçüncü Taraf Hizmet Sağlayıcılarla Paylaşım</h2>
<p>Kişisel verilerinizi satmıyoruz. Gerekli verileri, sıkı gizlilik sözleşmeleri altında güvenilir üçüncü taraflarla paylaşıyoruz:<br>
- <strong>Google Firebase:</strong> Güvenli SMS doğrulaması ve çökme analitiği için.<br>
- <strong>Adapty:</strong> Abonelikleri yönetmek için. Ham kredi kartı verilerinizi asla görmeyiz.<br>
- <strong>Google AdMob:</strong> Ücretsiz sürümde reklam sunmak için. AdMob, hedeflenen reklamları göstermek için reklam tanımlayıcılarını toplayabilir. Cihaz ayarlarınızdan kişiselleştirilmiş reklamlardan çıkabilirsiniz.</p>

<h2>5. Veri Güvenliği ve Uluslararası Aktarımlar</h2>
<p>Verilerinizi aktarım sırasında korumak için endüstri standardı SSL/TLS şifreleme kullanıyoruz. Ancak, İnternet üzerinden hiçbir iletim yöntemi %100 güvenli değildir. Uygulamayı kullanarak, verilerinizin standart sözleşme maddelerine uygun olarak, ikamet ettiğiniz ülke dışındaki (başta AB veya ABD olmak üzere) sunuculara aktarılmasına onay verirsiniz.</p>

<h2>6. Çocukların Gizliliği (COPPA / KVKK Uyumluluğu)</h2>
<p>Hizmetler 13 yaşın (veya AEA ülkelerinde 16 yaşın) altındaki kişilere yönelik değildir. Bilerek çocuklardan veri toplamıyoruz. Ebeveyn izni olmadan bir çocuğun bize veri sağladığını fark edersek, bu bilgileri derhal sileriz.</p>

<h2>7. Gizlilik Haklarınız (KVKK, GDPR, CCPA)</h2>
<p>Şunları yapma hakkına sahipsiniz: (i) Verilerinize erişme; (ii) Yanlış verilerin düzeltilmesini talep etme; (iii) İzinleri geri çekme; ve (iv) <strong>Silme Talebi:</strong> Uygulamanın ayarlar menüsünden ("Hesabı Sil") hesabınızı ve tüm verilerinizi kalıcı olarak silebilirsiniz.</p>

<h2>8. İletişim</h2>
<p>Gizlilikle ilgili tüm sorularınız için: <strong>support@orbit-talk.com</strong>.</p>
''';

  // 🇸🇦 ARABIC (RTL SUPPORTED)
  static const String _termsAr = r'''
<div dir="rtl" style="text-align: right;">
<h1>أوربيت بي تي تي - شروط الخدمة الشاملة واتفاقية ترخيص المستخدم النهائي</h1>
<p><strong>تاريخ النفاذ: 6 مايو 2026</strong></p>

<h2>1. النطاق والقبول وقابلية التطبيق</h2>
<p>تشكل شروط الخدمة واتفاقية ترخيص المستخدم النهائي هذه ("الشروط" أو "الاتفاقية") عقداً ملزماً قانوناً بينك ("المستخدم" أو "أنت") وبين شركة CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("أوربيت بي تي تي"، "الشركة"، "نحن"). من خلال تنزيل أو تثبيت أو استخدام تطبيق أوربيت بي تي تي ("التطبيق")، فإنك تقر صراحة بأنك قد قرأت وفهمت ووافقت على الالتزام بجميع الشروط والأحكام الواردة هنا. إذا كنت لا توافق على هذه الشروط بأكملها، فيُحظر عليك تماماً استخدام الخدمات ويجب عليك إلغاء تثبيت التطبيق على الفور.</p>

<h2>2. لا توجد مكالمات طوارئ (تحذير بالغ الأهمية)</h2>
<p><strong>تطبيق أوربيت بي تي تي ليس بديلاً عن هاتفك المحمول أو الأرضي العادي. لا يسمح لك التطبيق بإجراء مكالمات طوارئ لخدمات الطوارئ (مثل 911، 112، 999، أو أي أرقام طوارئ أخرى معمول بها في جميع أنحاء العالم).</strong> يجب عليك التأكد من توفر ترتيبات اتصال بديلة لديك لإجراء مكالمات الطوارئ إذا لزم الأمر. لا تتحمل الشركة بأي حال من الأحوال المسؤولية عن أي مطالبة أو ضرر أو خسارة ناشئة عن عدم قدرتك على استخدام التطبيق للاتصال بخدمات الطوارئ.</p>

<h2>3. الأهلية وتسجيل الحساب والأمان</h2>
<p>لاستخدام الخدمات، يجب ألا يقل عمرك عن 13 عاماً. أنت توافق على تقديم معلومات دقيقة وحديثة وكاملة أثناء عملية التسجيل (بما في ذلك رقم هاتفك للتحقق عبر الرسائل القصيرة). أنت المسؤول الوحيد عن حماية سرية بيانات اعتماد حسابك وعن جميع الأنشطة التي تحدث تحت حسابك.</p>

<h2>4. الاشتراكات والرسوم وشروط متجر التطبيقات (أوربيت بلس)</h2>
<p>نحن نقدم ميزات متميزة من خلال خدمة اشتراك تتجدد تلقائياً تسمى "أوربيت بلس".<br>
<strong>أ. الفواتير والتجديد التلقائي:</strong> يتم فرض رسوم الاشتراك على حساب Apple App Store أو Google Play Store الخاص بك عند تأكيد الشراء. تتجدد الاشتراكات تلقائياً ما لم يتم إيقاف التجديد التلقائي قبل 24 ساعة على الأقل من نهاية فترة الفواتير الحالية.<br>
<strong>ب. الإلغاء والاسترداد:</strong> جميع عمليات الاسترداد تخضع بشكل صارم لسياسات أبل وجوجل. نحن لا نقدم مبالغ مستردة لفترات الاشتراك الجزئية.</p>

<h2>5. المحتوى الذي ينشئه المستخدم (UGC) وسياسة عدم التسامح المطلق</h2>
<p>أنت تحتفظ بجميع حقوق الملكية للصوت والنصوص التي ترسلها. ومع ذلك، نحن نحافظ على <strong>سياسة صارمة لعدم التسامح المطلق</strong> ضد المحتوى المرفوض والسلوك المسيء. أنت توافق على عدم إرسال أي محتوى غير قانوني، أو مزعج، أو مهدد، أو تشهيري، أو فاحش، أو يروج للعنف والإرهاب. يتضمن التطبيق آليات مدمجة لحظيرة والإبلاغ عن المستخدمين المسيئين. سيتم تعليق حساب أي مستخدم يتبين انتهاكه لهذه القواعد بشكل دائم خلال 24 ساعة دون استرداد.</p>

<h2>6. الاستخدام المقبول والأنشطة المحظورة</h2>
<p>أنت توافق على عدم القيام بأي أنشطة محظورة، بما في ذلك التدخل في أمان النظام، أو الهندسة العكسية للتطبيق، أو استخدام أنظمة آلية للوصول إلى التطبيق.</p>

<h2>7. إخلاء المسؤولية من الضمانات</h2>
<p>يتم تقديم الخدمات على أساس "كما هي" و"كما هي متوفرة". نحن لا نضمن أن الخدمات ستكون دون انقطاع أو آمنة أو خالية من الأخطاء.</p>

<h2>8. تحديد المسؤولية والتعويض</h2>
<p>إلى أقصى حد يسمح به القانون، لن نكون مسؤولين عن أي أضرار غير مباشرة أو تأديبية أو عرضية أو تبعية ناشئة عن استخدام التطبيق. أنت توافق على تعويض الشركة عن أي مطالبات ناشئة عن انتهاكك لهذه الشروط.</p>

<h2>9. القانون المعمول به وتسوية النزاعات</h2>
<p>تخضع هذه الشروط لقوانين جمهورية تركيا. سيتم الفصل في أي نزاع حصرياً في محاكم ومكاتب التنفيذ في إسطنبول (كاديكوي / الأناضول)، تركيا.</p>

<h2>10. معلومات الاتصال</h2>
<p>البريد الإلكتروني: <strong>support@orbit-talk.com</strong></p>
</div>
''';
  static const String _privacyAr = r'''
<div dir="rtl" style="text-align: right;">
<h1>أوربيت بي تي تي - سياسة الخصوصية الشاملة</h1>
<p><strong>تاريخ النفاذ: 6 مايو 2026</strong></p>

<h2>1. مقدمة</h2>
<p>تحترم شركة CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("نحن") خصوصيتك. تشرح هذه السياسة بالتفصيل كيف نجمع ونستخدم ونعالج ونحمي معلوماتك.</p>

<h2>2. المعلومات التي نجمعها</h2>
<p><strong>أ. الوصول إلى الميكروفون (مهم جداً):</strong> يتطلب التطبيق الوصول إلى الميكروفون فقط عندما تضغط بنشاط مع الاستمرار على زر التحدث (PTT). نحن لا نسجل أو نستمع إلى الضوضاء الخلفية المحيطة عندما لا يتم الضغط على الزر.<br>
<strong>ب. جهات الاتصال:</strong> بإذنك الصريح، نصل إلى قائمة جهات الاتصال الخاصة بك. لحماية خصوصيتك، نستخدم التجزئة المشفرة الآمنة ولا نقوم بتحميل أو تخزين دفتر العناوين الخام الخاص بك على خوادمنا بشكل دائم.<br>
<strong>ج. البيانات الصوتية:</strong> يتم تخزين عمليات الإرسال الصوتي مؤقتاً على خوادمنا فقط لتسهيل التسليم إلى المستلم، ثم يتم مسحها نهائياً. نحن لا نبني قواعد بيانات للتسجيلات الصوتية للمستخدمين.</p>

<h2>3. مشاركة البيانات مع مزودي الطرف الثالث</h2>
<p>نحن لا نبيع بياناتك الشخصية. نشارك البيانات الضرورية مع أطراف ثالثة موثوقة:<br>
- <strong>Google Firebase:</strong> لمصادقة الرسائل القصيرة وإدارة قواعد البيانات.<br>
- <strong>Adapty:</strong> لإدارة الاشتراكات. لا نرى بيانات بطاقتك الائتمانية أبداً.<br>
- <strong>Google AdMob:</strong> لتقديم الإعلانات في الإصدار المجاني. قد يجمع AdMob معرّفات الإعلانات.</p>

<h2>4. خصوصية الأطفال</h2>
<p>الخدمات غير موجهة للأشخاص الذين تقل أعمارهم عن 13 عاماً. نحن لا نجمع معلومات من الأطفال عن قصد.</p>

<h2>5. حقوق الخصوصية الخاصة بك</h2>
<p>لديك الحق في الوصول إلى بياناتك أو تصحيحها، ويمكنك طلب الحذف الدائم لحسابك وجميع البيانات المرتبطة به مباشرة من قائمة إعدادات التطبيق.</p>

<h2>6. اتصل بنا</h2>
<p>البريد الإلكتروني: <strong>support@orbit-talk.com</strong></p>
</div>
''';

  // 🇪🇸 ESPAÑOL
  static const String _termsEs = r'''
<h1>ORBIT PTT - TÉRMINOS DE SERVICIO INTEGRALES Y EULA</h1>
<p><strong>Fecha de vigencia: 6 de mayo de 2026</strong></p>

<h2>1. Alcance, Aceptación y Aplicabilidad</h2>
<p>Estos Términos de Servicio y Acuerdo de Licencia de Usuario Final ("Términos") constituyen un contrato legalmente vinculante entre usted ("Usuario") y CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("Orbit PTT", "nosotros"). Al descargar o utilizar la aplicación móvil Orbit PTT (la "App"), usted reconoce expresamente que ha leído, entendido y acepta estar sujeto a estos Términos.</p>

<h2>2. NO HAY LLAMADAS DE EMERGENCIA (ADVERTENCIA CRÍTICA)</h2>
<p><strong>ORBIT PTT NO ES UN REEMPLAZO PARA SU TELÉFONO MÓVIL O FIJO ORDINARIO. LA APP NO LE PERMITE REALIZAR LLAMADAS A SERVICIOS DE EMERGENCIA (P. EJ., 911, 112).</strong> Debe asegurarse de tener medios de comunicación alternativos. Bajo ninguna circunstancia seremos responsables por cualquier incapacidad para contactar a los servicios de emergencia.</p>

<h2>3. Suscripciones y Tarifas (Orbit Plus)</h2>
<p>Las funciones premium están disponibles a través de una suscripción ("Orbit Plus"). Los cargos se realizan en su cuenta de Apple App Store o Google Play Store. Las suscripciones se renuevan automáticamente a menos que se apaguen 24 horas antes del final del período actual. Todos los reembolsos se rigen por las políticas de Apple y Google.</p>

<h2>4. Contenido Generado por el Usuario (UGC) y Política de Tolerancia Cero</h2>
<p>Mantenemos una <strong>POLÍTICA ESTRICTA DE TOLERANCIA CERO</strong> contra el contenido objetable. Usted acepta NO transmitir contenido que sea ilegal, acosador, difamatorio, obsceno o que promueva la violencia o el terrorismo. La App incluye mecanismos para bloquear y denunciar abusos. Los infractores serán suspendidos permanentemente dentro de las 24 horas, sin derecho a reembolso.</p>

<h2>5. Descargo de Responsabilidad y Limitación de Responsabilidad</h2>
<p>LOS SERVICIOS SE PROPORCIONAN "TAL CUAL". EN NINGÚN CASO SEREMOS RESPONSABLES POR DAÑOS INDIRECTOS, PUNITIVOS, INCIDENTALES O CONSECUENTES. Nuestra responsabilidad total nunca excederá el monto que nos pagó en los últimos 6 meses.</p>

<h2>6. Ley Aplicable y Jurisdicción</h2>
<p>Estos Términos se regirán por las leyes de la República de Turquía. Cualquier disputa se decidirá exclusivamente en los Tribunales y Oficinas de Ejecución de Estambul (Kadikoy/Anadolu), Turquía.</p>

<h2>7. Información de Contacto</h2>
<p>Correo electrónico: <strong>support@orbit-talk.com</strong></p>
''';
  static const String _privacyEs = r'''
<h1>ORBIT PTT - POLÍTICA DE PRIVACIDAD INTEGRAL</h1>
<p><strong>Fecha de vigencia: 6 de mayo de 2026</strong></p>

<h2>1. Información que Recopilamos</h2>
<p><strong>a. Acceso al Micrófono (Crucial):</strong> La App requiere acceso a su micrófono SÓLO cuando presiona activamente el botón PTT. NO grabamos, escuchamos ni monitoreamos el ruido de fondo.<br>
<strong>b. Contactos:</strong> Con su permiso, accedemos a su libreta de direcciones utilizando un hash criptográfico seguro. No almacenamos permanentemente su libreta de direcciones sin procesar.<br>
<strong>c. Datos de Audio:</strong> Los mensajes de voz se almacenan temporalmente en caché para facilitar la entrega, luego se purgan permanentemente de nuestros servidores.</p>

<h2>2. Compartir con Terceros</h2>
<p>Compartimos datos necesarios con terceros confiables:<br>
- <strong>Firebase:</strong> Para autenticación y análisis de fallos.<br>
- <strong>Adapty:</strong> Para gestionar suscripciones. Nunca vemos los datos de su tarjeta de crédito.<br>
- <strong>AdMob:</strong> Para anuncios. AdMob puede recopilar identificadores de publicidad.</p>

<h2>3. Privacidad Infantil (COPPA)</h2>
<p>Los Servicios no están dirigidos a menores de 13 años. No recopilamos datos personales de niños a sabiendas.</p>

<h2>4. Sus Derechos de Privacidad</h2>
<p>Tiene derecho a acceder a sus datos y solicitar la eliminación. Puede eliminar permanentemente su cuenta y todos los datos asociados directamente en el menú de configuración de la App.</p>

<h2>5. Contáctenos</h2>
<p>Correo electrónico: <strong>support@orbit-talk.com</strong></p>
''';

  // 🇩🇪 DEUTSCH
  static const String _termsDe = r'''
<h1>ORBIT PTT - UMFASSENDE NUTZUNGSBEDINGUNGEN UND EULA</h1>
<p><strong>Datum des Inkrafttretens: 6. Mai 2026</strong></p>

<h2>1. Geltungsbereich und Annahme</h2>
<p>Diese Nutzungsbedingungen ("Bedingungen") stellen eine rechtsverbindliche Vereinbarung zwischen Ihnen und CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ ("Orbit PTT", "wir") dar. Durch die Nutzung der App stimmen Sie diesen Bedingungen ausdrücklich zu.</p>

<h2>2. KEINE NOTRUFE (WICHTIGE WARNUNG)</h2>
<p><strong>ORBIT PTT IST KEIN ERSATZ FÜR IHR NORMALES TELEFON. DIE APP ERLAUBT KEINE NOTRUFE AN RETTUNGSDIENSTE (Z. B. 112, 911).</strong> Wir haften nicht für Schäden, die aus der Unmöglichkeit entstehen, Notdienste zu kontaktieren.</p>

<h2>3. Abonnements und Gebühren (Orbit Plus)</h2>
<p>Premium-Funktionen werden über ein Abonnement ("Orbit Plus") angeboten. Zahlungen erfolgen über den Apple App Store oder Google Play Store. Abonnements verlängern sich automatisch. Rückerstattungen richten sich nach den Richtlinien von Apple und Google.</p>

<h2>4. Benutzergenerierte Inhalte und Null-Toleranz-Politik</h2>
<p>Wir verfolgen eine <strong>STRIKTE NULL-TOLERANZ-POLITIK</strong> gegenüber anstößigen Inhalten. Es ist strengstens verboten, rechtswidrige, belästigende, diffamierende, obszöne oder gewaltverherrlichende Inhalte zu übertragen. Benutzer können andere melden und blockieren. Zuwiderhandelnde Konten werden innerhalb von 24 Stunden ohne Rückerstattung dauerhaft gesperrt.</p>

<h2>5. Haftungsausschluss und Haftungsbeschränkung</h2>
<p>DIE DIENSTE WERDEN "WIE BESEHEN" BEREITGESTELLT. WIR SCHLIESSEN ALLE GARANTIEN AUS. WIR HAFTEN IN KEINEM FALL FÜR INDIREKTE SCHÄDEN ODER FOLGESCHÄDEN.</p>

<h2>6. Anwendbares Recht und Gerichtsstand</h2>
<p>Diese Bedingungen unterliegen den Gesetzen der Republik Türkei. Ausschließlicher Gerichtsstand für alle Streitigkeiten sind die Gerichte und Vollstreckungsbehörden von Istanbul (Kadikoy/Anadolu), Türkei.</p>

<h2>7. Kontaktinformationen</h2>
<p>E-Mail: <strong>support@orbit-talk.com</strong></p>
''';
  static const String _privacyDe = r'''
<h1>ORBIT PTT - UMFASSENDE DATENSCHUTZERKLÄRUNG</h1>
<p><strong>Datum des Inkrafttretens: 6. Mai 2026</strong></p>

<h2>1. Informationen, die wir sammeln</h2>
<p><strong>a. Mikrofonzugriff (Wichtig):</strong> Die App greift NUR auf Ihr Mikrofon zu, wenn Sie die PTT-Taste aktiv drücken. Wir nehmen keine Hintergrundgeräusche auf und hören sie nicht ab.<br>
<strong>b. Kontakte:</strong> Mit Ihrer Erlaubnis greifen wir auf Ihr Adressbuch zu, verwenden jedoch sicheres kryptografisches Hashing. Ihr unverschlüsseltes Adressbuch wird nicht dauerhaft gespeichert.<br>
<strong>c. Audiodaten:</strong> Sprachnachrichten werden nur vorübergehend zur Zustellung zwischengespeichert und danach dauerhaft von unseren Servern gelöscht.</p>

<h2>2. Weitergabe an Drittanbieter</h2>
<p>Wir geben notwendige Daten an vertrauenswürdige Dritte weiter:<br>
- <strong>Firebase:</strong> Zur Authentifizierung und Absturzanalyse.<br>
- <strong>Adapty:</strong> Zur Verwaltung von Abonnements. Wir sehen niemals Ihre Kreditkartendaten.<br>
- <strong>AdMob:</strong> Für Werbung. AdMob kann Werbekennungen sammeln.</p>

<h2>3. Datenschutz für Kinder</h2>
<p>Die Dienste richten sich nicht an Personen unter 13 Jahren (bzw. 16 Jahren in einigen Ländern).</p>

<h2>4. Ihre Datenschutzrechte</h2>
<p>Sie haben das Recht auf Auskunft und Löschung. Sie können Ihr Konto und alle zugehörigen Daten direkt in den App-Einstellungen dauerhaft löschen.</p>

<h2>5. Kontaktieren Sie uns</h2>
<p>E-Mail: <strong>support@orbit-talk.com</strong></p>
''';

  // 🇷🇺 РУССКИЙ
  static const String _termsRu = r'''
<h1>ORBIT PTT - КОМПЛЕКСНЫЕ УСЛОВИЯ ОБСЛУЖИВАНИЯ И EULA</h1>
<p><strong>Дата вступления в силу: 6 мая 2026 г.</strong></p>

<h2>1. Область применения и принятие</h2>
<p>Настоящие Условия обслуживания («Условия») представляют собой юридически обязательный договор между вами («Пользователь») и CRENNO BİLİŞİM HİZMETLERİ AR-GE SANAYİ VE TİCARET LİMİTED ŞİRKETİ («Orbit PTT»). Используя приложение, вы соглашаетесь с настоящими Условиями.</p>

<h2>2. НЕТ ЭКСТРЕННЫХ ВЫЗОВОВ (КРИТИЧЕСКОЕ ПРЕДУПРЕЖДЕНИЕ)</h2>
<p><strong>ORBIT PTT НЕ ЯВЛЯЕТСЯ ЗАМЕНОЙ ВАШЕМУ ОБЫЧНОМУ ТЕЛЕФОНУ. ПРИЛОЖЕНИЕ НЕ ПОЗВОЛЯЕТ СОВЕРШАТЬ ЭКСТРЕННЫЕ ВЫЗОВЫ (НАПРИМЕР, 112, 911).</strong> Мы не несем ответственности за невозможность связаться с экстренными службами.</p>

<h2>3. Подписки и плата (Orbit Plus)</h2>
<p>Премиум-функции доступны по подписке («Orbit Plus»). Платежи обрабатываются через Apple App Store или Google Play Store. Подписки автоматически продлеваются. Все возвраты регулируются политикой Apple и Google.</p>

<h2>4. Пользовательский контент и политика нулевой терпимости</h2>
<p>Мы придерживаемся <strong>СТРОГОЙ ПОЛИТИКИ НУЛЕВОЙ ТЕРПИМОСТИ</strong> в отношении неприемлемого контента. Вы соглашаетесь не передавать незаконный, оскорбительный, непристойный или разжигающий ненависть контент. Пользователи могут блокировать и жаловаться на нарушителей. Нарушители будут заблокированы навсегда в течение 24 часов без возврата средств.</p>

<h2>5. Отказ от гарантий и ограничение ответственности</h2>
<p>УСЛУГИ ПРЕДОСТАВЛЯЮТСЯ «КАК ЕСТЬ». МЫ НЕ НЕСЕМ ОТВЕТСТВЕННОСТИ ЗА ЛЮБЫЕ КОСВЕННЫЕ, ШТРАФНЫЕ ИЛИ СЛУЧАЙНЫЕ УБЫТКИ.</p>

<h2>6. Применимое право и юрисдикция</h2>
<p>Настоящие Условия регулируются законодательством Турецкой Республики. Любые споры подлежат разрешению исключительно в судах Стамбула (Кадыкёй/Анатолия), Турция.</p>

<h2>7. Контактная информация</h2>
<p>Электронная почта: <strong>support@orbit-talk.com</strong></p>
''';
  static const String _privacyRu = r'''
<h1>ORBIT PTT - КОМПЛЕКСНАЯ ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ</h1>
<p><strong>Дата вступления в силу: 6 мая 2026 г.</strong></p>

<h2>1. Информация, которую мы собираем</h2>
<p><strong>а. Доступ к микрофону (Важно):</strong> Приложение получает доступ к микрофону ТОЛЬКО при активном нажатии кнопки PTT. Мы не записываем фоновый шум.<br>
<strong>б. Контакты:</strong> С вашего разрешения мы получаем доступ к адресной книге, используя криптографическое хеширование. Ваши контакты не хранятся у нас постоянно в открытом виде.<br>
<strong>в. Аудиоданные:</strong> Голосовые сообщения временно кэшируются для доставки, а затем навсегда удаляются с серверов.</p>

<h2>2. Обмен данными с третьими лицами</h2>
<p>Мы передаем необходимые данные доверенным третьим лицам:<br>
- <strong>Firebase:</strong> Для аутентификации и аналитики сбоев.<br>
- <strong>Adapty:</strong> Для управления подписками. Мы никогда не видим данные вашей кредитной карты.<br>
- <strong>AdMob:</strong> Для показа рекламы. AdMob может собирать рекламные идентификаторы.</p>

<h2>3. Конфиденциальность детей</h2>
<p>Услуги не предназначены для лиц младше 13 лет.</p>

<h2>4. Ваши права на конфиденциальность</h2>
<p>Вы имеете право на доступ к данным и их удаление. Вы можете навсегда удалить свою учетную запись и все данные прямо в настройках Приложения.</p>

<h2>5. Свяжитесь с нами</h2>
<p>Электронная почта: <strong>support@orbit-talk.com</strong></p>
''';
}
