import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import 'ask_question_modal.dart';

// Track selected signal type
enum SignalType { gotIt, sortOf, lost }

class StudentFeedbackScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const StudentFeedbackScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  ConsumerState<StudentFeedbackScreen> createState() => _StudentFeedbackScreenState();
}

class _StudentFeedbackScreenState extends ConsumerState<StudentFeedbackScreen> {
  SignalType? _selectedSignal;

  void _onSignalTap(SignalType signal) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedSignal = signal);

    // If Lost is tapped — open ask question modal
    if (signal == SignalType.lost) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _showAskQuestionModal();
      });
    }
  }

  void _showAskQuestionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AskQuestionModal(sessionId: widget.sessionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassPulseColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ClassPulseColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF374951),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live • ${widget.sessionId}',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: ClassPulseColors.onTertiaryFixed,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // "Ask a question" icon
          IconButton(
            onPressed: _showAskQuestionModal,
            icon: Icon(Icons.help_outline_rounded, color: ClassPulseColors.onSurfaceVariant),
            tooltip: 'Ask a question',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Current topic label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ClassPulseColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              '📚  Current Topic',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: ClassPulseColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'How well do you understand this?',
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold,
              color: ClassPulseColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
          // Signal buttons
          _SignalButton(
            label: 'Got it!',
            emoji: '✓',
            description: 'I understand clearly',
            bgColor: ClassPulseColors.tertiaryFixed,
            selectedBorderColor: const Color(0xFF374951),
            isSelected: _selectedSignal == SignalType.gotIt,
            onTap: () => _onSignalTap(SignalType.gotIt),
          ),
          const SizedBox(height: 12),
          _SignalButton(
            label: 'Sort of...',
            emoji: '～',
            description: 'I kind of follow along',
            bgColor: ClassPulseColors.softOrange,
            selectedBorderColor: const Color(0xFFE65100),
            isSelected: _selectedSignal == SignalType.sortOf,
            onTap: () => _onSignalTap(SignalType.sortOf),
          ),
          const SizedBox(height: 12),
          _SignalButton(
            label: 'Lost',
            emoji: '?',
            description: 'I need help — tap to ask',
            bgColor: ClassPulseColors.errorContainer,
            selectedBorderColor: ClassPulseColors.error,
            isSelected: _selectedSignal == SignalType.lost,
            onTap: () => _onSignalTap(SignalType.lost),
          ),
          const SizedBox(height: 24),
          // Selected state label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _selectedSignal != null
              ? Text(
                  key: ValueKey(_selectedSignal),
                  'Signal sent ✓ — you can change anytime',
                  style: TextStyle(fontSize: 13, color: ClassPulseColors.onSurfaceVariant),
                )
              : Text(
                  key: const ValueKey('empty'),
                  'Tap a button to let your teacher know',
                  style: TextStyle(fontSize: 13, color: ClassPulseColors.outlineVariant),
                ),
          ),
        ],
      ),
    );
  }
}

class _SignalButton extends StatelessWidget {
  final String label;
  final String emoji;
  final String description;
  final Color bgColor;
  final Color selectedBorderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _SignalButton({
    required this.label,
    required this.emoji,
    required this.description,
    required this.bgColor,
    required this.selectedBorderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Signal: $label. $description',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        height: 76,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: selectedBorderColor.withOpacity(0.5), width: 2)
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isSelected
              ? [BoxShadow(color: selectedBorderColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700,
                            color: ClassPulseColors.onSurface,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(fontSize: 13, color: ClassPulseColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: selectedBorderColor, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
