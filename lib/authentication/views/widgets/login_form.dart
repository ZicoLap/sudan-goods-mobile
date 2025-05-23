import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/Home/pages/home_page.dart';
import 'package:sudan_goods/authentication/controller/login_controller.dart';
import 'package:sudan_goods/authentication/data/login_form_data.dart';
import 'package:sudan_goods/authentication/views/register_page.dart';
import 'package:sudan_goods/authentication/views/widgets/password_reset_dialog.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/user/user_provider.dart';

class LoginForm extends StatefulWidget {
  final LoginFormData formData;

  const LoginForm({super.key, required this.formData});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = LoginController();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await _controller.login(
        widget.formData.email.text,
        widget.formData.password.text,
      );

      if (result == "unverified") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email.")),
        );
        return;
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await Provider.of<UserProvider>(context, listen: false).fetchUser(uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResetDialog() {
    showDialog(context: context, builder: (_) => const PasswordResetDialog());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Sudan Goods",
            style: GoogleFonts.staatliches(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 36),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _textField(widget.formData.email, "Email", icon: Icons.email),
                const SizedBox(height: 36),
                _textField(
                  widget.formData.password,
                  "Password",
                  obscure: true,
                  icon: Icons.lock,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialCircleButton("assets/images/google_logo.png", () {}),
              const SizedBox(width: 42),
              _socialCircleButton(null, () {}, icon: Icons.apple),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("LOGIN", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 36),
          Row(
            children: const [
              Expanded(child: Divider(color: Colors.black, thickness: 2)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "OR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Divider(color: Colors.black, thickness: 2)),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTER", style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _showResetDialog,
            child: const Text("Forgot password?"),
          ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 26,
          horizontal: 16,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _socialCircleButton(
    String? assetPath,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: AppColors.inputField,
        radius: 42,
        child:
            assetPath != null
                ? Image.asset(assetPath, width: 24, height: 24)
                : Icon(icon, size: 30, color: Colors.black),
      ),
    );
  }
}
