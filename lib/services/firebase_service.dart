import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirebaseService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('listings');

  // Flag to prevent multiple submissions within the same service instance
  bool _isSubmitting = false;

  // Helper method for capitalization logic
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // MODIFIED: Uses Future<bool> to return status and ensures single write
  Future<bool> addListing(Listing listing) async {
    // 1) Prevent multiple submission / Prevent double tap
    if (_isSubmitting) return false;

    try {
      _isSubmitting = true;

      // Ensure we are working with a clean map and server-side timestamp
      // 4) Implement bilingual save support: Save both _en and _te fields
      // Apply capitalization to text fields before saving
      Map<String, dynamic> data = {
        'category': listing.category,
        'ownerId': listing.ownerId,
        'f1_en': _capitalize(listing.f1En),
        'f1_te': _capitalize(listing.f1Te),
        'f2_en': listing.f2En,
        'f2_te': listing.f2Te,
        'f3_en': _capitalize(listing.f3En),
        'f3_te': _capitalize(listing.f3Te),
        'f4_en': _capitalize(listing.f4En),
        'f4_te': _capitalize(listing.f4Te),
        'f5_en': listing.f5En,
        'f5_te': listing.f5Te,
        'f6_en': _capitalize(listing.f6En),
        'f6_te': _capitalize(listing.f6Te),
        'desc_en': _capitalize(listing.descEn),
        'desc_te': _capitalize(listing.descTe),
      };

      // Force status to Pending for new submissions and set timestamp
      data['status'] = 'Pending';
      data['timestamp'] = FieldValue.serverTimestamp();
      data['isPinned'] = false;

      // 2) Ensure only one Firestore write per submission (Single Document Addition)
      // 1) Use proper async/await
      DocumentReference docRef = await _db.add(data);

      // 3) After success: Return true
      return docRef.id.isNotEmpty;
    } catch (e) {
      // Log error if necessary and return false to UI
      print("Firebase AddListing Error: $e");
      return false;
    } finally {
      // Reset flag so subsequent submissions are possible if needed
      _isSubmitting = false;
    }
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _db.doc(id).update(data);
  }

  Stream<List<Listing>> getApprovedListings(String category) {
    return _db
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'Approved')
        .orderBy('isPinned', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return Listing.fromFirestore(data, doc.id);
            }).toList());
  }

  Future<void> deleteListing(String id) async {
    await _db.doc(id).delete();
  }

  Future<void> approveListing(String id) async {
    await _db.doc(id).update({'status': 'Approved'});
  }

  Future<void> togglePinned(String id, bool value) async {
    await _db.doc(id).update({'isPinned': value});
  }

  Future<List<Listing>> getPendingListings() async {
    QuerySnapshot snap = await _db.where('status', isEqualTo: 'Pending').get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return Listing.fromFirestore(data, doc.id);
    }).toList();
  }

  Stream<int> getPendingCount() {
    return _db
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<List<Listing>> getMyListings(String deviceId) {
    return FirebaseFirestore.instance
        .collection('listings')
        .where('ownerId', isEqualTo: deviceId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return Listing.fromFirestore(data, doc.id);
            }).toList());
  }
}
