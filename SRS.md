# Multi-Domain Caesar Cipher Engine - SRS & Reference Spec

## 1. Core Functional Requirements
| ID | Requirement | Mathematical / Logic Rule | Purpose |
| :--- | :--- | :--- | :--- |
| **FR-01** | **Multi-Domain Alphabet Routing** | Per-character routing across 10 mutually exclusive character matrices ($N_D$). | Deterministic paper verification & multi-language support. |
| **FR-02** | **Encryption** | $C = ((P + K) \bmod N_D + N_D) \bmod N_D$ | Shift character index forward within its own domain $D$. |
| **FR-03** | **Decryption** | $P = ((C - K) \bmod N_D + N_D) \bmod N_D$ | Restore original character index handling negative shifts safely. |
| **FR-04** | **Smart Brute-Force (Crack)** | Iterate $K \in [1 \dots \max(N_{\text{detected}}) - 1]$ | Crack ciphertext without knowing $K$ based on detected domains. |
| **FR-05** | **Mathematical Trace Inspector** | Display per-grapheme table: `Char | Domain (N) | Index P | Formula | New Index C | Result` | 100% instant match with manual paper solution. |

## 2. Mutually Exclusive Character Domain Matrices (Strict Indexing 0 to N-1)
- **DOM_AR (N = 36):** `ابتثجحخدذرزسشصضطظعغفقكلمنهويأإآؤئءةى`
- **DOM_EN_UPPER (N = 26):** `ABCDEFGHIJKLMNOPQRSTUVWXYZ`
- **DOM_EN_LOWER (N = 26):** `abcdefghijklmnopqrstuvwxyz`
- **DOM_ES_EXT (N = 7):** `áéíóúüñ`
- **DOM_RU (N = 33):** `абвгдеёжзийклмнопрстуфхцчшщъыьэюя`
- **DOM_GR (N = 24):** `αβγδεζηθικλμνξοπρστυφχψω`
- **DOM_HE (N = 22):** `אבגדהוזחטיכלמנסעפצקרשת`
- **DOM_NUM (N = 10):** `0123456789`
- **DOM_SYM (N = 32):** ` !@#$%^&*()-_=+[]{}|;:'",.<>/?`~` *(Note: Index 0 is space `' '`)*
- **DOM_EMOJI (N = 20):** `😀😂😎😍🤔😭😡🥳👍👎❤️🔥✨🎉🚀💻🔒🔑🛡️⚡`

### Printed Index Reference Lookup (0 to N-1)
- **DOM_AR (36):** `0:ا | 1:ب | 2:ت | 3:ث | 4:ج | 5:ح | 6:خ | 7:د | 8:ذ | 9:ر | 10:ز | 11:س | 12:ش | 13:ص | 14:ض | 15:ط | 16:ظ | 17:ع | 18:غ | 19:ف | 20:ق | 21:ك | 22:ل | 23:م | 24:ن | 25:ه | 26:و | 27:ي | 28:أ | 29:إ | 30:آ | 31:ؤ | 32:ئ | 33:ء | 34:ة | 35:ى`
- **DOM_EN_UPPER (26):** `0:A | 1:B | 2:C | 3:D | 4:E | 5:F | 6:G | 7:H | 8:I | 9:J | 10:K | 11:L | 12:M | 13:N | 14:O | 15:P | 16:Q | 17:R | 18:S | 19:T | 20:U | 21:V | 22:W | 23:X | 24:Y | 25:Z`
- **DOM_EN_LOWER (26):** `0:a | 1:b | 2:c | 3:d | 4:e | 5:f | 6:g | 7:h | 8:i | 9:j | 10:k | 11:l | 12:m | 13:n | 14:o | 15:p | 16:q | 17:r | 18:s | 19:t | 20:u | 21:v | 22:w | 23:x | 24:y | 25:z`
- **DOM_ES_EXT (7):** `0:á | 1:é | 2:í | 3:ó | 4:ú | 5:ü | 6:ñ`
- **DOM_RU (33):** `0:а | 1:б | 2:в | 3:г | 4:д | 5:е | 6:ё | 7:ж | 8:з | 9:и | 10:й | 11:к | 12:л | 13:м | 14:н | 15:о | 16:п | 17:р | 18:с | 19:т | 20:у | 21:ф | 22:х | 23:ц | 24:ч | 25:ш | 26:щ | 27:ъ | 28:ы | 29:ь | 30:э | 31:ю | 32:я`
- **DOM_GR (24):** `0:α | 1:β | 2:γ | 3:δ | 4:ε | 5:ζ | 6:η | 7:θ | 8:ι | 9:κ | 10:λ | 11:μ | 12:ν | 13:ξ | 14:ο | 15:π | 16:ρ | 17:σ | 18:τ | 19:υ | 20:φ | 21:χ | 22:ψ | 23:ω`
- **DOM_HE (22):** `0:א | 1:ב | 2:ג | 3:ד | 4:ה | 5:ו | 6:ז | 7:ח | 8:ט | 9:י | 10:כ | 11:ל | 12:מ | 13:נ | 14:ס | 15:ע | 16:פ | 17:צ | 18:ק | 19:ר | 20:ש | 21:ת`
- **DOM_NUM (10):** `0:0 | 1:1 | 2:2 | 3:3 | 4:4 | 5:5 | 6:6 | 7:7 | 8:8 | 9:9`
- **DOM_SYM (32):** `0:' ' | 1:! | 2:@ | 3:# | 4:$ | 5:% | 6:^ | 7:& | 8:* | 9:( | 10:) | 11:- | 12:_ | 13:= | 14:+ | 15:[ | 16:] | 17:{ | 18:} | 19:| | 20:; | 21:: | 22:' | 23:" | 24:, | 25:. | 26:< | 27:> | 28:/ | 29:? | 30:` | 31:~`
- **DOM_EMOJI (20):** `0:😀 | 1:😂 | 2:😎 | 3:😍 | 4:🤔 | 5:😭 | 6:😡 | 7:🥳 | 8:👍 | 9:👎 | 10:❤️ | 11:🔥 | 12:✨ | 13:🎉 | 14:🚀 | 15:💻 | 16:🔒 | 17:🔑 | 18:🛡️ | 19:⚡`

## 3. User Stories & Acceptance Criteria
- **US-01 (User Input & Controls):**
  1. Multiline TextField supporting RTL/LTR mixed text with Copy, Paste, and Clear buttons.
  2. Controlled In-App Emoji Grid Picker (5x4 Modal Bottom Sheet or Popover triggered by an icon inside the TextField) displaying the exact 20 emojis from `DOM_EMOJI` with their index `0..19` underneath to prevent OS keyboard UTF-16 variation selector mismatches.
  3. Segmented Operation Selector: `Encrypt` | `Decrypt` | `Crack (Brute-Force)`.
  4. Integer Key Input with `+` / `-` stepper buttons (disabled/hidden in `Crack` mode).
  5. Toggle Switch: `"Preserve Spaces & Unknowns"` (Default: ON -> spaces `' '` and unknown characters bypass shifting and remain unchanged; OFF -> space is routed to `DOM_SYM` index 0).
- **US-02 (Grapheme-Aware Per-Character Routing):**
  1. MUST iterate over input text using Flutter's `characters` package (`input.characters`) so multi-byte emojis (like `❤️` or `🛡️`) are processed as single atomic graphemes.
  2. Each grapheme is matched against the predefined `CharacterDomain` list (Stored as explicit `List<String>` per domain, NOT raw String indexing).
- **US-03 (Smart Multi-Domain Brute-Force):**
  1. Detect active domains in the input text and display them as UI Badges (e.g., `AR (36)`, `EN_UPPER (26)`).
  2. Determine max bound $M = \max(N_{\text{detected}})$ (fallback to 36 if none detected) and generate candidate decryptions for $K \in [1 \dots M-1]$.
- **US-04 (Interactive Paper-Trace Inspector):**
  1. A dedicated tab/expandable view showing a clean data table of every character transformation: `Char`, `Domain (N)`, `Index P`, `Formula`, `New Index C`, `Result`.

## 4. Clean Architecture & Extensibility Structure
- `lib/core/alphabets/`: `CharacterDomain` entity and `PredefinedDomains` registry.
- `lib/domain/entities/`: `CharTraceStep`, `CipherProcessResult`, `BruteForceCandidate`.
- `lib/domain/ciphers/`: Abstract `CipherEngine` interface (Strategy Pattern for weekly new ciphers) and `CaesarCipherEngine` implementation.
- `lib/features/cipher_workspace/presentation/`: `CipherWorkspaceCubit` & `CipherWorkspaceState` (via `flutter_bloc` & `equatable`), Main Workspace Screen, Controlled Emoji Grid Sheet, Trace Table Widget, and Brute-Force Results List.