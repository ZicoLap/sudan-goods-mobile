import 'package:flutter/material.dart';
import 'package:sudan_goods/authentication/controller/register_controller.dart';
import 'package:sudan_goods/authentication/data/register_form_data.dart';
import 'package:sudan_goods/authentication/views/login_page.dart';
import 'package:sudan_goods/authentication/views/widgets/register_form_address.dart';
import 'package:sudan_goods/authentication/views/widgets/register_form_user.dart';
import 'package:sudan_goods/models/shared_models/address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKeyUser = GlobalKey<FormState>();
  final _formKeyAddress = GlobalKey<FormState>();

  final _controller = RegisterController();
  final _formData = RegisterFormData();

  bool _showAddressForm = false;
  bool _isLoading = false;

  String _gender = 'male';
  DateTime _birthday = DateTime(2000, 1, 1);

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    final address = Address(
      id: FirebaseFirestore.instance.collection('dummy').doc().id,
      label: _formData.addressLabel.text.trim(),
      street: _formData.street.text.trim(),
      city: _formData.city.text.trim(),
      country: _formData.country.text.trim(),
      postalCode: _formData.postalCode.text.trim(),
    );

    final result = await _controller.registerUser(
      email: _formData.email.text.trim(),
      password: _formData.password.text.trim(),
      firstName: _formData.firstName.text.trim(),
      lastName: _formData.lastName.text.trim(),
      phoneNumber: _formData.phone.text.trim(),
      gender: _gender,
      birthday: _birthday,
      address: address,
    );

    if (!mounted) return;

    if (result == "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your registration was successful. Please verify your email."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $result")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 36),
                padding: const EdgeInsets.all(36),
              
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _showAddressForm
                      ? RegisterFormAddress(
                          formData: _formData,
                          formKey: _formKeyAddress,
                          isLoading: _isLoading,
                          onSubmit: _submitRegistration,
                          onBack: () => setState(() => _showAddressForm = false),
                        )
                      : RegisterFormUser(
                          formData: _formData,
                          formKey: _formKeyUser,
                          gender: _gender,
                          birthday: _birthday,
                          onGenderChanged: (val) => setState(() => _gender = val),
                          onBirthdayChanged: (val) =>
                              setState(() => _birthday = val),
                          onNext: () {
                            if (_formKeyUser.currentState!.validate()) {
                              if (_formData.password.text != _formData.confirmPassword.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Passwords do not match")),
                                );
                                return;
                              }
                              setState(() => _showAddressForm = true);
                            }
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
