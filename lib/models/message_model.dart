import 'package:uuid/uuid.dart';

const idS = 'id';
const textS = 'text';
const dateS = 'date';
const isMeS = 'isMe';

class Message {
  String uid;
  String text;
  DateTime date;
  bool isMe;

  Message(this.text, {this.isMe = true})
      : uid = const Uuid().v1(),
        date = DateTime.now();

  Map<String, dynamic> toJson() => {
        textS: text,
        dateS: date.toString(),
        isMeS: isMe,
      };
}
