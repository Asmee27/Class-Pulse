import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/navigation/cp_bottom_nav.dart';
import '../../../core/widgets/navigation/cp_side_nav.dart';
import '../../../core/widgets/buttons/cp_primary_gradient_button.dart';

class TeacherWelcomeScreen extends ConsumerWidget {
  const TeacherWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: Stack(
        children: [
          // Side nav on desktop
          if (isDesktop) const Align(alignment: Alignment.centerLeft, child: CPSideNav(activeIndex: 0)),
          // Main content
          Padding(
            padding: EdgeInsets.only(left: isDesktop ? 80 : 0),
            child: Column(children: [
              const _TopAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    // Halo gradient background
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.8, -0.8),
                        radius: 1.5,
                        colors: [Color(0xFFDAE1FF), Color(0xFFF7F9FF)],
                        stops: [0.0, 0.6],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 120 : 24, 48,
                      24, 48,
                    ),
                    child: Column(children: [
                      // Two-column hero
                      isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _HeroContent()),
                              const SizedBox(width: 64),
                              const Expanded(child: _IllustrationCard()),
                            ],
                          )
                        : _HeroContent(),
                      const SizedBox(height: 96),
                      // Recent sessions
                      _RecentSessionsSection(),
                      if (!isDesktop) const SizedBox(height: 100), // spacing for bottom nav
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          // Bottom nav on mobile
          if (!isDesktop) const Align(
            alignment: Alignment.bottomCenter,
            child: CPBottomNav(activeIndex: 0),
          ),
        ],
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE5E8EF),
            radius: 20,
            child: Icon(Icons.person, color: Color(0xFF5A5E6E)),
          ),
          Text(
            'ClassPulse',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: const Color(0xFF253153),
            ),
            textAlign: TextAlign.center,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Color(0xFF5A5E6E)),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome badge chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD2E6EF),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF374951)),
            const SizedBox(width: 8),
            Text('Welcome Back, Dr. Aris',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 1.5, color: const Color(0xFF374951),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // Giant headline
        Text('ClassPulse',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 64, fontWeight: FontWeight.w900,
            color: const Color(0xFF253153), letterSpacing: -1.5,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Text('Real-time classroom understanding.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w500,
            color: const Color(0xFF45464E),
          ),
        ),
        const SizedBox(height: 40),
        // Action buttons
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(children: [
            CPPrimaryGradientButton(
              label: 'Start New Session',
              icon: Icons.play_circle_fill,
              onTap: () => context.push('/create'),
            ),
            const SizedBox(height: 12),
            _SecondaryPillButton(
              label: 'View Past Sessions',
              icon: Icons.history,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _TertiaryPillButton(
              label: 'Settings',
              icon: Icons.settings,
              onTap: () {},
            ),
          ]),
        ),
      ],
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SecondaryPillButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFDEE2F5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF253153))),
            const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFF253153), size: 20),
          ],
        ),
      ),
    );
  }
}

class _TertiaryPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _TertiaryPillButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF45464E))),
            const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFF45464E), size: 20),
          ],
        ),
      ),
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard();
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Halo blur behind card
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF253153).withOpacity(0.05),
              borderRadius: BorderRadius.circular(9999),
            ),
            transform: Matrix4.identity()..scale(1.1),
          ),
        ),
        // Main white card
        Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF181C21).withOpacity(0.05),
                blurRadius: 48, offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(children: [
            // Lightbulb SVG equivalent
            SizedBox(
              width: 180, height: 180,
              child: CustomPaint(painter: _InsightIllustrationPainter()),
            ),
            const SizedBox(height: 24),
            Text("TODAY'S INSIGHT",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w700,
                letterSpacing: 1.5, color: const Color(0xFF5A5E6E),
              ),
            ),
            const SizedBox(height: 8),
            Text('"Engagement peaks during collaborative problem-solving."',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: const Color(0xFF253153),
                fontStyle: FontStyle.italic,
              ),
            ),
          ]),
        ),
        // Floating chip — top left, rotated -6deg
        Positioned(
          top: 40, left: -24,
          child: Transform.rotate(
            angle: -6 * pi / 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD2E6EF),
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.groups, size: 14, color: Color(0xFF374951)),
                const SizedBox(width: 6),
                Text('85% Active',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: const Color(0xFF374951),
                  ),
                ),
              ]),
            ),
          ),
        ),
        // Floating chip — bottom right, rotated +3deg
        Positioned(
          bottom: 80, right: -24,
          child: Transform.rotate(
            angle: 3 * pi / 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.psychology, size: 14, color: Color(0xFF93000A)),
                const SizedBox(width: 6),
                Text('3 Lost',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: const Color(0xFF93000A),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDEE2F5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.lightbulb.codePoint),
      style: TextStyle(fontSize: size.width * 0.6, fontFamily: Icons.lightbulb.fontFamily, color: const Color(0xFF253153)),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, Offset((size.width - iconPainter.width) / 2, (size.height - iconPainter.height) / 2));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecentSessionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Recent Sessions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28, fontWeight: FontWeight.w800,
                color: const Color(0xFF253153), letterSpacing: -0.5,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            Text('Your last 24 hours of classroom activity.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: const Color(0xFF45464E),
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Text('See All', style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, color: const Color(0xFF253153),
          )),
          label: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF253153)),
        ),
      ]),
      const SizedBox(height: 24),
      // Grid
      LayoutBuilder(builder: (ctx, constraints) {
        final cols = constraints.maxWidth > 700 ? 3 : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 24, mainAxisSpacing: 24,
          childAspectRatio: cols == 1 ? 2.2 : 1.6,
          children: [
            const _SessionCard(time: '10:30 AM', title: 'Advanced Calculus',
              subtitle: 'Section B • 32 Students', trending: true),
            const _SessionCard(time: 'Yesterday', title: 'Physics 101',
              subtitle: 'Section A • 45 Students', trending: false),
            _GhostCard(),
          ],
        );
      }),
    ]);
  }
}

class _SessionCard extends StatelessWidget {
  final String time, title, subtitle;
  final bool trending;
  const _SessionCard({required this.time, required this.title,
    required this.subtitle, required this.trending});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: const Color(0xFF181C21).withOpacity(0.04),
          blurRadius: 24, offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E8EF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(time, style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: const Color(0xFF45464E),
              )),
            ),
            Icon(
              trending ? Icons.trending_up : Icons.trending_down,
              color: const Color(0xFFB6CAD2), size: 20,
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: const Color(0xFF253153),
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: const Color(0xFF45464E),
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
          Row(children: [
            const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF253153)),
            const SizedBox(width: 6),
            Text('View Report', style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: const Color(0xFF253153),
            )),
          ]),
        ],
      ),
    );
  }
}

class _GhostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC6C6CF).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E8EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF253153)),
          ),
          const SizedBox(height: 8),
          Text('Schedule New',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF45464E),
            ),
          ),
        ]),
      ),
    );
  }
}
