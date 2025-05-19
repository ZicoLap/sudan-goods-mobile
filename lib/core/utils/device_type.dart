import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceType {
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600; // Mobile
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024; // Tablet range
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1024; // Desktop
  }

  static bool isWebOrTablet(BuildContext context) {
    return kIsWeb || isTablet(context);
  }

  static bool isTabletOrDesktop(BuildContext context) {
    return isTablet(context) || isDesktop(context);
  }
}
