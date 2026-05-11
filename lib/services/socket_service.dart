import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http; 

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal(); 

  late socket_io.Socket socket;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String myUserId = ""; 
  bool _isInitialized = false; 

  // --- Callback Fonksiyonları ---
  Function(String callerId)? onCallReceived;
  Function(String senderId, String filePath, String messageId)? onAudioPlayed;
  Function(String messageId, String readerId, String? readerName, bool isLiveRead)? onAudioRead; 
  Function(String targetId)? onCallAccepted; 
  Function(String targetId)? onCallRejected; 
  Function(String callerId)? onCallMissed;
  Function(String targetId)? onCallTimeout;
  Function(String callerId, bool isSpeaking)? onUserSpeaking;
  Function(String senderId, String senderName)? onNudgeReceived;
  Function(String senderId, String senderName)? onRogerThatReceived;
  Function(String senderId, String emoji)? onReactionReceived;
  Function(String userId, String status)? onUserStatusChanged;

  Future<void> initConnection(String myPhone, String token) async {
    if (_isInitialized && socket.connected) return;

    myUserId = myPhone;
    String serverUrl = 'https://orbit-talk.com:443';
    
    debugPrint('📡 Telsiz frekansı ayarlanıyor: $serverUrl');

    socket = socket_io.io(serverUrl, 
      socket_io.OptionBuilder()
        .setTransports(['websocket']) 
        .setAuth({'token': token})    
        .enableAutoConnect()         
        .enableReconnection()        
        .build()
    );

    socket.onConnect((_) {
      _isInitialized = true;
      debugPrint('🟢 Telsiz Sunucusuna Bağlanıldı! (Kimlik: $myUserId)');
      _registerWithToken();
    });

    socket.onConnectError((err) {
      _isInitialized = false;
      debugPrint('❌ Soket Bağlantı Hatası: $err');
    });

    socket.onError((err) {
      debugPrint('⚠️ Soket Hatası Oluştu: $err');
    });

    socket.onDisconnect((_) {
      _isInitialized = false;
      debugPrint('🔴 Sunucu bağlantısı koptu. Yeniden bağlanmaya çalışılıyor...');
    });

    socket.on('user_speaking', (data) { 
      if (onUserSpeaking != null) onUserSpeaking!(data['callerId'], data['isSpeaking']); 
    });

    socket.on('receiveNudge', (data) {
      if (onNudgeReceived != null && data != null) {
        onNudgeReceived!(data['senderId'], data['senderName']);
      }
    });

    socket.on('receiveRogerThat', (data) {
      if (onRogerThatReceived != null && data != null) {
        onRogerThatReceived!(data['senderId'], data['senderName']);
      }
    });

    socket.on('user_status', (data) {
      if (onUserStatusChanged != null && data != null) {
        onUserStatusChanged!(data['userId'].toString(), data['status'].toString());
      }
    });
    
    socket.on('receiveReaction', (data) {
      if (onReactionReceived != null && data != null) {
        onReactionReceived!(data['senderId'], data['emoji']);
      }
    });

    socket.on('incoming_call', (data) { if (onCallReceived != null) onCallReceived!(data['callerId']); });
    socket.on('call_accepted', (data) { if (onCallAccepted != null) onCallAccepted!(data['targetId']); });
    socket.on('call_rejected', (data) { if (onCallRejected != null) onCallRejected!(data['targetId']); });
    socket.on('call_timeout', (data) { if (onCallTimeout != null) onCallTimeout!(data['targetId']); });
    socket.on('missed_call', (data) { if (onCallMissed != null) onCallMissed!(data['callerId']); });
    
    socket.on('audio_read', (data) { 
      if (onAudioRead != null && data != null) {
        onAudioRead!(data['messageId'], data['readerId'] ?? 'unknown', data['readerName'], data['isLiveRead'] ?? false); 
      }
    });

    socket.on('receive_audio', (data) async {
      try {
        String audioUrl = data['audioUrl']; 
        String msgId = data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        
        if (audioUrl.startsWith('http://188.166.101.147')) {
          audioUrl = audioUrl.replaceFirst('http://188.166.101.147:3005', 'https://orbit-talk.com');
        }

        Directory docDir = await getApplicationDocumentsDirectory();
        File audioFile = File('${docDir.path}/incoming_audio_$msgId.m4a');
        
        var response = await http.get(Uri.parse(audioUrl));
        if (response.statusCode == 200) {
          await audioFile.writeAsBytes(response.bodyBytes, flush: true);
          if (onAudioPlayed != null) onAudioPlayed!(data['callerId'], audioFile.path, msgId);
        } else {
          debugPrint('❌ Ses indirilemedi: HTTP ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Ses indirme hatası: $e');
      }
    });
  }

  Future<void> _registerWithToken() async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("⚠️ FCM Token alınamadı: $e");
    }
    socket.emit('register', { 'userId': myUserId, 'fcmToken': fcmToken });
  }

  // --- ODA/GRUP ve BİREYSEL GÖNDERİM FONKSİYONLARI ---
  void joinGroup(String groupId) {
    socket.emit('join_group', { 'userId': myUserId, 'groupId': groupId });
  }

  void startCall(String targetUserId, {bool isGroup = false}) { 
    if (isGroup) {
        socket.emit('start_group_call', { 'callerId': myUserId, 'groupId': targetUserId });
    } else {
        socket.emit('start_call', { 'callerId': myUserId, 'targetId': targetUserId }); 
    }
  }
  
  void acceptCall(String callerId) { socket.emit('accept_call', { 'callerId': callerId, 'targetId': myUserId }); }
  void rejectCall(String callerId) { socket.emit('reject_call', { 'callerId': callerId, 'targetId': myUserId }); }
  void cancelCall(String targetUserId) { socket.emit('cancel_call', { 'callerId': myUserId, 'targetId': targetUserId }); }

  void sendAudio(String targetUserId, String audioUrl, String messageId, {bool isGroup = false}) {
    if (isGroup) {
        socket.emit('send_group_audio', { 'callerId': myUserId, 'groupId': targetUserId, 'audioUrl': audioUrl, 'messageId': messageId });
    } else {
        socket.emit('send_audio', { 'callerId': myUserId, 'targetId': targetUserId, 'audioUrl': audioUrl, 'messageId': messageId });
    }
  }

  void sendAudioRead(String targetUserId, String messageId, bool isLiveRead, String readerName) { 
    socket.emit('audio_read', { 'targetId': targetUserId, 'messageId': messageId, 'readerId': myUserId, 'readerName': readerName, 'isLiveRead': isLiveRead }); 
  }
  
  Future<void> stopAudio() async { await _audioPlayer.release(); }
  Future<void> playLiveAudio(String filePath) async {
    await _audioPlayer.release(); 
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(DeviceFileSource(filePath));
  }

  void sendSpeakingState(String targetUserId, bool isSpeaking, {bool isGroup = false}) {
    if (isGroup) {
        socket.emit('group_user_speaking', { 'callerId': myUserId, 'groupId': targetUserId, 'isSpeaking': isSpeaking });
    } else {
        socket.emit('user_speaking', { 'callerId': myUserId, 'targetId': targetUserId, 'isSpeaking': isSpeaking });
    }
  }
  
  void sendNudge(String targetId, String senderId, String senderName, {bool isGroup = false}) {
    if (isGroup) {
        socket.emit('sendGroupNudge', { 'groupId': targetId, 'senderId': senderId, 'senderName': senderName });
    } else {
        socket.emit('sendNudge', { 'targetId': targetId, 'senderId': senderId, 'senderName': senderName });
    }
  }

  void sendRogerThat(String targetId, String senderId, String senderName, {bool isGroup = false}) {
    if (isGroup) {
        socket.emit('sendGroupRogerThat', { 'groupId': targetId, 'senderId': senderId, 'senderName': senderName });
    } else {
        socket.emit('sendRogerThat', { 'targetId': targetId, 'senderId': senderId, 'senderName': senderName });
    }
  }
  
  void sendReaction(String targetId, String senderId, String emoji, {bool isGroup = false}) {
    if (isGroup) {
        socket.emit('sendGroupReaction', { 'groupId': targetId, 'senderId': senderId, 'emoji': emoji });
    } else {
        socket.emit('sendReaction', { 'targetId': targetId, 'senderId': senderId, 'emoji': emoji });
    }
  }
}
