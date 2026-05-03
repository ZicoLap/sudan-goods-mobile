import 'package:flutter/foundation.dart';
import '../data/about_us_service.dart';
import '../models/about_us_content.dart';

enum AboutUsStatus { idle, loading, loaded, error }

class AboutUsController extends ChangeNotifier {
  final AboutUsService _service;

  AboutUsController({AboutUsService? service})
      : _service = service ?? AboutUsService();

  AboutUsStatus _status = AboutUsStatus.idle;
  AboutUsContent? _content;
  AboutUsStatus get status => _status;
  AboutUsContent? get content => _content;

  bool get isLoading => _status == AboutUsStatus.loading;
  bool get isLoaded => _status == AboutUsStatus.loaded;
  bool get isError => _status == AboutUsStatus.error;

  Future<void> load() async {
    if (_status == AboutUsStatus.loading) return;
    _status = AboutUsStatus.loading;
    notifyListeners();
    try {
      _content = await _service.fetch();
      _status = AboutUsStatus.loaded;
    } catch (_) {
      _status = AboutUsStatus.error;
    }
    notifyListeners();
  }
}
