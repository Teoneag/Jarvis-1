import 'package:flutter/material.dart';
import '/utils.dart';
import '/models/message_model.dart';
import '/methdos/chat/chat_methods.dart';

class ChatWidget extends StatefulWidget {
  final String chatName;

  const ChatWidget(this.chatName, {super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

// TODO: solve the flickering with moveing the cO as an internal parameter, and calling init only when the chatName changes

class _ChatWidgetState extends State<ChatWidget> {
  final _isSyncing = BoolW(false);
  final List<Message> _messages = [];
  final _messageC = TextEditingController();
  final _focusNode = FocusNode();
  late final IntW messageIndex;
  late final ChatObj cO;

  @override
  void initState() {
    cO = ChatObj(_messages, SyncObj(setState, _isSyncing));
    messageIndex = IntW(_messages.length - 1);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChatWidget oldWidget) {
    if (widget.chatName.isNotEmpty && widget.chatName != oldWidget.chatName) {
      ChatM.loadMessages(widget.chatName, cO);
      messageIndex.v = _messages.length - 1;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _messageC.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isSyncing.v
        ? loadingCenter()
        : widget.chatName.isEmpty
            ? const Text('Please select a chat')
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
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
                          event, messageIndex, _messageC, _messages),
                      child: TextField(
                          autofocus: true,
                          focusNode: _focusNode,
                          controller: _messageC,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => ChatM.sendMessage(
                                  _messageC, widget.chatName, cO),
                              icon: const Icon(Icons.send),
                            ),
                          ),
                          onSubmitted: (_) {
                            ChatM.sendMessage(_messageC, widget.chatName, cO);
                            _focusNode
                                .requestFocus(); // TODO: Make it autoscroll
                          }),
                    ),
                  ),
                ],
              );
  }
}
