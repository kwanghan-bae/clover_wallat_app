export 'platform_check_stub.dart'
    if (dart.library.html) 'platform_check_web.dart'
    if (dart.library.io) 'platform_check_io.dart';
