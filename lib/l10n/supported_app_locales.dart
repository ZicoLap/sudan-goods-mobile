/// Supported application language codes for Sudan Goods.
class SupportedAppLocales {
  SupportedAppLocales._();

  static const supportedLanguageCodes = {'en', 'ar'};

  static bool isSupported(String? code) {
    if (code == null || code.isEmpty) return false;
    return supportedLanguageCodes.contains(code);
  }
}
