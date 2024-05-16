import 'package:flutter/material.dart';

import 'package:sigil/data/auth.dart';
import 'package:sigil/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordconfirmationController =
      TextEditingController();

  void validateFields() {
    if (passwordconfirmationController.text != passwordController.text) {
      throw Exception("Passwords do not match.");
    }
  }

  // TODO don't share context across async gap like this
  Future<void> register(BuildContext context) async {
    final authService = AuthService();
    try {
      validateFields();
      await authService.createUserWithEmailAndPassword(
          emailController.text, passwordController.text);
      Navigator.of(context).pop();
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Register with email",
            style: TextStyle(fontSize: 24),
          ),
          leading: IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SigilEntryField(
                controller: emailController,
                hintText: "Email",
                autofillHints: const [
                  AutofillHints.email,
                ],
              ),
              const SizedBox(height: 10),
              SigilEntryField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
                autofillHints: const [
                  AutofillHints.password,
                ],
              ),
              const SizedBox(height: 10),
              SigilEntryField(
                controller: passwordconfirmationController,
                hintText: "Confirm Password",
                obscureText: true,
                autofillHints: const [
                  AutofillHints.password,
                ],
              ),
              const SizedBox(height: 10),
              SigilEntryButton(
                  onPress: () => register(context), text: "Register"),
            ],
          )),
        ));
  }
}
