import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final String category;
  final String? subCategory;
  final String ownerId;

  // Bilingual Core Fields (Original f1-f6 preserved for background compatibility)
  final String f1En;
  final String f1Te;
  final String f2En;
  final String f2Te;
  final String f3En;
  final String f3Te;
  final String f4En;
  final String f4Te;
  final String f5En;
  final String f5Te;
  final String f6En;
  final String f6Te;

  // New Structural Fields for UI Clarity & Bug Fixes
  final double price;
  final String priceUnitEn;
  final String priceUnitTe;
  final String locationEn;
  final String locationTe;

  final String descEn;
  final String descTe;
  final String status;
  final bool isPinned;
  final bool isFlagged;
  final dynamic timestamp;
  final String? emoji;

  Listing({
    required this.id,
    required this.category,
    this.subCategory,
    required this.ownerId,
    required this.f1En,
    required this.f1Te,
    required this.f2En,
    required this.f2Te,
    required this.f3En,
    required this.f3Te,
    required this.f4En,
    required this.f4Te,
    required this.f5En,
    required this.f5Te,
    required this.f6En,
    required this.f6Te,
    required this.price,
    required this.priceUnitEn,
    required this.priceUnitTe,
    required this.locationEn,
    required this.locationTe,
    required this.descEn,
    required this.descTe,
    this.status = "pending",
    this.isPinned = false,
    this.isFlagged = false,
    this.timestamp,
    this.emoji,
  });

  // Helper for green price display in feeds
  String getFormattedPrice(bool isTelugu) {
    final unit = isTelugu ? priceUnitTe : priceUnitEn;
    final formattedVal =
        price % 1 == 0 ? price.toInt().toString() : price.toStringAsFixed(2);
    return "₹$formattedVal $unit";
  }

  // Automatic Emoji Detection (Covers all Rayachoty app categories)
  static String getFinalEmoji(
      String name, String subCategory, String category) {
    final text = name.toLowerCase();
    final sub = subCategory.toLowerCase();
    final cat = category.toLowerCase();

    if (cat.contains("blood") ||
        sub.contains("+") ||
        sub.contains("-") ||
        sub.contains("blood")) return "🩸";
    if (cat.contains("emergency")) return "🚨";
    if (sub.contains("ambulance")) return "🚑";
    if (cat.contains("farmer")) return "🌾";
    if (text.contains("apple")) return "🍎";
    if (cat.contains("service")) return "🛠";
    if (sub.contains("electrician")) return "💡";
    if (cat.contains("job")) return "💼";
    if (cat.contains("hospital")) return "🏥";
    if (cat.contains("school")) return "🏫";
    if (cat.contains("rent") || sub.contains("house")) return "🏠";
    if (cat.contains("vehicle")) return "🚗";
    if (cat.contains("shop")) return "🛒";
    if (cat.contains("restaurant")) return "🍔";
    if (cat.contains("movie")) return "🎬";
    if (cat.contains("loan")) return "🏦";

    return "📂";
  }

  factory Listing.fromFirestore(Map<String, dynamic>? data, String id) {
    final doc = data ?? {};
    final storedEmoji = doc['emoji']?.toString();

    return Listing(
      id: id,
      category: doc['category']?.toString() ?? '',
      subCategory: doc['sub_category']?.toString(),
      ownerId: doc['ownerId']?.toString() ?? '',
      f1En: doc['f1_en']?.toString() ?? '',
      f1Te: doc['f1_te']?.toString() ?? '',
      f2En: doc['f2_en']?.toString() ?? '',
      f2Te: doc['f2_te']?.toString() ?? '',
      f3En: doc['f3_en']?.toString() ?? '',
      f3Te: doc['f3_te']?.toString() ?? '',
      f4En: doc['f4_en']?.toString() ?? '',
      f4Te: doc['f4_te']?.toString() ?? '',
      f5En: doc['f5_en']?.toString() ?? '',
      f5Te: doc['f5_te']?.toString() ?? '',
      f6En: doc['f6_en']?.toString() ?? '',
      f6Te: doc['f6_te']?.toString() ?? '',
      price: double.tryParse(doc['price']?.toString() ?? '0') ?? 0.0,
      priceUnitEn: doc['price_unit_en']?.toString() ?? '',
      priceUnitTe: doc['price_unit_te']?.toString() ?? '',
      locationEn: doc['location_en']?.toString() ?? '',
      locationTe: doc['location_te']?.toString() ?? '',
      descEn: doc['desc_en']?.toString() ?? '',
      descTe: doc['desc_te']?.toString() ?? '',
      status: doc['status']?.toString() ?? 'pending',
      isPinned: doc['isPinned'] == true,
      isFlagged: doc['is_flagged'] == true,
      timestamp: doc['timestamp'],
      emoji: (storedEmoji == null || storedEmoji.isEmpty)
          ? getFinalEmoji(
              doc['f1_en']?.toString() ?? '',
              doc['sub_category']?.toString() ?? '',
              doc['category']?.toString() ?? '')
          : storedEmoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'sub_category': subCategory,
      'ownerId': ownerId,
      'f1_en': f1En,
      'f1_te': f1Te,
      'f2_en': f2En,
      'f2_te': f2Te,
      'f3_en': f3En,
      'f3_te': f3Te,
      'f4_en': f4En,
      'f4_te': f4Te,
      'f5_en': f5En,
      'f5_te': f5Te,
      'f6_en': f6En,
      'f6_te': f6Te,
      'price': price,
      'price_unit_en': priceUnitEn,
      'price_unit_te': priceUnitTe,
      'location_en': locationEn,
      'location_te': locationTe,
      'desc_en': descEn,
      'desc_te': descTe,
      'status': status,
      'isPinned': isPinned,
      'is_flagged': isFlagged,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'emoji': emoji ?? getFinalEmoji(f1En, subCategory ?? "", category),
    };
  }
}
