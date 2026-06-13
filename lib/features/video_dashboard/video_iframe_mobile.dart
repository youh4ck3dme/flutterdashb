import 'package:flutter/material.dart';

/// Mobile implementation placeholder
Widget createVideoIFrameWidget(String url) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_iphone, size: 48, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'Video vyžaduje WebView na mobilných zariadeniach',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
