import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class StudentWrapUpScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const StudentWrapUpScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  ConsumerState<StudentWrapUpScreen> createState() => _StudentWrapUpScreenState();
}

class _StudentWrapUpScreenState extends ConsumerState<StudentWrapUpScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedEmoji;
  int? _starRating;
  final _feedbackController = TextEditingController();
  bool _submitted = false;
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  final List<String> _emojis = ['😞', '😐', '🙂', '😊', '🎉'];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut);
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassPulseColors.surface,
      body: SafeArea(
        child: _submitted ? _buildThankYou() : _buildRatingScreen(),
      ),
    );
  }

  Widget _buildThankYou() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎓', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            'Thank you!',
            style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold,
              color: ClassPulseColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your feedback helps your teacher improve.',
            style: TextStyle(fontSize: 15, color: ClassPulseColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildRatingScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Celebration icon with spring animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF253153), Color(0xFF3C486B)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Session Ended!',
            style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold,
              color: ClassPulseColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great work today. How was the class?',
            style: TextStyle(fontSize: 16, color: ClassPulseColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Emoji row
          CPCard(
            child: Column(
              children: [
                Text(
                  'How did you feel?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClassPulseColors.onSurface),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_emojis.length, (i) {
                    final selected = _selectedEmoji == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: selected ? ClassPulseColors.tertiaryFixed : Colors.transparent,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: ClassPulseColors.onTertiaryFixed, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(_emojis[i], style: TextStyle(fontSize: selected ? 32 : 26)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Star rating
          CPCard(
            child: Column(
              children: [
                Text(
                  'Rate this session',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ClassPulseColors.onSurface),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = _starRating != null && i < _starRating!;
                    return GestureDetector(
                      onTap: () => setState(() => _starRating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 40,
                          color: filled ? const Color(0xFFFFC107) : ClassPulseColors.outlineVariant,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Optional text feedback
          TextField(
            controller: _feedbackController,
            maxLength: 200,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any feedback for your teacher? (optional)',
              hintStyle: TextStyle(color: ClassPulseColors.outlineVariant, fontSize: 14),
              filled: true,
              fillColor: ClassPulseColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: ClassPulseColors.primary, width: 2),
              ),
              counterStyle: TextStyle(color: ClassPulseColors.outlineVariant, fontSize: 11),
            ),
          ),
          const SizedBox(height: 28),
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF253153), Color(0xFF3C486B)],
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
                child: const Text('Submit & Done', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
