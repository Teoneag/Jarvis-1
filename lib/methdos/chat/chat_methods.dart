import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jarvis_1/methdos/jarvis/jarvis_methods.dart';
import '/models/message_model.dart';
import '/firestore/firestore_methods.dart';

import '/utils.dart';

class ChatM {
  static Future addDialog(BuildContext context, TextEditingController titleC,
      SyncObj sO, List<String> chatNames) async {
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
            addChat(titleC.text, sO, chatNames);
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
              addChat(titleC.text, sO, chatNames);
              titleC.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future removeDialog(BuildContext context, String chatName, SyncObj sO,
      List<String> chatNames) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove a task'),
        content: Text('Are you sure you want to remove $chatName?'),
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
              removeChat(chatName, sO, chatNames);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  static Future addChat(
      String chatName, SyncObj sO, List<String> chatNames) async {
    chatNames.add(chatName);
    await syncFun(sO, () async => await FirestoreM.addChat(chatName));
  }

  static Future removeChat(
      String chatName, SyncObj sO, List<String> chatNames) async {
    chatNames.remove(chatName);
    await syncFun(sO, () async => await FirestoreM.removeChat(chatName));
  }

  static Future loadChatNamesAndChat(
    List<String> chatNames,
    List<Message> messages,
    SyncObj sO,
    BoolW isRailSyncing,
    BoolW isChatSyncing,
  ) async {
    isChatSyncing.v = true;
    await loadChatNames(chatNames, sO, isRailSyncing);
    if (chatNames.isEmpty) {
      isChatSyncing.v = false;
      return;
    }
    await loadMessages(chatNames[0], messages, sO, isChatSyncing);
  }

  static Future loadChatNames(
    List<String> chatNames,
    SyncObj sO,
    BoolW isRailSyncing,
  ) async {
    await syncFun(sO, () async {
      isRailSyncing.v = true;
      try {
        final snap = await FirestoreM.loadChatNames();
        chatNames.clear();
        chatNames.addAll((snap[chatNamesS] as List<dynamic>).cast<String>());
      } catch (e) {
        print(e);
      }
      isRailSyncing.v = false;
    });
  }

  static Future loadMessages(
    String chatName,
    List<Message> messages,
    SyncObj sO,
    BoolW isChatSyncing,
  ) async {
    await syncFun(sO, () async {
      isChatSyncing.v = true;
      try {
        final snap = await FirestoreM.loadMessages(chatName);
        messages.clear();
        messages.addAll(snap.docs
            .map((doc) =>
                Message.fromSnap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
      } catch (e) {
        print(e);
      }
      isChatSyncing.v = false;
    });
  }

  static Future sendMessage(TextEditingController textC, String chatName,
      SyncObj sO, List<Message> messages) async {
    await syncFun(sO, () async {
      try {
        final text = textC.text.trim();
        await FirestoreM.sendMessage(Message(text: text), chatName);
        messages.add(Message(text: text));
        // print(JarvisM.isSentenceQuestion(textC.text));
        textC.clear();
        await JarvisM.processSentence(text, textC);
      } catch (e) {
        print(e);
      }
    });
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
