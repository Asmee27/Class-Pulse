import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:shared/shared.dart';

import '../../../core/widgets/navigation/cp_bottom_nav.dart';
import '../../../core/widgets/navigation/cp_side_nav.dart';
import '../../../core/widgets/cp_stat_tile.dart';
import '../../../core/widgets/cp_live_indicator.dart';
import '../../../core/widgets/buttons/cp_primary_gradient_button.dart';
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
              Text('New Topic', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: 'Topic Name (e.g. Intro to Arrays)',
                  filled: true,
                  fillColor: const Color(0xFFF1F4FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              CPPrimaryGradientButton(
                label: 'Start Topic',
                onTap: () async {
                  if (ctrl.text.isEmpty) return;
                  context.pop();
                  setState(() => _isActionRunning = true);
                  try {
                    final topicsRef = FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).collection('topics');
                    final now = FieldValue.serverTimestamp();
                    final activeQuery = await topicsRef.where('endedAt', isNull: true).get();
                    for (var doc in activeQuery.docs) {
                      await doc.reference.update({'endedAt': now});
                    }
                    final newTopicRef = topicsRef.doc();
                    await newTopicRef.set({
                      'id': newTopicRef.id,
                      'sessionId': widget.sessionId,
                      'name': ctrl.text,
                      'startedAt': now,
                      'endedAt': null,
                      'gotItCount': 0, 'sortOfCount': 0, 'lostCount': 0,
                    });
                    await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).update({
                      'currentTopic': ctrl.text,
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
        title: Text('End Session?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF253153))),
        content: Text('Are you sure you want to end this session? Students will be redirected to wrap-up.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF45464E))),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF5A5E6E)))),
          TextButton(
            onPressed: () async {
              context.pop();
              setState(() => _isActionRunning = true);
              try {
                final now = FieldValue.serverTimestamp();
                await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).update({
                  'status': 'ended',
                  'endedAt': now,
                });
                final topicsRef = FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).collection('topics');
                final activeQuery = await topicsRef.where('endedAt', isNull: true).get();
                for (var doc in activeQuery.docs) {
                  await doc.reference.update({'endedAt': now});
                }
                if (mounted) context.go('/session/${widget.sessionId}/summary');
              } catch (e) {
                debugPrint('Error ending session: $e');
                if (mounted) setState(() => _isActionRunning = false);
              }
            },
            child: Text('End Session', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF93000A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    
    final signalsAsync = ref.watch(liveSignalsProvider(widget.sessionId));
    final studentCountAsync = ref.watch(studentCountProvider(widget.sessionId));
    final currentTopicAsync = ref.watch(currentTopicProvider(widget.sessionId));
    final topicSegmentsAsync = ref.watch(topicSegmentsProvider(widget.sessionId));

    final signals = signalsAsync.valueOrNull ?? const SignalCounts();
    final studentCount = studentCountAsync.valueOrNull ?? 0;
    final currentTopic = currentTopicAsync.valueOrNull ?? 'Loading topic...';
    final topicSegments = topicSegmentsAsync.valueOrNull ?? [];
    
    final lostPercent = signals.lostPercent;
    final showToast = lostPercent >= 40.0 && !_dismissedToast;
    final total = signals.total > 0 ? signals.total : 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: Stack(
        children: [
          if (isDesktop) const Align(alignment: Alignment.centerLeft, child: CPSideNav(activeIndex: 1)),
          Padding(
            padding: EdgeInsets.only(left: isDesktop ? 80 : 0, bottom: isDesktop ? 0 : 80),
            child: Column(
              children: [
                if (_isActionRunning) const LinearProgressIndicator(),
                _TopNav(currentTopic: currentTopic, onNewTopic: _showNewTopicSheet),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 48 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroHeader(studentCount: studentCount),
                        const SizedBox(height: 48),
                        _InsightsBentoGrid(signals: signals, total: total),
                        const SizedBox(height: 64),
                        _TopicTimeline(segments: topicSegments),
                        const SizedBox(height: 64), // extra padding for fab
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isDesktop) const Align(alignment: Alignment.bottomCenter, child: CPBottomNav(activeIndex: 1)),
          LostAlertToast(
            visible: showToast,
            lostPercent: lostPercent,
            onDismiss: () => setState(() => _dismissedToast = true),
          ),
          Positioned(
            bottom: isDesktop ? 48 : 100,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF253153), Color(0xFF3C486B)]),
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [BoxShadow(color: const Color(0xFF253153).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: _confirmEndSession,
                icon: const Icon(Icons.campaign, color: Colors.white),
                label: Text('End Session', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final String currentTopic;
  final VoidCallback onNewTopic;
  const _TopNav({required this.currentTopic, required this.onNewTopic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text('ClassPulse', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF253153))),
                const SizedBox(width: 16),
                Container(width: 1, height: 24, color: const Color(0xFFE5E8EF)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(currentTopic, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF5A5E6E))),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                height: 40, width: 140,
                child: CPPrimaryGradientButton(label: 'New Topic', onTap: onNewTopic),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE5E8EF),
                child: Icon(Icons.person, size: 16, color: Color(0xFF5A5E6E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final int studentCount;
  const _HeroHeader({required this.studentCount});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CPLiveIndicator(),
        const SizedBox(height: 12),
        Text('Student Comprehension', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w800, color: const Color(0xFF253153), letterSpacing: -0.72)),
        const SizedBox(height: 8),
        Text('Monitoring real-time feedback for CS101...', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF45464E))),
      ],
    );

    final statsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CPStatTile(icon: Icons.groups, number: '$studentCount', label: 'ACTIVE STUDENTS'),
        const SizedBox(width: 16),
        const CPStatTile(icon: Icons.timer, number: '24:15', label: 'SESSION TIME'),
      ],
    );
    
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: textContent),
              const SizedBox(width: 48),
              statsRow,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textContent,
              const SizedBox(height: 24),
              statsRow,
            ],
          );
  }
}

class _InsightsBentoGrid extends StatelessWidget {
  final SignalCounts signals;
  final int total;
  const _InsightsBentoGrid({required this.signals, required this.total});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900 ? 3 : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 32,
          crossAxisSpacing: 24,
          childAspectRatio: cols == 1 ? 2.0 : 1.1,
          children: [
            _InsightBentoCard(
              chipLabel: 'Got It',
              chipBg: const Color(0xFFD2E6EF), chipTextColor: const Color(0xFF374951),
              icon: Icons.sentiment_satisfied_rounded, iconColor: const Color(0xFF253153), iconBg: const Color(0xFFD2E6EF).withOpacity(0.4),
              progressValue: signals.gotIt / total,
              count: signals.gotIt,
              progressColor: const Color(0xFF253153),
              description: 'Most students are comfortable and tracking cleanly.',
            ),
            _InsightBentoCard(
              chipLabel: 'Sort Of',
              chipBg: const Color(0xFFFFF3E0), chipTextColor: const Color(0xFFE65100),
              icon: Icons.sentiment_neutral_rounded, iconColor: const Color(0xFFE65100), iconBg: const Color(0xFFFFF3E0).withOpacity(0.6),
              progressValue: signals.sortOf / total,
              count: signals.sortOf,
              progressColor: const Color(0xFFE65100),
              description: 'Students have minor doubts but are keeping up.',
            ),
            _InsightBentoCard(
              chipLabel: 'Lost',
              chipBg: const Color(0xFFFFDAD6), chipTextColor: const Color(0xFF93000A),
              icon: Icons.sentiment_very_dissatisfied_rounded, iconColor: const Color(0xFF93000A), iconBg: const Color(0xFFFFDAD6).withOpacity(0.5),
              progressValue: signals.lost / total,
              count: signals.lost,
              progressColor: const Color(0xFF93000A),
              description: 'High priority: these students have lost the thread.',
            ),
          ],
        );
      }
    );
  }
}

class _InsightBentoCard extends StatelessWidget {
  final String chipLabel;
  final Color chipBg, chipTextColor;
  final Color iconBg;
  final int count;
  final IconData icon;
  final Color iconColor;
  final String description;
  final double progressValue;
  final Color progressColor;

  const _InsightBentoCard({
    required this.chipLabel, required this.chipBg, required this.chipTextColor,
    required this.iconBg, required this.count,
    required this.icon, required this.iconColor, required this.description,
    required this.progressValue, required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -14, left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Text(chipLabel.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: chipTextColor),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: const Color(0xFF181C21).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))],
            border: Border.all(color: const Color(0xFFC6C6CF).withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
                    child: Icon(icon, size: 32, color: iconColor),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      tween: Tween<double>(begin: 0, end: progressValue * 100),
                      builder: (context, value, child) => Text(
                        '${value.toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48, fontWeight: FontWeight.w900,
                          color: const Color(0xFF253153), letterSpacing: -1.0, height: 1.0,
                        ),
                      ),
                    ),
                    Text('$count Students', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF5A5E6E))),
                  ]),
                ],
              ),
              const Spacer(),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: 0, end: progressValue),
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E8EF),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(description, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45464E), height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicTimeline extends StatelessWidget {
  final List<TopicSegment> segments;
  const _TopicTimeline({required this.segments});

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Topic Timeline', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF253153))),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left, color: Color(0xFF253153))),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right, color: Color(0xFF253153))),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: segments.reversed.map((seg) => _TopicCard(segment: seg)).toList(),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicSegment segment;
  const _TopicCard({required this.segment});

  @override
  Widget build(BuildContext context) {
    final isCurrent = segment.endedAt == null;
    final duration = isCurrent 
        ? DateTime.now().difference(segment.startedAt).inMinutes
        : segment.endedAt!.difference(segment.startedAt).inMinutes;

    final total = (segment.gotItCount + segment.sortOfCount + segment.lostCount);
    final gotP = total > 0 ? (segment.gotItCount / total * 100).toInt() : 0;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, top: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.white : const Color(0xFFF1F4FB),
        borderRadius: BorderRadius.circular(16),
        border: isCurrent ? Border.all(color: const Color(0xFF253153), width: 2) : const Border(left: BorderSide(color: Color(0xFF253153), width: 4)),
        boxShadow: isCurrent ? [BoxShadow(color: const Color(0xFF181C21).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))] : [],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isCurrent)
            Positioned(
              top: -36, right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF253153), borderRadius: BorderRadius.circular(9999)),
                child: Text('CURRENT', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${duration}m', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isCurrent ? const Color(0xFF253153) : const Color(0xFF5A5E6E))),
              const SizedBox(height: 8),
              Text(segment.name, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF253153))),
              const SizedBox(height: 24),
              Row(
                children: [
                  _MiniStat(icon: Icons.sentiment_satisfied_rounded, color: const Color(0xFF374951), bgColor: const Color(0xFFD2E6EF), count: segment.gotItCount),
                  const SizedBox(width: 8),
                  _MiniStat(icon: Icons.sentiment_neutral_rounded, color: const Color(0xFFE65100), bgColor: const Color(0xFFFFF3E0), count: segment.sortOfCount),
                  const SizedBox(width: 8),
                  _MiniStat(icon: Icons.sentiment_very_dissatisfied_rounded, color: const Color(0xFF93000A), bgColor: const Color(0xFFFFDAD6), count: segment.lostCount),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color, bgColor;
  final int count;
  const _MiniStat({required this.icon, required this.color, required this.bgColor, required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
