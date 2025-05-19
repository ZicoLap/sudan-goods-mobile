import 'package:flutter/material.dart';

class RegisterFormData {
  // Step 1 - User Info
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // Step 2 - Address Info
  final addressLabel = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController();
  final postalCode = TextEditingController();

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    addressLabel.dispose();
    street.dispose();
    city.dispose();
    country.dispose();
    postalCode.dispose();
  }
}
