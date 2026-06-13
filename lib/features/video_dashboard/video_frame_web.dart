// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Creates a video frame using HTML iframe for web platform
Widget createVideoFrame(String url) {
  // Create a unique view type for this iframe
  final viewType = 'video-iframe-${url.hashCode}';
  
  // Register the view factory
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent'
        ..allowFullscreen = true
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
      

      
      return iframe;
    },
  );
  
  return HtmlElementView(viewType: viewType);
}
