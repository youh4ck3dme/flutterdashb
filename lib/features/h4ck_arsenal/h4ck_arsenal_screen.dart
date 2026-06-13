import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../frame_wrapper/frame_screen.dart';
import '../video_dashboard/video_frame_stub.dart'
    if (dart.library.html) '../video_dashboard/video_frame_web.dart';

class H4ckArsenalScreen extends StatelessWidget {
  static const String url = 'https://arsenal.h4ck3d.me/';

  const H4ckArsenalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FrameScreen(
      url: url,
      title: 'H4CK Arsenal',
      icon: LucideIcons.terminal,
      frameBuilder: (url) => createVideoFrame(url),
    );
  }
}
