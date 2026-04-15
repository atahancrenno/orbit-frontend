import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide PermissionStatus;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ContactsBottomSheet extends StatefulWidget {
  final int initialIndex;
  const ContactsBottomSheet({super.key, this.initialIndex = 0});

  static Future<Map<String, dynamic>?> show(BuildContext context, {int initialIndex = 0}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true, 
      useSafeArea: true, 
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7), 
      builder: (context) => ContactsBottomSheet(initialIndex: initialIndex), 
    );
  }

  @override
  State<ContactsBottomSheet> createState() => _ContactsBottomSheetState();
}

class _ContactsBottomSheetState extends State<ContactsBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasPermission = false;

  List<Map<String, dynamic>> _orbitContacts = [];
  List<Map<String, dynamic>> _inviteContacts = [];
  
  final Set<String> _selectedPhonesForGroup = {};
  final TextEditingController _groupNameController = TextEditingController();

  String? _currentUserPhone; 
  String _debugError = "";

  // 🟢 DİL VE ÇEVİRİ ALTYAPISI
  String _currentLang = 'tr';

  final Map<String, Map<String, String>> _texts = {
    'tab_contacts': {'tr': 'Kişiler', 'en': 'Contacts', 'es': 'Contactos', 'ar': 'جهات الاتصال', 'de': 'Kontakte', 'ru': 'Контакты'},
    'tab_group': {'tr': 'Grup Kur', 'en': 'New Group', 'es': 'Nuevo Grupo', 'ar': 'مجموعة جديدة', 'de': 'Neue Gruppe', 'ru': 'Новая группа'},
    'tab_invite': {'tr': 'Davet', 'en': 'Invite', 'es': 'Invitar', 'ar': 'دعوة', 'de': 'Einladen', 'ru': 'Пригласить'},
    'server_error': {'tr': 'Sunucu Bağlantı Hatası: Lütfen aynı WiFi ağında olduğunuza emin olun.', 'en': 'Server Connection Error: Ensure you are on the same WiFi network.', 'es': 'Error de servidor: Asegúrese de estar en la misma red WiFi.', 'ar': 'خطأ في الخادم: تأكد من أنك على نفس شبكة WiFi.', 'de': 'Serverfehler: Stellen Sie sicher, dass Sie im selben WLAN sind.', 'ru': 'Ошибка сервера: убедитесь, что вы находитесь в той же сети WiFi.'},
    'no_orbit_users': {'tr': 'Rehberinizde Orbit kullanan kimse bulunamadı.\n\nEğer bir sorun olduğunu düşünüyorsanız izinleri kontrol edin.', 'en': 'No Orbit users found in your contacts.\n\nCheck permissions if you think there is an issue.', 'es': 'No se encontraron usuarios de Orbit.\n\nVerifique los permisos si cree que hay un problema.', 'ar': 'لم يتم العثور على مستخدمي Orbit في جهات الاتصال الخاصة بك.\n\nتحقق من الأذونات إذا كنت تعتقد أن هناك مشكلة.', 'de': 'Keine Orbit-Nutzer in Ihren Kontakten gefunden.\n\nÜberprüfen Sie die Berechtigungen, wenn Sie ein Problem vermuten.', 'ru': 'В ваших контактах не найдено пользователей Orbit.\n\nПроверьте разрешения, если считаете, что возникла проблема.'},
    'no_contacts': {'tr': 'Rehberinizde kimse bulunamadı.', 'en': 'No contacts found.', 'es': 'No se encontraron contactos.', 'ar': 'لم يتم العثور على جهات اتصال.', 'de': 'Keine Kontakte gefunden.', 'ru': 'Контакты не найдены.'},
    'check_permissions': {'tr': 'İzinleri Kontrol Et', 'en': 'Check Permissions', 'es': 'Comprobar permisos', 'ar': 'التحقق من الأذونات', 'de': 'Berechtigungen prüfen', 'ru': 'Проверить разрешения'},
    'processing_contacts': {'tr': 'Rehberiniz işleniyor...', 'en': 'Processing contacts...', 'es': 'Procesando contactos...', 'ar': 'جاري معالجة جهات الاتصال...', 'de': 'Kontakte werden verarbeitet...', 'ru': 'Обработка контактов...'},
    'permission_required': {'tr': 'Rehber İzni Gerekli', 'en': 'Contacts Permission Required', 'es': 'Se requiere permiso de contactos', 'ar': 'مطلوب إذن جهات الاتصال', 'de': 'Berechtigung für Kontakte erforderlich', 'ru': 'Требуется разрешение на контакты'},
    'permission_desc': {'tr': 'Seni genel ayarlara yönlendirirsek, Kişiler erişimini manuel açman gerekebilir.', 'en': 'If redirected to settings, you may need to enable Contacts access manually.', 'es': 'Si se le redirige a la configuración, es posible que deba habilitar el acceso manualmente.', 'ar': 'إذا تم إعادة توجيهك إلى الإعدادات ، فقد تحتاج إلى تمكين الوصول إلى جهات الاتصال يدويًا.', 'de': 'Wenn Sie zu den Einstellungen weitergeleitet werden, müssen Sie den Zugriff möglicherweise manuell aktivieren.', 'ru': 'Если вы будете перенаправлены в настройки, вам может потребоваться включить доступ к контактам вручную.'},
    'allow': {'tr': 'İzin Ver', 'en': 'Allow', 'es': 'Permitir', 'ar': 'يسمح', 'de': 'Erlauben', 'ru': 'Разрешить'},
    'no_group_members': {'tr': 'Gruba eklenecek kimse yok.', 'en': 'No one to add to the group.', 'es': 'Nadie para añadir al grupo.', 'ar': 'لا يوجد أحد لإضافته إلى المجموعة.', 'de': 'Niemand, der der Gruppe hinzugefügt werden kann.', 'ru': 'Некого добавить в группу.'},
    'selected_people': {'tr': 'Kişi Seçildi', 'en': 'Selected', 'es': 'Seleccionados', 'ar': 'المحدد', 'de': 'Ausgewählt', 'ru': 'Выбрано'},
    'group_name_hint': {'tr': 'Grup Adı (Örn: Operasyon Ekibi)', 'en': 'Group Name (e.g. Alpha Team)', 'es': 'Nombre del grupo (ej. Equipo Alfa)', 'ar': 'اسم المجموعة (مثل فريق ألفا)', 'de': 'Gruppenname (z.B. Alpha-Team)', 'ru': 'Название группы (например, Команда Альфа)'},
    'create_group_btn': {'tr': 'Grubu Oluştur', 'en': 'Create Group', 'es': 'Crear Grupo', 'ar': 'إنشاء مجموعة', 'de': 'Gruppe erstellen', 'ru': 'Создать группу'},
    'group_name_empty': {'tr': 'Lütfen gruba bir isim verin.', 'en': 'Please enter a group name.', 'es': 'Por favor, introduzca un nombre de grupo.', 'ar': 'الرجاء إدخال اسم المجموعة.', 'de': 'Bitte geben Sie einen Gruppennamen ein.', 'ru': 'Пожалуйста, введите название группы.'},
    'group_min_members': {'tr': 'Gruba en az 1 kişi daha eklemelisiniz.', 'en': 'You must add at least 1 person.', 'es': 'Debes añadir al menos a 1 persona.', 'ar': 'يجب عليك إضافة شخص واحد على الأقل.', 'de': 'Sie müssen mindestens 1 Person hinzufügen.', 'ru': 'Вы должны добавить хотя бы 1 человека.'},
    'group_max_members': {'tr': 'Bir grupta en fazla 50 kişi olabilir!', 'en': 'A group can have a maximum of 50 people!', 'es': '¡Un grupo puede tener un máximo de 50 personas!', 'ar': 'يمكن أن تضم المجموعة 50 شخصًا كحد أقصى!', 'de': 'Eine Gruppe kann maximal 50 Personen haben!', 'ru': 'В группе может быть не более 50 человек!'},
    'whatsapp_invite': {'tr': 'Seni Orbit PTT\'ye bekliyorum! https://orbitptt.com', 'en': 'Join me on Orbit PTT! https://orbitptt.com', 'es': '¡Únete a mí en Orbit PTT! https://orbitptt.com', 'ar': 'انضم إلي على Orbit PTT! https://orbitptt.com', 'de': 'Mach mit bei Orbit PTT! https://orbitptt.com', 'ru': 'Присоединяйтесь ко мне в Orbit PTT! https://orbitptt.com'},
    'unknown_name': {'tr': 'İsimsiz', 'en': 'Unknown', 'es': 'Desconocido', 'ar': 'غير معروف', 'de': 'Unbekannt', 'ru': 'Неизвестный'},
  };

  String _t(String key) {
    return _texts[key]?[_currentLang] ?? _texts[key]?['en'] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex); 
    _loadLanguagePreference().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _startContactProcess();
      });
    });
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentLang = prefs.getString('app_lang') ?? 'tr';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _startContactProcess() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserPhone = prefs.getString('user_phone');

      var status = await ph.Permission.contacts.status;
      if (status.isGranted) {
        if (mounted) setState(() { _hasPermission = true; _isLoading = true; _debugError = ""; });
        await _fetchAndMatchContactsSafe();
      } else {
         status = await ph.Permission.contacts.request();
         if (status.isGranted) {
            if (mounted) setState(() { _hasPermission = true; _isLoading = true; _debugError = ""; });
            await _fetchAndMatchContactsSafe();
         } else {
            if (mounted) setState(() { _hasPermission = false; _isLoading = false; });
         }
      }
    } catch (e) {
      if (mounted) setState(() { _hasPermission = false; _isLoading = false; _debugError = "Error: $e"; });
    }
  }

  String _getDeviceCountryCode() {
    try {
      String localeName = Platform.localeName; 
      if (localeName.contains('_')) {
        String countryIso = localeName.split('_').last.toUpperCase();
        switch (countryIso) {
          case 'US': case 'CA': return '+1';
          case 'GB': return '+44';
          case 'DE': return '+49';
          case 'FR': return '+33';
          case 'AZ': return '+994';
          case 'RU': case 'KZ': return '+7';
          default: return '+90'; 
        }
      }
    } catch (e) {
      debugPrint("Country code error: $e");
    }
    return '+90';
  }

  Future<void> _fetchAndMatchContactsSafe() async {
    try {
      var contacts = await FlutterContacts.getAll(properties: {ContactProperty.name, ContactProperty.phone});
      
      Set<String> registeredPhonesSet = {};
      try {
        final response = await http.get(Uri.parse('http://192.168.1.7:3000/api/users'));
        
        if (response.statusCode == 200) {
          List<dynamic> users = jsonDecode(response.body);
          registeredPhonesSet = users
              .map((u) => u['phone']?.toString() ?? "")
              .where((p) => p.isNotEmpty && p != _currentUserPhone).toSet();
        } else {
           throw Exception("Server Error: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("API Error: $e");
        if (mounted) {
          setState(() { 
            _debugError = _t('server_error'); 
          });
        }
      }

      List<Map<String, dynamic>> orbitList = [];
      List<Map<String, dynamic>> inviteList = [];
      String defaultCountryCode = _getDeviceCountryCode();

      for (int i = 0; i < contacts.length; i++) {
        if (i % 50 == 0) await Future.delayed(Duration.zero);

        var contact = contacts[i];
        if (contact.phones.isNotEmpty) {
          String rawPhone = contact.phones.first.number;
          String normalized = rawPhone.replaceAll(RegExp(r'[^\d+]'), ''); 
          
          if (normalized.startsWith('00')) {
            normalized = '+${normalized.substring(2)}';
          } else if (normalized.startsWith('0')) {
            normalized = '$defaultCountryCode${normalized.substring(1)}';
          } else if (!normalized.startsWith('+')) {
            normalized = '$defaultCountryCode$normalized';
          }

          String name = (contact.displayName != null && contact.displayName!.isNotEmpty) ? contact.displayName! : _t('unknown_name');
          final cData = {"name": name, "phone": normalized, "status": "available", "isGroup": false};

          if (registeredPhonesSet.contains(normalized)) {
            orbitList.add(cData);
          } else {
            inviteList.add(cData);
          }
        }
      }

      orbitList.sort((a, b) => a["name"].toString().toLowerCase().compareTo(b["name"].toString().toLowerCase()));
      inviteList.sort((a, b) => a["name"].toString().toLowerCase().compareTo(b["name"].toString().toLowerCase()));

      var seenPhones = <String>{};
      orbitList.retainWhere((c) => seenPhones.add(c['phone']));
      
      seenPhones.clear();
      inviteList.retainWhere((c) => seenPhones.add(c['phone']));

      if (mounted) {
        setState(() {
          _orbitContacts = orbitList;
          _inviteContacts = inviteList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _debugError = "Critical Error: $e"; });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return "${parts[0][0]}${parts[parts.length - 1][0]}".toUpperCase();
  }

  Future<void> _inviteViaWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    String message = Uri.encodeComponent(_t('whatsapp_invite'));
    final url = Uri.parse("https://wa.me/$cleanPhone?text=$message");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _createAndReturnGroup() {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('group_name_empty')), backgroundColor: Colors.orange));
      return;
    }
    if (_selectedPhonesForGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('group_min_members')), backgroundColor: Colors.orange));
      return;
    }

    String groupId = "group_${DateTime.now().millisecondsSinceEpoch}";
    List<String> allMembers = _selectedPhonesForGroup.toList();
    if (_currentUserPhone != null && !allMembers.contains(_currentUserPhone)) {
      allMembers.add(_currentUserPhone!); 
    }

    Map<String, dynamic> newGroup = {
      "id": groupId,
      "name": _groupNameController.text.trim(),
      "isGroup": true,
      "members": allMembers,
      "admins": _currentUserPhone != null ? [_currentUserPhone] : [], 
      "createdBy": _currentUserPhone ?? "unknown",
      "createdAt": DateTime.now().toIso8601String(),
    };

    Navigator.pop(context, newGroup);
  }

  void _handleGroupSelection(String phone, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectedPhonesForGroup.length >= 49) { 
           ScaffoldMessenger.of(context).hideCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text(_t('group_max_members')), 
             backgroundColor: Colors.redAccent,
             behavior: SnackBarBehavior.floating,
           ));
           return;
        }
        _selectedPhonesForGroup.add(phone);
      } else {
        _selectedPhonesForGroup.remove(phone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.85;
    TextDirection layoutDirection = _currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: layoutDirection,
      child: Container(
        height: sheetHeight, 
        width: double.infinity, 
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            
            if (_debugError.isNotEmpty)
               Container(
                 margin: const EdgeInsets.all(10),
                 padding: const EdgeInsets.all(8),
                 color: Colors.redAccent.withValues(alpha: 0.2),
                 child: Text(_debugError, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
               ),

            if (!_hasPermission && !_isLoading)
              Expanded(child: _buildPermissionPrompt())
            else if (_isLoading)
              Expanded(child: _buildLoadingState())
            else
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.cyanAccent,
                      labelColor: Colors.cyanAccent,
                      unselectedLabelColor: Colors.white38,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: _t('tab_contacts')), 
                        Tab(text: _t('tab_group')), 
                        Tab(text: _t('tab_invite'))
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(_orbitContacts, true), 
                          _buildGroupCreator(), 
                          _buildList(_inviteContacts, false)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)),
        const SizedBox(height: 20),
        Text(_t('processing_contacts'), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
      ],
    );
  }

  Widget _buildPermissionPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.contacts, color: Colors.white12, size: 80),
        const SizedBox(height: 20),
        Text(_t('permission_required'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(_t('permission_desc'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2), foregroundColor: Colors.cyanAccent),
          onPressed: () async {
            final status = await ph.Permission.contacts.request();
            if (status.isGranted) {
              if (mounted) setState(() { _hasPermission = true; _isLoading = true; });
              await _fetchAndMatchContactsSafe();
            } else {
               ph.openAppSettings();
            }
          },
          child: Text(_t('allow')),
        )
      ],
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list, bool isOrbit) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isOrbit ? _t('no_orbit_users') : _t('no_contacts'), 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, height: 1.5)
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings, size: 16),
                label: Text(_t('check_permissions')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.cyanAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  ph.openAppSettings();
                },
              )
            ],
          )
        )
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final c = list[index];
        return ListTile(
          onTap: isOrbit ? () => Navigator.pop(context, c) : null,
          leading: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.05), child: Text(_getInitials(c['name']), style: const TextStyle(color: Colors.cyanAccent, fontSize: 12))),
          title: Text(c['name'], style: const TextStyle(color: Colors.white, fontSize: 15)),
          subtitle: Text(c['phone'], style: const TextStyle(color: Colors.white24, fontSize: 12)),
          trailing: isOrbit 
            ? const Icon(Icons.check_circle, color: Colors.cyanAccent, size: 20)
            : IconButton(
                icon: const Icon(Icons.share, color: Colors.greenAccent, size: 20),
                onPressed: () => _inviteViaWhatsApp(c['phone'] ?? ""),
              ),
        );
      },
    );
  }

  Widget _buildGroupCreator() {
    if (_orbitContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_t('no_group_members'), style: const TextStyle(color: Colors.white24)),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, size: 14),
              label: Text(_t('check_permissions'), style: const TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withValues(alpha: 0.1), foregroundColor: Colors.cyanAccent),
              onPressed: () => ph.openAppSettings(),
            )
          ],
        )
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "${_selectedPhonesForGroup.length + 1}/50 ${_t('selected_people')}", 
            style: TextStyle(color: _selectedPhonesForGroup.length >= 49 ? Colors.redAccent : Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 10),
            itemCount: _orbitContacts.length,
            itemBuilder: (context, index) {
              final c = _orbitContacts[index];
              final phone = c['phone'] as String;
              final isSelected = _selectedPhonesForGroup.contains(phone);
              
              return ListTile(
                onTap: () => _handleGroupSelection(phone, !isSelected),
                leading: Stack(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.05), child: Text(_getInitials(c['name']), style: const TextStyle(color: Colors.cyanAccent, fontSize: 12))),
                    if (isSelected)
                      Positioned(
                        right: -2, bottom: -2,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: Colors.black, size: 14)
                        ),
                      )
                  ],
                ),
                title: Text(c['name'], style: const TextStyle(color: Colors.white, fontSize: 15)),
                subtitle: Text(phone, style: const TextStyle(color: Colors.white24, fontSize: 12)),
                trailing: Checkbox(
                  value: isSelected,
                  activeColor: Colors.greenAccent,
                  checkColor: Colors.black,
                  side: const BorderSide(color: Colors.white54),
                  onChanged: (val) => _handleGroupSelection(phone, val == true),
                ),
              );
            },
          ),
        ),
        
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _selectedPhonesForGroup.isNotEmpty ? 130 : 0,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))]
          ),
          padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 30),
          child: _selectedPhonesForGroup.isNotEmpty ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _groupNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _t('group_name_hint'),
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2), foregroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.group_add, size: 18),
                  label: Text(_t('create_group_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _createAndReturnGroup,
                ),
              )
            ],
          ) : const SizedBox.shrink(),
        )
      ],
    );
  }
}