import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class TeacherWelcomeScreen extends ConsumerWidget {
  const TeacherWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDAE1FF), Color(0xFFF7F9FF)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 32),
              _buildHeroSection(context),
              const SizedBox(height: 48),
              Expanded(child: _buildPastSessions()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ClassPulseColors.surfaceContainerHigh,
            child: Icon(Icons.person_outline, color: ClassPulseColors.onSurface),
          ),
          const SizedBox(width: 12),
          Text(
            'ClassPulse',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ClassPulseColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning,\nTeacher 👋',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: ClassPulseColors.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to pulse the classroom?',
            style: TextStyle(
              fontSize: 16,
              color: ClassPulseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          CPButton(
            label: '✦ Start New Session',
            onPressed: () => context.go('/create'),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPastSessions() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ClassPulseColors.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past Sessions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ClassPulseColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 64, color: ClassPulseColors.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: TextStyle(fontSize: 16, color: ClassPulseColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your first session above',
                    style: TextStyle(fontSize: 14, color: ClassPulseColors.outlineVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
