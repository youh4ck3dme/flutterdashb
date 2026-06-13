import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../frame_wrapper/frame_screen.dart';
import 'video_frame_stub.dart' if (dart.library.html) 'video_frame_web.dart';

/// Video Dashboard Screen with iframe
///
/// For Web: Uses HTML iframe (fully working)
/// For Mobile: Shows placeholder (add webview_flutter for full support)
///
/// Usage:
/// ```dart
/// VideoDashboardScreen(
///   videoUrl: 'https://youtube.com/embed/VIDEO_ID',
/// )
/// VideoDashboardScreen(
///   videoUrl: 'https://your-app.vercel.app',
/// )
/// ```
class VideoDashboardScreen extends StatelessWidget {
  final String videoUrl;

  const VideoDashboardScreen({
    super.key,
    this.videoUrl = 'https://video.your-dashboard.com',
  });

  @override
  Widget build(BuildContext context) {
    return FrameScreen(
      url: videoUrl,
      title: 'Video Dashboard',
      icon: LucideIcons.video,
      frameBuilder: (url) => createVideoFrame(url),
    );
  }
}
