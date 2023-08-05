// multi-word expression

import '/models/word_model.dart';

const taggedWordsS = 'taggedWords';

// TODO add link to first word

class MWE {
  String text;
  List<String> tags;
  List<String> taggedWords = [];
  String partOfSpeach;

  MWE(
    this.text, {
    this.tags = const [],
    this.taggedWords = const [],
    this.partOfSpeach = '',
  });

  factory MWE.fromJson(Map<String, dynamic> json) {
    return MWE(
      json[textS] ?? '',
      tags: ((json[tagsS] ?? []) as List).cast<String>(),
      taggedWords: ((json[taggedWordsS] ?? []) as List).cast<String>(),
      partOfSpeach: json[partOfSpeachS] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        tagsS: tags,
        taggedWordsS: taggedWords,
        partOfSpeachS: partOfSpeach,
      };
}

const properNounS = 'proper noun';

List<MWE> basicMWE = [
  MWE(partOfSpeachS, taggedWords: [
    verbS,
    nounS,
    pronounS,
    adjectiveS,
    adverbS,
    prepositionS,
    conjunctionS,
    interjectionS,
  ]),
  MWE(
    properNounS,
    tags: [partOfSpeachS],
    partOfSpeach: nounS,
  ),
];
