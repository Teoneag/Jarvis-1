import 'package:uuid/uuid.dart';

const idS = 'id';
const textS = 'text';
const dateS = 'date';
const isMeS = 'isMe';
const isAuxS = 'isAux';

// TODO: save /n

class Message {
  String uid;
  String text;
  DateTime date;
  bool isMe;
  bool isAux;

  Message(
      {required this.text,
      String? uid,
      DateTime? date,
      bool? isMe,
      bool? isAux})
      : uid = uid ?? const Uuid().v1(),
        date = date ?? DateTime.now(),
        isMe = isMe ?? true,
        isAux = isAux ?? false;

  factory Message.fromSnap(String uid, Map<String, dynamic> json) {
    return Message(
      uid: uid,
      text: json[textS],
      date: DateTime.parse(json[dateS]),
      isMe: json[isMeS],
      isAux: json[isAuxS],
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        dateS: date.toString(),
        isMeS: isMe,
        isAuxS: isAux,
      };
}
