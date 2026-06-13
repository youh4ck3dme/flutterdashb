// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Web implementation using HTML iframe
Widget createVideoIFrameWidget(String url) {
  final String viewType = 'video-frame-web';

  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent'
        ..allowFullscreen = true
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
    },
  );

  return HtmlElementView(viewType: viewType);
}
