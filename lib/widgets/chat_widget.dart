import 'package:flutter/material.dart';
import '/methdos/chat/chat_methods.dart';
import '/utils.dart';

class ChatWidget extends StatefulWidget {
  final HSV hSV;
  const ChatWidget(this.hSV, {super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final messageC = TextEditingController();
  final focusNode = FocusNode();
  final messageIndex = IntW(-1);

  @override
  void dispose() {
    super.dispose();
    messageC.dispose();
    focusNode.dispose();
  }

  // TODO: handle new line: flutter simplest way to achive the whatsapp enter function: when pressing normal enter, send the message, when pressing it while holding shift, add /n to the text
  // TODO: show date of messages

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: widget.hSV.messages.length,
            itemBuilder: (context, index) {
              final message = widget.hSV.messages[index];
              return ListTile(
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 1),
                ),
                contentPadding: message.isAux
                    ? const EdgeInsets.symmetric(horizontal: 50)
                    : null,
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
                event, messageIndex, messageC, widget.hSV.messages),
            child: TextField(
                autofocus: true,
                focusNode: focusNode,
                controller: messageC,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => ChatM.sendMessageMe(widget.hSV, messageC),
                    icon: const Icon(Icons.send),
                  ),
                ),
                onSubmitted: (_) {
                  ChatM.sendMessageMe(widget.hSV, messageC);
                  focusNode.requestFocus(); // TODO: Make it autoscroll
                }),
          ),
        ),
      ],
    );
  }
}
