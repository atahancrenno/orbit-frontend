enum UserStatus { available, busy, away }

class AudioMessage {
  final String id;
  final String contactName; 
  final String? senderName; 
  final bool isMe; 
  final int durationInSeconds;
  final String time; 
  bool isRead; 
  String? readTime; 
  
  Map<String, String> listenedBy;

  bool isPlaying;
  double playProgress;
  bool isDeleted;
  bool isSaved;
  final bool isLiveMessage;
  final DateTime createdAt;
  bool isPendingDeletion;
  int deletionSecondsRemaining;
  bool showTranscription; 
  String transcriptionText; 
  bool hasReaction; 
  double playbackSpeed; 
  String? repliedToMessageId; 
  final String? audioFilePath;
  
  // 🟢 YENİ: Ses Efekti (Normal, Askeri, Megafon, Ajan)
  final String voiceEffect; 

  AudioMessage({
    required this.id,
    required this.contactName,
    this.senderName,
    required this.isMe,
    required this.durationInSeconds,
    required this.time,
    this.isRead = false,
    this.readTime,
    Map<String, String>? listenedBy, 
    this.isPlaying = false,
    this.playProgress = 0.0,
    this.isDeleted = false,
    this.isSaved = false,
    this.isLiveMessage = false,
    this.isPendingDeletion = false,
    this.deletionSecondsRemaining = 30,
    this.showTranscription = false,
    this.transcriptionText = "Bu bir simüle edilmiş sesli mesaj metnidir.",
    this.hasReaction = false,
    this.playbackSpeed = 1.0,
    this.repliedToMessageId,
    this.audioFilePath,
    this.voiceEffect = "Normal", // 🟢 Varsayılan efekt Normal
    DateTime? createdAt,
  }) : 
       listenedBy = listenedBy ?? {}, 
       createdAt = createdAt ?? DateTime.now();
       
  String getInitials(String name) {
    if (name.trim().isEmpty) return "";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return "";
    if (parts.length == 1) return parts[0].substring(0, 2).toUpperCase();
    return "${parts[0][0]}.${parts.last[0]}".toUpperCase();
  }
}