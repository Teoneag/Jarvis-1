import 'package:flutter/widgets.dart';
import 'package:jarvis_1/merriam_webster/m_w_api_methods.dart';

class JarvisM {
  static bool isSentenceQuestion(String sentence) {
    try {
      if (sentence.trim().endsWith('?')) return true;
      final lowercaseText = sentence.trim().toLowerCase();
      final firstWord = lowercaseText.split(' ')[0];

      return auxVerbs.contains(firstWord) || whWords.contains(firstWord);
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future processSentence(
      String sentence, TextEditingController textC) async {
    try {
      await MWApiM.getJson('word');
      // TODO: detect verbs
      // final lowercaseText = sentence.trim().toLowerCase();
      // final words = lowercaseText.split(' ');

      // TODO: split in parts execute every part
      // if (isSentenceQuestion(sentence)) {
      //   // handle question
      //   return;
      // }

      // handle statement
      // split it in parts
      // detect verbs

      // TODO: at the end say smth like ok
    } catch (e) {
      print(e);
    }
  }
}

List<String> auxVerbs = modalVerbs + auxiliaryVerbs + semiModalAuxVerbs;

List<String> modalVerbs = [
  "can",
  "could",
  "may",
  "might",
  "will",
  "would",
  "shall",
  "should",
  "do",
  "does",
  "did",
  "have",
  "has",
  "had",
];

List<String> auxiliaryVerbs = [
  "be",
  "am",
  "is",
  "are",
  "was",
  "were",
];

List<String> semiModalAuxVerbs = [
  "ought",
  "need",
  "dare",
  "used",
];

List<String> whWords = [
  "what",
  "when",
  "where",
  "which",
  "who",
  "whom",
  "whose",
  "why",
  "how",
];
