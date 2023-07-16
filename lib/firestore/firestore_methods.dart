import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/message_model.dart';
import '/utils.dart';

const chatsS = 'chats';
const messagesS = 'messages';

class FirestoreM {
  static final _firestore = FirebaseFirestore.instance;

  static Future<String> addChat(String chatName) async {
    try {
      await _firestore.collection(chatsS).doc(chatName).set({});
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> removeChat(String chatName) async {
    try {
      await _firestore.collection(chatsS).doc(chatName).delete();
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
