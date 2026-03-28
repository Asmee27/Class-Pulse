import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared/shared.dart';
import 'session_code_generator.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();

  String? _generatedCode;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassPulseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: ClassPulseColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _generatedCode == null ? _buildForm() : _buildInvitePanel(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return CPCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a Session',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ClassPulseColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the details below to start your live class.',
            style: TextStyle(color: ClassPulseColors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          _inputField(_titleController, 'Session Title *', 'e.g. Grade 8 – Algebra'),
          const SizedBox(height: 16),
          _inputField(_subjectController, 'Subject / Class', 'Optional'),
          const SizedBox(height: 16),
          _inputField(_topicController, 'First Topic *', 'e.g. Quadratic Equations'),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: ClassPulseColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 32),
          CPButton(
            label: _isGenerating ? 'Generating…' : 'Generate Session',
            onPressed: _isGenerating ? () {} : _handleGenerate,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: ClassPulseColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: ClassPulseColors.onSurfaceVariant),
        filled: true,
        fillColor: ClassPulseColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ClassPulseColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _handleGenerate() async {
    if (_titleController.text.trim().isEmpty || _topicController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Session title and first topic are required.');
      return;
    }
    setState(() { _isGenerating = true; _errorMessage = null; });
    try {
      final code = await SessionCodeGenerator.generateUniqueCode();
      setState(() { _generatedCode = code; _isGenerating = false; });
    } catch (e) {
      setState(() { _errorMessage = 'Failed to generate code. Try again.'; _isGenerating = false; });
    }
  }

  Widget _buildInvitePanel() {
    final inviteUrl = 'https://classpulse.app/session/$_generatedCode';
    return CPCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Session Ready! 🎉',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ClassPulseColors.onSurface)),
          const SizedBox(height: 8),
          Text(_titleController.text.trim(),
            style: TextStyle(color: ClassPulseColors.onSurfaceVariant)),
          const SizedBox(height: 32),
          Text(
            _generatedCode!,
            style: TextStyle(
              fontSize: 56, fontWeight: FontWeight.bold,
              color: ClassPulseColors.primary, letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text('Students enter this code to join',
            style: TextStyle(fontSize: 13, color: ClassPulseColors.onSurfaceVariant)),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [ClassPulseShadows.ambient],
            ),
            child: QrImageView(data: inviteUrl, version: QrVersions.auto, size: 180),
          ),
          const SizedBox(height: 12),
          Text(inviteUrl,
            style: TextStyle(fontSize: 11, color: ClassPulseColors.outlineVariant),
            textAlign: TextAlign.center),
          const SizedBox(height: 32),
          CPButton(
            label: '▶  Begin Session',
            onPressed: () => context.go('/session/$_generatedCode'),
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          CPButton(
            label: 'Back to Form',
            onPressed: () => setState(() => _generatedCode = null),
            isPrimary: false,
          ),
        ],
      ),
    );
  }
}
