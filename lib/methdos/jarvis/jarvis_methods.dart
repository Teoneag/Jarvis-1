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
