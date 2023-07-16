import 'package:flutter/material.dart';
import 'package:jarvis_1/chat/chat_methods.dart';
import '/models/message_model.dart';
import '/utils.dart';

class ChatWidget extends StatefulWidget {
  final String chatName;
  const ChatWidget(this.chatName, {super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _messageC = TextEditingController();
  List<Message> messages = [];
  final _isSyncing = BoolW(false);
  late SyncObj sO;

  @override
  void initState() {
    super.initState();
    sO = SyncObj(setState, _isSyncing);
    ChatM.loadMessages(messages, sO, widget.chatName);
  }

  @override
  void dispose() {
    super.dispose();
    _messageC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isSyncing.v
              ? loadingCenter()
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index].text),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            controller: _messageC,
            decoration: InputDecoration(
              hintText: 'Type a message',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () =>
                    ChatM.sendMessage(_messageC, widget.chatName, sO),
                icon: const Icon(Icons.send),
              ),
            ),
            onSubmitted: (_) =>
                ChatM.sendMessage(_messageC, widget.chatName, sO),
          ),
        ),
      ],
    );
  }
}
