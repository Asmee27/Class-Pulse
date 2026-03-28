import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:shared/shared.dart';
import '../../../core/widgets/cp_stat_tile.dart';
import '../../../core/widgets/buttons/cp_primary_gradient_button.dart';
import '../../../core/widgets/navigation/cp_side_nav.dart';
import '../../../core/widgets/navigation/cp_bottom_nav.dart';

class SessionSummaryScreen extends ConsumerWidget {
  final String sessionId;
  const SessionSummaryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicSegmentsAsync = ref.watch(topicSegmentsProvider(sessionId));
    final topics = topicSegmentsAsync.valueOrNull ?? [];
    
    // Aggregates
    int totalGotIt = 0;
    int totalSortOf = 0;
    int totalLost = 0;
    double maxLostPct = 0;
    String peakLostTopic = "N/A";
    
    for (var t in topics) {
      totalGotIt += t.gotItCount;
      totalSortOf += t.sortOfCount;
      totalLost += t.lostCount;
      int tTotal = t.gotItCount + t.sortOfCount + t.lostCount;
      if (tTotal > 0) {
        double lostPct = t.lostCount / tTotal;
        if (lostPct > maxLostPct) {
          maxLostPct = lostPct;
          peakLostTopic = t.name;
        }
      }
    }
    
    int allSignals = totalGotIt + totalSortOf + totalLost;
    int avgConf = allSignals > 0 ? ((totalGotIt / allSignals) * 100).toInt() : 0;
    int maxLostPctDisplay = (maxLostPct * 100).toInt();

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100, left: isDesktop ? 200 : -100,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFFDAE1FF).withOpacity(0.6), Colors.transparent]),
              ),
            ),
          ),
          
          if (isDesktop) const Align(alignment: Alignment.centerLeft, child: CPSideNav(activeIndex: 0)),
          
          Padding(
            padding: EdgeInsets.only(left: isDesktop ? 80 : 0, bottom: isDesktop ? 0 : 80),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isDesktop ? 64 : 24, 64, isDesktop ? 64 : 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFD2E6EF), borderRadius: BorderRadius.circular(9999)),
                          child: Text('SESSION CONCLUDED', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFF374951))),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 24),
                        Text('Session Summary', style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: const Color(0xFF253153), letterSpacing: -1.0, height: 1.1))
                          .animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 12),
                        Text('Review how student comprehension shifted across today\'s topics.', style: GoogleFonts.plusJakartaSans(fontSize: 18, color: const Color(0xFF45464E)))
                          .animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        
                        const SizedBox(height: 48),
                        
                        // Top Stats
                        LayoutBuilder(builder: (ctx, constraints) {
                          return Wrap(
                            spacing: 24, runSpacing: 24,
                            children: [
                              SizedBox(width: 250, child: CPStatTile(icon: Icons.check_circle_rounded, number: '$avgConf%', label: 'AVG CONFIDENCE')),
                              SizedBox(width: 250, child: CPStatTile(icon: Icons.trending_down_rounded, number: '$maxLostPctDisplay%', label: 'PEAK CONFUSION')),
                              SizedBox(width: 250, child: CPStatTile(icon: Icons.list_alt_rounded, number: '${topics.length}', label: 'TOPICS COVERED')),
                            ],
                          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9));
                        }),
                        
                        const SizedBox(height: 64),
                        
                        // Timeline Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Topic Breakdown', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF253153))),
                            if (peakLostTopic != "N/A")
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFF93000A)),
                                    const SizedBox(width: 8),
                                    Text('Review: $peakLostTopic', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF93000A))),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 600.ms).shakeX(),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Render Topic Cards
                        if (topics.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...topics.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _SummaryTopicCard(topic: t)
                              .animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                          )).toList(),
                          
                        const SizedBox(height: 48),
                        
                        Center(
                          child: SizedBox(
                            width: 300,
                            child: CPPrimaryGradientButton(
                              label: 'Return to Dashboard',
                              icon: Icons.home_rounded,
                              onTap: () => context.go('/'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isDesktop) const Align(alignment: Alignment.bottomCenter, child: CPBottomNav(activeIndex: 0)),
        ],
      ),
    );
  }
}

class _SummaryTopicCard extends StatelessWidget {
  final TopicSegment topic;
  const _SummaryTopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    int tTotal = topic.gotItCount + topic.sortOfCount + topic.lostCount;
    int durationMins = topic.endedAt != null ? topic.endedAt!.difference(topic.startedAt).inMinutes : DateTime.now().difference(topic.startedAt).inMinutes;
    if (durationMins < 1) durationMins = 1;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF181C21).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))],
        border: Border.all(color: const Color(0xFFC6C6CF).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(topic.name, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF253153))),
              Text('${durationMins}m', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF5A5E6E))),
            ],
          ),
          const SizedBox(height: 32),
          
          if (tTotal == 0)
            Text('No signals recorded for this topic.', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF5A5E6E), fontStyle: FontStyle.italic))
          else
            _SegmentedBarChart(gotIt: topic.gotItCount, sortOf: topic.sortOfCount, lost: topic.lostCount, total: tTotal),
        ],
      ),
    );
  }
}

class _SegmentedBarChart extends StatelessWidget {
  final int gotIt, sortOf, lost, total;
  const _SegmentedBarChart({required this.gotIt, required this.sortOf, required this.lost, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatLegend(label: 'Got It ($gotIt)', color: const Color(0xFF253153)),
            _StatLegend(label: 'Sort Of ($sortOf)', color: const Color(0xFFE65100)),
            _StatLegend(label: 'Lost ($lost)', color: const Color(0xFF93000A)),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                if (gotIt > 0) Expanded(flex: gotIt, child: Container(color: const Color(0xFF253153))),
                if (sortOf > 0) Expanded(flex: sortOf, child: Container(color: const Color(0xFFE65100))),
                if (lost > 0) Expanded(flex: lost, child: Container(color: const Color(0xFF93000A))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _StatLegend({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45464E))),
      ],
    );
  }
}
