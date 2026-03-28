import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_models.dart';
import 'firebase_providers.dart';

TopicSegment _segmentFromDoc(DocumentSnapshot doc) {
  final d = doc.data() as Map<String, dynamic>;
  return TopicSegment(
    id: doc.id,
    sessionId: d['sessionId'] ?? '',
    name: d['name'] ?? '',
    startedAt: (d['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    endedAt: (d['endedAt'] as Timestamp?)?.toDate(),
    gotItCount: (d['gotItCount'] as num?)?.toInt() ?? 0,
    sortOfCount: (d['sortOfCount'] as num?)?.toInt() ?? 0,
    lostCount: (d['lostCount'] as num?)?.toInt() ?? 0,
  );
}

// All topic segments for a session in chronological order
final topicSegmentsProvider = StreamProvider.family<List<TopicSegment>, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .collection('topicSegments')
    .orderBy('startedAt', descending: false)
    .snapshots()
    .map((snap) => snap.docs.map(_segmentFromDoc).toList());
});

// The current active topic name (streams session doc)
final currentTopicProvider = StreamProvider.family<String, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .snapshots()
    .map((snap) => snap.data()?['currentTopic'] as String? ?? '');
});

// Session status — used by student to detect session end
final sessionStatusProvider = StreamProvider.family<String, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .snapshots()
    .map((snap) => snap.data()?['status'] as String? ?? 'active');
});
