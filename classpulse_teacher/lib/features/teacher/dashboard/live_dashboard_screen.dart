import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import 'widgets/signal_ring.dart';
import 'widgets/lost_alert_toast.dart';

class LiveDashboardScreen extends ConsumerStatefulWidget {
  final String sessionId;
  
  const LiveDashboardScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  ConsumerState<LiveDashboardScreen> createState() => _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends ConsumerState<LiveDashboardScreen> {
  bool _dismissedToast = false;
  bool _isActionRunning = false;
  
  void _showNewTopicSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final ctrl = TextEditingController();
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Topic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: 'Topic Name (e.g. Intro to Arrays)',
                  filled: true,
                  fillColor: ClassPulseColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              CPButton(
                label: 'Start Topic',
                onPressed: () async {
                  if (ctrl.text.isEmpty) return;
                  context.pop();
                  setState(() => _isActionRunning = true);
                  try {
                    await FirebaseFunctions.instance.httpsCallable('newTopic').call({
                      'sessionId': widget.sessionId,
                      'topicName': ctrl.text,
                    });
                  } catch (e) {
                    debugPrint('Error starting topic: $e');
                  }
                  if (mounted) setState(() => _isActionRunning = false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmEndSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this session? Students will be redirected to wrap-up.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              context.pop();
              setState(() => _isActionRunning = true);
              try {
                await FirebaseFunctions.instance.httpsCallable('endSession').call({
                  'sessionId': widget.sessionId,
                });
                if (mounted) context.go('/session/${widget.sessionId}/summary');
              } catch (e) {
                debugPrint('Error ending session: $e');
                if (mounted) setState(() => _isActionRunning = false);
              }
            },
            child: const Text('End Session', style: TextStyle(color: ClassPulseColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signalsAsync = ref.watch(liveSignalsProvider(widget.sessionId));
    final studentCountAsync = ref.watch(studentCountProvider(widget.sessionId));
    final currentTopicAsync = ref.watch(currentTopicProvider(widget.sessionId));
    final topicSegmentsAsync = ref.watch(topicSegmentsProvider(widget.sessionId));
    final questionsAsync = ref.watch(questionQueueProvider(widget.sessionId));

    final signals = signalsAsync.valueOrNull ?? const SignalCounts();
    final studentCount = studentCountAsync.valueOrNull ?? 0;
    final currentTopic = currentTopicAsync.valueOrNull ?? 'Loading topic...';
    final topicSegments = topicSegmentsAsync.valueOrNull ?? [];
    final activeQuestions = questionsAsync.valueOrNull ?? [];
    
    final lostPercent = signals.lostPercent;
    final showToast = lostPercent >= 40.0 && !_dismissedToast;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ClassPulseColors.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  if (_isActionRunning) const LinearProgressIndicator(),
                  _buildTopBar(currentTopic, studentCount),
                  const SizedBox(height: 16),
                  _buildSignalsRow(signals),
                  const SizedBox(height: 24),
                  TabBar(
                    labelColor: ClassPulseColors.primary,
                    unselectedLabelColor: ClassPulseColors.onSurfaceVariant,
                    indicatorColor: ClassPulseColors.primary,
                    dividerColor: ClassPulseColors.surfaceContainerHigh,
                    tabs: [
                      const Tab(text: 'Timeline'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Questions Queue'),
                            if (activeQuestions.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: ClassPulseColors.error, borderRadius: BorderRadius.circular(10)),
                                child: Text('${activeQuestions.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ]
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTopicSegments(topicSegments),
                        _buildQuestionQueue(activeQuestions),
                      ],
                    )
                  ),
                ],
              ),
              LostAlertToast(
                visible: showToast,
                lostPercent: lostPercent,
                onDismiss: () => setState(() => _dismissedToast = true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String currentTopic, int studentCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Session',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ClassPulseColors.onSurface),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: ClassPulseColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
                    child: Text('$studentCount joined', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined, color: ClassPulseColors.error),
                    onPressed: _confirmEndSession,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  currentTopic,
                  style: const TextStyle(fontSize: 16, color: ClassPulseColors.secondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _showNewTopicSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Topic'),
                style: TextButton.styleFrom(foregroundColor: ClassPulseColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsRow(SignalCounts signals) {
    final total = signals.total > 0 ? signals.total : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: SignalRing(
              count: signals.gotIt,
              percentage: signals.gotIt / total,
              arcColor: ClassPulseColors.tertiaryFixed,
              label: 'Got it',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SignalRing(
              count: signals.sortOf,
              percentage: signals.sortOf / total,
              arcColor: ClassPulseColors.softOrange,
              label: 'Sort of',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SignalRing(
              count: signals.lost,
              percentage: signals.lost / total,
              arcColor: ClassPulseColors.errorContainer,
              label: 'Lost',
              isPulsing: signals.lostPercent >= 40.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSegments(List<TopicSegment> segments) {
    if (segments.isEmpty) {
      return const Center(child: Text('No topics yet', style: TextStyle(color: ClassPulseColors.onSurfaceVariant)));
    }
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: segments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final seg = segments[segments.length - 1 - index]; // reversed
        final isCurrent = seg.endedAt == null;
        
        final duration = isCurrent 
            ? DateTime.now().difference(seg.startedAt).inMinutes
            : seg.endedAt!.difference(seg.startedAt).inMinutes;

        final total = (seg.gotItCount + seg.sortOfCount + seg.lostCount).toDouble();
        final gotP = total > 0 ? seg.gotItCount / total : 0.0;
        final sortP = total > 0 ? seg.sortOfCount / total : 0.0;
        final lostP = total > 0 ? seg.lostCount / total : 0.0;

        return Stack(
          children: [
            CPCard(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(seg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${duration}m', style: const TextStyle(fontSize: 12, color: ClassPulseColors.secondary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              children: [
                                if (gotP > 0) Expanded(flex: (gotP * 100).toInt(), child: Container(color: ClassPulseColors.tertiaryFixed)),
                                if (sortP > 0) Expanded(flex: (sortP * 100).toInt(), child: Container(color: ClassPulseColors.softOrange)),
                                if (lostP > 0) Expanded(flex: (lostP * 100).toInt(), child: Container(color: ClassPulseColors.errorContainer)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: ClassPulseColors.errorContainer, borderRadius: BorderRadius.circular(12)),
                          child: Text('${seg.lostCount} lost', style: const TextStyle(fontSize: 12, color: ClassPulseColors.error)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isCurrent)
              Positioned(
                left: 0, top: 24, bottom: 24,
                child: Container(width: 4, decoration: BoxDecoration(color: ClassPulseColors.primary, borderRadius: BorderRadius.circular(2))),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionQueue(List<AnonymousQuestion> questions) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(Icons.mark_chat_read_rounded, size: 48, color: ClassPulseColors.outlineVariant),
             const SizedBox(height: 16),
             const Text('Queue is clear!', style: TextStyle(color: ClassPulseColors.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.bold)),
             const Text('Students are following along nicely.', style: TextStyle(color: ClassPulseColors.outlineVariant)),
          ],
        )
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final q = questions[index];
        
        return Dismissible(
          key: Key(q.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            decoration: BoxDecoration(
              color: ClassPulseColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
          ),
          onDismissed: (_) {
             FirebaseFirestore.instance
                .collection('sessions')
                .doc(widget.sessionId)
                .collection('questions')
                .doc(q.id)
                .update({'acknowledged': true});
          },
          child: CPCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: ClassPulseColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(99)),
                      child: Text(_categoryLabel(q.category), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ClassPulseColors.onSurfaceVariant)),
                    ),
                    const Spacer(),
                    Text(
                      '${DateTime.now().difference(q.submittedAt).inMinutes}m ago',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ClassPulseColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  q.text.isEmpty ? '(No distinct text provided. Just general confusion.)' : q.text,
                  style: TextStyle(
                     fontSize: 16, 
                     color: q.text.isEmpty ? ClassPulseColors.outlineVariant : ClassPulseColors.onSurface,
                     fontStyle: q.text.isEmpty ? FontStyle.italic : null,
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                   child: Text(
                     '< Swipe to acknowledge',
                     style: TextStyle(fontSize: 11, color: ClassPulseColors.outlineVariant),
                   )
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryLabel(QuestionCategory cat) {
    switch (cat) {
      case QuestionCategory.doubt: return '💬 Doubt';
      case QuestionCategory.repeat: return '🔄 Repeat';
      case QuestionCategory.slowDown: return '🐢 Slow Down';
    }
  }
}
