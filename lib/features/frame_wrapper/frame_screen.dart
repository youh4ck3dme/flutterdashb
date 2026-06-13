import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';
import '../bugs/bug_create_screen.dart';
import 'frame_error_handler.dart';

/// Generic frame screen with error handling and bug reporting
class FrameScreen extends StatefulWidget {
  final String url;
  final String title;
  final IconData icon;
  final Widget Function(String url) frameBuilder;

  const FrameScreen({
    super.key,
    required this.url,
    required this.title,
    required this.icon,
    required this.frameBuilder,
  });

  @override
  State<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends State<FrameScreen> {
  bool _hasError = false;
  String? _errorMessage;

  void _handleError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  void _reportBug(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BugCreateScreen(
          prefilledData: {
            'title': 'Chyba v ${widget.title}',
            'description': 'Frame ${widget.url} zlyhal: ${_errorMessage ?? "Neznáma chyba"}',
            'environment': 'Frame: ${widget.title} | URL: ${widget.url}',
          },
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Icon(widget.icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(widget.title),
            ],
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.alertTriangle,
                    size: 64,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Frame sa nepodarilo načítať',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: AppTheme.glassDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chybová správa:',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(LucideIcons.bug, size: 18),
                      label: const Text('Nahlásiť chybu'),
                      onPressed: () => _reportBug(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      icon: const Icon(LucideIcons.refreshCw, size: 18),
                      label: const Text('Skúsiť znova'),
                      onPressed: _retry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FrameErrorHandler(
      url: widget.url,
      onError: _handleError,
      child: _buildFrameContent(),
    );
  }

  Widget _buildFrameContent() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: widget.frameBuilder(widget.url),
    );
  }
}

