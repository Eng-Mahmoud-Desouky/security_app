import 'package:equatable/equatable.dart';
import '../../core/alphabets/character_domain.dart';
import '../entities/brute_force_candidate.dart';
import '../entities/cipher_process_result.dart';

/// Strategy interface for cryptographic cipher engines.
/// Enables seamless addition of weekly new ciphers without modifying presentation logic.
abstract class CipherEngine extends Equatable {
  const CipherEngine();

  /// Unique identifier for the cipher engine.
  String get id;

  /// Human-readable name displayed in the workspace header.
  String get name;

  /// Short mathematical description of the cipher.
  String get description;

  /// Detects all active [CharacterDomain]s present in [inputText]
  /// according to the [preserveSpaces] routing rule.
  List<CharacterDomain> detectDomains(
    String inputText, {
    required bool preserveSpaces,
  });

  /// Computes the maximum modulus M = max(N_detected), falling back to 36 if none detected.
  int calculateMaxModulus(List<CharacterDomain> detectedDomains);

  /// Encrypts [inputText] with integer shift [key].
  CipherProcessResult encrypt(
    String inputText, {
    required int key,
    required bool preserveSpaces,
  });

  /// Decrypts [inputText] with integer shift [key].
  CipherProcessResult decrypt(
    String inputText, {
    required int key,
    required bool preserveSpaces,
  });

  /// Generates Smart Brute-Force (Crack) candidates for K in [1 .. max(N_detected) - 1].
  List<BruteForceCandidate> crack(
    String inputText, {
    required bool preserveSpaces,
  });
}
