import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String id;
  final String category;
  final String ownerId;
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
  final String descEn;
  final String descTe;
  final String status;
  final bool isPinned;
  final dynamic timestamp;

  Listing({
    required this.id,
    required this.category,
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
    required this.descEn,
    required this.descTe,
    this.status = 'Pending',
    this.isPinned = false,
    this.timestamp,
  });

  // HELPER METHOD: Returns main highlight based on category and current language
  String getHighlightedTitle(String language) {
    bool isEng = language == "English";

    switch (category) {
      case "Farmers":
        return isEng ? f3En : f3Te;
      case "Shops":
        return isEng ? f1En : f1Te;
      case "Services":
        return isEng ? f1En : f1Te;
      case "Jobs":
        return isEng ? f1En : f1Te;
      case "Hospitals":
        return isEng ? f1En : f1Te;
      case "Emergency":
        return isEng ? f1En : f1Te;
      case "Schools":
        return isEng ? f1En : f1Te;
      case "Hotels":
        return isEng ? f1En : f1Te;
      case "Old Goods":
        return isEng ? f1En : f1Te;
      case "House Rent":
        return isEng ? f1En : f1Te;
      case "Vehicle Rentals":
        return isEng ? f1En : f1Te;
      default:
        return isEng ? f1En : f1Te;
    }
  }

  factory Listing.fromFirestore(Map<String, dynamic>? data, String id) {
    final Map<String, dynamic> doc = data ?? {};

    return Listing(
      id: id,
      category: doc['category']?.toString() ?? '',
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
      descEn: doc['desc_en']?.toString() ?? '',
      descTe: doc['desc_te']?.toString() ?? '',
      status: doc['status']?.toString() ?? 'Pending',
      isPinned: doc['isPinned'] is bool ? doc['isPinned'] : false,
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
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
      'desc_en': descEn,
      'desc_te': descTe,
      'status': status,
      'isPinned': isPinned,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
