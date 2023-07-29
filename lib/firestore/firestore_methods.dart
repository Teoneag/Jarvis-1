import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/message_model.dart';
import '/utils.dart';

const chatsS = 'chats';
const messagesS = 'messages';
const generalS = 'general';
const chatNamesS = 'chatNames';

class FirestoreM {
  static final _firestore = FirebaseFirestore.instance;

  static Future<String> addChat(String chatName) async {
    try {
      await _firestore.collection(generalS).doc(chatsS).update({
        chatNamesS: FieldValue.arrayUnion([chatName])
      });
      return successS;
    } catch (e) {
      if (e.toString() ==
          'FirebaseError: [code=not-found]: No document to update: projects/jarvis-tn-1/databases/(default)/documents/general/chats') {
        await _firestore.collection(generalS).doc(chatsS).set({
          chatNamesS: [chatName]
        });
        return successS;
      }
      print(e);
      return '$e';
    }
  }

  static Future<DocumentSnapshot> loadChatNames() async {
    try {
      return await _firestore.collection(generalS).doc(chatsS).get();
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  static Future<QuerySnapshot> loadMessages(chatName) async {
    try {
      return await _firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .get();
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  static Future<QuerySnapshot> loadMessagesByTimestamp(chatName) async {
    try {
      return await _firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .orderBy(dateS, descending: true)
          .get();
    } catch (e) {
      print(e);
      throw Error();
    }
  }

  // TODO: when there are to many messages to be loaded, load them in batches

  static Future<String> removeChat(String chatName) async {
    try {
      await _firestore.collection(generalS).doc(chatsS).update({
        chatNamesS: FieldValue.arrayRemove([chatName])
      });

      final snap = await _firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .get();

      await Future.wait(snap.docs.map((doc) => doc.reference.delete()));
      // TODO: if i add any fields, delete the doc as well
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> sendMessage(Message message, String chatName) async {
    try {
      await _firestore
          .collection(chatsS)
          .doc(chatName)
          .collection(messagesS)
          .doc(message.uid)
          .set(message.toJson());
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }
}
