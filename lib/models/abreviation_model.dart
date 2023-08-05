import '/models/word_model.dart';

const abreviationFromS = 'abreviationFrom';

class Abreviation {
  String text;
  String abreviationFrom;

  Abreviation(
    this.text, {
    this.abreviationFrom = '',
  });

  factory Abreviation.fromJson(Map<String, dynamic> json) {
    return Abreviation(
      json[textS] ?? '',
      abreviationFrom: json[abreviationFromS] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        textS: text,
        abreviationFromS: abreviationFrom,
      };
}

List<Abreviation> basicAbreviations = [
  Abreviation('y', abreviationFrom: yesS),
  Abreviation('n', abreviationFrom: noS),
  Abreviation('v', abreviationFrom: verbS),
  Abreviation('noun', abreviationFrom: nounS),
  Abreviation('pron', abreviationFrom: pronounS),
  Abreviation('adj', abreviationFrom: adjectiveS),
  Abreviation('adv', abreviationFrom: adverbS),
  Abreviation('prep', abreviationFrom: prepositionS),
  Abreviation('conj', abreviationFrom: conjunctionS),
  Abreviation('interj', abreviationFrom: interjectionS),
];
