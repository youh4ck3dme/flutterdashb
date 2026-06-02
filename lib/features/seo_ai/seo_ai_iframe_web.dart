import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createIFrameWidget(String url) {
  final String viewType = 'iframe-seo-ai';

  // Register the view factory
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      return html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent';
    },
  );

  return HtmlElementView(viewType: viewType);
}
