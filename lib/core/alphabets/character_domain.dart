import 'package:equatable/equatable.dart';

/// Represents a mutually exclusive character domain matrix with strict 0 to N-1 indexing.
class CharacterDomain extends Equatable {
  final String id;
  final String shortName;
  final String displayName;
  final List<String> symbols;
  final Map<String, int> _indexLookup;

  CharacterDomain({
    required this.id,
    required this.shortName,
    required this.displayName,
    required List<String> symbols,
    required int expectedModulus,
  })  : assert(
          symbols.length == expectedModulus,
          'Domain $id expected $expectedModulus symbols, but got ${symbols.length}.',
        ),
        symbols = List<String>.unmodifiable(symbols),
        _indexLookup = {
          for (int i = 0; i < symbols.length; i++) symbols[i]: i,
        };

  /// Modulus N_D of this character domain.
  int get modulus => symbols.length;

  /// Badge label formatted as e.g. "AR (36)" or "EN_UPPER (26)".
  String get badgeLabel => '$shortName ($modulus)';

  /// Returns the 0-based index of [grapheme] in this domain, or null if not present.
  int? indexOf(String grapheme) => _indexLookup[grapheme];

  /// Returns true if [grapheme] belongs to this domain.
  bool contains(String grapheme) => _indexLookup.containsKey(grapheme);

  /// Returns the symbol at [index] (must be within 0..modulus-1).
  String symbolAt(int index) => symbols[index];

  @override
  List<Object?> get props => [id, shortName, displayName, symbols];
}
