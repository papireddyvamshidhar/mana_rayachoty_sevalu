import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
// REFACTOR IMPORTS
import 'package:mana_rayachoty_sevalu/models/listing_model.dart';
import 'package:mana_rayachoty_sevalu/services/firebase_service.dart';
import 'package:mana_rayachoty_sevalu/services/translation_service.dart';

// Global Instances
final FirebaseService firebaseService = FirebaseService();
final TranslationService translationService = TranslationService();
bool isAdminLoggedIn = false;
String currentLanguage = "Telugu";
bool isDarkMode = false;

// ==================================================
// ANDHRA / RAYALASEEMA PRO EMOJI KEYWORD ENGINE
// ==================================================

final Map<String, String> andhraEmojiKeywords = {
  // ================= FRUITS =================
  "mango": "🥭", "mamidi": "🥭", "మామిడి": "🥭",
  "banana": "🍌", "arati": "🍌", "అరటి": "🍌",
  "papaya": "🍈", "boppayi": "🍈", "బొప్పాయి": "🍈",
  "grapes": "🍇", "draksha": "🍇", "ద్రాక్ష": "🍇",
  "watermelon": "🍉", "puchakaya": "🍉", "పుచ్చకాయ": "🍉",
  "guava": "🍏", "jama": "🍏", "జామ": "🍏",
  "sapota": "🍑", "chikoo": "🍑", "చిక్కూ": "🍑",
  "custard apple": "🍏", "sitaphalam": "🍏", "సీతాఫలం": "🍏",
  "coconut": "🥥", "kobbari": "🥥", "కొబ్బరి": "🥥",
  "orange": "🍊", "narinja": "🍊", "నారింజ": "🍊",

  // ================= VEGETABLES =================
  "tomato": "🍅", "టమోటా": "🍅",
  "potato": "🥔", "ఆలుగడ్డ": "🥔",
  "onion": "🧅", "ఉల్లిపాయ": "🧅",
  "brinjal": "🍆", "vankaya": "🍆", "వంకాయ": "🍆",
  "chilli": "🌶️", "mirchi": "🌶️", "మిర్చి": "🌶️",
  "carrot": "🥕", "క్యారెట్": "🥕",
  "cucumber": "🥒", "dosakaya": "🥒", "దోసకాయ": "🥒",
  "drumstick": "🥒", "munagakaya": "🥒", "మునగకాయ": "🥒",
  "ridge gourd": "🥒", "beerakaya": "🥒", "బీరకాయ": "🥒",
  "bottle gourd": "🥒", "sorakaya": "🥒", "సొరకాయ": "🥒",
  "lady finger": "🌿", "bendakaya": "🌿", "బెండకాయ": "🌿",
  "cabbage": "🥬",
  "cauliflower": "🥦",

  // ================= FLOWERS =================
  "jasmine": "🌼", "malle": "🌼", "మల్లె": "🌼",
  "rose": "🌹", "gulabi": "🌹", "గులాబీ": "🌹",
  "lotus": "🪷", "tamara": "🪷", "తామర": "🪷",
  "marigold": "🌼", "banthi": "🌼", "బంతి": "🌼",
  "sunflower": "🌻", "mandaram": "🌺",

  // ================= GRAINS & CROPS =================
  "rice": "🍚", "paddy": "🌾", "vari": "🌾", "వరి": "🌾",
  "groundnut": "🥜", "pallelu": "🥜", "పల్లీలు": "🥜",
  "maize": "🌽", "mokajonna": "🌽", "మొక్కజొన్న": "🌽",
  "ragi": "🌾", "ragulu": "🌾",
  "cotton": "🌾", "patti": "🌾", "పత్తి": "🌾",
  "sunflower seeds": "🌻",

  // ================= SERVICES =================
  "teacher": "👨‍🏫", "టీచర్": "👨‍🏫",
  "electrician": "💡", "ఎలక్ట్రిషియన్": "💡",
  "plumber": "🚿", "ప్లంబర్": "🚿",
  "mechanic": "🔧", "మెకానిక్": "🔧",
  "carpenter": "🪚", "కార్పెంటర్": "🪚",
  "mason": "🧱", "మేస్త్రీ": "🧱",
  "painter": "🖌️",
  "driver": "🚕",
  "tailor": "🧵",
  "salon": "💇", "beauty": "💄",
  "mobile repair": "📱",
  "computer repair": "💻",
  "ac repair": "❄️",
  "bore repair": "🚰",

  // ================= VEHICLES =================
  "auto": "🛺", "ఆటో": "🛺",
  "car": "🚗", "కారు": "🚗",
  "bike": "🏍️", "బైక్": "🏍️",
  "tractor": "🚜", "ట్రాక్టర్": "🚜",
  "jcb": "🏗️",
  "lorry": "🚛",

  // ================= RESTAURANT =================
  "biryani": "🍗",
  "meals": "🍛",
  "veg": "🥦",
  "non veg": "🍖",
  "tiffin": "🥞",
  "tea": "☕",
  "coffee": "☕",

  // ================= LOANS =================
  "gold loan": "👑",
  "personal loan": "💰",
  "business loan": "🏢",
  "home loan": "🏠",
  "finance": "🏦",

  // ================= OLD GOODS =================
  "furniture": "🛋️",
  "tv": "📺",
  "fridge": "🧊",
  "books": "📚",
};

// 🔥 PRE-SORTED KEYWORDS (Longest first match priority)
final List<MapEntry<String, String>> sortedAndhraKeywords =
    andhraEmojiKeywords.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

String getFinalEmoji(
  String f1,
  String subCategory,
  String category,
  String f4,
  String f3,
) {
  final text = ("$f1 $f3 $f4 $subCategory $category").toLowerCase();

  // 🔥 Longest keyword match first
  for (final entry in sortedAndhraKeywords) {
    if (text.contains(entry.key)) {
      return entry.value;
    }
  }

  // Subcategory fallback
  if (strictSubCategoryEmoji.containsKey(subCategory)) {
    return strictSubCategoryEmoji[subCategory]!;
  }

  // Category fallback
  switch (category) {
    case "Farmers":
      return "👨‍🌾";
    case "Services":
      return "🛠";
    case "Restaurant":
      return "🍔";
    case "Jobs":
      return "💼";
    case "Hospitals":
      return "🏥";
    case "Loans":
      return "🏦";
    case "Movies":
      return "🎬";
    case "Vehicle Rentals":
      return "🚗";
    default:
      return "📂";
  }
}

// ==================================================
// 1. CATEGORY LABELS (STRICT SYNC - FINAL SAFE)
// ==================================================

Map<String, List<String>> categoryLabels = {
  "Farmers": [
    "Farmer Name", // f1
    "Phone", // f2
    "Crop Name", // f3
    "Description", // f4
    "Price", // f5
    "Location" // f6
  ],
  "Shops": ["Shop Name", "Phone", "Owner Name", "Description", "Location"],
  "Services": [
    "Provider Name", // 🔥 Changed from Service Name
    "Phone",
    "Service Type",
    "Description",
    "Charges",
    "Location"
  ],
  "Schools": ["School Name", "Phone", "Classes", "Description", "Location"],
  "Jobs": [
    "Job Title",
    "Phone",
    "Company Name", // 🔥 Added Company Name
    "Experience", // 🔥 Kept Experience
    "Salary",
    "Location"
  ],
  "Hospitals": [
    "Hospital Name",
    "Phone",
    "Speciality",
    "Description",
    "Timings",
    "Location"
  ],
  "Emergency": [
    "Service Name",
    "Phone",
    "Contact Person",
    "Description",
    "Location"
  ],
  "Hotels": [
    "Hotel Name",
    "Phone",
    "Food Type",
    "Description",
    "Price",
    "Location"
  ],
  "Old Goods": [
    "Item Name",
    "Phone",
    "Condition",
    "Description",
    "Price",
    "Location"
  ],
  "House Rent": [
    "Owner Name",
    "Phone",
    "House Type",
    "Description",
    "Rent",
    "Location"
  ],
  "Vehicle Rentals": [
    "Vehicle Name",
    "Phone",
    "Model",
    "Description",
    "Price",
    "Location"
  ],
  "AP Sevalu": [
    "Service Name",
    "Phone",
    "Official Link",
    "Description",
    "Location"
  ],
  "Restaurant": [
    "Restaurant Name",
    "Phone",
    "Specialty",
    "Description",
    "Min Price",
    "Location"
  ],
  "Hotel Rooms": [
    "Hotel Name",
    "Phone",
    "Room Type",
    "Description",
    "Price",
    "Location"
  ],
  "Hostel": ["Hostel Name", "Phone", "Type", "Description", "Rent", "Location"],
  "Movies": ["Theater Name", "Movie Name"],
  "Events": [
    "Event Name",
    "Phone",
    "Date",
    "Description",
    "Entry Fee",
    "Location"
  ],
  "Blood Donor": [
    "Donor Name",
    "Phone",
    "Blood Group",
    "Description",
    "Location"
  ],
  "Loans": [
    "Finance Name",
    "Phone",
    "Loan Type",
    "Description",
    "Interest Rate",
    "Location"
  ],
};

Map<String, List<String>> categoryLabelsTe = {
  "Farmers": ["రైతు పేరు", "ఫోన్", "పంట పేరు", "వివరణ", "ధర", "స్థలం"],
  "Shops": ["దుకాణం పేరు", "ఫోన్", "యజమాని పేరు", "వివరణ", "స్థలం"],
  "Services": [
    "వ్యక్తి పేరు",
    "ఫోన్",
    "సేవ రకం",
    "వివరణ",
    "చార్జీలు",
    "స్థలం"
  ], // 🔥 Changed సేవ పేరు to వ్యక్తి పేరు
  "Schools": ["పాఠశాల పేరు", "ఫోన్", "తరగతులు", "వివరణ", "స్థలం"],
  "Jobs": [
    "ఉద్యోగ శీర్షిక",
    "ఫోన్",
    "కంపెనీ పేరు",
    "అనుభవం",
    "జీతం",
    "స్థలం"
  ], // 🔥 Updated Telugu Jobs
  "Hospitals": [
    "ఆసుపత్రి పేరు",
    "ఫోన్",
    "ప్రత్యేకత",
    "వివరణ",
    "సమయాలు",
    "స్థలం"
  ],
  "Emergency": ["సేవ పేరు", "ఫోన్", "సంప్రదింపు వ్యక్తి", "వివరణ", "స్థలం"],
  "Hotels": ["హోటల్ పేరు", "ఫోన్", "ఆహార రకం", "వివరణ", "ధర", "స్థలం"],
  "Old Goods": ["వస్తువు పేరు", "ఫోన్", "స్థితి", "వివరణ", "ధర", "స్థలం"],
  "House Rent": ["యజమాని పేరు", "ఫోన్", "ఇల్లు రకం", "వివరణ", "అద్దె", "స్థలం"],
  "Vehicle Rentals": ["వాహనం పేరు", "ఫోన్", "మోడల్", "వివరణ", "ధర", "స్థలం"],
  "AP Sevalu": ["సేవ పేరు", "ఫోన్", "లింక్", "వివరణ", "స్థలం"],
  "Restaurant": [
    "రెస్టారెంట్ పేరు",
    "ఫోన్",
    "ప్రత్యేకత",
    "వివరణ",
    "కనిష్ట ధర",
    "స్థలం"
  ],
  "Hotel Rooms": ["హోటల్ పేరు", "ఫోన్", "గది రకం", "వివరణ", "ధర", "స్థలం"],
  "Hostel": ["హాస్టల్ పేరు", "ఫోన్", "రకం", "వివరణ", "అద్దె", "స్థలం"],
  "Movies": ["థియేటర్ పేరు", "సినిమా పేరు"],
  "Events": ["ఈవెంట్ పేరు", "ఫోన్", "తేదీ", "వివరణ", "ప్రవేశ రుసుము", "స్థలం"],
  "Blood Donor": ["దాత పేరు", "ఫోన్", "రక్త గ్రూప్", "వివరణ", "స్థలం"],
  "Loans": [
    "ఫైనాన్స్ పేరు",
    "ఫోన్",
    "లోన్ రకం",
    "వివరణ",
    "వడ్డీ రేటు",
    "స్థలం"
  ],
};
// ==================================================
// 2. CATEGORY HINTS (PERFECT 1:1 SYNC WITH LABELS)
// ==================================================
Map<String, List<String>> categoryHintsEn = {
  "Farmers": [
    "Ex: Ramesh",
    "Ex: 9876543210",
    "Ex: Tomato",
    "Ex: Fresh organic crop",
    "Ex: 20 per KG",
    "Ex: Rayachoty"
  ],
  "Shops": [
    "Ex: Lakshmi Stores",
    "Ex: 9876543210",
    "Ex: Venkatesh",
    "Ex: Groceries & daily needs",
    "Ex: Rayachoty"
  ],
  "Services": [
    "Ex: Raju",
    "Ex: 9876543210",
    "Ex: Plumbing",
    "Ex: Tap repair & pipe fitting",
    "Ex: 500 per Service",
    "Ex: Rayachoty"
  ],
  "Schools": [
    "Ex: Archana School",
    "Ex: 9876543210",
    "Ex: LKG to 10th",
    "Ex: English Medium",
    "Ex: Rayachoty"
  ],
  "Jobs": [
    "Ex: Sales Executive",
    "Ex: 9876543210",
    "Ex: Reliance",
    "Ex: 2 Years",
    "Ex: 15000 per Month",
    "Ex: Rayachoty"
  ],
  "Hospitals": [
    "Ex: City Clinic",
    "Ex: 9876543210",
    "Ex: General Medicine",
    "Ex: Expert care",
    "Ex: 24/7",
    "Ex: Rayachoty"
  ],
  "Emergency": [
    "Ex: Ambulance",
    "Ex: 108",
    "Ex: Ravi",
    "Ex: Fast response",
    "Ex: Rayachoty"
  ],
  "Hotels": [
    "Ex: Balaji Hotel",
    "Ex: 9876543210",
    "Ex: Veg Meals",
    "Ex: Family restaurant",
    "Ex: 150 per Plate",
    "Ex: Rayachoty"
  ],
  "Old Goods": [
    "Ex: Honda Activa",
    "Ex: 9876543210",
    "Ex: Good Condition",
    "Ex: 2021 Model, smooth engine",
    "Ex: 25000",
    "Ex: Rayachoty"
  ],
  "House Rent": [
    "Ex: Raja",
    "Ex: 9876543210",
    "Ex: 2BHK",
    "Ex: Near bus stand, water facility",
    "Ex: 8000 per Month",
    "Ex: Rayachoty"
  ],
  "Vehicle Rentals": [
    "Ex: Swift Dzire",
    "Ex: 9876543210",
    "Ex: 2022 AC",
    "Ex: Available with driver",
    "Ex: 2000 per Day",
    "Ex: Rayachoty"
  ],
  "AP Sevalu": [
    "Ex: MeeSeva",
    "Ex: 9876543210",
    "Ex: ap.gov.in",
    "Ex: Certificate services",
    "Ex: Rayachoty"
  ],
  "Restaurant": [
    "Ex: Food Court",
    "Ex: 9876543210",
    "Ex: Biryani",
    "Ex: Tasty & hygienic",
    "Ex: 100 per Item",
    "Ex: Rayachoty"
  ],
  "Hotel Rooms": [
    "Ex: Royal Inn",
    "Ex: 9876543210",
    "Ex: AC Double Bed",
    "Ex: Clean rooms with WiFi",
    "Ex: 1200 per Day",
    "Ex: Rayachoty"
  ],
  "Hostel": [
    "Ex: SR Boys Hostel",
    "Ex: 9876543210",
    "Ex: Boys",
    "Ex: 3 times food, safe",
    "Ex: 5000 per Month",
    "Ex: Rayachoty"
  ],
  "Movies": ["Ex: Sai Theatre", "Ex: Game Changer"],
  "Events": [
    "Ex: Agriculture Fair",
    "Ex: 9876543210",
    "Ex: Jan 20th",
    "Ex: Seeds and tools expo",
    "Ex: 50 per Head",
    "Ex: Rayachoty"
  ],
  "Blood Donor": [
    "Ex: Kalyan",
    "Ex: 9876543210",
    "Ex: O+",
    "Ex: Ready to donate anytime",
    "Ex: Rayachoty"
  ],
  "Loans": [
    "Ex: Vamshi Finance",
    "Ex: 9876543210",
    "Ex: Gold Loan",
    "Ex: Instant cash approval",
    "Ex: 2% per Month",
    "Ex: Rayachoty"
  ],
};

Map<String, List<String>> categoryHintsTe = {
  "Farmers": [
    "ఉదా: రమేష్",
    "9876543210",
    "టమోటా",
    "తాజా సేంద్రియ పంట",
    "కిలో 20",
    "రాయచోటి"
  ],
  "Shops": [
    "లక్ష్మి స్టోర్స్",
    "9876543210",
    "వెంకటేష్",
    "కిరాణా & నిత్యావసరాలు",
    "రాయచోటి"
  ],
  "Services": [
    "రాజు",
    "9876543210",
    "ప్లంబింగ్",
    "పైపుల మరమ్మత్తు",
    "సర్వీస్‌కి 500",
    "రాయచోటి"
  ],
  "Schools": [
    "అర్చన స్కూల్",
    "9876543210",
    "LKG నుండి 10వ తరగతి",
    "ఇంగ్లీష్ మీడియం",
    "రాయచోటి"
  ],
  "Jobs": [
    "సేల్స్ ఎగ్జిక్యూటివ్",
    "9876543210",
    "రిలయన్స్",
    "2 ఏళ్లు",
    "నెలకు 15000",
    "రాయచోటి"
  ],
  "Hospitals": [
    "సిటీ క్లినిక్",
    "9876543210",
    "జనరల్ మెడిసిన్",
    "మంచి వైద్యం",
    "24/7",
    "రాయచోటి"
  ],
  "Emergency": ["అంబులెన్స్", "108", "రవి", "వెంటనే వస్తాము", "రాయచోటి"],
  "Hotels": [
    "బాలాజీ హోటల్",
    "9876543210",
    "వెజ్ మీల్స్",
    "ఫ్యామిలీ రెస్టారెంట్",
    "ప్లేట్ 150",
    "రాయచోటి"
  ],
  "Old Goods": [
    "హోండా యాక్టివా",
    "9876543210",
    "మంచి కండిషన్",
    "2021 మోడల్",
    "25000",
    "రాయచోటి"
  ],
  "House Rent": [
    "రాజా",
    "9876543210",
    "2BHK",
    "బస్టాండ్ దగ్గర",
    "నెలకు 8000",
    "రాయచోటి"
  ],
  "Vehicle Rentals": [
    "స్విఫ్ట్ డిజైర్",
    "9876543210",
    "2022 ఏసీ",
    "డ్రైవర్ తో అందుబాటులో",
    "రోజుకు 2000",
    "రాయచోటి"
  ],
  "AP Sevalu": [
    "మీసేవ",
    "9876543210",
    "ap.gov.in",
    "సర్టిఫికేట్ సేవలు",
    "రాయచోటి"
  ],
  "Restaurant": [
    "ఫుడ్ కోర్ట్",
    "9876543210",
    "బిర్యానీ",
    "రుచికరమైనది",
    "ఐటమ్ 100",
    "రాయచోటి"
  ],
  "Hotel Rooms": [
    "రాయల్ ఇన్",
    "9876543210",
    "ఏసీ డబుల్ బెడ్",
    "వైఫై మరియు శుభ్రమైన గదులు",
    "రోజుకు 1200",
    "రాయచోటి"
  ],
  "Hostel": [
    "SR బాయ్స్ హాస్టల్",
    "9876543210",
    "బాయ్స్",
    "3 పూటల భోజనం, భద్రత",
    "నెలకు 5000",
    "రాయచోటి"
  ],
  "Movies": ["సాయి థియేటర్", "గేమ్ ఛేంజర్"],
  "Events": [
    "వ్యవసాయ ప్రదర్శన",
    "9876543210",
    "జనవరి 20",
    "విత్తనాల ప్రదర్శన",
    "మనిషికి 50",
    "రాయచోటి"
  ],
  "Blood Donor": ["కళ్యాణ్", "9876543210", "O+", "ఎప్పుడైనా సిద్ధం", "రాయచోటి"],
  "Loans": [
    "వంశీ ఫైనాన్స్",
    "9876543210",
    "గోల్డ్ లోన్",
    "వెంటనే నగదు",
    "నెలకు 2%",
    "రాయచోటి"
  ],
};

// ==================================================
// 4. SUBCATEGORY AUTO DETECTION (RESTORED SAFE)
// ==================================================
String detectSubCategory(String name, String desc) {
  String combined = ("$name $desc").toLowerCase();

  if (combined.contains("apple") ||
      combined.contains("mango") ||
      combined.contains("fruit") ||
      combined.contains("పండు")) {
    return "Fruits";
  }

  if (combined.contains("tomato") ||
      combined.contains("potato") ||
      combined.contains("veg") ||
      combined.contains("కూర")) {
    return "Vegetables";
  }

  if (combined.contains("rice") ||
      combined.contains("grain") ||
      combined.contains("ధాన్యం")) {
    return "Grains";
  }

  if (combined.contains("electrician") ||
      combined.contains("light") ||
      combined.contains("ఎలక్ట్రిషియన్")) {
    return "Electrician";
  }

  if (combined.contains("plumber") ||
      combined.contains("tap") ||
      combined.contains("ప్లంబర్")) {
    return "Plumber";
  }

  return "Other";
}

// ==================================================
// AUTO CAPITALIZE TEXT FUNCTION (TITLE CASE)
// ==================================================
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

// ==================================================
// 4. SMART PRICE UNIT SYSTEM (STRICT RULES)
// ==================================================
String formatPriceWithUnit(String price, String category, bool isEng) {
  if (price.isEmpty) return "";

  // 1. Rules for categories that DO NOT use a price display
  const noPriceCategories = [
    "Shops",
    "Schools",
    "Blood Donor",
    "AP Sevalu",
    "Movies",
    "Emergency"
  ];
  if (noPriceCategories.contains(category)) return "";

  // 2. Prevent double-formatting
  bool hasUnit = price.contains("/") ||
      price.contains("%") ||
      price.contains("per") ||
      price.contains("కిలో") ||
      price.contains("రోజు") ||
      price.contains("గంట") ||
      price.contains("నెల") ||
      price.contains("Visit");

  if (hasUnit) {
    if (category == "Loans" || price.contains("%")) return price;
    if (!price.contains("₹")) return "₹$price";
    return price;
  }

  // 3. Automatic Unit Assignment based on Category
  String unit = "";
  if (category == "Farmers") {
    unit = isEng ? " / KG" : " / కిలో";
  } else if (category == "Jobs" ||
      category == "House Rent" ||
      category == "Hostel") {
    unit = isEng ? " / Month" : " / నెల";
  } else if (category == "Hospitals") {
    unit = isEng ? " / Visit" : " / విజిట్";
  } else if (category == "Hotel Rooms" || category == "Vehicle Rentals") {
    unit = isEng ? " / Day" : " / రోజు";
  } else if (category == "Events") {
    unit = isEng ? " / Entry" : " / ప్రవేశం";
  } else if (category == "Restaurant") {
    return isEng ? "Starting ₹$price" : "ప్రారంభం ₹$price";
  } else if (category == "Loans") {
    return price.contains("%") ? price : "$price%"; // Handles Loans correctly
  } else if (category == "Services" || category == "Old Goods") {
    return "₹$price"; // Handles mechanics, plumbers, bikes etc
  }

  return "₹$price$unit";
}

// ==================================================
// 5. MAIN ENTRY POINT
// ==================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.playIntegrity);
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  SharedPreferences prefs = await SharedPreferences.getInstance();

  currentLanguage = prefs.getString('selected_language') ?? "Telugu";

// 🔥 RESTORE ADMIN SESSION
  isAdminLoggedIn = prefs.getBool('isAdmin') ?? false;

  runApp(const RayachotySevaluApp());
}

class RayachotySevaluApp extends StatefulWidget {
  const RayachotySevaluApp({super.key});
  @override
  State<RayachotySevaluApp> createState() => _RayachotySevaluAppState();
}

class _RayachotySevaluAppState extends State<RayachotySevaluApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
          useMaterial3: true,
          textTheme:
              GoogleFonts.notoSansTeluguTextTheme(Theme.of(context).textTheme),
          primaryColor: const Color(0xFF673AB7),
          scaffoldBackgroundColor: Colors.white),
      home:
          const DashboardScreen(), // 🔥 డైరెక్ట్ గా డ్యాష్‌బోర్డ్ కి వెళ్తుంది
    );
  }
}

const Map<String, String> categoryMap = {
  "Emergency": "అత్యవసరం",
  "Farmers": "రైతులు",
  "Shops": "దుకాణాలు",
  "Services": "సేవలు",
  "Jobs": "ఉద్యోగాలు",
  "Hospitals": "ఆసుపత్రులు",
  "Schools": "పాఠశాలలు",
  "Hotels": "హోటళ్ళు",
  "Old Goods": "పాత వస్తువులు",
  "House Rent": "ఇల్లు అద్దె",
  "Vehicle Rentals": "వాహనాలు",
  "AP Sevalu": "ఏపీ సేవలు",
  "Restaurant": "రెస్టారెంట్",
  "Hotel Rooms": "గదులు",
  "Hostel": "హాస్టల్",
  "Movies": "సినిమాలు",
  "Events": "ఈవెంట్స్",
  "Blood Donor": "రక్తదాతలు",
  "Loans": "రుణాలు",
};

String getCategory(String category) {
  if (currentLanguage == "Telugu") return categoryMap[category] ?? category;
  return category;
}

// ==================================================
// 6. DASHBOARD SCREEN (OPTIMIZED + FULL FEATURE RESTORED)
// ==================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> categories = const [
    {
      "title": "Emergency",
      "telugu": "అత్యవసరం",
      "icon": Icons.warning,
      "color": Color(0xFFF3E5F5),
      "iconColor": Colors.purple
    },
    {
      "title": "Farmers",
      "telugu": "రైతులు",
      "isEmoji": true,
      "emoji": "👨‍🌾", // 🔥 ఇక్కడ యాపిల్ కి బదులు ఫార్మర్ పెట్టాను
      "color": Color(0xFFE8F5E9),
      "iconColor": Colors.green
    },
    {
      "title": "AP Sevalu",
      "telugu": "ఏపీ సేవలు",
      "icon": Icons.account_balance,
      "color": Color(0xFFE8F5E9),
      "iconColor": Colors.green
    },
    {
      "title": "Old Goods",
      "telugu": "పాత వస్తువులు",
      "icon": Icons.recycling,
      "color": Color(0xFFEFEBE9),
      "iconColor": Colors.brown
    },
    {
      "title": "House Rent",
      "telugu": "ఇల్లు అద్దె",
      "icon": Icons.home,
      "color": Color(0xFFF1F8E9),
      "iconColor": Colors.lightGreen
    },
    {
      "title": "Services",
      "telugu": "సేవలు",
      "isEmoji": true,
      "emoji": "👨‍🔧",
      "color": Color(0xFFE3F2FD),
      "iconColor": Colors.blue
    },
    {
      "title": "Vehicle Rentals",
      "telugu": "వాహనాలు",
      "icon": Icons.directions_car,
      "color": Color(0xFFE8EAF6),
      "iconColor": Colors.indigo
    },
    {
      "title": "Shops",
      "telugu": "దుకాణాలు",
      "icon": Icons.store,
      "color": Color(0xFFFFF3E0),
      "iconColor": Colors.orange
    },
    {
      "title": "Jobs",
      "telugu": "ఉద్యోగాలు",
      "icon": Icons.work,
      "color": Color(0xFFE0F2F1),
      "iconColor": Colors.teal
    },
    {
      "title": "Hospitals",
      "telugu": "ఆసుపత్రులు",
      "icon": Icons.local_hospital,
      "color": Color(0xFFFFEBEE),
      "iconColor": Colors.red
    },
    {
      "title": "Schools",
      "telugu": "పాఠశాలలు",
      "icon": Icons.school,
      "color": Color(0xFFFFF8E1),
      "iconColor": Colors.amber
    },
    {
      "title": "Restaurant",
      "telugu": "రెస్టారెంట్",
      "isEmoji": true,
      "emoji": "🍔",
      "color": Color(0xFFFFF3E0),
      "iconColor": Colors.deepOrange
    },
    {
      "title": "Hotel Rooms",
      "telugu": "గదులు",
      "isEmoji": true,
      "emoji": "🛌",
      "color": Color(0xFFE3F2FD),
      "iconColor": Colors.blue
    },
    {
      "title": "Hostel",
      "telugu": "హాస్టల్",
      "icon": Icons.apartment,
      "color": Color(0xFFF1F8E9),
      "iconColor": Colors.lightGreen
    },
    {
      "title": "Movies",
      "telugu": "సినిమాలు",
      "icon": Icons.movie,
      "color": Color(0xFFFCE4EC),
      "iconColor": Colors.pink
    },
    {
      "title": "Events",
      "telugu": "ఈవెంట్స్",
      "icon": Icons.event,
      "color": Color(0xFFEDE7F6),
      "iconColor": Colors.purple
    },
    {
      "title": "Blood Donor",
      "telugu": "రక్తదాతలు",
      "icon": Icons.bloodtype,
      "color": Color(0xFFFFEBEE),
      "iconColor": Colors.red
    },
    {
      "title": "Loans",
      "telugu": "రుణాలు",
      "icon": Icons.account_balance_wallet,
      "color": Color(0xFFF1F8E9),
      "iconColor": Colors.green
    },
  ];

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
    fixOldEmojis();
  }

  void _incrementViewCount() {
    FirebaseFirestore.instance
        .collection('admin')
        .doc('analytics')
        .set({'total_views': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> fixOldEmojis() async {
    final settingsRef =
        FirebaseFirestore.instance.collection('admin').doc('settings');
    final settingsSnap = await settingsRef.get();
    if (settingsSnap.data()?['emojiFixDone'] == true) return;

    final querySnap = await FirebaseFirestore.instance
        .collection('listings')
        .where('emoji', whereIn: ["", "📦"])
        .limit(300)
        .get();

    if (querySnap.docs.isEmpty) {
      await settingsRef.set({'emojiFixDone': true}, SetOptions(merge: true));
      return;
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnap.docs) {
      final data = doc.data();
      final name = data['f1_en'] ?? "";
      final sub = data['sub_category'] ?? "";
      final cat = data['category'] ?? "";
      batch.update(doc.reference, {
        'emoji': getFinalEmoji(
          name,
          sub,
          cat,
          data['f4_en'] ?? "",
          data['f3_en'] ?? "", // 👈 ADD
        )
      });
    }
    await batch.commit();
  }

  void _showChangePinDialog() {
    final TextEditingController newPinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Admin PIN"),
        content: TextField(
          controller: newPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(hintText: "Enter 4-digit PIN"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (newPinController.text.length == 4) {
                await FirebaseFirestore.instance
                    .collection('admin')
                    .doc('settings')
                    .update({'pin': newPinController.text});
                Navigator.pop(ctx);
              }
            },
            child: const Text("SAVE"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140, // 🔥 Increased to comfortably fit the split title
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onLongPress: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AdminLoginPage()),
          ).then((_) => setState(() {})),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔥 SPLIT TITLE FOR ENGLISH, SINGLE LINE FOR TELUGU
              if (isEng) ...[
                Text(
                  "Mana",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Rayachoty Sevalu",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ] else ...[
                Text(
                  "మన రాయచోటి సేవలు",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                isEng
                    ? "Connecting Local Services"
                    : "స్థానిక సేవలను కలుపుతుంది",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEng
                    ? "Powered by Vamshi Tech Infra"
                    : "వంశి టెక్ ఇన్‌ఫ్రా ఆధ్వర్యంలో",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          StreamBuilder<int>(
            stream: firebaseService.getPendingCount(),
            builder: (context, snap) {
              int count = snap.data ?? 0;
              // Feature preserved: Shows pending count ONLY if logged in, but with NO shield icon.
              if (count > 0 && isAdminLoggedIn) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Text(
                        "$count",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              // Empty space to perfectly balance the left-side icon so the title stays dead center
              return const SizedBox(width: 48);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ==========================================
          // UTILITY ROW: LANGUAGE TOGGLE & PROFILE
          // ==========================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                // 1. Sleek Animated Language Toggle
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      children: [
                        // Animated sliding background pill
                        AnimatedAlign(
                          alignment: isEng
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF673AB7),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text Labels
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'selected_language', "English");
                                  setState(() => currentLanguage = "English");
                                },
                                child: Center(
                                  child: Text(
                                    "English",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isEng
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'selected_language', "Telugu");
                                  setState(() => currentLanguage = "Telugu");
                                },
                                child: Center(
                                  child: Text(
                                    "తెలుగు",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: !isEng
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Modern Profile Pill Button
                Expanded(
                  flex: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyListingsPage()),
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(25),
                        border:
                            Border.all(color: Colors.blue.shade100, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.manage_accounts_rounded,
                              color: Color(0xFF0288D1), size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isEng ? "User" : "వినియోగదారు",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0288D1),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    14, // 🔥 Increased font size for better visibility
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // PREMIUM "ADD SERVICE" CTA BUTTON
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7E57C2),
                    Color(0xFF512DA8)
                  ], // Premium Purple Gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF512DA8).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const AddListingPage())),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEng ? "Add Your Service" : "మీ సేవను జోడించండి",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12), // Beautiful spacing before the grid
          if (isAdminLoggedIn)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade100)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                      onPressed: _showChangePinDialog,
                      icon: const Icon(Icons.pin, size: 18),
                      label: const Text("PIN")),
                  TextButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminApprovalPage())),
                      icon: const Icon(Icons.dashboard_customize, size: 18),
                      label: const Text("Panel")),
                  TextButton.icon(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isAdmin', false);
                      setState(() => isAdminLoggedIn = false);
                    },
                    icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                    label:
                        const Text("Exit", style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () async {
                    if (cat["title"] == "AP Sevalu") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const APSevaluStaticPage()));
                    } else if (cat["title"] == "Emergency")
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EmergencyCollectionPage()));
                    else if (cat["title"] == "Movies") {
                      await _handleMoviesAutoInsert();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ListingPage(categoryTitle: cat["title"])));
                    } else
                      _navigateWithSubCategory(cat["title"]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: cat["color"],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cat["isEmoji"] == true
                            ? Text(cat["emoji"],
                                style: const TextStyle(fontSize: 32))
                            : Icon(cat["icon"],
                                size: 32, color: cat["iconColor"]),
                        const SizedBox(height: 4),
                        Text(isEng ? cat["title"] : cat["telugu"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateWithSubCategory(String catTitle) {
    // UPDATED: Strict subcategory mapping for filtering logic
    final Map<String, List<String>> subCatMapEn = {
      "Services": [
        "Plumber",
        "Electrician",
        "Mechanic",
        "Carpenter",
        "Mason",
        "Painter",
        "AC Repair",
        "Bore Repair",
        "Others"
      ],
      "Farmers": ["Fruits", "Vegetables", "Flowers", "Grains", "Others"],
      "Shops": [
        "Grocery",
        "Medical",
        "Bakery",
        "Electronics",
        "Clothes",
        "Others"
      ],
      "Jobs": [
        "Software",
        "Sales",
        "Teacher",
        "Driver",
        "Construction",
        "Others"
      ],
      "Hospitals": [
        "General",
        "Cardiology",
        "Dentist",
        "Eye Care",
        "Skin",
        "Others"
      ],
      "Restaurant": ["Veg", "Non-Veg", "Both"], // Others Removed
      "Hotel Rooms": ["AC", "Non-AC", "Others"],
      "Hostel": ["Boys", "Girls"], // Others Removed
      "Vehicle Rentals": ["Auto", "Car", "Bike", "Tractor", "JCB", "Others"],
      "Old Goods": ["Electronics", "Furniture", "Vehicles", "Books", "Others"],
      "Schools": ["LKG-10", "Intermediate", "Degree", "Coaching", "Others"],
      "Blood Donor": [
        "A+",
        "A-",
        "B+",
        "B-",
        "O+",
        "O-",
        "AB+",
        "AB-"
      ], // Others Removed
      "Loans": [
        "Personal Loan",
        "Gold Loan",
        "Business Loan",
        "Home Loan",
        "Others"
      ], // Others Added
      "House Rent": [
        "House",
        "Commercial Rentals",
        "Plot Rentals"
      ], // Updated Structure
    };

    final Map<String, List<String>> subCatMapTe = {
      "Services": [
        "ప్లంబర్",
        "ఎలక్ట్రీషియన్",
        "మెకానిక్",
        "కార్పెంటర్",
        "మేస్త్రీ",
        "పెయింటర్",
        "AC రిపేర్",
        "బోర్ రిపేర్",
        "ఇతరులు"
      ],
      "Farmers": ["పండ్లు", "కూరగాయలు", "పూలు", "ధాన్యాలు", "ఇతరులు"],
      "Shops": [
        "కిరాణా",
        "మెడికల్",
        "బేకరీ",
        "ఎలక్ట్రానిక్స్",
        "బట్టలు",
        "ఇతరులు"
      ],
      "Jobs": [
        "సాఫ్ట్‌వేర్",
        "సేల్స్",
        "టీచర్",
        "డ్రైవర్",
        "నిర్మాణం",
        "ఇతరులు"
      ],
      "Hospitals": [
        "జనరల్",
        "కార్డియాలజీ",
        "డెంటిస్ట్",
        "కంటి వైద్యం",
        "స్కిన్",
        "ఇతరులు"
      ],
      "Restaurant": ["వెజ్", "నాన్-వెజ్", "రెండూ"], // Others Removed
      "Hotel Rooms": ["AC", "నాన్-AC", "ఇతరులు"],
      "Hostel": ["బాయ్స్", "గర్ల్స్"], // Others Removed
      "Vehicle Rentals": ["ఆటో", "కారు", "బైక్", "ట్రాక్టర్", "JCB", "ఇతరులు"],
      "Old Goods": [
        "ఎలక్ట్రానిక్స్",
        "ఫర్నిచర్",
        "వాహనాలు",
        "పుస్తకాలు",
        "ఇతరులు"
      ],
      "Schools": ["LKG-10", "ఇంటర్మీడియట్", "డిగ్రీ", "కోచింగ్", "ఇతరులు"],
      "Blood Donor": [
        "A+",
        "A-",
        "B+",
        "B-",
        "O+",
        "O-",
        "AB+",
        "AB-"
      ], // Others Removed
      "Loans": [
        "పర్సనల్ లోన్",
        "గోల్డ్ లోన్",
        "బిజినెస్ లోన్",
        "హోమ్ లోన్",
        "ఇతరులు"
      ], // Others Added
      "House Rent": [
        "House",
        "కమర్షియల్ అద్దె",
        "ప్లాట్లు అద్దెకు"
      ], // Updated Structure
    };

    if (subCatMapEn.containsKey(catTitle)) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SubCategoryGridScreen(
                    categoryTitle: catTitle,
                    subCategories: currentLanguage == "English"
                        ? subCatMapEn[catTitle]!
                        : subCatMapTe[catTitle]!,
                  )));
    } else {
      // Movies and other categories skip subcategory screen
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ListingPage(categoryTitle: catTitle)));
    }
  }

  Future<void> _handleMoviesAutoInsert() async {
    final moviesRef = FirebaseFirestore.instance.collection('movies_theatres');
    final snap = await moviesRef.limit(1).get();
    if (snap.docs.isEmpty) {
      List<String> theaters = [
        "Gowtham Cinemas",
        "Prasad Theatre",
        "Sai Theatre"
      ];
      for (var theater in theaters) {
        await moviesRef.add({
          'theatreName': theater,
          'movieName': '',
          'lastUpdated': FieldValue.serverTimestamp()
        });
      }
    }
  }
}

// ==================================================
// 10. SUB-CATEGORY GRID (3 PER ROW + RIPPLE + ZOOM)
// ==================================================

class SubCategoryGridScreen extends StatelessWidget {
  final String categoryTitle;
  final List<String> subCategories;

  const SubCategoryGridScreen({
    super.key,
    required this.categoryTitle,
    required this.subCategories,
  });

  String getMainCategoryEmoji(String category) {
    switch (category) {
      case "Restaurant":
        return "🍔";
      case "Hospitals":
        return "🏥";
      case "Jobs":
        return "💼";
      case "Schools":
        return "🏫";
      case "Blood Donor":
        return "🩸";
      case "Loans":
        return "🏦";
      case "Vehicle Rentals":
        return "🚗";
      case "Farmers":
      case "Farmers":
        return "👨‍🌾";
      case "Shops":
        return "🛒";
      case "Services":
        return "🛠";
      case "House Rent":
        return "🏠";
      default:
        return "📂";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    List<String> gridItems = [isEng ? "All" : "అన్నీ", ...subCategories];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        title: Text(isEng ? "Select Category" : "కేటగిరీ ఎంచుకోండి"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gridItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 🔥 3 per row
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, i) {
          String item = gridItems[i];
          bool isAll = item == "All" || item == "అన్నీ";

          String emoji = isAll
              ? getMainCategoryEmoji(categoryTitle)
              : (strictSubCategoryEmoji[item] ??
                  getMainCategoryEmoji(categoryTitle));

          return _AnimatedTile(
            emoji: emoji,
            label: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingPage(
                    categoryTitle: categoryTitle,
                    subCategory: isAll ? null : item,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AnimatedTile extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _AnimatedTile({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.deepPurple.withOpacity(0.12),
        highlightColor: Colors.deepPurple.withOpacity(0.04),
        onTap: widget.onTap,
        onHighlightChanged: (value) {
          setState(() => _pressed = value);
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 Light contrast circle (not pure white)
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF673AB7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================
// 8. EMERGENCY PAGE (POLICY COMPLIANT)
// ==================================================
class EmergencyCollectionPage extends StatelessWidget {
  const EmergencyCollectionPage({super.key});

  String getEmergencyEmoji(String title) {
    final t = title.toLowerCase();
    if (t.contains("ambulance")) return "🚑";
    if (t.contains("emergency")) return "🚨";
    if (t.contains("fire")) return "🔥";
    if (t.contains("women")) return "👩";
    if (t.contains("child")) return "🧒";
    if (t.contains("electricity")) return "⚡";
    if (t.contains("health")) return "🏥";
    if (t.contains("disaster")) return "🌪";
    if (t.contains("police")) return "🚓";
    return "🚨";
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    return Scaffold(
      appBar: AppBar(
        title: Text(isEng ? "Emergency Services" : "అత్యవసర సేవలు"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ===============================
          // 🔥 REQUIRED GOOGLE PLAY DISCLAIMER
          // ===============================
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEng
                        ? "Disclaimer: This app does NOT represent any government entity. These are publicly available national helpline numbers."
                        : "గమనిక: ఈ యాప్ ఏ ప్రభుత్వ విభాగానికి చెందినది కాదు. ఇవి పబ్లిక్ గా అందుబాటులో ఉన్న జాతీయ హెల్ప్‌లైన్ నంబర్లు.",
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===============================
          // SERVICES LIST
          // ===============================
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firebaseService.getEmergencyServices(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snap.data!.length,
                    itemBuilder: (context, i) {
                      final item = snap.data![i];
                      final String title =
                          isEng ? item['name_en'] : item['name_te'];
                      return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                              leading: Text(getEmergencyEmoji(item['name_en']),
                                  style: const TextStyle(fontSize: 24)),
                              title: Text(title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(item['phone']),
                              trailing: IconButton(
                                  icon: const Icon(Icons.call,
                                      color: Colors.green),
                                  onPressed: () => launchUrl(
                                      Uri.parse("tel:${item['phone']}"))),
                              onTap: () => launchUrl(
                                  Uri.parse("tel:${item['phone']}"))));
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// 9. CONTACT ADMIN (PREMIUM UI + VALIDATION)
// ==================================================
class ContactAdminPage extends StatefulWidget {
  const ContactAdminPage({super.key});

  @override
  State<ContactAdminPage> createState() => _ContactAdminPageState();
}

class _ContactAdminPageState extends State<ContactAdminPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();

  bool _isSending = false;
  bool _sent = false;

  Future<void> _sendMessage() async {
    bool isEng = currentLanguage == "English";

    // 1. Basic Empty Check
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(isEng ? "All fields required" : "అన్ని ఫీల్డ్స్ తప్పనిసరి"),
          backgroundColor: Colors.red));
      return;
    }

    // 2. Strict Phone Validation (10 Digits)
    if (!RegExp(r'^[0-9]{10}$').hasMatch(_phoneCtrl.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEng
              ? "Enter valid 10 digit number"
              : "సరైన 10 అంకెల నంబర్ నమోదు చేయండి"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSending = true);

    // 3. Apply Title Case to Name automatically
    String safeName = toTitleCase(_nameCtrl.text.trim());

    await FirebaseFirestore.instance.collection('contact_messages').add({
      'userName': safeName,
      'userPhone': _phoneCtrl.text.trim(),
      'message': _reasonCtrl.text.trim(),
      'type': 'general',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending'
    });

    setState(() {
      _isSending = false;
      _sent = true;
    });
  }

  // Premium TextField Decoration Helper
  InputDecoration _premiumDecoration(String label) {
    return InputDecoration(
      labelText: label,
      counterText: "",
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle:
          TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF673AB7), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";

    return Scaffold(
      appBar: AppBar(
        title: Text(isEng ? "Contact Admin" : "అడ్మిన్‌ను సంప్రదించండి"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _sent
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      isEng
                          ? "Message sent successfully!\nWe will contact you soon."
                          : "సందేశం విజయవంతంగా పంపబడింది!\nమేము త్వరలో మిమ్మల్ని సంప్రదిస్తాము.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization:
                        TextCapitalization.words, // Soft keyboard caps
                    decoration:
                        _premiumDecoration(isEng ? "Your Name" : "మీ పేరు"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: _premiumDecoration(
                        isEng ? "Phone Number" : "ఫోన్ నంబర్"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _reasonCtrl,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _premiumDecoration(
                        isEng ? "Reason for Contact" : "సంప్రదించడానికి కారణం"),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendMessage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: const Color(0xFF673AB7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEng ? "SEND MESSAGE" : "సందేశం పంపండి",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ==================================================
// 10. AP GOVT SERVICES STATIC PAGE (POLICY COMPLIANT)
// ==================================================

class APSevaluStaticPage extends StatelessWidget {
  const APSevaluStaticPage({super.key});

  String getAPEmoji(String title) {
    final t = title.toLowerCase();

    if (t.contains("industry")) return "🏭";
    if (t.contains("education")) return "🎓";
    if (t.contains("civil")) return "🧾";
    if (t.contains("energy")) return "⚡";
    if (t.contains("police")) return "🚓";
    if (t.contains("anna")) return "🍛";
    if (t.contains("ttd")) return "🛕";
    if (t.contains("grievance")) return "📢";

    return "🏛";
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";

    final List<Map<String, String>> services = [
      {
        "titleEn": "Industry Services",
        "titleTe": "ఇండస్ట్రీ సేవలు",
        "url": "https://industries.ap.gov.in"
      },
      {
        "titleEn": "Education Services",
        "titleTe": "ఎడ్యుకేషన్ సేవలు",
        "url": "https://education.ap.gov.in"
      },
      {
        "titleEn": "Civil Supply Services",
        "titleTe": "సివిల్ సరఫరాలు",
        "url": "https://civilsupplies.ap.gov.in"
      },
      {
        "titleEn": "Energy Services",
        "titleTe": "ఎనర్జీ సేవలు",
        "url": "https://energy.ap.gov.in"
      },
      {
        "titleEn": "Police Services",
        "titleTe": "పోలీస్ సేవలు",
        "url": "https://police.ap.gov.in"
      },
      {
        "titleEn": "Anna Canteen",
        "titleTe": "అన్నా క్యాంటీన్",
        "url": "https://annacanteen.ap.gov.in"
      },
      {
        "titleEn": "TTD Services",
        "titleTe": "టీటీడీ సేవలు",
        "url": "https://tirumala.org"
      },
      {
        "titleEn": "Grievance Redressal",
        "titleTe": "ఫిర్యాదు పరిష్కారం",
        "url": "https://spandana.ap.gov.in"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        // Changed "Govt" to "Public" to be safe
        title: Text(isEng ? "AP Public Services" : "ఏపీ పబ్లిక్ సేవలు"),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: Column(
        children: [
          // ===============================
          // 🔥 REQUIRED GOOGLE PLAY DISCLAIMER
          // ===============================
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEng
                        ? "Disclaimer: This app does NOT represent any government entity. These are publicly available links provided for citizen convenience."
                        : "గమనిక: ఈ యాప్ ఏ ప్రభుత్వ విభాగానికి చెందినది కాదు. ఇక్కడ ఉన్న సమాచారం పబ్లిక్ సోర్సెస్ నుండి తీసుకోబడింది.",
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===============================
          // PREMIUM WHATSAPP BUTTON (Removed "Official" text)
          // ===============================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () async {
                        final Uri whatsappAppUri =
                            Uri.parse("whatsapp://send?phone=919552300009");

                        final Uri whatsappWebUri = Uri.parse(
                            "https://api.whatsapp.com/send?phone=919552300009");

                        if (await canLaunchUrl(whatsappAppUri)) {
                          await launchUrl(
                            whatsappAppUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          await launchUrl(
                            whatsappWebUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                // REMOVED THE WORD "OFFICIAL"
                                isEng
                                    ? "AP State WhatsApp"
                                    : "ఏపీ పబ్లిక్ వాట్సాప్ సేవలు",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    isEng
                        ? "Reach state services through WhatsApp."
                        : "ప్రభుత్వ సేవలను వాట్సాప్ ద్వారా పొందండి.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===============================
          // SERVICES LIST
          // ===============================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final title = isEng ? service["titleEn"]! : service["titleTe"]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Text(
                        getAPEmoji(service["titleEn"]!),
                        style: const TextStyle(fontSize: 26),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () async {
                        final Uri url = Uri.parse(service["url"]!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// 11. REGISTRATION PAGE (MOVIES: THEATER + MOVIE FIELDS)
// ==================================================

final Map<String, List<String>> categorySubMapEn = {
  "Farmers": ["Fruits", "Vegetables", "Flowers", "Grains", "Others"],
  "Shops": [
    "Grocery",
    "Medical",
    "Bakery",
    "Clothing",
    "Electronics",
    "Hardware",
    "Others"
  ],
  "Services": [
    "Plumber",
    "Electrician",
    "Mechanic",
    "Carpenter",
    "Mason",
    "Painter",
    "AC Repair",
    "Bore Repair",
    "Others"
  ],
  "Schools": ["LKG-10", "Intermediate", "Degree", "Coaching", "Others"],
  "Jobs": [
    "IT",
    "Software",
    "Sales",
    "Teacher",
    "Driver",
    "Construction",
    "Others"
  ],
  "Hospitals": [
    "General",
    "Cardiology",
    "Dentist",
    "Eye Care",
    "Skin",
    "Others"
  ],
  "House Rent": ["House", "Commercial Rentals", "Plot Rentals"],
  "Vehicle Rentals": ["Auto", "Car", "Bike", "Tractor", "JCB", "Others"],
  "Old Goods": ["Electronics", "Furniture", "Vehicles", "Books", "Others"],
  "Restaurant": ["Veg", "Non-Veg", "Both"],
  "Hotel Rooms": ["AC", "Non-AC", "Others"],
  "Hostel": ["Boys", "Girls"],
  "Blood Donor": ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
  "Loans": [
    "Personal Loan",
    "Gold Loan",
    "Business Loan",
    "Home Loan",
    "Others"
  ],
  "Movies": ["Now Showing", "Coming Soon"],
};

final Map<String, List<String>> categorySubMapTe = {
  "Farmers": ["పండ్లు", "కూరగాయలు", "పూలు", "ధాన్యాలు", "ఇతరులు"],
  "Shops": [
    "కిరాణా",
    "మెడికల్",
    "బేకరీ",
    "దుస్తులు",
    "ఎలక్ట్రానిక్స్",
    "హార్డ్‌వేర్",
    "ఇతరులు"
  ],
  "Services": [
    "ప్లంబర్",
    "ఎలక్ట్రీషియన్",
    "మెకానిక్",
    "కార్పెంటర్",
    "మేస్త్రీ",
    "పెయింటర్",
    "AC రిపేర్",
    "బోర్ రిపేర్",
    "ఇతరులు"
  ],
  "Schools": ["LKG-10", "ఇంటర్మీడియట్", "డిగ్రీ", "కోచింగ్", "ఇతరులు"],
  "Jobs": [
    "ఐటీ",
    "సాఫ్ట్‌వేర్",
    "సేల్స్",
    "టీచర్",
    "డ్రైవర్",
    "నిర్మాణం",
    "ఇతరులు"
  ],
  "Hospitals": [
    "జనరల్",
    "కార్డియాలజీ",
    "డెంటిస్ట్",
    "కంటి వైద్యం",
    "స్కిన్",
    "ఇతరులు"
  ],
  "House Rent": ["House", "కమర్షియల్ అద్దె", "ప్లాట్లు అద్దెకు"],
  "Vehicle Rentals": ["ఆటో", "కారు", "బైక్", "ట్రాక్టర్", "JCB", "ఇతరులు"],
  "Old Goods": ["ఎలక్ట్రానిక్స్", "ఫర్నిచర్", "వాహనాలు", "పుస్తకాలు", "ఇతరులు"],
  "Restaurant": ["వెజ్", "నాన్-వెజ్", "రెండూ"],
  "Hotel Rooms": ["AC", "నాన్-AC", "ఇతరులు"],
  "Hostel": ["బాయ్స్", "గర్ల్స్"],
  "Blood Donor": ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
  "Loans": [
    "పర్సనల్ లోన్",
    "గోల్డ్ లోన్",
    "బిజినెస్ లోన్",
    "హోమ్ లోన్",
    "ఇతరులు"
  ],
  "Movies": ["ప్రస్తుతం ప్రదర్శనలో", "త్వరలో రాబోతుంది"],
};

class AddListingPage extends StatefulWidget {
  final String? autoSubCat;
  const AddListingPage({super.key, this.autoSubCat});
  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final _formKey = GlobalKey<FormState>();
  String selectedCat = "Farmers";
  String? selectedSubCategory;
  bool isSubmitting = false;

  final Map<String, TextEditingController> controllers = {
    'f1': TextEditingController(),
    'f2': TextEditingController(),
    'f3': TextEditingController(),
    'f4': TextEditingController(),
    'f5': TextEditingController(),
    'f6': TextEditingController()
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    bool isEng = currentLanguage == "English";
    bool? proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Row(children: [
                  const Icon(Icons.verified_user, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(isEng ? "Safety Rules" : "భద్రతా నియమాలు")
                ]),
                content: Text(isEng
                    ? "✅ Use numbers for business only.\n\n❌ NEVER pay money in advance.\n\n❌ Do not share private info.\n\n🤝 This app only helps you connect."
                    : "✅ నంబర్లను వ్యాపార కాల్స్ కోసం మాత్రమే వాడండి.\n\n❌ డబ్బు ముందస్తుగా చెల్లించవద్దు.\n\n❌ మీ వ్యక్తిగత వివరాలు పంచుకోవద్దు.\n\n🤝 ఈ యాప్ కేవలం ఇద్దరిని కలపడానికి మాత్రమే."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(isEng ? "CANCEL" : "రద్దు")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7)),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(isEng ? "I AGREE" : "నేను అంగీకరిస్తున్నాను",
                          style: const TextStyle(color: Colors.white)))
                ]));
    if (proceed != true) return;
    setState(() => isSubmitting = true);

    // 🔥 1. Capture the messenger BEFORE popping the screen
    final messenger = ScaffoldMessenger.of(context);

    Navigator.of(context).popUntil((route) => route.isFirst);
    _processSubmissionInBackground();

    // 🔥 2. Use the captured messenger
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue.shade700,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEng
                    ? "Service registered. Please wait for admin approval."
                    : "సేవ నమోదు చేయబడింది. అడ్మిన్ ఆమోదం కోసం వేచి ఉండండి.",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processSubmissionInBackground() async {
    try {
      await _processSubmission();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // 🔥 UPGRADED: SMART ROUTING LOGIC (Transliterate vs Translate vs Skip)
  Future<void> _processSubmission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (selectedCat == "Movies") {
      controllers['f3']!.clear();
      controllers['f4']!.clear();
      controllers['f5']!.clear();
      controllers['f6']!.clear();
    }
    String devId = prefs.getString('user_device_id') ??
        "USER_${DateTime.now().millisecondsSinceEpoch}";
    await prefs.setString('user_device_id', devId);

    List<String> lbls = categoryLabels[selectedCat] ?? [];
    double parsedPrice = 0.0;

    for (int i = 0; i < lbls.length; i++) {
      String label = lbls[i].toLowerCase();
      if (label.contains("price") ||
          label.contains("rent") ||
          label.contains("charges") ||
          label.contains("salary") ||
          label.contains("fee")) {
        String rawPrice =
            controllers['f${i + 1}']!.text.trim().replaceAll(",", "");
        parsedPrice = double.tryParse(rawPrice) ?? 0.0;
        break;
      }
    }

    Map<String, String> fields = {
      'f1': controllers['f1']!.text.trim(),
      'f2': controllers['f2']!.text.trim(),
      'f3': controllers['f3']!.text.trim(),
      'f4': controllers['f4']!.text.trim(),
      'f5': controllers['f5']!.text.trim(),
      'f6': controllers['f6']!.text.trim(),
    };

    Map<String, String> finalEn = {};
    Map<String, String> finalTe = {};

    // SMART ROUTING: Decides whether to Translate, Transliterate, or Skip!
    for (int i = 0; i < 6; i++) {
      String key = 'f${i + 1}';
      String rawText = fields[key] ?? "";
      String label = (i < lbls.length) ? lbls[i].toLowerCase() : "";

      // 🚫 SKIP: Numbers, Codes, and strict fields
      bool isSkip = label.contains("phone") ||
          label.contains("price") ||
          label.contains("rent") ||
          label.contains("salary") ||
          label.contains("fee") ||
          label.contains("charges") ||
          label.contains("blood group") ||
          label.contains("rate");

      // 🔥 TRANSLITERATE (Sound it out): Names (except Crop), Places, Brands, Models
      bool isTransliterate =
          (label.contains("name") && !label.contains("crop")) ||
              label.contains("person") ||
              label.contains("hospital") ||
              label.contains("company") ||
              label.contains("title") ||
              label.contains("location") ||
              label.contains("model");

      if (rawText.isEmpty || isSkip) {
        finalEn[key] = rawText;
        finalTe[key] = rawText;
      } else {
        bool isInputTe = translationService.isTelugu(rawText);
        if (isInputTe) {
          finalTe[key] = rawText;
          finalEn[key] = toTitleCase(
              await translationService.translateText(rawText, 'en'));
        } else {
          finalEn[key] = toTitleCase(rawText);
          if (isTransliterate) {
            finalTe[key] =
                await translationService.transliterateToTelugu(rawText);
          } else {
            finalTe[key] =
                await translationService.translateText(rawText, 'te');
          }
        }
      }
    }

    String uEn = "";
    String uTe = "";
    if (selectedCat == "Farmers") {
      uEn = " / KG";
      uTe = " / కిలో";
    } else if (selectedCat == "House Rent") {
      uEn = " / Month";
      uTe = " / నెల";
    } else if (selectedCat == "Vehicle Rentals") {
      uEn = " / Day";
      uTe = " / రోజు";
    }

    await firebaseService.addListing(Listing(
      id: '',
      category: selectedCat,
      subCategory: selectedSubCategory ?? "Others",
      ownerId: devId,
      f1En: finalEn['f1']!,
      f1Te: finalTe['f1']!,
      f2En: finalEn['f2']!,
      f2Te: finalTe['f2']!,
      f3En: finalEn['f3']!,
      f3Te: finalTe['f3']!,
      f4En: finalEn['f4']!,
      f4Te: finalTe['f4']!,
      f5En: finalEn['f5']!,
      f5Te: finalTe['f5']!,
      f6En: finalEn['f6']!,
      f6Te: finalTe['f6']!,
      price: parsedPrice,
      priceUnitEn: uEn,
      priceUnitTe: uTe,
      locationEn: finalEn['f6']!,
      locationTe: finalTe['f6']!,
      descEn: finalEn['f4']!,
      descTe: finalTe['f4']!,
      emoji: getFinalEmoji(
        fields['f1']!,
        selectedSubCategory ?? "Others",
        selectedCat,
        fields['f4']!,
        fields['f3']!,
      ),
      status: "pending",
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    bool isMovies = selectedCat == "Movies";

    List<String> subCats = isEng
        ? (categorySubMapEn[selectedCat] ?? [])
        : (categorySubMapTe[selectedCat] ?? []);
    List<String> lbls = isMovies
        ? (isEng
            ? ["Theater Name", "Movie Name"]
            : ["థియేటర్ పేరు", "సినిమా పేరు"])
        : (isEng
            ? (categoryLabels[selectedCat] ?? [])
            : (categoryLabelsTe[selectedCat] ?? []));
    List<String> hnts = isEng
        ? (categoryHintsEn[selectedCat] ?? [])
        : (categoryHintsTe[selectedCat] ?? []);

    return Scaffold(
        appBar: AppBar(
            title: Text(isEng ? "Register Service" : "సేవను నమోదు చేయండి")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  DropdownButtonFormField<String>(
                      initialValue: selectedCat,
                      items: categoryMap.keys
                          .where((k) =>
                              k != "Emergency" &&
                              k != "AP Sevalu" &&
                              k != "Hotels")
                          .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(isEng ? k : (categoryMap[k] ?? k))))
                          .toList(),
                      onChanged: (v) => setState(() {
                            selectedCat = v!;
                            selectedSubCategory = null;
                            for (var controller in controllers.values) {
                              controller.clear();
                            }
                          }),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Category")),
                  if (subCats.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                        initialValue: selectedSubCategory,
                        items: subCats
                            .map((sub) =>
                                DropdownMenuItem(value: sub, child: Text(sub)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedSubCategory = v),
                        decoration: InputDecoration(
                            labelText: isEng ? "Sub Category" : "ఉప వర్గం",
                            border: const OutlineInputBorder()))
                  ],
                  const SizedBox(height: 15),
                  for (int i = 0; i < lbls.length; i++) ...[
                    Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                            controller: controllers['f${i + 1}'],
                            keyboardType: (lbls[i]
                                        .toLowerCase()
                                        .contains("phone") ||
                                    lbls[i].contains("ఫోన్") ||
                                    lbls[i].toLowerCase().contains("price") ||
                                    lbls[i].contains("ధర"))
                                ? TextInputType.number
                                : TextInputType.text,
                            maxLength:
                                (lbls[i].toLowerCase().contains("phone") ||
                                        lbls[i].contains("ఫోన్"))
                                    ? 10
                                    : 150,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Required";
                              }

                              // 🔥 Strict phone validation
                              if (lbls[i].toLowerCase().contains("phone") ||
                                  lbls[i].contains("ఫోన్")) {
                                if (!RegExp(r'^[0-9]{10}$')
                                    .hasMatch(v.trim())) {
                                  return "Enter valid 10 digit number";
                                }
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: lbls[i],
                              hintText: i < hnts.length ? hnts[i] : "",
                              counterText: "",
                              filled: true, // 🔥 Modern filled look
                              fillColor:
                                  Colors.grey.shade50, // 🔥 Light background
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide
                                    .none, // Removes thick black lines
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: Color(0xFF673AB7), width: 2),
                              ),
                            )))
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60),
                          backgroundColor: const Color(0xFF673AB7)),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEng ? "SUBMIT" : "సబ్మిట్ చేయండి",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                ]))));
  }
}

// ==================================================
// 12. LISTING PAGE (VERSION C - STRICT + CLEAN UI)
// ==================================================
class ListingPage extends StatefulWidget {
  final String categoryTitle;
  final String? subCategory;

  const ListingPage({
    super.key,
    required this.categoryTitle,
    this.subCategory,
  });

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  String searchQuery = "";
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    bool isMovies = widget.categoryTitle == "Movies";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isEng ? "Search..." : "వెతకండి...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {
                  searchQuery = value.toLowerCase();
                }),
              )
            : Text(widget.subCategory ?? getCategory(widget.categoryTitle)),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = "";
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Listing>>(
        stream: firebaseService.getApprovedListings(
          widget.categoryTitle,
          subCategory: widget.subCategory,
        ),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    isEng ? "No Services Found." : "సేవలు లేవు.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEng
                        ? "Be the first to add a service here!"
                        : "మొదటగా మీ సేవను ఇక్కడ జోడించండి!",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          List<Listing> list = snap.data!;

          // SEARCH FILTER
          if (searchQuery.isNotEmpty) {
            list = list.where((l) {
              String f1 = (isEng ? l.f1En : l.f1Te).toLowerCase();
              String f3 = (isEng ? l.f3En : l.f3Te).toLowerCase();
              return f1.contains(searchQuery) || f3.contains(searchQuery);
            }).toList();
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              Listing l = list[i];

              // =========================================================
              // 1. SMART TITLE LOGIC (Shows Product instead of Owner)
              // =========================================================
              bool f3IsMain = [
                "Farmers",
                "Services",
                "Hospitals",
                "House Rent",
                "Loans",
                "Blood Donor"
              ].contains(widget.categoryTitle);

              String mainTitleEn = f3IsMain ? l.f3En : l.f1En;
              String mainTitleTe = f3IsMain ? l.f3Te : l.f1Te;
              String subTitleEn = f3IsMain ? l.f1En : l.f3En;
              String subTitleTe = f3IsMain ? l.f1Te : l.f3Te;

              // Fallbacks
              if (mainTitleEn.isEmpty) mainTitleEn = l.f1En;
              if (mainTitleTe.isEmpty) mainTitleTe = l.f1Te;

              String displayMainTitle =
                  toTitleCase(isEng ? mainTitleEn : mainTitleTe);
              String displaySubTitle =
                  toTitleCase(isEng ? subTitleEn : subTitleTe);

              // Movies Exception
              if (isMovies) {
                displayMainTitle = isEng ? l.f2En : l.f2Te; // Movie Name
                displaySubTitle = isEng ? l.f1En : l.f1Te; // Theater Name
                if (displayMainTitle.isEmpty) {
                  displayMainTitle = displaySubTitle;
                }
              }

              String displayPrice =
                  formatPriceWithUnit(l.f5En, widget.categoryTitle, isEng);

              // =========================================================
              // 🔥 DYNAMIC LOCATION LOGIC (Fixes Shops & Schools)
              // =========================================================
              String displayLocation = "";
              List<String> currentLabelsEn =
                  categoryLabels[widget.categoryTitle] ?? [];
              int locIndex = currentLabelsEn.indexWhere(
                  (label) => label.toLowerCase().contains("location"));
              if (locIndex != -1) {
                switch (locIndex) {
                  case 0:
                    displayLocation = isEng ? l.f1En : l.f1Te;
                    break;
                  case 1:
                    displayLocation = isEng ? l.f2En : l.f2Te;
                    break;
                  case 2:
                    displayLocation = isEng ? l.f3En : l.f3Te;
                    break;
                  case 3:
                    displayLocation = isEng ? l.f4En : l.f4Te;
                    break;
                  case 4:
                    displayLocation = isEng ? l.f5En : l.f5Te;
                    break;
                  case 5:
                    displayLocation = isEng ? l.f6En : l.f6Te;
                    break;
                }
              }

              displayLocation =
                  toTitleCase(displayLocation); // 🔥 Capitalizes Rayachoty

              // =========================================================
              // 2. BEAUTIFUL MODERN CARD UI
              // =========================================================
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: const Color(0xFF673AB7).withOpacity(0.1),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(listing: l)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // --- LEFT SIDE: TEXT DATA ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔥 MAIN TITLE (Product / Service)
                              Text(
                                displayMainTitle,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // 🔥 SUBTITLE (Owner / Details)
                              if (displaySubTitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  displaySubTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              const SizedBox(height: 12),

                              // 🔥 PRICE TAG
                              if (displayPrice.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade200, width: 1),
                                  ),
                                  child: Text(
                                    displayPrice,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),

                              if (displayPrice.isNotEmpty &&
                                  displayLocation.isNotEmpty)
                                const SizedBox(height: 10),

                              // 🔥 LOCATION WITH PIN ICON
                              if (displayLocation.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 16, color: Colors.red.shade400),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        displayLocation,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // --- RIGHT SIDE: EMOJI & BOLD ARROW ---
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔥 ANIMATED EMOJI (No Background)
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.2, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: Center(
                                      child: Text(
                                        l.emoji ?? "📂",
                                        style: const TextStyle(fontSize: 38),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 🔥 BOLD "VIEW" BUTTON
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF673AB7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF673AB7)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isEng ? "View" : "చూడు",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF673AB7),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddListingPage(autoSubCat: widget.subCategory),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ==================================================
// 13. USER PROFILE (MY SERVICES & CONTACT ADMIN TABS)
// ==================================================
class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});
  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  int selectedTab = 0; // 0 = My Services, 1 = Contact Admin

  // --- Contact Admin State Variables ---
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  Future<void> _sendMessage() async {
    bool isEng = currentLanguage == "English";
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _reasonCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              isEng ? "All fields required" : "అన్ని ఫీల్డ్స్ తప్పనిసరి")));
      return;
    }
    setState(() => _isSending = true);
    await FirebaseFirestore.instance.collection('contact_messages').add({
      'userName': _nameCtrl.text,
      'userPhone': _phoneCtrl.text,
      'message': _reasonCtrl.text,
      'type': 'general',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending'
    });
    setState(() {
      _isSending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";
    return Scaffold(
      appBar: AppBar(
        title: Text(isEng ? "User Profile" : "వినియోగదారు ప్రొఫైల్"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔥 TAB HEADER (Matching Admin Panel Style)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabIcon(
                    Icons.list_alt, isEng ? "My Services" : "నా సేవలు", 0),
                _buildTabIcon(Icons.support_agent,
                    isEng ? "Contact Admin" : "అడ్మిన్‌ కు మెసేజ్", 1),
              ],
            ),
          ),
          const Divider(height: 1),

          // 🔥 TAB BODY CONTENT
          Expanded(
            child: selectedTab == 0
                ? _buildMyServicesSection(isEng)
                : _buildContactAdminSection(isEng),
          ),
        ],
      ),
    );
  }

  // ================= TAB ICON BUILDER =================
  Widget _buildTabIcon(IconData icon, String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Icon(icon,
              size: 32,
              color: isSelected ? const Color(0xFF673AB7) : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF673AB7) : Colors.grey)),
          if (isSelected)
            Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 40,
                color: const Color(0xFF673AB7))
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: MY SERVICES
  // ==========================================
  Widget _buildMyServicesSection(bool isEng) {
    return FutureBuilder<String>(
      future: SharedPreferences.getInstance()
          .then((p) => p.getString('user_device_id') ?? ""),
      builder: (context, idSnap) {
        if (!idSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<Listing>>(
          stream: firebaseService.getMyListings(idSnap.data!),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.data!.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    isEng ? "No Services Added." : "సేవలు లేవు.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500),
                  ),
                ],
              ));
            }
            return ListView.builder(
              itemCount: snap.data!.length,
              itemBuilder: (context, i) {
                final l = snap.data![i];
                // 🔥 Capitalize the title to match the rest of the app
                String displayTitle = toTitleCase(isEng ? l.f1En : l.f1Te);

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(displayTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${l.category} (${l.status})"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AddListingPage(
                                        autoSubCat: l.subCategory)))),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                firebaseService.deleteListing(l.id)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 2: CONTACT ADMIN
  // ==========================================
  Widget _buildContactAdminSection(bool isEng) {
    if (_sent) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text(
              isEng
                  ? "Message sent successfully!"
                  : "సందేశం విజయవంతంగా పంపబడింది!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _sent = false;
                  _nameCtrl.clear();
                  _phoneCtrl.clear();
                  _reasonCtrl.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7)),
              child: Text(isEng ? "Send Another" : "మరొకటి పంపండి",
                  style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: isEng ? "Your Name" : "మీ పేరు",
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: isEng ? "Phone Number" : "ఫోన్ నంబర్",
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _reasonCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: isEng ? "Contact For" : "సంప్రదించడానికి కారణం",
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: _isSending ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: const Color(0xFF673AB7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSending
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEng ? "SUBMIT" : "సబ్మిట్ చేయండి",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// 14. DETAIL PAGE (PRODUCT-FOCUSED & SCALABLE)
// ==================================================
class DetailPage extends StatefulWidget {
  final Listing listing;
  const DetailPage({super.key, required this.listing});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    bool isEng = currentLanguage == "English";

    // Standardized Price Formatting
    String displayPrice = formatPriceWithUnit(
      widget.listing.f5En,
      widget.listing.category,
      isEng,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEng ? "Service Details" : "సేవ వివరాలు"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    toTitleCase(isEng
                        ? widget.listing.f1En
                        : widget.listing.f1Te), // 🔥 MAIN TITLE CAPITALS
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7),
                    ),
                  ),
                ),
                Text(
                  widget.listing.emoji ?? "📂",
                  style: const TextStyle(fontSize: 55),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 40),

// ================= INFO SECTION (FULLY DYNAMIC) =================
            ...List.generate(
              isEng
                  ? (categoryLabels[widget.listing.category]?.length ?? 0)
                  : (categoryLabelsTe[widget.listing.category]?.length ?? 0),
              (index) {
                List<String> currentLabels = isEng
                    ? categoryLabels[widget.listing.category]!
                    : categoryLabelsTe[widget.listing.category]!;

                List<String> englishLabels =
                    categoryLabels[widget.listing.category]!;

                // 🔥 CRITICAL FIX: Map database fields exactly to the loop index.
                String getEnValue(int i) {
                  switch (i) {
                    case 0:
                      return widget.listing.f1En;
                    case 1:
                      return widget.listing.f2En;
                    case 2:
                      return widget.listing.f3En;
                    case 3:
                      return widget.listing.f4En;
                    case 4:
                      return widget.listing.f5En;
                    case 5:
                      return widget.listing.f6En;
                    default:
                      return "";
                  }
                }

                String getTeValue(int i) {
                  switch (i) {
                    case 0:
                      return widget.listing.f1Te;
                    case 1:
                      return widget.listing.f2Te;
                    case 2:
                      return widget.listing.f3Te;
                    case 3:
                      return widget.listing.f4Te;
                    case 4:
                      return widget.listing.f5Te;
                    case 5:
                      return widget.listing.f6Te;
                    default:
                      return "";
                  }
                }

                String valueEn = getEnValue(index);
                String valueTe = getTeValue(index);

                // Fallback to English data if Telugu data is missing
                String finalValue =
                    (isEng || valueTe.isEmpty) ? valueEn : valueTe;

                finalValue =
                    toTitleCase(finalValue); // 🔥 Capitalizes all details

                String label = currentLabels[index];
                String enLabel = englishLabels[index].toLowerCase();

                // Skip Empty values or Phone Numbers (Phone has its own Call button)
                if (finalValue.isEmpty || enLabel.contains("phone")) {
                  return const SizedBox.shrink();
                }

                IconData icon = Icons.info_outline;
                Color? textColor;

                // Auto-assign formatting based on the English Label keywords
                if (enLabel.contains("owner") ||
                    enLabel.contains("name") ||
                    enLabel.contains("person")) {
                  icon = Icons.person;
                } else if (enLabel.contains("location")) {
                  icon = Icons.location_on;
                } else if (enLabel.contains("desc")) {
                  icon = Icons.description;
                } else if (enLabel.contains("price") ||
                    enLabel.contains("charge") ||
                    enLabel.contains("rent") ||
                    enLabel.contains("salary") ||
                    enLabel.contains("fee")) {
                  icon = Icons.currency_rupee;
                  textColor = Colors.green;
                  // Apply formatting dynamically
                  finalValue = formatPriceWithUnit(
                      finalValue, widget.listing.category, isEng);
                } else {
                  icon = Icons.category;
                }

                return _infoItem(icon, label, finalValue, color: textColor);
              },
            ),
            // ================= SAFETY BOX =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.gpp_maybe, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Text(
                        isEng ? "Safety Guidelines" : "భద్రతా మార్గదర్శకాలు",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB71C1C),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEng
                        ? "• Verify details before making payments.\n"
                            "• Beware of fraudulent calls or links.\n"
                            "• Report suspicious listings to admin."
                        : "• నగదు చెల్లించే ముందు వివరాలను సరిచూసుకోండి.\n"
                            "• నకిలీ కాల్స్ లేదా లింక్‌ల పట్ల జాగ్రత్తగా ఉండండి.\n"
                            "• అనుమానాస్పద పోస్టులను అడ్మిన్‌కు నివేదించండి.",
                    style: TextStyle(
                      color: Colors.red.shade800,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= PREMIUM CALL BUTTON =================
            if (widget.listing.category !=
                "Movies") // 🔥 HIDES BUTTON FOR CINEMAS
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00C853),
                      Color(0xFF43A047)
                    ], // Glowing green
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final String phone = widget.listing.f2En;
                    if (phone.isEmpty) return;
                    final Uri callUri = Uri.parse("tel:$phone");
                    if (await canLaunchUrl(callUri)) await launchUrl(callUri);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor:
                        Colors.transparent, // Let gradient show through
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.call, color: Colors.white, size: 26),
                  label: Text(
                    isEng ? "CALL NOW" : "కాల్ చేయండి",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= INFO ITEM WIDGET =================
  Widget _infoItem(IconData icon, String label, String value, {Color? color}) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color ?? Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// 15. ADMIN PANEL (SWAPPED TABS + TELUGU EDIT + APPROVE)
// ==================================================
class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});
  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  int selectedTab = 0; // 0 = Approvals, 1 = Messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Control Panel"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabIcon(Icons.approval, "Approvals", 0),
                _buildTabIcon(Icons.message, "Messages", 1),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedTab == 0
                ? _buildListingsSection()
                : _buildMessagesSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Icon(icon,
              size: 32,
              color: isSelected ? const Color(0xFF673AB7) : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF673AB7) : Colors.grey)),
          if (isSelected)
            Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 40,
                color: const Color(0xFF673AB7))
        ],
      ),
    );
  }

  // ==================================================
  // MESSAGES SECTION
  // ==================================================
  Widget _buildMessagesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contact_messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data!.docs.isEmpty) {
          return const Center(child: Text("No messages."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, i) {
            var doc = snap.data!.docs[i];
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['userName'] ?? "Unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    Text("Phone: ${data['userPhone']}\n${data['message']}"),
                trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete()),
              ),
            );
          },
        );
      },
    );
  }

  // ==================================================
  // LISTINGS SECTION (WITH APPROVE BUTTON)
  // ==================================================
  Widget _buildListingsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final l = Listing.fromFirestore(
                docs[i].data() as Map<String, dynamic>, docs[i].id);

            bool isPending = l.status.toLowerCase() == "pending";

            return Card(
              color: isPending ? Colors.orange.shade50 : Colors.white,
              child: ExpansionTile(
                leading:
                    Text(l.emoji ?? "📦", style: const TextStyle(fontSize: 24)),
                title: Text(l.f1En,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Status: ${l.status}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sub: ${l.subCategory ?? ""}",
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        Text("Phone: ${l.f2En}"),

                        // 1. Price (Strictly f5)
                        Text("Price Value (f5): ${l.f5En}"),

                        // 2. Location (Strictly f6)
                        Text("Location (f6): ${l.f6En}"),

                        // 3. Secondary Info (Strictly f3)
                        Text("Sec Info (f3): ${l.f3En}"),

                        // 4. Description (Strictly f4)
                        Text("Description (f4): ${l.f4En}"),

                        const SizedBox(height: 15),
                        // 🔥 RESPONSIVE WRAP: Fixes all small screen overflow issues!
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 0, // Horizontal space between buttons
                          runSpacing:
                              4, // Vertical space if pushed to next line
                          children: [
                            // ✅ APPROVE BUTTON
                            if (l.status.toLowerCase() != 'approved')
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green, size: 26),
                                constraints:
                                    const BoxConstraints(), // Reduces padding footprint
                                padding: const EdgeInsets.all(8),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('listings')
                                      .doc(l.id)
                                      .update({'status': 'approved'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Approved successfully")));
                                },
                              ),

                            // ❌ REJECT BUTTON
                            if (l.status.toLowerCase() != 'rejected')
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.orange, size: 26),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('listings')
                                      .doc(l.id)
                                      .update({'status': 'rejected'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Rejected successfully")));
                                },
                              ),

                            // 📌 PIN / UNPIN BUTTON
                            IconButton(
                              icon: Icon(
                                  l.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  color:
                                      l.isPinned ? Colors.orange : Colors.grey,
                                  size: 24),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('listings')
                                    .doc(l.id)
                                    .update({'isPinned': !l.isPinned});
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(l.isPinned
                                            ? "Unpinned successfully"
                                            : "Pinned successfully")));
                              },
                            ),

                            // ✏ EDIT BUTTON (OPENS UPGRADED DIALOG)
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.purple, size: 24),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => _showFullEdit(l),
                            ),

                            // 🗑 DELETE BUTTON
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 24),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => docs[i].reference.delete(),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================================================
  // 🔥 UPGRADED FULL EDIT DIALOG (WITH EMOJI EDITOR + MAGIC TRANSLATE)
  // ==================================================
  void _showFullEdit(Listing l) {
    List<String> labelsEn = categoryLabels[l.category] ?? [];
    List<String> labelsTe = categoryLabelsTe[l.category] ?? [];

    List<TextEditingController> enControllers = [
      TextEditingController(text: l.f1En),
      TextEditingController(text: l.f2En),
      TextEditingController(text: l.f3En),
      TextEditingController(text: l.f4En),
      TextEditingController(text: l.f5En),
      TextEditingController(text: l.f6En),
    ];
    List<TextEditingController> teControllers = [
      TextEditingController(text: l.f1Te),
      TextEditingController(text: l.f2Te),
      TextEditingController(text: l.f3Te),
      TextEditingController(text: l.f4Te),
      TextEditingController(text: l.f5Te),
      TextEditingController(text: l.f6Te),
    ];

    // 🔥 NEW: EMOJI TEXT CONTROLLER
    TextEditingController emojiController =
        TextEditingController(text: l.emoji ?? "📂");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true, // 🔥 THIS FIXES THE KEYBOARD OVERFLOW
        title: Text("Edit: ${l.category}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // 🔥 NEW: ADMIN EMOJI EDITOR (Cleaned UI)
              // ==========================================================
              Row(
                children: [
                  const Text("Emoji:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7))),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: emojiController,
                      style: const TextStyle(fontSize: 28),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 25),

              // ==========================================================
              // TEXT FIELDS (WITH 1-CLICK MAGIC BUTTON)
              // ==========================================================
              ...List.generate(labelsEn.length, (i) {
                String labelTitle = labelsEn[i];
                if (labelsTe.length > i) labelTitle += " / ${labelsTe[i]}";

                String safeLabel = labelsEn[i].toLowerCase();

                // Apply the exact smart rules to the Magic Button!
                bool isTransliterate = (safeLabel.contains("name") &&
                        !safeLabel.contains("crop")) ||
                    safeLabel.contains("person") ||
                    safeLabel.contains("hospital") ||
                    safeLabel.contains("company") ||
                    safeLabel.contains("title") ||
                    safeLabel.contains("location") ||
                    safeLabel.contains("model");

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(labelTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF673AB7))),
                    const SizedBox(height: 5),
                    TextField(
                        controller: enControllers[i],
                        decoration: const InputDecoration(
                            hintText: "English", border: OutlineInputBorder())),
                    const SizedBox(height: 5),

                    // 🔥 TELUGU TEXT BOX WITH MAGIC TRANSLATE BUTTON
                    TextField(
                      controller: teControllers[i],
                      decoration: InputDecoration(
                        hintText: "తెలుగు",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.g_translate,
                              color: Color(0xFF673AB7)),
                          tooltip: "Translate/Transliterate",
                          onPressed: () async {
                            String enText = enControllers[i].text.trim();
                            if (enText.isNotEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      content: Text("Processing..."),
                                      duration: Duration(milliseconds: 700)));

                              // 🔥 SMART ROUTING IN ADMIN PANEL
                              String result = isTransliterate
                                  ? await translationService
                                      .transliterateToTelugu(enText)
                                  : await translationService.translateText(
                                      enText, 'te');

                              teControllers[i].text = result;
                            }
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 25),
                  ],
                );
              })
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              messenger.showSnackBar(SnackBar(
                  content: const Text("Saving updates..."),
                  backgroundColor: Colors.blue.shade700,
                  duration: const Duration(seconds: 1)));

              for (int i = 0; i < 6; i++) {
                String enText = enControllers[i].text.trim();
                String teText = teControllers[i].text.trim();
                String label =
                    (labelsEn.length > i) ? labelsEn[i].toLowerCase() : "";

                bool isSkip = label.contains("phone") ||
                    label.contains("price") ||
                    label.contains("rent") ||
                    label.contains("salary") ||
                    label.contains("fee") ||
                    label.contains("charges") ||
                    label.contains("blood group") ||
                    label.contains("rate");

                bool isTransliterate =
                    (label.contains("name") && !label.contains("crop")) ||
                        label.contains("person") ||
                        label.contains("hospital") ||
                        label.contains("company") ||
                        label.contains("title") ||
                        label.contains("location") ||
                        label.contains("model");

                if (!isSkip) {
                  if (enText.isNotEmpty && teText.isEmpty) {
                    teText = isTransliterate
                        ? await translationService.transliterateToTelugu(enText)
                        : await translationService.translateText(enText, 'te');
                  } else if (teText.isNotEmpty && enText.isEmpty) {
                    enText =
                        await translationService.translateText(teText, 'en');
                  }

                  enControllers[i].text = toTitleCase(enText);

                  if (!RegExp(r'[\u0C00-\u0C7F]').hasMatch(teText)) {
                    teControllers[i].text = toTitleCase(teText);
                  } else {
                    teControllers[i].text = teText;
                  }
                }
              }

              // 🔥 Use Admin's manually selected Emoji. If empty, generate a fallback.
              String finalEmoji = emojiController.text.trim();
              if (finalEmoji.isEmpty) {
                finalEmoji = getFinalEmoji(
                    enControllers[0].text.trim(),
                    l.subCategory ?? "",
                    l.category,
                    enControllers[3].text.trim(),
                    enControllers[2].text.trim());
              }

              String rawPrice =
                  enControllers[4].text.trim().replaceAll(",", "");
              double parsedPrice = double.tryParse(rawPrice) ?? 0.0;

              await FirebaseFirestore.instance
                  .collection('listings')
                  .doc(l.id)
                  .update({
                'f1_en': enControllers[0].text.trim(),
                'f1_te': teControllers[0].text.trim(),
                'f2_en': enControllers[1].text.trim(),
                'f2_te': teControllers[1].text.trim(),
                'f3_en': enControllers[2].text.trim(),
                'f3_te': teControllers[2].text.trim(),
                'f4_en': enControllers[3].text.trim(),
                'f4_te': teControllers[3].text.trim(),
                'f5_en': enControllers[4].text.trim(),
                'f5_te': teControllers[4].text.trim(),
                'f6_en': enControllers[5].text.trim(),
                'f6_te': teControllers[5].text.trim(),
                'emoji': finalEmoji,
                'price': parsedPrice,
              });

              messenger.showSnackBar(const SnackBar(
                  content: Text("Listing updated successfully!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: Colors.green));
            },
            child: const Text("Save Updates"),
          )
        ],
      ),
    );
  }
}

// ==================================================
// 16. ADMIN LOGIN
// ==================================================
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _pin = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextField(
                controller: _pin,
                decoration: const InputDecoration(labelText: "PIN"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  final snap = await FirebaseFirestore.instance
                      .collection('admin')
                      .doc('settings')
                      .get();
                  if (_pin.text == snap.data()?['pin']) {
                    isAdminLoggedIn = true;
                    (await SharedPreferences.getInstance())
                        .setBool('isAdmin', true);
                    Navigator.pop(context);
                  }
                },
                child: const Text("LOGIN"))
          ])),
    );
  }
}

// ==================================================
// 17. STRICT SUBCATEGORY EMOJI MAP (FINAL SYNC)
// ==================================================
final Map<String, String> strictSubCategoryEmoji = {
  // ================= SERVICES =================
  "Electrician": "💡", "Plumber": "🚿", "Mechanic": "🔧", "Carpenter": "🪚",
  "Mason": "🧱", "Painter": "🖌️", "AC Repair": "❄️", "Bore Repair": "🚰",
  "ఎలక్ట్రిషియన్": "💡", "ప్లంబర్": "🚿", "మెకానిక్": "🔧", "కార్పెంటర్": "🪚",
  "మేస్త్రీ": "🧱", "పెయింటర్": "🖌️", "AC రిపేర్": "❄️", "బోర్ రిపేర్": "🚰",

  // ================= FARMERS =================
  "Fruits": "🍎", "Vegetables": "🥕", "Grains": "🌾", "Flowers": "🌸",
  "పండ్లు": "🍎", "కూరగాయలు": "🥕", "ధాన్యాలు": "🌾", "పూలు": "🌸",

  // ================= SHOPS =================
  "Grocery": "🛒", "Medical": "💊", "Bakery": "🍰", "Clothing": "👕",
  "Electronics": "🔌", "Hardware": "🔨",
  "కిరాణా": "🛒", "మెడికల్": "💊", "బేకరీ": "🍰", "దుస్తులు": "👕",
  "ఎలక్ట్రానిక్స్": "🔌", "హార్డ్‌వేర్": "🔨",

  // ================= SCHOOLS =================
  "LKG-10": "🏫", "Intermediate": "📚", "Degree": "🎓", "Coaching": "🧑‍🏫",
  "ఎల్కేజీ నుండి 10వ తరగతి": "🏫", "ఇంటర్మీడియట్": "📚", "డిగ్రీ": "🎓",
  "కోచింగ్": "🧑‍🏫",

  // ================= JOBS =================
  "IT": "💻", "Software": "💻", "Sales": "📈", "Teacher": "👨‍🏫",
  "Driver": "🚕", "Construction": "🏗️",
  "ఐటీ": "💻", "సాఫ్ట్‌వేర్": "💻", "సేల్స్": "📈", "టీచర్": "👨‍🏫",
  "డ్రైవర్": "🚕", "నిర్మాణం": "🏗️",

  // ================= HOSPITALS =================
  "General": "🏥", "Cardiology": "🫀", "Dentist": "🦷", "Eye Care": "👁️",
  "Skin": "🧴",
  "జనరల్": "🏥", "సాధారణ": "🏥", "కార్డియాలజీ": "🫀", "డెంటిస్ట్": "🦷",
  "కంటి వైద్యం": "👁️", "స్కిన్": "🧴",

  // ================= HOUSE RENT =================
  "House": "🏠", "Commercial Rentals": "🏢", "Plot Rentals": "📐",
  "ఇల్లు అద్దెకు": "🏠", "కమర్షియల్ అద్దె": "🏢", "ప్లాట్లు అద్దెకు": "📐",

  // ================= VEHICLE RENTALS =================
  "Auto": "🛺", "Car": "🚗", "Bike": "🏍️", "Tractor": "🚜", "JCB": "🏗️",
  "ఆటో": "🛺", "కారు": "🚗", "బైక్": "🏍️", "ట్రాక్టర్": "🚜",

  // ================= OLD GOODS =================
  "Electronics": "📻", "Furniture": "🛋️", "Vehicles": "🚲", "Books": "📚",
  "ఎలక్ట్రానిక్స్": "📻", "ఫర్నిచర్": "🛋️", "వాహనాలు": "🚲", "పుస్తకాలు": "📚",

  // ================= RESTAURANT =================
  "Veg": "🥦", "Non-Veg": "🍗", "Both": "🍱",
  "వెజ్": "🥦", "నాన్-వెజ్": "🍗", "రెండూ": "🍱",

  // ================= HOTEL ROOMS =================
  "AC": "❄️", "Non-AC": "🛏️",
  "నాన్-AC": "🛏️",

  // ================= HOSTEL =================
  "Boys": "👦", "Girls": "👧",
  "బాయ్స్": "👦", "గర్ల్స్": "👧",

  // ================= LOANS =================
  "Personal Loan": "💰", "Gold Loan": "👑", "Business Loan": "🏢",
  "Home Loan": "🏠",
  "పర్సనల్ లోన్": "💰", "గోల్డ్ లోన్": "👑", "బిజినెస్ లోన్": "🏢",
  "హోమ్ లోన్": "🏠",

  // ================= DEFAULTS =================
  "Others": "📂", "इतर": "📂", "Other": "📂", "ఇతర": "📂", "ఇతరులు": "📂",
};
