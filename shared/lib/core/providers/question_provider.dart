import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_models.dart';
import 'firebase_providers.dart';

AnonymousQuestion _questionFromDoc(DocumentSnapshot doc) {
  final d = doc.data() as Map<String, dynamic>;
  return AnonymousQuestion(
    id: doc.id,
    sessionId: d['sessionId'] ?? '',
    topicSegmentId: d['topicSegmentId'] ?? '',
    text: d['text'] ?? '',
    category: QuestionCategory.values.firstWhere(
      (c) => c.name == (d['category'] ?? 'doubt'),
      orElse: () => QuestionCategory.doubt,
    ),
    submittedAt: (d['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    acknowledged: d['acknowledged'] ?? false,
  );
}

// Active (unacknowledged) questions for teacher queue
final questionQueueProvider = StreamProvider.family<List<AnonymousQuestion>, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .collection('questions')
    .where('acknowledged', isEqualTo: false)
    .orderBy('submittedAt', descending: false)
    .snapshots()
    .map((snap) => snap.docs.map(_questionFromDoc).toList());
});

// All questions (for filtering by category)
final allQuestionsProvider = StreamProvider.family<List<AnonymousQuestion>, String>((ref, sessionId) {
  final db = ref.watch(firestoreProvider);
  return db
    .collection('sessions')
    .doc(sessionId)
    .collection('questions')
    .orderBy('submittedAt', descending: false)
    .snapshots()
    .map((snap) => snap.docs.map(_questionFromDoc).toList());
});
