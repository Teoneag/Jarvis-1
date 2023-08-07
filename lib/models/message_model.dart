import 'package:uuid/uuid.dart';

const idS = 'id';
const textS = 'text';
const dateS = 'date';
const isMeS = 'isMe';
const indentS = 'indent';

// TODO: save /n

class Message {
  String uid;
  String text;
  DateTime date;
  bool isMe;
  int indent; // 0 = normal text, 1 = indent, 2 = indent more, -1: log

  Message(
    this.text, {
    String? uid,
    DateTime? date,
    this.isMe = true,
    this.indent = 0,
  })  : uid = uid ?? const Uuid().v1(),
        date = date ?? DateTime.now();

  factory Message.fromSnap(String uid, Map<String, dynamic> json) {
    return Message(
      json[textS],
      uid: uid,
      date: DateTime.parse(json[dateS]),
      isMe: json[isMeS],
      indent: json[indentS],
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        dateS: date.toString(),
        isMeS: isMe,
        indentS: indent,
      };
}
