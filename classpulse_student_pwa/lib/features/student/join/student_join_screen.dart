import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class StudentJoinScreen extends ConsumerStatefulWidget {
  const StudentJoinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentJoinScreen> createState() => _StudentJoinScreenState();
}

class _StudentJoinScreenState extends ConsumerState<StudentJoinScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) return;
    // Auto-advance to next box
    if (index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else {
      // Last digit entered — auto-submit
      _join();
    }
  }

  Future<void> _join() async {
    final code = _fullCode.toUpperCase();
    if (code.length < 4) {
      setState(() => _errorMessage = 'Please enter the full 4-digit code.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    // Simulate Firestore session lookup (Phase 4 will wire real Firestore)
    await Future.delayed(const Duration(milliseconds: 800));

    // For now: any 4-char code is "valid" — Firestore check added in Phase 4
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/session/$code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassPulseColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 56),
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF253153), Color(0xFF3C486B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'ClassPulse',
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: ClassPulseColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join a Session',
                style: TextStyle(fontSize: 16, color: ClassPulseColors.onSurfaceVariant),
              ),
              const SizedBox(height: 56),
              Text(
                'Enter your 4-digit code',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600,
                  color: ClassPulseColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your teacher will show this on the board',
                style: TextStyle(fontSize: 14, color: ClassPulseColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              // 4 OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => _buildDigitBox(i)),
              ),
              const SizedBox(height: 16),
              // Error message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _errorMessage != null
                  ? Padding(
                      key: ValueKey(_errorMessage),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: ClassPulseColors.error, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox(key: ValueKey('no-error'), height: 8),
              ),
              const SizedBox(height: 24),
              // Join button
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
                    onPressed: _isLoading ? null : _join,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Join Session', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
              const Spacer(),
              // Bottom tag
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'No account needed • 100% anonymous',
                  style: TextStyle(fontSize: 12, color: ClassPulseColors.outlineVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int i) {
    return Container(
      width: 64,
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: ClassPulseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNodes[i].hasFocus ? ClassPulseColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controllers[i],
        focusNode: _focusNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
        style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold,
          color: ClassPulseColors.primary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (v) => _onDigitChanged(i, v),
        onTap: () => setState(() {}), // trigger border repaint on focus
      ),
    );
  }
}
