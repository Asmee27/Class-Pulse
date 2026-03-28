import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/teacher/welcome/teacher_welcome_screen.dart';
import '../../features/teacher/create_session/create_session_screen.dart';
import '../../features/teacher/dashboard/live_dashboard_screen.dart';
import '../../features/teacher/summary/session_summary_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TeacherWelcomeScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateSessionScreen(),
    ),
    GoRoute(
      path: '/session/:id',
      builder: (context, state) => LiveDashboardScreen(sessionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/session/:id/summary',
      builder: (context, state) => SessionSummaryScreen(sessionId: state.pathParameters['id']!),
    ),
  ],
);
