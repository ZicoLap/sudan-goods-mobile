import 'package:flutter/material.dart';

class LoginFormData {
  final email = TextEditingController();
  final password = TextEditingController();

  void dispose() {
    email.dispose();
    password.dispose();
  }
}
