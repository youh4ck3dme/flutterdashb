import 'package:flutter/material.dart';

/// Notification for frame loading errors
class FrameErrorNotification extends Notification {
  final String errorMessage;

  FrameErrorNotification(this.errorMessage);
}

/// Wrapper that catches errors from iframes and webviews
class FrameErrorHandler extends StatefulWidget {
  final String url;
  final Widget child;
  final Function(String errorMessage) onError;

  const FrameErrorHandler({
    super.key,
    required this.url,
    required this.child,
    required this.onError,
  });

  @override
  State<FrameErrorHandler> createState() => _FrameErrorHandlerState();
}

class _FrameErrorHandlerState extends State<FrameErrorHandler> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<FrameErrorNotification>(
      onNotification: (notification) {
        widget.onError(notification.errorMessage);
        return true;
      },
      child: widget.child,
    );
  }
}
