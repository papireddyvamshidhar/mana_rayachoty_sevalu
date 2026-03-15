import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';

class FirebaseService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('listings');
  bool _isSubmitting = false;

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // =========================================================
  // 1. PRIMARY SUBMISSION (BILINGUAL + STRUCTURAL)
  // =========================================================
  Future<bool> addListing(Listing listing) async {
    if (_isSubmitting) return false;
    try {
      _isSubmitting = true;
      Map<String, dynamic> data = listing.toMap();
      data['timestamp'] = FieldValue.serverTimestamp();

      DocumentReference dr = await _db.add(data);
      return dr.id.isNotEmpty;
    } catch (e) {
      debugPrint("AddListing Error: $e");
      return false;
    } finally {
      _isSubmitting = false;
    }
  }

  // =========================================================
  // 2. RETRIEVAL (ROBUST VISIBILITY FIX)
  // =========================================================
  Stream<List<Listing>> getApprovedListings(String cat, {String? subCategory}) {
    Query q = _db
        .where('category', isEqualTo: cat)
        .where('status', isEqualTo: 'approved')
        .orderBy('timestamp', descending: true);

    return q.snapshots().map((snap) {
      return snap.docs
          .map((doc) => Listing.fromFirestore(
              doc.data() as Map<String, dynamic>?, doc.id))
          .where((l) {
        bool matchesSub = true;
        if (subCategory != null &&
            subCategory != "All" &&
            subCategory != "అన్నీ") {
          matchesSub =
              (l.subCategory ?? "").toLowerCase() == subCategory.toLowerCase();
        }

        return matchesSub;
      }).toList()
        ..sort((a, b) {
          if (a.isPinned == b.isPinned) return 0;
          return a.isPinned ? -1 : 1;
        });
    });
  }

  Stream<List<Listing>> getMyListings(String deviceId) {
    return _db.where('ownerId', isEqualTo: deviceId).snapshots().map((snap) =>
        snap.docs
            .map((doc) => Listing.fromFirestore(
                doc.data() as Map<String, dynamic>?, doc.id))
            .toList());
  }

  // =========================================================
  // 3. ADMIN & HELPER METHODS (PRESERVED)
  // =========================================================
  Future<void> rejectListing(String id) async =>
      await _db.doc(id).update({'status': 'rejected'});
  Future<void> updateListing(String id, Map<String, dynamic> data) async =>
      await _db.doc(id).update(data);

  Future<void> deleteListing(String id) async => await _db.doc(id).delete();

  Future<void> approveListing(String id) async =>
      await _db.doc(id).update({'status': 'approved'});

  Future<void> togglePinned(String id, bool value) async =>
      await _db.doc(id).update({'isPinned': value});

  Future<void> flagListing(String id) async =>
      await _db.doc(id).update({'is_flagged': true});

  Stream<int> getPendingCount() => _db
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.docs.length);

  // =========================================================
  // 4. EMERGENCY & MOVIES (AUTO-SEEDING PRESERVED)
  // =========================================================
  Stream<List<Map<String, dynamic>>> getEmergencyServices() {
    seedEmergencyDataIfEmpty();
    return FirebaseFirestore.instance
        .collection('emergency_services')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final d = doc.data();
              d['id'] = doc.id;
              return d;
            }).toList());
  }

  Future<void> seedEmergencyDataIfEmpty() async {
    final col = FirebaseFirestore.instance.collection('emergency_services');
    final snap = await col.limit(1).get();
    if (snap.docs.isEmpty) {
      final services = [
        {
          'name_en': 'Ambulance',
          'name_te': 'అంబులెన్స్',
          'phone': '108',
          'order': 1
        },
        {'name_en': 'Police', 'name_te': 'పోలీస్', 'phone': '112', 'order': 2},
        {
          'name_en': 'Fire Engine',
          'name_te': 'అగ్నిమాపక దళం',
          'phone': '101',
          'order': 3
        },
        {'name_en': 'Disha', 'name_te': 'దిశ', 'phone': '181', 'order': 4},
        {
          'name_en': 'Electricity',
          'name_te': 'విద్యుత్ శాఖ',
          'phone': '1912',
          'order': 7
        },
        {
          'name_en': 'Arogya Sree',
          'name_te': 'ఆరోగ్య శ్రీ',
          'phone': '104',
          'order': 8
        },
        {
          'name_en': 'Crime Against Women',
          'name_te': 'మహిళలపై క్రైమ్',
          'phone': '1091',
          'order': 11
        },
      ];
      for (var s in services) {
        await col.add(s);
      }
    }
  }

  Stream<List<Map<String, dynamic>>> getMovieTheatres() {
    seedMoviesTheatresIfEmpty();
    return FirebaseFirestore.instance
        .collection('movies_theatres')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final d = doc.data();
              d['id'] = doc.id;
              return d;
            }).toList());
  }

  Future<void> seedMoviesTheatresIfEmpty() async {
    final col = FirebaseFirestore.instance.collection('movies_theatres');
    final snap = await col.limit(1).get();
    if (snap.docs.isEmpty) {
      final theatres = [
        {
          'theatreName': 'Gowtham Cinemas',
          'movieName': '',
          'lastUpdated': FieldValue.serverTimestamp()
        },
        {
          'theatreName': 'Prasad Theatre',
          'movieName': '',
          'lastUpdated': FieldValue.serverTimestamp()
        },
        {
          'theatreName': 'Sai Theatre',
          'movieName': '',
          'lastUpdated': FieldValue.serverTimestamp()
        },
      ];
      for (var t in theatres) {
        await col.add(t);
      }
    }
  }
}
