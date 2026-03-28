import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 1: onSignalWrite
// Fires on any create/update/delete to a student signal document.
// Maintains the aggregated counter in sessions/{id}/aggregates/signals
// ─────────────────────────────────────────────────────────────────────────────
export const onSignalWrite = functions.firestore
  .document("sessions/{sessionId}/signals/{deviceId}")
  .onWrite(async (change, context) => {
    const {sessionId} = context.params;
    const aggregateRef = db
      .collection("sessions")
      .doc(sessionId)
      .collection("aggregates")
      .doc("signals");

    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    await db.runTransaction(async (tx) => {
      const aggSnap = await tx.get(aggregateRef);
      const agg = aggSnap.exists
        ? aggSnap.data()!
        : {gotIt: 0, sortOf: 0, lost: 0, total: 0};

      // Remove old signal contribution
      if (before?.signal) {
        const key = signalKey(before.signal);
        agg[key] = Math.max(0, (agg[key] ?? 0) - 1);
        if (!after) agg.total = Math.max(0, (agg.total ?? 1) - 1); // DELETE
      }

      // Add new signal contribution
      if (after?.signal) {
        const key = signalKey(after.signal);
        agg[key] = (agg[key] ?? 0) + 1;
        if (!before) agg.total = (agg.total ?? 0) + 1; // CREATE
      }

      agg.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      tx.set(aggregateRef, agg, {merge: true});
    });
  });

function signalKey(signal: string): string {
  switch (signal) {
    case "gotIt": return "gotIt";
    case "sortOf": return "sortOf";
    case "lost": return "lost";
    default: return "gotIt";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 2: onQuestionCreate
// Fires when a student submits an anonymous question.
// Increments total question count in the aggregate doc.
// ─────────────────────────────────────────────────────────────────────────────
export const onQuestionCreate = functions.firestore
  .document("sessions/{sessionId}/questions/{questionId}")
  .onCreate(async (snap, context) => {
    const {sessionId} = context.params;
    const aggregateRef = db
      .collection("sessions")
      .doc(sessionId)
      .collection("aggregates")
      .doc("signals");

    await aggregateRef.set(
      {totalQuestions: admin.firestore.FieldValue.increment(1)},
      {merge: true}
    );
  });

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 3: endSession  (HTTP Callable)
// Teacher calls this to end a live session.
// Sets status=ended, closes open topic segment, writes final summary.
// ─────────────────────────────────────────────────────────────────────────────
export const endSession = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");

  const {sessionId} = data as {sessionId: string};
  if (!sessionId) throw new functions.https.HttpsError("invalid-argument", "sessionId required.");

  const sessionRef = db.collection("sessions").doc(sessionId);
  const sessionSnap = await sessionRef.get();
  if (!sessionSnap.exists) throw new functions.https.HttpsError("not-found", "Session not found.");

  const now = admin.firestore.Timestamp.now();

  // Close any open topic segment
  const openSegments = await sessionRef
    .collection("topicSegments")
    .where("endedAt", "==", null)
    .get();

  const batch = db.batch();
  openSegments.forEach((seg) => batch.update(seg.ref, {endedAt: now}));

  // Mark session as ended
  batch.update(sessionRef, {status: "ended", endedAt: now});
  await batch.commit();

  // Compute and write summary
  const allSegments = await sessionRef.collection("topicSegments").orderBy("startedAt").get();
  const aggSnap = await sessionRef.collection("aggregates").doc("signals").get();
  const agg = aggSnap.data() ?? {};

  const peakLostPct = allSegments.docs.reduce((max, seg) => {
    const d = seg.data();
    const total = (d.gotItCount ?? 0) + (d.sortOfCount ?? 0) + (d.lostCount ?? 0);
    const pct = total > 0 ? ((d.lostCount ?? 0) / total) * 100 : 0;
    return Math.max(max, pct);
  }, 0);

  await sessionRef.collection("summary").doc("result").set({
    sessionId,
    totalQuestions: agg.totalQuestions ?? 0,
    peakLostPct,
    segments: allSegments.docs.map((s) => ({id: s.id, ...s.data()})),
    createdAt: now,
  });

  return {success: true};
});

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 4: newTopic  (HTTP Callable)
// Teacher starts a new topic — closes old segment, creates a new one.
// ─────────────────────────────────────────────────────────────────────────────
export const newTopic = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");

  const {sessionId, topicName} = data as {sessionId: string; topicName: string};
  if (!sessionId || !topicName) {
    throw new functions.https.HttpsError("invalid-argument", "sessionId and topicName required.");
  }

  const sessionRef = db.collection("sessions").doc(sessionId);
  const now = admin.firestore.Timestamp.now();

  // Close previous open segment
  const openSegments = await sessionRef
    .collection("topicSegments")
    .where("endedAt", "==", null)
    .get();

  const batch = db.batch();
  openSegments.forEach((seg) => batch.update(seg.ref, {endedAt: now}));

  // Create new segment
  const newSegRef = sessionRef.collection("topicSegments").doc();
  batch.set(newSegRef, {
    id: newSegRef.id,
    sessionId,
    name: topicName,
    startedAt: now,
    endedAt: null,
    gotItCount: 0,
    sortOfCount: 0,
    lostCount: 0,
  });

  // Update session's currentTopic
  batch.update(sessionRef, {currentTopic: topicName});
  await batch.commit();

  return {success: true, segmentId: newSegRef.id};
});

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTION 5: getSessionSummary  (HTTP Callable)
// Returns the full session summary with topic breakdowns.
// ─────────────────────────────────────────────────────────────────────────────
export const getSessionSummary = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");

  const {sessionId} = data as {sessionId: string};
  const summarySnap = await db
    .collection("sessions")
    .doc(sessionId)
    .collection("summary")
    .doc("result")
    .get();

  if (!summarySnap.exists) {
    throw new functions.https.HttpsError("not-found", "Summary not ready yet.");
  }

  return summarySnap.data();
});
