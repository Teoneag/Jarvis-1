import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/methdos/jarvis/jarvis_methods.dart';
import '/models/message_model.dart';
import '/firestore/firestore_methods.dart';
import '/utils.dart';

class ChatM {
  static Future addDialog(
    BuildContext context,
    TextEditingController titleC,
    RailObj rO,
    Function(int) onIndexChange,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a task'),
        content: TextField(
          controller: titleC,
          decoration: const InputDecoration(hintText: 'Type your task'),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _addChat(titleC.text, rO, onIndexChange);
            titleC.clear();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addChat(titleC.text, rO, onIndexChange);
              titleC.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future _addChat(
      String chatName, RailObj rO, Function(int) onChangeRail) async {
    rO.chatNames.add(chatName);
    onChangeRail(rO.chatNames.length - 1);
    await FirestoreM.addChat(chatName);
  }

  static Future removeDialog(
    BuildContext context,
    RailObj rO,
    ChatObj cO,
    int removeI,
    int selectedI,
    Function(int) onIndexChange,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove a task'),
        content:
            Text('Are you sure you want to remove ${rO.chatNames[removeI]}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeChat(rO, cO, removeI, selectedI, onIndexChange);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  static Future _removeChat(
    RailObj rO,
    ChatObj cO,
    int removeI,
    int selectedI,
    Function(int) onIndexChange,
  ) async {
    try {
      final chatName = rO.chatNames[removeI];
      rO.sO.setState(() {
        rO.chatNames.removeAt(removeI);
      });
      if (rO.chatNames.isNotEmpty) {
        if (removeI == selectedI) {
          int newI = selectedI - 1;
          if (newI < 0) newI = 0;
          onIndexChange(newI);
        } else if (removeI < selectedI) {
          onIndexChange(selectedI - 1);
        }
      }
      await FirestoreM.removeChat(chatName);
    } catch (e) {
      print(e);
    }
  }

  static Future loadChatNamesAndChat(RailObj rO, ChatObj cO) async {
    await loadChatNames(rO);
    if (rO.chatNames.isNotEmpty) {
      await loadMessages(rO.chatNames[0], cO);
    }
  }

  static Future loadChatNames(RailObj rO) async {
    await syncFun(rO.sO, () async {
      try {
        final snap = await FirestoreM.loadChatNames();
        rO.chatNames.clear();
        rO.chatNames.addAll((snap[chatNamesS] as List<dynamic>).cast<String>());
      } catch (e) {
        print(e);
      }
    });
  }

  static Future loadMessages(String chatName, ChatObj cO) async {
    await syncFun(cO.sO, () async {
      try {
        final snap = await FirestoreM.loadMessages(chatName);
        cO.messages.clear();
        cO.messages.addAll(snap.docs
            .map((doc) =>
                Message.fromSnap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
      } catch (e) {
        print(e);
      }
    });
  }

  static Future sendMessage(
      TextEditingController textC, String chatName, ChatObj cO) async {
    if (textC.text.trim().isEmpty) return;
    try {
      final text = textC.text.trim();
      cO.messages.add(Message(text: text));
      cO.sO.setState(() {});
      await FirestoreM.sendMessage(Message(text: text), chatName);
      // print(JarvisM.isSentenceQuestion(textC.text));
      textC.clear();
      await JarvisM.processSentence(text, textC);
    } catch (e) {
      print(e);
    }
  }

  static void handleKeyPress(
    RawKeyEvent event,
    IntW i,
    TextEditingController c,
    List<Message> messages,
  ) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      i.v--;
      if (i.v < 0) i.v = 0;
      c.text = messages[i.v].text;
    } else if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      i.v++;
      if (i.v > messages.length) i.v = messages.length;
      if (i.v == messages.length) {
        c.clear();
      } else {
        c.text = messages[i.v].text;
      }
    }
  }
}

Future<void> syncFun(SyncObj sO, Function callback) async {
  sO.setState(() {
    sO.isSyncing.v = true;
  });
  await callback();
  sO.setState(() {
    sO.isSyncing.v = false;
  });
}

class RailObj {
  final List<String> chatNames;
  final SyncObj sO;

  RailObj(this.chatNames, this.sO);
}

class ChatObj {
  final List<Message> messages;
  final SyncObj sO;

  ChatObj(this.messages, this.sO);
}
