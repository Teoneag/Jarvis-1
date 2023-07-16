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

  Message({required this.text, String? uid, DateTime? date, bool? isMe})
      : uid = uid ?? const Uuid().v1(),
        date = date ?? DateTime.now(),
        isMe = isMe ?? true;

  factory Message.fromSnap(String uid, Map<String, dynamic> json) {
    return Message(
      uid: uid,
      text: json[textS],
      date: DateTime.parse(json[dateS]),
      isMe: json[isMeS],
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        dateS: date.toString(),
        isMeS: isMe,
      };
}
