import 'dart:convert';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  
  SocketService._internal(); 

  late socket_io.Socket socket;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String myUserId = Platform.isIOS ? 'user_atahan' : 'Ayşe Yılmaz'; 

  Function(String callerId)? onCallReceived;
  Function(String senderId, String filePath, String messageId)? onAudioPlayed;
  Function(String messageId)? onAudioRead; 
  
  Function(String targetId)? onCallAccepted; 
  Function(String targetId)? onCallRejected; 
  // 🟢 YENİ: Karşı taraf 30 saniye içinde açmazsa veya isteği geri çekerse tetiklenecekler 🟢
  Function(String callerId)? onCallMissed;
  Function(String targetId)? onCallTimeout;

  void initConnection() {
    String serverUrl =  'http://192.168.1.39:3000';
    
    socket = socket_io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      debugPrint('🟢 Telsiz Sunucusuna Bağlanıldı!');
      socket.emit('register', myUserId);
    });

    socket.onDisconnect((_) => debugPrint('🔴 Sunucu bağlantısı koptu.'));

    socket.on('incoming_call', (data) {
      if (onCallReceived != null) onCallReceived!(data['callerId']);
    });

    socket.on('call_accepted', (data) {
      if (onCallAccepted != null) onCallAccepted!(data['targetId']);
    });

    socket.on('call_rejected', (data) {
      if (onCallRejected != null) onCallRejected!(data['targetId']);
    });

    // 🟢 YENİ: Sunucudan çağrı zaman aşımına uğradı bilgisi gelirse
    socket.on('call_timeout', (data) {
      if (onCallTimeout != null) onCallTimeout!(data['targetId']);
    });

    // 🟢 YENİ: Arayan kişi çağrıyı iptal ederse
    socket.on('missed_call', (data) {
       debugPrint('⏰ Cevapsız Çağrı! ${data['callerId']}');
       if (onCallMissed != null) onCallMissed!(data['callerId']);
    });

    socket.on('audio_read', (data) {
      if (onAudioRead != null) onAudioRead!(data['messageId']);
    });

    socket.on('receive_audio', (data) async {
      try {
        Uint8List audioBytes = base64Decode(data['audioBase64']);
        Directory docDir = await getApplicationDocumentsDirectory();
        
        File audioFile = File('${docDir.path}/incoming_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
        await audioFile.writeAsBytes(audioBytes, flush: true);
        
        if (onAudioPlayed != null) {
          String msgId = data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
          onAudioPlayed!(data['callerId'], audioFile.path, msgId);
        }
      } catch (e) {
        debugPrint('❌ Ses kaydetme hatası: $e');
      }
    });
  }

  void startCall(String targetUserId) {
    socket.emit('start_call', { 'callerId': myUserId, 'targetId': targetUserId });
  }

  void acceptCall(String callerId) {
    socket.emit('accept_call', { 'callerId': callerId, 'targetId': myUserId });
  }

  void rejectCall(String callerId) {
    socket.emit('reject_call', { 'callerId': callerId, 'targetId': myUserId });
  }

  // 🟢 YENİ: 30 Saniye dolduğunda çağrıyı iptal etme fonksiyonu 🟢
  void cancelCall(String targetUserId) {
     socket.emit('cancel_call', { 'callerId': myUserId, 'targetId': targetUserId });
  }

  void sendAudio(String targetUserId, String audioBase64, String messageId) {
    socket.emit('send_audio', { 
      'callerId': myUserId, 
      'targetId': targetUserId, 
      'audioBase64': audioBase64,
      'messageId': messageId 
    });
  }

  void sendAudioRead(String targetUserId, String messageId) {
    socket.emit('audio_read', {
      'targetId': targetUserId,
      'messageId': messageId
    });
  }

  Future<void> stopAudio() async {
    await _audioPlayer.release(); 
  }

  Future<void> playLiveAudio(String filePath) async {
    await _audioPlayer.release(); 
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(DeviceFileSource(filePath));
  }
}