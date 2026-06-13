import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Universal frame loader that works on web and mobile
///
/// On web: Uses HTML iframe
/// On mobile: Uses WebView (when available)
///
/// Usage:
/// ```dart
/// FrameLoader(url: 'https://example.com')
/// ```
class FrameLoader extends StatefulWidget {
  final String url;
  final bool allowFullscreen;
  final bool allowCamera;
  final bool allowMicrophone;

  const FrameLoader({
    super.key,
    required this.url,
    this.allowFullscreen = true,
    this.allowCamera = false,
    this.allowMicrophone = false,
  });

  @override
  State<FrameLoader> createState() => _FrameLoaderState();
}

class _FrameLoaderState extends State<FrameLoader> {

  @override
  Widget build(BuildContext context) {
    // On web, use the existing iframe implementation
    if (kIsWeb) {
      return _buildWebFrame();
    }

    // On mobile, try to use WebView if available
    // If WebView is not available, show a message
    return _buildMobileFrame();
  }

  Widget _buildWebFrame() {
    // This will be replaced by the actual web iframe implementation
    // from the specific feature modules
    return const Center(
      child: Text(
        'Frame Loader: Use platform-specific implementation',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildMobileFrame() {
    // Try to use WebView
    // This requires webview_flutter package
    // If not available, show a message

    // For now, show a message that WebView is required
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_iphone, size: 48, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'Frame vyžaduje WebView package',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Pridaj do pubspec.yaml:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'webview_flutter: ^4.4.2',
              style: TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            Text(
              'webview_flutter_wkwebview: ^4.4.2',
              style: TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            Text(
              'webview_flutter_android: ^4.2.6',
              style: TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
