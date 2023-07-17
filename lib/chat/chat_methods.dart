import 'package:flutter/material.dart';
import '/models/message_model.dart';
import '/firestore/firestore_methods.dart';

import '/utils.dart';

class ChatM {
  static Future displayDialog(BuildContext context,
      TextEditingController titleC, SyncObj sO, List<String> chatNames) async {
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

  static Future addChat(
      String chatName, SyncObj sO, List<String> chatNames) async {
    chatNames.add(chatName);
    await syncFun(sO, () async => await FirestoreM.addChat(chatName));
  }

  // static Future removeChat(String chatName, SyncObj sO) async {
  //   await syncFun(sO, () async => await FirestoreM.removeChat(chatName));
  // }

  static Future loadChatNamesAndChat(
    List<String> chatNames,
    List<Message> messages,
    SyncObj sO,
    BoolW isRailSyncing,
    BoolW isChatSyncing,
  ) async {
    isChatSyncing.v = true;
    await loadChatNames(chatNames, sO, isRailSyncing);
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
        await FirestoreM.sendMessage(Message(text: textC.text), chatName);
        messages.add(Message(text: textC.text));
        textC.clear();
      } catch (e) {
        print(e);
      }
    });
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
