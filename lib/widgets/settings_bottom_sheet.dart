import 'package:flutter/material.dart';
import 'dart:io';

class SettingsBottomSheet extends StatefulWidget {
  final String userName;
  final String? userAvatarPath;
  final String myStatus; // "available", "busy", "away"
  final ValueChanged<String> onUserNameChanged;
  final Future<String?> Function() onPickAvatar;
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
  final bool useSpeaker;
  final ValueChanged<bool> onSpeakerChanged;

  final int selfDestructSeconds;
  final ValueChanged<int> onSelfDestructChanged;
  final String liveAudioPermission;
  final ValueChanged<String> onLivePermissionChanged;

  final int deleteFilterDays;
  final ValueChanged<int> onDeleteFilterDaysChanged;
  final Function(int) onClearOldMessages;
  final String? customBackgroundImagePath;
  final Future<String?> Function() onPickBackground;
  final VoidCallback onRemoveBackground;

  const SettingsBottomSheet({
    super.key,
    required this.userName,
    required this.userAvatarPath,
    required this.myStatus,
    required this.onUserNameChanged,
    required this.onPickAvatar,
    required this.onStatusChanged,
    required this.isLeftHanded,
    required this.onLeftHandedChanged,
    required this.selectedLiveAnimation,
    required this.animationOptions,
    required this.onLiveAnimationChanged,
    required this.isBackgroundTransparent,
    required this.onBackgroundTransparentChanged,
    required this.isCircularMessageStyle,
    required this.onCircularMessageStyleChanged,
    required this.hapticEnabled,
    required this.onHapticChanged,
    required this.useSpeaker,
    required this.onSpeakerChanged,
    required this.selfDestructSeconds,
    required this.onSelfDestructChanged,
    required this.liveAudioPermission,
    required this.onLivePermissionChanged,
    required this.deleteFilterDays,
    required this.onDeleteFilterDaysChanged,
    required this.onClearOldMessages,
    required this.customBackgroundImagePath,
    required this.onPickBackground,
    required this.onRemoveBackground,
  });

  static void show({
    required BuildContext context,
    required String userName,
    required String? userAvatarPath,
    required String myStatus,
    required ValueChanged<String> onUserNameChanged,
    required Future<String?> Function() onPickAvatar,
    required ValueChanged<String> onStatusChanged,
    required bool isLeftHanded,
    required ValueChanged<bool> onLeftHandedChanged,
    required String selectedLiveAnimation,
    required List<String> animationOptions,
    required ValueChanged<String> onLiveAnimationChanged,
    required bool isBackgroundTransparent,
    required ValueChanged<bool> onBackgroundTransparentChanged,
    required bool isCircularMessageStyle,
    required ValueChanged<bool> onCircularMessageStyleChanged,
    required bool hapticEnabled,
    required ValueChanged<bool> onHapticChanged,
    required bool useSpeaker,
    required ValueChanged<bool> onSpeakerChanged,
    required int selfDestructSeconds,
    required ValueChanged<int> onSelfDestructChanged,
    required String liveAudioPermission,
    required ValueChanged<String> onLivePermissionChanged,
    required int deleteFilterDays,
    required ValueChanged<int> onDeleteFilterDaysChanged,
    required Function(int) onClearOldMessages,
    required String? customBackgroundImagePath,
    required Future<String?> Function() onPickBackground,
    required VoidCallback onRemoveBackground,
    required VoidCallback onClosed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SettingsBottomSheet(
        userName: userName,
        userAvatarPath: userAvatarPath,
        myStatus: myStatus,
        onUserNameChanged: onUserNameChanged,
        onPickAvatar: onPickAvatar,
        onStatusChanged: onStatusChanged,
        isLeftHanded: isLeftHanded,
        onLeftHandedChanged: onLeftHandedChanged,
        selectedLiveAnimation: selectedLiveAnimation,
        animationOptions: animationOptions,
        onLiveAnimationChanged: onLiveAnimationChanged,
        isBackgroundTransparent: isBackgroundTransparent,
        onBackgroundTransparentChanged: onBackgroundTransparentChanged,
        isCircularMessageStyle: isCircularMessageStyle,
        onCircularMessageStyleChanged: onCircularMessageStyleChanged,
        hapticEnabled: hapticEnabled,
        onHapticChanged: onHapticChanged,
        useSpeaker: useSpeaker,
        onSpeakerChanged: onSpeakerChanged,
        selfDestructSeconds: selfDestructSeconds,
        onSelfDestructChanged: onSelfDestructChanged,
        liveAudioPermission: liveAudioPermission,
        onLivePermissionChanged: onLivePermissionChanged,
        deleteFilterDays: deleteFilterDays,
        onDeleteFilterDaysChanged: onDeleteFilterDaysChanged,
        onClearOldMessages: onClearOldMessages,
        customBackgroundImagePath: customBackgroundImagePath,
        onPickBackground: onPickBackground,
        onRemoveBackground: onRemoveBackground,
      ),
    ).whenComplete(onClosed);
  }

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  late bool _isLeftHanded;
  late String _selectedLiveAnimation;
  late bool _isBackgroundTransparent;
  late bool _isCircularMessageStyle;
  late int _deleteFilterDays;
  late bool _hapticEnabled;
  late bool _useSpeaker;
  late int _selfDestructSeconds;
  late String _liveAudioPermission;
  late String _myStatus;
  
  String? _customBackgroundImagePath;
  String? _userAvatarPath;
  late String _userName;

  bool _notificationsEnabled = true;
  bool _lowDataMode = false;

  @override
  void initState() {
    super.initState();
    _isLeftHanded = widget.isLeftHanded;
    _selectedLiveAnimation = widget.selectedLiveAnimation;
    _isBackgroundTransparent = widget.isBackgroundTransparent;
    _isCircularMessageStyle = widget.isCircularMessageStyle;
    _deleteFilterDays = widget.deleteFilterDays;
    _customBackgroundImagePath = widget.customBackgroundImagePath;
    
    _hapticEnabled = widget.hapticEnabled;
    _useSpeaker = widget.useSpeaker;
    _selfDestructSeconds = widget.selfDestructSeconds;
    _liveAudioPermission = widget.liveAudioPermission;
    _myStatus = widget.myStatus;
    _userName = widget.userName;
    _userAvatarPath = widget.userAvatarPath;
  }

  void _editNameDialog() {
    TextEditingController nameCtrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("İsmini Değiştir", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.cyanAccent),
          cursorColor: Colors.cyanAccent,
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() => _userName = nameCtrl.text.trim());
                widget.onUserNameChanged(_userName);
              }
              Navigator.pop(c);
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("Hesabı Kapat", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Hesabını silmek istediğinden emin misin? Bu işlem geri alınamaz; tüm yörünge ayarların, mesajların ve kayıtlı kişilerin kalıcı olarak silinecektir.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Vazgeç", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.2), elevation: 0),
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hesap silme işlemi başlatıldı...")));
            },
            child: const Text("Kalıcı Olarak Sil", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  void _showMockDocumentDialog(String title) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.cyanAccent, fontSize: 18)),
        content: SizedBox(
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              "Bu bir demo metnidir. Uygulama mağazaya yüklenirken buraya gerçek '$title' metni eklenecektir.\n\n"
              "1. Kullanıcı verileri uçtan uca şifrelenmektedir.\n"
              "2. Ses kayıtları cihazda yerel olarak barındırılır.\n"
              "3. Orbit, izinsiz veri paylaşımına karşı sıkı güvenlik protokolleri uygular.\n\n"
              "Lütfen detaylar için web sitemizi ziyaret edin.",
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Okudum, Anladım", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, 
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        border: Border.all(color: Colors.white12, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.05), blurRadius: 30, spreadRadius: 5)]
      ),
      child: Column(
        children: [
          Center(
            child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 16),
          const Text("Ayarlar", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              // GÜNCELLEME: Listenin altına bolca padding vererek son elemanların iPhone Home çizgisi altında kalmasını (kesilmesini) engelliyoruz.
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 60), 
              children: [
                // 1. KATEGORİ: PROFİL VE DURUM
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: const Icon(Icons.person, color: Colors.cyanAccent),
                    title: const Text("Profil ve Durum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    iconColor: Colors.cyanAccent,
                    collapsedIconColor: Colors.white54,
                    children: [
                      ListTile(
                        leading: GestureDetector(
                          onTap: () async {
                            String? newPath = await widget.onPickAvatar();
                            if (newPath != null) {
                              setState(() => _userAvatarPath = newPath);
                            }
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: _userAvatarPath != null ? FileImage(File(_userAvatarPath!)) : null,
                            child: _userAvatarPath == null ? const Icon(Icons.add_a_photo, color: Colors.white54) : null,
                          ),
                        ),
                        title: Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: const Text("İsmi değiştirmek için tıkla", style: TextStyle(color: Colors.white30, fontSize: 12)),
                        trailing: const Icon(Icons.edit, color: Colors.white54, size: 18),
                        onTap: _editNameDialog,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Mevcut Durum", style: TextStyle(color: Colors.white70)),
                            DropdownButton<String>(
                              dropdownColor: Colors.grey.shade900,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              underline: Container(),
                              value: _myStatus,
                              items: const [
                                DropdownMenuItem(value: "available", child: Text("🟢 Müsait")),
                                DropdownMenuItem(value: "busy", child: Text("🔴 Meşgul")),
                                DropdownMenuItem(value: "away", child: Text("🟠 Uzakta")),
                              ],
                              onChanged: (v) {
                                setState(() => _myStatus = v!);
                                widget.onStatusChanged(v!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),

                // 2. KATEGORİ: ARAYÜZ VE ERGONOMİ
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.design_services, color: Colors.purpleAccent),
                    title: const Text("Arayüz ve Ergonomi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    iconColor: Colors.purpleAccent,
                    collapsedIconColor: Colors.white54,
                    children: [
                      SwitchListTile(
                        title: const Text("Sol El Modu", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Menüyü sol ele alır", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.purpleAccent,
                        value: _isLeftHanded,
                        onChanged: (val) {
                          setState(() => _isLeftHanded = val);
                          widget.onLeftHandedChanged(val);
                        },
                      ),
                      SwitchListTile(
                        title: const Text("Kamera Arka Planı", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Transparan siber görünüm", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.purpleAccent,
                        value: _isBackgroundTransparent,
                        onChanged: (val) {
                          setState(() {
                            _isBackgroundTransparent = val;
                            if (val) _customBackgroundImagePath = null;
                          });
                          widget.onBackgroundTransparentChanged(val);
                        },
                      ),
                      // EKSİK OLAN MESAJ GÖRÜNÜMÜ AYARI BURAYA EKLENDİ
                      SwitchListTile(
                        title: const Text("Dairesel Mesaj Görünümü", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Hap şekli veya Dairesel Kapsül", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.purpleAccent,
                        value: _isCircularMessageStyle,
                        onChanged: (val) {
                          setState(() => _isCircularMessageStyle = val);
                          widget.onCircularMessageStyleChanged(val);
                        },
                      ),
                      ListTile(
                        title: const Text("Özel Arka Plan Seç", style: TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: const Icon(Icons.image, color: Colors.purpleAccent),
                        onTap: () async {
                          String? newPath = await widget.onPickBackground();
                          if (newPath != null) {
                            setState(() => _customBackgroundImagePath = newPath);
                          }
                        },
                      ),
                      if (_customBackgroundImagePath != null)
                        ListTile(
                          title: const Text("Arka Planı Kaldır", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                          trailing: const Icon(Icons.delete, color: Colors.redAccent),
                          onTap: () {
                            setState(() => _customBackgroundImagePath = null);
                            widget.onRemoveBackground();
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Canlı Telsiz Efekti", style: TextStyle(color: Colors.white, fontSize: 14)),
                            DropdownButton<String>(
                              dropdownColor: Colors.grey.shade900,
                              style: const TextStyle(color: Colors.purpleAccent, fontSize: 14),
                              underline: Container(), 
                              value: _selectedLiveAnimation,
                              items: widget.animationOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                              onChanged: (v) {
                                setState(() => _selectedLiveAnimation = v!);
                                widget.onLiveAnimationChanged(v!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),

                // 3. KATEGORİ: SES VE DONANIM
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.settings_voice, color: Colors.orangeAccent),
                    title: const Text("Ses ve Sistem", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    iconColor: Colors.orangeAccent,
                    collapsedIconColor: Colors.white54,
                    children: [
                      SwitchListTile(
                        title: const Text("Hoparlör Modu", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Kapalıyken ahizeden ses verir", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.orangeAccent,
                        value: _useSpeaker,
                        onChanged: (val) {
                          setState(() => _useSpeaker = val);
                          widget.onSpeakerChanged(val);
                        },
                      ),
                      SwitchListTile(
                        title: const Text("Titreşim Geri Bildirimi", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Dokunma hissiyatı (Haptic)", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.orangeAccent,
                        value: _hapticEnabled,
                        onChanged: (val) {
                          setState(() => _hapticEnabled = val);
                          widget.onHapticChanged(val);
                        },
                      ),
                      SwitchListTile(
                        title: const Text("Bildirim Sesleri", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Yeni telsiz uyarıları", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.orangeAccent,
                        value: _notificationsEnabled,
                        onChanged: (val) => setState(() => _notificationsEnabled = val),
                      ),
                      SwitchListTile(
                        title: const Text("Düşük Veri Modu", style: TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: const Text("Sadece Wi-Fi ile medyaları indir", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        activeThumbColor: Colors.orangeAccent,
                        value: _lowDataMode,
                        onChanged: (val) => setState(() => _lowDataMode = val),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),

                // 4. KATEGORİ: GİZLİLİK VE DEPOLAMA
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.security, color: Colors.greenAccent),
                    title: const Text("Gizlilik ve Depolama", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    iconColor: Colors.greenAccent,
                    collapsedIconColor: Colors.white54,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Canlı Yayın İzni", style: TextStyle(color: Colors.white, fontSize: 14)),
                            DropdownButton<String>(
                              dropdownColor: Colors.grey.shade900,
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                              underline: Container(), 
                              value: _liveAudioPermission,
                              items: const [
                                DropdownMenuItem(value: "Herkes", child: Text("Herkes")),
                                DropdownMenuItem(value: "Sadece Rehber", child: Text("Sadece Rehber")),
                                DropdownMenuItem(value: "Hiç Kimse", child: Text("Hiç Kimse")),
                              ],
                              onChanged: (v) {
                                setState(() => _liveAudioPermission = v!);
                                widget.onLivePermissionChanged(v!);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Mesaj İmha Süresi", style: TextStyle(color: Colors.white, fontSize: 14)),
                            DropdownButton<int>(
                              dropdownColor: Colors.grey.shade900,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                              underline: Container(), 
                              value: _selfDestructSeconds,
                              items: const [
                                DropdownMenuItem(value: 10, child: Text("10 Saniye")),
                                DropdownMenuItem(value: 30, child: Text("30 Saniye")),
                                DropdownMenuItem(value: 60, child: Text("1 Dakika")),
                                DropdownMenuItem(value: 0, child: Text("Asla Silinmesin")),
                              ],
                              onChanged: (v) {
                                setState(() => _selfDestructSeconds = v!);
                                widget.onSelfDestructChanged(v!);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Eski Kayıtları Sil", style: TextStyle(color: Colors.white, fontSize: 14)),
                            Row(
                              children: [
                                DropdownButton<int>(
                                  dropdownColor: Colors.grey.shade900,
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                                  underline: Container(), 
                                  value: _deleteFilterDays,
                                  items: const [
                                    DropdownMenuItem(value: 7, child: Text("7 Günlük")),
                                    DropdownMenuItem(value: 30, child: Text("30 Günlük")),
                                    DropdownMenuItem(value: 90, child: Text("90 Günlük")),
                                  ],
                                  onChanged: (v) {
                                    setState(() => _deleteFilterDays = v!);
                                    widget.onDeleteFilterDaysChanged(v!);
                                  },
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context, 
                                      builder: (c) => AlertDialog(
                                        backgroundColor: Colors.grey.shade900,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: const Text("Kayıtları Sil", style: TextStyle(color: Colors.white, fontSize: 18)),
                                        content: Text("Seçili olan $_deleteFilterDays günden eski tüm yerel kayıtlar tamamen silinecek.", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(c), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
                                          TextButton(
                                            onPressed: () { 
                                              widget.onClearOldMessages(_deleteFilterDays);
                                              Navigator.pop(c); 
                                              Navigator.pop(context); 
                                            }, 
                                            child: const Text("SİL", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                                          ),
                                        ],
                                      )
                                    );
                                  },
                                  child: const Text("TEMİZLE"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12),

                // 5. KATEGORİ: HESAP VE YASAL METİNLER
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.manage_accounts, color: Colors.blueAccent),
                    title: const Text("Hesap ve Yasal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    iconColor: Colors.blueAccent,
                    collapsedIconColor: Colors.white54,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.description, color: Colors.white54, size: 20),
                        title: const Text("Kullanıcı Sözleşmesi", style: TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 16),
                        onTap: () => _showMockDocumentDialog("Kullanım Koşulları"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip, color: Colors.white54, size: 20),
                        title: const Text("Gizlilik Politikası (KVKK)", style: TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 16),
                        onTap: () => _showMockDocumentDialog("Gizlilik Politikası"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.orangeAccent, size: 20),
                        title: const Text("Oturumu Kapat", style: TextStyle(color: Colors.orangeAccent, fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oturum kapatılıyor...")));
                        },
                      ),
                      // İŞTE BAHSETTİĞİMİZ SİLME BUTONU BURADA
                      ListTile(
                        leading: const Icon(Icons.person_off, color: Colors.redAccent, size: 20),
                        title: const Text("Hesabı Kalıcı Olarak Sil", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                        onTap: _showDeleteAccountDialog,
                      ),
                    ],
                  ),
                ),
                
                // VERSİYON BİLGİSİ
                const Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: Center(
                    child: Text("Orbit v1.0.0 (Core)", style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}