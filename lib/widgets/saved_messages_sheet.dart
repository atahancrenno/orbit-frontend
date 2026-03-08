import 'package:flutter/material.dart';
import '../models/audio_message.dart';

class SavedMessagesSheet extends StatefulWidget {
  final List<AudioMessage> savedMessages;
  final Function(AudioMessage) onUnsave;
  final String Function(int) formatDuration;

  const SavedMessagesSheet({
    super.key,
    required this.savedMessages,
    required this.onUnsave,
    required this.formatDuration,
  });

  static void show({
    required BuildContext context,
    required List<AudioMessage> savedMessages,
    required Function(AudioMessage) onUnsave,
    required String Function(int) formatDuration,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SavedMessagesSheet(
        savedMessages: savedMessages,
        onUnsave: onUnsave,
        formatDuration: formatDuration,
      ),
    );
  }

  @override
  State<SavedMessagesSheet> createState() => _SavedMessagesSheetState();
}

class _SavedMessagesSheetState extends State<SavedMessagesSheet> {
  late List<AudioMessage> _localMessages;

  @override
  void initState() {
    super.initState();
    // Listeyi yerel state'e alıyoruz ki silinince ekrandan anında kaybolsun
    _localMessages = List.from(widget.savedMessages);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kaydedilen Mesajlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
          const SizedBox(height: 10),
          Expanded(
            child: _localMessages.isEmpty 
              ? const Center(child: Text("Henüz kaydedilmiş mesaj yok.", style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _localMessages.length,
                  itemBuilder: (context, i) {
                    final msg = _localMessages[i];
                    return ListTile(
                      leading: Icon(msg.isMe ? Icons.call_made : Icons.call_received, color: msg.isMe ? Colors.cyanAccent : Colors.greenAccent),
                      title: Text("${msg.contactName} - ${msg.time}", style: const TextStyle(fontSize: 14, color: Colors.white)),
                      subtitle: Text("Süre: ${widget.formatDuration(msg.durationInSeconds)}", style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _localMessages.removeAt(i);
                          });
                          widget.onUnsave(msg);
                        },
                      ),
                    );
                  }
                ),
          )
        ],
      ),
    );
  }
}