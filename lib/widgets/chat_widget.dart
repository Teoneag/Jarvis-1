import 'package:flutter/material.dart';
import '../methdos/chat/chat_methods.dart';
import '/utils.dart';

class ChatWidget extends StatefulWidget {
  final String chatName;
  final ChatObj cO;
  final SyncObj sO;

  const ChatWidget(this.chatName, this.cO, this.sO, {super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _messageC = TextEditingController();
  final _focusNode = FocusNode();
  late final IntW messageIndex;

  @override
  void initState() {
    super.initState();
    messageIndex = IntW(widget.cO.messages.length - 1);
  }

  @override
  void dispose() {
    super.dispose();
    _messageC.dispose();
    _focusNode.dispose();
  }

  // TODO: handle new line: flutter simplest way to achive the whatsapp enter function: when pressing normal enter, send the message, when pressing it while holding shift, add /n to the text
  // TODO: show messages cronologically

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.cO.messages.length,
            itemBuilder: (context, index) {
              final message = widget.cO.messages[index];
              return ListTile(
                title: Align(
                    alignment: message.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(message.text)),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => ChatM.handleKeyPress(
                event, messageIndex, _messageC, widget.cO.messages),
            child: TextField(
                autofocus: true,
                focusNode: _focusNode,
                controller: _messageC,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => ChatM.sendMessageMe(
                        _messageC, widget.chatName, widget.cO, widget.sO),
                    icon: const Icon(Icons.send),
                  ),
                ),
                onSubmitted: (_) {
                  ChatM.sendMessageMe(
                      _messageC, widget.chatName, widget.cO, widget.sO);
                  _focusNode.requestFocus(); // TODO: Make it autoscroll
                }),
          ),
        ),
      ],
    );
  }
}
