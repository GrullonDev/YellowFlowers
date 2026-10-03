import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSyncService {
  FirestoreSyncService();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCollection(String userId) =>
      _db.collection('users').doc(userId).collection('garden_data');

  Future<void> backupStreak({
    required String userId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastVisit,
  }) async {
    try {
      await _userCollection(userId).doc('streak').set({
        'current': currentStreak,
        'longest': longestStreak,
        'lastVisit': Timestamp.fromDate(lastVisit),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Sync] Streak backup failed: $e');
    }
  }

  Future<Map<String, dynamic>?> restoreStreak(String userId) async {
    try {
      final doc = await _userCollection(userId).doc('streak').get();
      return doc.data();
    } catch (e) {
      debugPrint('[Sync] Streak restore failed: $e');
      return null;
    }
  }

  Future<void> backupMoodHistory({
    required String userId,
    required List<Map<String, dynamic>> entries,
  }) async {
    try {
      final batch = _db.batch();
      final col = _userCollection(userId);
      for (final entry in entries) {
        final docId =
            entry['date'] as String? ?? DateTime.now().toIso8601String();
        batch.set(
            col.doc('mood_$docId'),
            {
              ...entry,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[Sync] Mood backup failed: $e');
    }
  }
}
