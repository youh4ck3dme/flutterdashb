import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../frame_wrapper/frame_screen.dart';
import '../video_dashboard/video_frame_stub.dart'
    if (dart.library.html) '../video_dashboard/video_frame_web.dart';

class BlueprintsScreen extends StatelessWidget {
  static const String url = 'https://svelte-pwa-blueprints.vercel.app/';

  const BlueprintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FrameScreen(
      url: url,
      title: 'Blueprints',
      icon: LucideIcons.layoutTemplate,
      frameBuilder: (frameUrl) => createVideoFrame(frameUrl),
    );
  }
}
