import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ClassPulseStudentApp()));
}

class ClassPulseStudentApp extends StatelessWidget {
  const ClassPulseStudentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ClassPulse Student',
      theme: AppTheme.light(),
      routerConfig: studentRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
