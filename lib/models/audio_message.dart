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
  final String? audioFilePath; // 👇 YENİ EKLENDİ: Sesin cihazdaki konumu

  AudioMessage({
    required this.id,
    required this.contactName,
    this.senderName,
    required this.isMe,
    required this.durationInSeconds,
    required this.time,
    this.isRead = false,
    this.readTime,
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
    this.audioFilePath, // 👇 YENİ EKLENDİ
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}