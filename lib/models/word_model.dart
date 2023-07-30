const textS = 'text';
const partOfSpeachS = 'partOfSpeach';

class Word {
  String text;
  String partOfSpeach;

  Word(this.text, {String? partOfSpeach})
      : partOfSpeach = partOfSpeach ?? unknownS;

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      json[textS],
      partOfSpeach: json[partOfSpeachS],
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        partOfSpeachS: partOfSpeach,
      };
}

const verbS = 'verb';
const nounS = 'noun';
const unknownS = 'unknown';
const oovWord = 'oovWord';
// const adjectiveS = 'adj';
// const adverbS = 'adv';
