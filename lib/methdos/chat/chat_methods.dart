import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/methdos/jarvis/jarvis_methods.dart';
import '/models/message_model.dart';
import '/firestore/firestore_methods.dart';
import '/utils.dart';

class ChatM {
  static Future addDialog(
      BuildContext context, TextEditingController titleC, HSV hSV) async {
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
            _addChat(titleC.text, hSV);
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
              _addChat(titleC.text, hSV);
              titleC.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future _addChat(String chatName, HSV hSV) async {
    hSV.chatNames.add(chatName);
    hSV.onIndexChange(hSV.chatNames.length - 1);
    await FirestoreM.addChat(chatName);
  }

  static Future removeDialog(
    HSV hSV,
    BuildContext context,
    int removeI,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove a task'),
        content:
            Text('Are you sure you want to remove ${hSV.chatNames[removeI]}?'),
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
              _removeChat(hSV, removeI);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  static Future _removeChat(
    HSV hSV,
    int removeI,
  ) async {
    try {
      final chatName = hSV.chatNames[removeI];
      hSV.setState(() {
        hSV.chatNames.removeAt(removeI);
      });
      if (hSV.chatNames.isNotEmpty) {
        if (removeI == hSV.navIndex.v) {
          int newI = hSV.navIndex.v - 1;
          if (newI < 0) newI = 0;
          hSV.onIndexChange(newI);
        } else if (removeI < hSV.navIndex.v) {
          hSV.onIndexChange(hSV.navIndex.v - 1);
        }
      }
      await FirestoreM.removeChat(chatName);
    } catch (e) {
      print(e);
    }
  }

  static Future loadChatNamesAndChat(HSV hSV) async {
    await loadChatNames(hSV);
    if (hSV.chatNames.isNotEmpty) {
      await loadMessages(hSV);
    }
  }

  static Future loadChatNames(HSV hSV) async {
    await syncFun(SyncObj(hSV.setState, hSV.isRailSyncing), () async {
      try {
        final snap = await FirestoreM.loadChatNames();
        hSV.chatNames.clear();
        hSV.chatNames
            .addAll((snap[chatNamesS] as List<dynamic>).cast<String>());
      } catch (e) {
        print('This is loadChatNames: $e');
      }
    });
  }

  static Future loadMessages(HSV hSV) async {
    await syncFun(SyncObj(hSV.setState, hSV.isChatSyncing), () async {
      try {
        final snap = await FirestoreM.loadMessagesByTimestamp(hSV.chatName);
        hSV.messages.clear();
        hSV.messages.addAll(snap.docs
            .map((doc) =>
                Message.fromSnap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());

        final snap2 = await FirestoreM.loadChat(hSV.chatName);
        hSV.pendingSentence.v = snap2[pendingSentenceS];
      } catch (e) {
        print('This is loadMessages: $e');
      }
    });
  }

  static Future sendMessageMe(HSV hSV, TextEditingController textC) async {
    syncFun(SyncObj(hSV.setState, hSV.isAppSyncing), () async {
      try {
        final text = textC.text.trim();
        if (text.isEmpty) return;
        textC.clear();
        Message message = Message(text: text);
        await sendMessage(message, hSV);
        await JarvisM.processSentence(text, hSV);
      } catch (e) {
        print(e);
      }
    });
  }

  static Future sendMessage(Message message, HSV hSV) async {
    try {
      hSV.messages.insert(0, message);
      hSV.setState(() {});
      await FirestoreM.sendMessage(message, hSV.chatName);
      // print(JarvisM.isSentenceQuestion(textC.text));
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
      i.v++;
      if (i.v >= messages.length) i.v = messages.length - 1;
      c.text = messages[i.v].text;
    } else if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      i.v--;
      if (i.v < -1) i.v = -1;
      if (i.v == -1) {
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

// class RailObj {
//   final List<String> chatNames;
//   final SyncObj sO;

//   RailObj(this.chatNames, this.sO);
// }

// class ChatObj {
//   String chatName;
//   final List<Message> messages;
//   final SyncObj sO;
//   final BoolW isRespondWaited;
//   ChatObj(this.chatName, this.messages, this.sO, this.isRespondWaited);
// }

class HSV {
  final BoolW isAppSyncing;
  final BoolW isRailSyncing;
  final BoolW isChatSyncing;
  final BoolW isRailHidden;
  final StringNW pendingSentence;
  final IntW navIndex;
  final List<String> chatNames;
  final List<Message> messages;
  final void Function(int) onIndexChange;
  final void Function() onRailChange;
  final StateSetter setState;

  HSV(
    this.isAppSyncing,
    this.isRailSyncing,
    this.isChatSyncing,
    this.isRailHidden,
    this.pendingSentence,
    this.navIndex,
    this.chatNames,
    this.messages,
    this.onIndexChange,
    this.onRailChange,
    this.setState,
  );

  String get chatName => chatNames[navIndex.v];
}
