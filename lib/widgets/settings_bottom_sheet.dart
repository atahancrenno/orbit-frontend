import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

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
  final bool useSpeaker;
  final ValueChanged<bool> onSpeakerChanged;
  final int selfDestructSeconds;
  final ValueChanged<int> onSelfDestructChanged;
  final String liveAudioPermission;
  final ValueChanged<String> onLivePermissionChanged;
  
  // 🟢 YENİ BİLDİRİM PARAMETRELERİ 🟢
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final bool messageNotificationsEnabled;
  final ValueChanged<bool> onMessageNotificationsChanged;
  final bool callNotificationsEnabled;
  final ValueChanged<bool> onCallNotificationsChanged;

  final int deleteFilterDays;
  final ValueChanged<int> onDeleteFilterDaysChanged;
  final ValueChanged<int> onClearOldMessages;
  final String? customBackgroundImagePath;
  final Future<String?> Function() onPickBackground;
  final VoidCallback onRemoveBackground;
  final VoidCallback onClosed;

  const SettingsBottomSheet({
    super.key,
    required this.userName,
    this.userAvatarPath,
    required this.customAvatarColor,
    required this.onCustomAvatarColorChanged,
    required this.myStatus,
    required this.onUserNameChanged,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onRemoveAvatar,
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
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.messageNotificationsEnabled,
    required this.onMessageNotificationsChanged,
    required this.callNotificationsEnabled,
    required this.onCallNotificationsChanged,
    required this.deleteFilterDays,
    required this.onDeleteFilterDaysChanged,
    required this.onClearOldMessages,
    this.customBackgroundImagePath,
    required this.onPickBackground,
    required this.onRemoveBackground,
    required this.onClosed,
  });

  static void show({
    required BuildContext context,
    required String userName,
    String? userAvatarPath,
    required Color customAvatarColor,
    required ValueChanged<Color> onCustomAvatarColorChanged,
    required String myStatus,
    required ValueChanged<String> onUserNameChanged,
    required Future<String?> Function() onPickFromGallery,
    required Future<String?> Function() onPickFromCamera,
    required VoidCallback onRemoveAvatar,
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
    required bool notificationsEnabled,
    required ValueChanged<bool> onNotificationsChanged,
    required bool messageNotificationsEnabled,
    required ValueChanged<bool> onMessageNotificationsChanged,
    required bool callNotificationsEnabled,
    required ValueChanged<bool> onCallNotificationsChanged,
    required int deleteFilterDays,
    required ValueChanged<int> onDeleteFilterDaysChanged,
    required ValueChanged<int> onClearOldMessages,
    String? customBackgroundImagePath,
    required Future<String?> Function() onPickBackground,
    required VoidCallback onRemoveBackground,
    required VoidCallback onClosed,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => SettingsBottomSheet(
        userName: userName,
        userAvatarPath: userAvatarPath,
        customAvatarColor: customAvatarColor,
        onCustomAvatarColorChanged: onCustomAvatarColorChanged,
        myStatus: myStatus,
        onUserNameChanged: onUserNameChanged,
        onPickFromGallery: onPickFromGallery,
        onPickFromCamera: onPickFromCamera,
        onRemoveAvatar: onRemoveAvatar,
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
        notificationsEnabled: notificationsEnabled,
        onNotificationsChanged: onNotificationsChanged,
        messageNotificationsEnabled: messageNotificationsEnabled,
        onMessageNotificationsChanged: onMessageNotificationsChanged,
        callNotificationsEnabled: callNotificationsEnabled,
        onCallNotificationsChanged: onCallNotificationsChanged,
        deleteFilterDays: deleteFilterDays,
        onDeleteFilterDaysChanged: onDeleteFilterDaysChanged,
        onClearOldMessages: onClearOldMessages,
        customBackgroundImagePath: customBackgroundImagePath,
        onPickBackground: onPickBackground,
        onRemoveBackground: onRemoveBackground,
        onClosed: onClosed,
      ),
    ).whenComplete(onClosed);
  }

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  String? _expandedSection = "Profil ve Durum"; 
  late TextEditingController _nameController;

  String? _currentAvatarPath;
  late Color _currentAvatarColor;
  late String _currentStatus;
  late bool _isLeftHanded;
  late bool _isCircularMessageStyle;
  late String _selectedLiveAnimation;
  late bool _useSpeaker;
  late bool _hapticEnabled;
  late int _selfDestructSeconds;
  late String _liveAudioPermission;
  late int _deleteFilterDays;
  
  // Bildirimler için yerel state
  late bool _notificationsEnabled;
  late bool _messageNotificationsEnabled;
  late bool _callNotificationsEnabled;

  final List<Color> _avatarColors = [
    Colors.blueGrey.shade800, Colors.cyanAccent.shade700, Colors.blueAccent, 
    Colors.purpleAccent, Colors.pinkAccent, Colors.redAccent,
    Colors.orangeAccent, Colors.greenAccent.shade700, Colors.tealAccent.shade700
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    
    _currentAvatarPath = widget.userAvatarPath;
    _currentAvatarColor = widget.customAvatarColor;
    _currentStatus = widget.myStatus;
    _isLeftHanded = widget.isLeftHanded;
    _isCircularMessageStyle = widget.isCircularMessageStyle;
    _selectedLiveAnimation = widget.selectedLiveAnimation;
    _useSpeaker = widget.useSpeaker;
    _hapticEnabled = widget.hapticEnabled;
    _selfDestructSeconds = widget.selfDestructSeconds;
    _liveAudioPermission = widget.liveAudioPermission;
    _deleteFilterDays = widget.deleteFilterDays;
    
    _notificationsEnabled = widget.notificationsEnabled;
    _messageNotificationsEnabled = widget.messageNotificationsEnabled;
    _callNotificationsEnabled = widget.callNotificationsEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return "";
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
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

  Widget _buildProfileContent() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext ctx) {
                return Container(
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                  ),
                  child: SafeArea(
                    child: Wrap(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 20, left: 20, bottom: 10),
                          child: Text("Profil Fotoğrafı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
                        ListTile(
                          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.cyanAccent, size: 20)),
                          title: const Text('Kameradan Çek', style: TextStyle(color: Colors.white, fontSize: 15)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            String? newPath = await widget.onPickFromCamera();
                            if (newPath != null) setState(() => _currentAvatarPath = newPath);
                          },
                        ),
                        ListTile(
                          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.photo_library, color: Colors.cyanAccent, size: 20)),
                          title: const Text('Galeriden Seç', style: TextStyle(color: Colors.white, fontSize: 15)),
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
                            title: const Text('Fotoğrafı Sil', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
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
          const Text("Profil Renginizi Seçin", style: TextStyle(color: Colors.white54, fontSize: 11)),
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
            labelText: "Görünen Ad",
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
          decoration: const InputDecoration(labelText: "Durum", labelStyle: TextStyle(color: Colors.white54)),
          items: const [
            DropdownMenuItem(value: "available", child: Text("Müsait")),
            DropdownMenuItem(value: "busy", child: Text("Meşgul")),
            DropdownMenuItem(value: "away", child: Text("Uzakta")),
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
          title: const Text("Sol El Modu", style: TextStyle(color: Colors.white)),
          subtitle: const Text("Arayüzü sol ele göre optimize eder", style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _isLeftHanded,
          activeThumbColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() => _isLeftHanded = val);
            widget.onLeftHandedChanged(val);
          },
        ),
        SwitchListTile(
          title: const Text("Dairesel Mesaj Balonları", style: TextStyle(color: Colors.white)),
          subtitle: const Text("Klasik hap tasarımı yerine çembersel", style: TextStyle(color: Colors.white54, fontSize: 12)),
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
          decoration: const InputDecoration(labelText: "Canlı Yayın Animasyonu", labelStyle: TextStyle(color: Colors.white54)),
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
          title: const Text("Hoparlörü Kullan", style: TextStyle(color: Colors.white)),
          subtitle: const Text("Sesleri ahize yerine dışarı verir", style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _useSpeaker,
          activeThumbColor: Colors.orangeAccent,
          onChanged: (val) {
            setState(() => _useSpeaker = val);
            widget.onSpeakerChanged(val);
          },
        ),
        SwitchListTile(
          title: const Text("Haptic (Titreşim) Geri Bildirim", style: TextStyle(color: Colors.white)),
          subtitle: const Text("Tuşlara basıldığında cihaz titrer", style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _hapticEnabled,
          activeThumbColor: Colors.orangeAccent,
          onChanged: (val) {
            setState(() => _hapticEnabled = val);
            widget.onHapticChanged(val);
          },
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
          decoration: const InputDecoration(labelText: "Kaydedilmeyen Sesleri Sil", labelStyle: TextStyle(color: Colors.white54)),
          items: const [
            DropdownMenuItem(value: 10, child: Text("10 Saniye Sonra")),
            DropdownMenuItem(value: 30, child: Text("30 Saniye Sonra")),
            DropdownMenuItem(value: 60, child: Text("1 Dakika Sonra")),
            DropdownMenuItem(value: -1, child: Text("Asla Silme")),
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
          decoration: const InputDecoration(labelText: "Kimler Canlı Bağlanabilir?", labelStyle: TextStyle(color: Colors.white54)),
          items: const [
            DropdownMenuItem(value: "Herkes", child: Text("Herkes")),
            DropdownMenuItem(value: "Kişilerim", child: Text("Sadece Kişilerim")),
            DropdownMenuItem(value: "Hiç Kimse", child: Text("Hiç Kimse (Kapalı)")),
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

  // 🟢 YENİ EKLENEN BİLDİRİM ARAYÜZÜ 🟢
  Widget _buildNotificationsContent() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Tüm Bildirimler", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: const Text("Orbit'ten gelen tüm bildirimleri açar veya kapatır", style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _notificationsEnabled,
          activeThumbColor: Colors.blueAccent,
          onChanged: (val) {
            setState(() {
              _notificationsEnabled = val;
              // Ana şalter kapanırsa alt şalterleri de kapat
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
          title: const Text("Sesli Mesaj Bildirimleri", style: TextStyle(color: Colors.white)),
          subtitle: const Text("Biri size telsiz mesajı bıraktığında", style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _messageNotificationsEnabled,
          activeThumbColor: Colors.blueAccent,
          onChanged: _notificationsEnabled ? (val) {
            setState(() => _messageNotificationsEnabled = val);
            widget.onMessageNotificationsChanged(val);
          } : null, // Ana şalter kapalıysa bu pasif olur
        ),
        SwitchListTile(
          title: const Text("Canlı Arama Bildirimleri", style: TextStyle(color: Colors.white)),
          subtitle: const Text("Biri sizinle canlı bağlantı kurmak istediğinde", style: TextStyle(color: Colors.white54, fontSize: 12)),
          value: _callNotificationsEnabled,
          activeThumbColor: Colors.blueAccent,
          onChanged: _notificationsEnabled ? (val) {
            setState(() => _callNotificationsEnabled = val);
            widget.onCallNotificationsChanged(val);
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
                decoration: const InputDecoration(
                  labelText: "Şu süreden eskileri sil:",
                  labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
                items: const [
                  DropdownMenuItem(value: 30, child: Text("30 Gün")),
                  DropdownMenuItem(value: 60, child: Text("60 Gün")),
                  DropdownMenuItem(value: 90, child: Text("90 Gün")),
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
              label: const Text("Temizle"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha: 0.2), foregroundColor: Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text("Cihazda tutulan kayıtlı ses dosyalarının boyutunu azaltmak için seçtiğiniz günden daha eski dosyaları topluca silebilirsiniz.", style: TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGlassmorphismContainer(
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
              
              const Text("Orbit Sistem Ayarları", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, letterSpacing: 1.2)),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSectionHeader("Profil ve Durum", Icons.person_outline, Colors.cyanAccent),
                    _buildSectionContent(title: "Profil ve Durum", child: _buildProfileContent()),

                    _buildSectionHeader("Görünüm ve Arayüz", Icons.palette_outlined, Colors.purpleAccent),
                    _buildSectionContent(title: "Görünüm ve Arayüz", child: _buildAppearanceContent()),

                    _buildSectionHeader("Ses ve Donanım", Icons.headset_mic_outlined, Colors.orangeAccent),
                    _buildSectionContent(title: "Ses ve Donanım", child: _buildAudioContent()),

                    _buildSectionHeader("Gizlilik ve Güvenlik", Icons.lock_outline, Colors.greenAccent),
                    _buildSectionContent(title: "Gizlilik ve Güvenlik", child: _buildPrivacyContent()),
                    
                    _buildSectionHeader("Bildirimler", Icons.notifications_active_outlined, Colors.blueAccent),
                    _buildSectionContent(title: "Bildirimler", child: _buildNotificationsContent()),

                    _buildSectionHeader("Depolama ve Veri", Icons.storage_outlined, Colors.redAccent),
                    _buildSectionContent(title: "Depolama ve Veri", child: _buildStorageContent()),
                    
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}