import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirebaseService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('listings');

  Future<void> addListing(Listing listing) async {
    await _db.add(listing.toMap());
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
}
