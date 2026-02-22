import 'package:translator/translator.dart';

class TranslationService {
  final _translator = GoogleTranslator();

  // Manual Dictionary Map for specific overrides
  final Map<String, String> manualDictionary = {
    "rayachoty": "రాయచోటి",
    "vehicle": "వాహనం",
    "bike": "బైక్",
    "car": "కారు",
    "tractor": "ట్రాక్టర్",
    "auto": "ఆటో",
    "good": "మంచి"
  };

  /// Detects if a string contains Telugu Unicode characters
  bool _isTelugu(String text) {
    return RegExp(r'[\u0C00-\u0C7F]').hasMatch(text);
  }

  /// Detect simple name-like strings (hari, madana, ramesh)
  bool _looksLikeName(String text) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(text) &&
        text.length <= 15 &&
        !text.contains(" ");
  }

  /// Manual dictionary lookup
  String? _lookupManual(String text, String targetLang) {
    final trimmedLower = text.trim().toLowerCase();

    if (targetLang == 'te') {
      if (manualDictionary.containsKey(trimmedLower)) {
        return manualDictionary[trimmedLower];
      }
    } else if (targetLang == 'en') {
      for (var entry in manualDictionary.entries) {
        if (entry.value == text.trim()) {
          return entry.key;
        }
      }
    }
    return null;
  }

  Future<String> translateText(
    String text,
    String targetLang, {
    bool isNameField = false,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return "";
    }

    // 1️⃣ Manual dictionary first
    final manualMatch = _lookupManual(trimmedText, targetLang);
    if (manualMatch != null) {
      return manualMatch;
    }

    // 2️⃣ If this is name-like and target is Telugu,
    // use Google but prevent meaning distortion
    try {
      var translation =
          await _translator.translate(trimmedText, to: targetLang);

      String translated = translation.text.trim();

      // Protect name fields
      if (targetLang == 'te' && (isNameField || _looksLikeName(trimmedText))) {
        return translated;
      }

      return translated;
    } catch (e) {
      return trimmedText;
    }
  }

  Future<Map<String, String>> translateAllFields(
      Map<String, String> fields, bool isInputEnglish) async {
    final Map<String, String> result = {};
    List<String> keys = fields.keys.toList();

    List<Future<String>> translationFutures = keys.map((key) {
      String text = fields[key] ?? "";

      // Detect language dynamically
      String targetLang = _isTelugu(text) ? 'en' : 'te';

      // Apply name rule only to f1 and f2 (Title & Principal/Owner)
      bool isNameField = key == 'f1' || key == 'f2';

      return translateText(
        text,
        targetLang,
        isNameField: isNameField,
      );
    }).toList();

    List<String> translatedTexts = await Future.wait(translationFutures);

    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      String original = (fields[key] ?? "").trim();
      String translated = translatedTexts[i].trim();

      if (_isTelugu(original)) {
        result['${key}_te'] = original;
        result['${key}_en'] = translated;
      } else {
        result['${key}_en'] = original;
        result['${key}_te'] = translated;
      }
    }

    // Ensure mandatory keys exist
    final requiredKeys = ['f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'desc'];
    for (var rk in requiredKeys) {
      if (!result.containsKey('${rk}_en')) result['${rk}_en'] = "";
      if (!result.containsKey('${rk}_te')) result['${rk}_te'] = "";
    }

    return result;
  }
}
