enum SessionStatus { active, ended }
enum SignalType { gotIt, sortOf, lost }
enum QuestionCategory { doubt, repeat, slowDown }

class ClassSession {
  final String id;
  final String teacherId;
  final String title;
  final String currentTopic;
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int studentCount;

  ClassSession({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.currentTopic,
    required this.status,
    required this.createdAt,
    this.endedAt,
    this.studentCount = 0,
  });
}

class TopicSegment {
  final String id;
  final String sessionId;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int gotItCount;
  final int sortOfCount;
  final int lostCount;

  TopicSegment({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.startedAt,
    this.endedAt,
    this.gotItCount = 0,
    this.sortOfCount = 0,
    this.lostCount = 0,
  });
}

class StudentSignal {
  final String sessionId;
  final String anonymousDeviceId;
  final SignalType signal;
  final DateTime updatedAt;

  StudentSignal({
    required this.sessionId,
    required this.anonymousDeviceId,
    required this.signal,
    required this.updatedAt,
  });
}

class AnonymousQuestion {
  final String id;
  final String sessionId;
  final String topicSegmentId;
  final String text;
  final QuestionCategory category;
  final DateTime submittedAt;
  final bool acknowledged;

  AnonymousQuestion({
    required this.id,
    required this.sessionId,
    required this.topicSegmentId,
    required this.text,
    required this.category,
    required this.submittedAt,
    this.acknowledged = false,
  });
}

class SessionSummary {
  final String sessionId;
  final List<TopicSegment> segments;
  final int totalQuestions;
  final double peakLostPct;
  final String? aiSummary;

  SessionSummary({
    required this.sessionId,
    required this.segments,
    required this.totalQuestions,
    required this.peakLostPct,
    this.aiSummary,
  });
}
