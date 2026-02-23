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
    "good": "మంచి",
    "cabbage": "క్యాబేజీ",
    "potato": "బంగాళాదుంప",
    "plumber": "ప్లంబర్",
    // 2) Added Translation for Add Service button
    "Add Your Service": "మీ సేవను జోడించండి",
  };

  // 1) Added form hints dictionary to ensure Telugu hints show correctly
  final Map<String, String> formHints = {
    "Ex: Ramesh": "ఉదాహరణ: రమేష్",
    "Ex: 9876543210": "ఉదాహరణ: 9876543210",
    "Ex: Tomato": "ఉదాహరణ: టమోటా",
    "Ex: 100 kg": "ఉదాహరణ: 100 కిలోలు",
    "Ex: ₹20 per kg": "ఉదాహరణ: కిలో రూ. 20",
    "Ex: Rayachoty": "ఉదాహరణ: రాయచోటి",
    "Ex: Fresh farm vegetables available":
        "ఉదాహరణ: తాజా పొలం కూరగాయలు అందుబాటులో ఉన్నాయి",
    "Ex: Sri Lakshmi Stores": "ఉదాహరణ: శ్రీ లక్ష్మి స్టోర్స్",
    "Ex: Venkatesh": "ఉదాహరణ: వెంకటేష్",
    "Ex: Grocery": "ఉదాహరణ: కిరాణా",
    "Ex: 9AM - 9PM": "ఉదాహరణ: ఉదయం 9 నుండి రాత్రి 9 వరకు",
    "Ex: All daily essentials available":
        "ఉదాహరణ: అన్ని నిత్యావసర వస్తువులు లభిస్తాయి",
    "Ex: Electrician": "ఉదాహరణ: ఎలక్ట్రీషియన్",
    "Ex: Raju": "ఉదాహరణ: రాజు",
    "Ex: 5 years": "ఉదాహరణ: 5 సంవత్సరాలు",
    "Ex: ₹500 per visit": "ఉదాహరణ: సందర్శనకు రూ. 500",
    "Ex: Home electrical repairs": "ఉదాహరణ: ఇంటి విద్యుత్ మరమ్మతులు",
    "Ex: Sales Executive": "ఉదాహరణ: సేల్స్ ఎగ్జిక్యూటివ్",
    "Ex: ABC Company": "ఉదాహరణ: ఏబీసీ కంపెనీ",
    "Ex: ₹15000 per month": "ఉదాహరణ: నెలకు రూ. 15000",
    "Ex: Degree": "ఉదాహరణ: డిగ్రీ",
    "Ex: Immediate joining required": "ఉదాహరణ: వెంటనే చేరాలి",
    "Ex: City Hospital": "ఉదాహరణ: సిటీ హాస్పిటల్",
    "Ex: Dr. Kumar": "ఉదాహరణ: డాక్టర్ కుమార్",
    "Ex: Cardiology": "ఉదాహరణ: కార్డియాలజీ",
    "Ex: 9AM - 6PM": "ఉదాహరణ: ఉదయం 9 నుండి సాయంత్రం 6 వరకు",
    "Ex: 24/7 emergency available":
        "ఉదాహరణ: 24/7 అత్యవసర సేవలు అందుబాటులో ఉన్నాయి",
    "Ex: Ambulance Service": "ఉదాహరణ: అంబులెన్స్ సేవ",
    "Ex: Ravi": "ఉదాహరణ: రవి",
    "Ex: 24/7": "ఉదాహరణ: 24/7",
    "Ex: Medical": "ఉదాహరణ: మెడికల్",
    "Ex: Fast response service": "ఉదాహరణ: వేగవంతమైన స్పందన సేవ",
    "Ex: Archana School": "ఉదాహరణ: అర్చన స్కూల్",
    "Ex: Mr. Reddy": "ఉదాహరణ: మిస్టర్ రెడ్డి",
    "Ex: 1-10": "ఉదాహరణ: 1-10 తరగతులు",
    "Ex: ₹5000": "ఉదాహరణ: రూ. 5000",
    "Ex: English medium school": "ఉదాహరణ: ఇంగ్లీష్ మీడియం స్కూల్",
    "Ex: Sri Balaji Hotel": "ఉదాహరణ: శ్రీ బాలాజీ హోటల్",
    "Ex: Veg / Non-Veg": "ఉదాహరణ: వెజ్ / నాన్-వెజ్",
    "Ex: ₹150 per meal": "ఉదాహరణ: భోజనం రూ. 150",
    "Ex: Home Delivery Available": "ఉదాహరణ: హోమ్ డెలివరీ కలదు",
    "Ex: Family restaurant": "ఉదాహరణ: ఫ్యామిలీ రెస్టారెంట్",
    "Ex: Used Bike": "ఉదాహరణ: పాత బైక్",
    "Ex: Vamshi": "ఉదాహరణ: వంశీ",
    "Ex: Good condition": "ఉదాహరణ: మంచి స్థితిలో ఉంది",
    "Ex: ₹25000": "ఉదాహరణ: రూ. 25000",
    "Ex: Well maintained vehicle": "ఉదాహరణ: బాగా నిర్వహించబడిన వాహనం",
    "Ex: 2BHK": "ఉదాహరణ: 2BHK",
    "Ex: ₹8000": "ఉదాహరణ: రూ. 8000",
    "Ex: ₹20000": "ఉదాహరణ: రూ. 20000",
    "Ex: Near bus stand": "ఉదాహరణ: బస్టాండ్ దగ్గర",
    "Ex: Swift Car": "ఉదాహరణ: స్విఫ్ట్ కారు",
    "Ex: Srinivas": "ఉదాహరణ: శ్రీనివాస్",
    "Ex: 2022 Model": "ఉదాహరణ: 2022 మోడల్",
    "Ex: ₹2000 per day": "ఉదాహరణ: రోజుకు రూ. 2000",
    "Ex: With driver available": "ఉదాహరణ: డ్రైవర్‌తో అందుబాటులో ఉంది",
  };

  /// Helper function: Detects if a string contains Telugu Unicode characters
  bool isTelugu(String text) {
    return RegExp(r'[\u0C00-\u0C7F]').hasMatch(text);
  }

  /// Helper function: Detect simple name-like strings or proper nouns
  bool isLikelyName(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    bool isSingleWord = !trimmed.contains(" ");
    bool startsWithCapital = trimmed.isNotEmpty &&
        trimmed[0] == trimmed[0].toUpperCase() &&
        trimmed[0] != trimmed[0].toLowerCase();

    return isSingleWord && startsWithCapital && trimmed.length <= 15;
  }

  /// Capitalize method for consistent formatting
  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Manual dictionary lookup
  String? _lookupManual(String text, String targetLang) {
    final trimmedLower = text.trim().toLowerCase();

    // Check formHints first for UI consistency
    if (targetLang == 'te' && formHints.containsKey(text)) {
      return formHints[text];
    }

    if (targetLang == 'te') {
      if (manualDictionary.containsKey(trimmedLower)) {
        return manualDictionary[trimmedLower];
      }
      if (manualDictionary.containsKey(text.trim())) {
        return manualDictionary[text.trim()];
      }
    } else if (targetLang == 'en') {
      for (var entry in manualDictionary.entries) {
        if (entry.value == text.trim()) {
          return entry.key;
        }
      }
      for (var entry in formHints.entries) {
        if (entry.value == text.trim()) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Enhanced translation logic with specific rule handling
  Future<String> translateText(
    String text,
    String targetLang, {
    bool isNameField = false,
    bool isDescription = false,
    bool isLocation = false,
  }) async {
    // 1) Capitalize input first
    String processedText = capitalize(text.trim());

    if (processedText.isEmpty) {
      return "";
    }

    // Rule: Numeric values / Phone numbers (10 digits) → Do not translate
    final numericRegex = RegExp(r'^[0-9\s₹\+\-\.,]+$');
    if (numericRegex.hasMatch(processedText)) {
      return processedText;
    }
    if (processedText.length == 10 &&
        RegExp(r'^[0-9]+$').hasMatch(processedText)) {
      return processedText;
    }

    // Rule 3: Manual dictionary has priority
    final manualMatch = _lookupManual(processedText, targetLang);
    if (manualMatch != null) {
      return manualMatch;
    }

    // DO NOT translate if already in Telugu and target is Telugu
    if (targetLang == 'te' && isTelugu(processedText)) {
      return processedText;
    }

    // Rule 1: Names → Transliterate only (Personal, Shop, Hospital, Owner)
    if (isNameField) {
      try {
        // transliterate name fields only (API-based transliteration hint)
        var translation =
            await _translator.translate(processedText, to: targetLang);
        return translation.text.trim();
      } catch (e) {
        return processedText;
      }
    }

    // Rule 2: Items like cabbage, potato, car, bike, plumber → API Full Translate
    try {
      var translation =
          await _translator.translate(processedText, to: targetLang);
      return translation.text.trim();
    } catch (e) {
      return processedText;
    }
  }

  /// Save-time translation logic (called once during submission)
  Future<Map<String, String>> translateAllFields(
      Map<String, String> fields, bool isInputEnglish) async {
    final Map<String, String> result = {};
    List<String> keys = fields.keys.toList();

    List<Future<String>> translationFutures = keys.map((key) {
      String text = fields[key] ?? "";
      String targetLang = isTelugu(text) ? 'en' : 'te';

      // Define logic based on field type
      // f1 and f3 are typically names (Owner, Shop, Hospital, Farmer)
      bool isNameFieldPosition = key == 'f1' || key == 'f3';
      bool isDescriptionField = key == 'desc';
      bool isLocationField = key == 'f6';

      return translateText(
        text,
        targetLang,
        isNameField: isNameFieldPosition,
        isDescription: isDescriptionField,
        isLocation: isLocationField,
      );
    }).toList();

    List<String> translatedTexts = await Future.wait(translationFutures);

    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      String original = capitalize((fields[key] ?? "").trim());
      String translated = translatedTexts[i].trim();

      // Ensure Rule 4: Stores both EN and TE fields properly
      if (isTelugu(original)) {
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

  /// Detects if a string contains Telugu Unicode characters
  bool _isTelugu(String text) {
    return isTelugu(text);
  }

  /// Detect simple name-like strings (hari, madana, ramesh)
  bool _looksLikeName(String text) {
    return isLikelyName(text);
  }
}
