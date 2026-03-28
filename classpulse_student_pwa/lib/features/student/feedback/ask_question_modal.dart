import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

enum QuestionCategory { doubt, repeat, slowDown }

class AskQuestionModal extends ConsumerStatefulWidget {
  final String sessionId;
  const AskQuestionModal({Key? key, required this.sessionId}) : super(key: key);

  @override
  ConsumerState<AskQuestionModal> createState() => _AskQuestionModalState();
}

class _AskQuestionModalState extends ConsumerState<AskQuestionModal> {
  final _textController = TextEditingController();
  QuestionCategory? _selectedCategory;
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    // Simulate Firestore write — Phase 4 wires real write
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() { _isSending = false; _sent = true; });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, controller) => GestureDetector(
          onTap: () {}, // prevent tap-through to outer GestureDetector
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [ClassPulseShadows.ambient],
            ),
            child: _sent ? _buildSentState() : _buildForm(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: ClassPulseColors.outlineVariant,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "You're stuck — ask anonymously",
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: ClassPulseColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your teacher sees the question, not who sent it.",
            style: TextStyle(fontSize: 13, color: ClassPulseColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          // Text input
          TextField(
            controller: _textController,
            maxLength: 150,
            maxLines: 4,
            style: TextStyle(color: ClassPulseColors.onSurface),
            decoration: InputDecoration(
              hintText: "What's confusing you?",
              hintStyle: TextStyle(color: ClassPulseColors.outlineVariant),
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
          const SizedBox(height: 20),
          Text(
            'What kind of help do you need?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ClassPulseColors.onSurface),
          ),
          const SizedBox(height: 12),
          // Category chips
          Row(
            children: [
              _CategoryChip(
                label: '💬 Doubt',
                isSelected: _selectedCategory == QuestionCategory.doubt,
                onTap: () => setState(() => _selectedCategory = QuestionCategory.doubt),
              ),
              const SizedBox(width: 10),
              _CategoryChip(
                label: '🔄 Repeat',
                isSelected: _selectedCategory == QuestionCategory.repeat,
                onTap: () => setState(() => _selectedCategory = QuestionCategory.repeat),
              ),
              const SizedBox(width: 10),
              _CategoryChip(
                label: '🐢 Slow Down',
                isSelected: _selectedCategory == QuestionCategory.slowDown,
                onTap: () => setState(() => _selectedCategory = QuestionCategory.slowDown),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ClassPulseColors.outlineVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    minimumSize: const Size(0, 52),
                  ),
                  child: Text('Cancel', style: TextStyle(color: ClassPulseColors.onSurfaceVariant)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF253153), Color(0xFF3C486B)],
                    ),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: _isSending
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Send Anonymously', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Question sent!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ClassPulseColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Your teacher will address it anonymously.',
            style: TextStyle(fontSize: 14, color: ClassPulseColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ClassPulseColors.primary : ClassPulseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : ClassPulseColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
