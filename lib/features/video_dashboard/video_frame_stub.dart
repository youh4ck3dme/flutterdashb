import 'package:flutter/material.dart';

Widget createVideoFrame(String url) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Frame preview is available in the web build: $url',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    ),
  );
}
