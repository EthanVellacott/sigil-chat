import 'package:flutter/material.dart';

import 'package:sigil/data/auth.dart';
import 'package:sigil/widgets.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // TODO don't share context across async gap like this
  /// Log the user in, the auth instance will notify a change upstream in the tree automatically
  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(10),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome!",
            style: TextStyle(fontSize: 24),
          ),
          const Icon(
            Icons.route_rounded,
            size: 128,
          ),
          const Text(
            "Login with Sigil Chat",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
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
            onSubmit: (value) => login(context),
            autofillHints: const [
              AutofillHints.password,
            ],
          ),
          const SizedBox(height: 10),
          SigilEntryButton(onPress: () => login(context), text: "Login"),
          const SizedBox(height: 10),
          // const Text("No account? Register!")
          SigilEntryButton(
            onPress: () => Navigator.pushNamed(context, '/register'),
            text: "Register",
            color: Theme.of(context).colorScheme.tertiary,
            mini: true,
          ),
        ],
      )),
    ));
  }
}
