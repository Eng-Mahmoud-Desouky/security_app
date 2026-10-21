import 'character_domain.dart';

/// Registry of the 10 mutually exclusive character domains defined in SRS Section 2.
class PredefinedDomains {
  PredefinedDomains._();

  /// DOM_AR (N = 36)
  /// 0:ا | 1:ب | 2:ت | 3:ث | 4:ج | 5:ح | 6:خ | 7:د | 8:ذ | 9:ر | 10:ز | 11:س |
  /// 12:ش | 13:ص | 14:ض | 15:ط | 16:ظ | 17:ع | 18:غ | 19:ف | 20:ق | 21:ك | 22:ل |
  /// 23:م | 24:ن | 25:ه | 26:و | 27:ي | 28:أ | 29:إ | 30:آ | 31:ؤ | 32:ئ | 33:ء |
  /// 34:ة | 35:ى
  static final CharacterDomain domAr = CharacterDomain(
    id: 'DOM_AR',
    shortName: 'AR',
    displayName: 'Arabic',
    expectedModulus: 36,
    symbols: const <String>[
      'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
      'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
      'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي', 'أ', 'إ',
      'آ', 'ؤ', 'ئ', 'ء', 'ة', 'ى',
    ],
  );

  /// DOM_EN_UPPER (N = 26)
  static final CharacterDomain domEnUpper = CharacterDomain(
    id: 'DOM_EN_UPPER',
    shortName: 'EN_UPPER',
    displayName: 'English Uppercase',
    expectedModulus: 26,
    symbols: const <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
      'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
      'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
  );

  /// DOM_EN_LOWER (N = 26)
  static final CharacterDomain domEnLower = CharacterDomain(
    id: 'DOM_EN_LOWER',
    shortName: 'EN_LOWER',
    displayName: 'English Lowercase',
    expectedModulus: 26,
    symbols: const <String>[
      'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
      'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
      'u', 'v', 'w', 'x', 'y', 'z',
    ],
  );

  /// DOM_ES_EXT (N = 7)
  /// 0:á | 1:é | 2:í | 3:ó | 4:ú | 5:ü | 6:ñ
  static final CharacterDomain domEsExt = CharacterDomain(
    id: 'DOM_ES_EXT',
    shortName: 'ES_EXT',
    displayName: 'Spanish Extended',
    expectedModulus: 7,
    symbols: const <String>[
      'á', 'é', 'í', 'ó', 'ú', 'ü', 'ñ',
    ],
  );

  /// DOM_RU (N = 33)
  /// 0:а | 1:б | 2:в | 3:г | 4:д | 5:е | 6:ё | 7:ж | 8:з | 9:и | 10:й | 11:к |
  /// 12:л | 13:м | 14:н | 15:о | 16:п | 17:р | 18:с | 19:т | 20:у | 21:ф | 22:х |
  /// 23:ц | 24:ч | 25:ш | 26:щ | 27:ъ | 28:ы | 29:ь | 30:э | 31:ю | 32:я
  static final CharacterDomain domRu = CharacterDomain(
    id: 'DOM_RU',
    shortName: 'RU',
    displayName: 'Russian Lowercase',
    expectedModulus: 33,
    symbols: const <String>[
      'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и',
      'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т',
      'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь',
      'э', 'ю', 'я',
    ],
  );

  /// DOM_GR (N = 24)
  /// 0:α | 1:β | 2:γ | 3:δ | 4:ε | 5:ζ | 6:η | 7:θ | 8:ι | 9:κ | 10:λ | 11:μ |
  /// 12:ν | 13:ξ | 14:ο | 15:π | 16:ρ | 17:σ | 18:τ | 19:υ | 20:φ | 21:χ | 22:ψ | 23:ω
  static final CharacterDomain domGr = CharacterDomain(
    id: 'DOM_GR',
    shortName: 'GR',
    displayName: 'Greek Lowercase',
    expectedModulus: 24,
    symbols: const <String>[
      'α', 'β', 'γ', 'δ', 'ε', 'ζ', 'η', 'θ', 'ι', 'κ',
      'λ', 'μ', 'ν', 'ξ', 'ο', 'π', 'ρ', 'σ', 'τ', 'υ',
      'φ', 'χ', 'ψ', 'ω',
    ],
  );

  /// DOM_HE (N = 22)
  /// 0:א | 1:ב | 2:ג | 3:ד | 4:ה | 5:ו | 6:ז | 7:ח | 8:ט | 9:י | 10:כ | 11:ל |
  /// 12:מ | 13:נ | 14:ס | 15:ע | 16:פ | 17:צ | 18:ק | 19:ר | 20:ש | 21:ת
  static final CharacterDomain domHe = CharacterDomain(
    id: 'DOM_HE',
    shortName: 'HE',
    displayName: 'Hebrew',
    expectedModulus: 22,
    symbols: const <String>[
      'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י',
      'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ', 'ק', 'ר',
      'ש', 'ת',
    ],
  );

  /// DOM_NUM (N = 10)
  /// 0:0 | 1:1 | 2:2 | 3:3 | 4:4 | 5:5 | 6:6 | 7:7 | 8:8 | 9:9
  static final CharacterDomain domNum = CharacterDomain(
    id: 'DOM_NUM',
    shortName: 'NUM',
    displayName: 'Numbers',
    expectedModulus: 10,
    symbols: const <String>[
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ],
  );

  /// DOM_SYM (N = 32)
  /// 0:' ' | 1:! | 2:@ | 3:# | 4:$ | 5:% | 6:^ | 7:& | 8:* | 9:( | 10:) | 11:- |
  /// 12:_ | 13:= | 14:+ | 15:[ | 16:] | 17:{ | 18:} | 19:| | 20:; | 21:: | 22:' |
  /// 23:" | 24:, | 25:. | 26:< | 27:> | 28:/ | 29:? | 30:` | 31:~
  static final CharacterDomain domSym = CharacterDomain(
    id: 'DOM_SYM',
    shortName: 'SYM',
    displayName: 'Symbols & Space',
    expectedModulus: 32,
    symbols: const <String>[
      ' ', '!', '@', '#', r'$', '%', '^', '&', '*', '(',
      ')', '-', '_', '=', '+', '[', ']', '{', '}', '|',
      ';', ':', "'", '"', ',', '.', '<', '>', '/', '?',
      '`', '~',
    ],
  );

  /// DOM_EMOJI (N = 20)
  /// 0:😀 | 1:😂 | 2:😎 | 3:😍 | 4:🤔 | 5:😭 | 6:😡 | 7:🥳 | 8:👍 | 9:👎 |
  /// 10:❤️ | 11:🔥 | 12:✨ | 13:🎉 | 14:🚀 | 15:💻 | 16:🔒 | 17:🔑 | 18:🛡️ | 19:⚡
  static final CharacterDomain domEmoji = CharacterDomain(
    id: 'DOM_EMOJI',
    shortName: 'EMOJI',
    displayName: 'Emojis',
    expectedModulus: 20,
    symbols: const <String>[
      '😀', '😂', '😎', '😍', '🤔', '😭', '😡', '🥳', '👍', '👎',
      '❤️', '🔥', '✨', '🎉', '🚀', '💻', '🔒', '🔑', '🛡️', '⚡',
    ],
  );

  /// Ordered list of all 10 mutually exclusive character domains.
  static final List<CharacterDomain> all = List<CharacterDomain>.unmodifiable([
    domAr,
    domEnUpper,
    domEnLower,
    domEsExt,
    domRu,
    domGr,
    domHe,
    domNum,
    domSym,
    domEmoji,
  ]);

  /// O(1) global lookup from any grapheme to its owning [CharacterDomain].
  static final Map<String, CharacterDomain> _graphemeToDomain = {
    for (final domain in all)
      for (final symbol in domain.symbols) symbol: domain,
  };

  /// Finds the [CharacterDomain] for a single [grapheme].
  ///
  /// When [preserveSpaces] is `true`, space `' '` is bypassed (returns `null`).
  /// When [preserveSpaces] is `false`, space `' '` resolves to [domSym] (index 0).
  static CharacterDomain? resolveDomain(
    String grapheme, {
    required bool preserveSpaces,
  }) {
    if (grapheme == ' ' && preserveSpaces) {
      return null;
    }
    return _graphemeToDomain[grapheme];
  }
}
