import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import '../../features/student/join/student_join_screen.dart';
import '../../features/student/feedback/student_feedback_screen.dart';
import '../../features/student/wrapup/student_wrapup_screen.dart';

final studentRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const StudentJoinScreen(),
    ),
    GoRoute(
      path: '/session/:id',
      builder: (context, state) => StudentFeedbackScreen(
        sessionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/session/:id/done',
      builder: (context, state) => StudentWrapUpScreen(
        sessionId: state.pathParameters['id']!,
      ),
    ),
  ],
);
