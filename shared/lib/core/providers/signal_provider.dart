import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_models.dart';
import 'firebase_providers.dart';

class SignalCounts {
  final int gotIt;
  final int sortOf;
  final int lost;
  final int total;
  double get lostPercent => total == 0 ? 0.0 : (lost / total) * 100;

  const SignalCounts({
    this.gotIt = 0,
    this.sortOf = 0,
    this.lost = 0,
    this.total = 0,
  });

  factory SignalCounts.fromMap(Map<String, dynamic> m) {
    return SignalCounts(
      gotIt: (m['gotIt'] as num?)?.toInt() ?? 0,
      sortOf: (m['sortOf'] as num?)?.toInt() ?? 0,
      lost: (m['lost'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
    );
  }
}

// Streams the live aggregate signal counts for a session (1 document read)
final liveSignalsProvider = StreamProvider.family<SignalCounts, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .collection('aggregates')
    .doc('signals')
    .snapshots()
    .map((snap) => snap.exists
        ? SignalCounts.fromMap(snap.data()!)
        : const SignalCounts());
});

// Streams the live student count (unique deviceIds in signals subcollection)
final studentCountProvider = StreamProvider.family<int, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .collection('signals')
    .snapshots()
    .map((snap) => snap.size);
});
