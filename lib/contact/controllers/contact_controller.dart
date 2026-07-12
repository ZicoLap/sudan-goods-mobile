import 'package:flutter/foundation.dart';
import '../data/contact_service.dart';

enum ContactStatus { idle, sending, success, error }

class ContactController extends ChangeNotifier {
  final ContactService _service;

  ContactController({ContactService? service})
      : _service = service ?? ContactService();

  ContactStatus _status = ContactStatus.idle;
  ContactStatus get status => _status;

  bool get isIdle => _status == ContactStatus.idle;
  bool get isSending => _status == ContactStatus.sending;
  bool get isSuccess => _status == ContactStatus.success;
  bool get isError => _status == ContactStatus.error;

  Future<void> submit({
    required String uid,
    required String email,
    required String subject,
    required String message,
  }) async {
    _status = ContactStatus.sending;
    notifyListeners();
    try {
      await _service.submit(
        uid: uid,
        email: email,
        subject: subject,
        message: message,
      );
      _status = ContactStatus.success;
    } catch (_) {
      _status = ContactStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = ContactStatus.idle;
    notifyListeners();
  }
}
