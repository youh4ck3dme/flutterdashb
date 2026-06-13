export 'video_iframe_stub.dart'
    if (dart.library.html) 'video_iframe_web.dart'
    if (dart.library.io) 'video_iframe_mobile.dart';
