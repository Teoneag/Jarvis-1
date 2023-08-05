const textS = 'text';
const partOfSpeachS = 'partOfSpeach';
const tagsS = 'tags';
const synonimsS = 'synonims';

// TODO save source

class Word {
  String text;
  List<String> tags;
  String partOfSpeach;
  // List<String> synonyms;
  // List<String> abreviations;

  Word(
    this.text, {
    this.tags = const [],
    this.partOfSpeach = '',
    // this.synonyms = const [],
    // this.abreviations = const [],
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      json[textS] ?? '',
      tags: ((json[tagsS] ?? []) as List).cast<String>(),
      partOfSpeach: json[partOfSpeachS] ?? '',
      // synonyms: ((json[synonimsS] ?? []) as List).cast<String>(),
      // abreviations: ((json[abreviationsS] ?? []) as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        tagsS: tags,
        partOfSpeachS: partOfSpeach,
        // synonimsS: synonyms,
        // abreviationsS: abreviations,
      };
}

const yesS = 'yes';
const noS = 'no';

const verbS = 'verb';
const nounS = 'noun';
const pronounS = 'pronoun';
const adjectiveS = 'adjective';
const adverbS = 'adverb';
const prepositionS = 'preposition';
const conjunctionS = 'conjunction';
const interjectionS = 'interjection';

const specialS = 'special';

List<Word> basicWords = [
  Word(yesS, partOfSpeach: specialS),
  Word(noS, partOfSpeach: specialS),
  Word(verbS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(nounS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(pronounS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(adjectiveS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(adverbS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(prepositionS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(conjunctionS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(interjectionS, partOfSpeach: nounS, tags: [partOfSpeachS]),
  Word(specialS, partOfSpeach: nounS, tags: [partOfSpeachS]),
];
