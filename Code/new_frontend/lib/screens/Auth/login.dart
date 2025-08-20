// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:new_frontend/services/authServices.dart';
import 'package:new_frontend/widgets/button.dart';
import 'package:new_frontend/widgets/txtfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;

  void login() async {
    final response = await AuthService.login(
      emailController.text,
      passwordController.text,
    );

    if (response['token'] != null) {
      Navigator.pushReplacementNamed(context, '/navbar');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Welcome back!",
                    style: TextStyle(color: Colors.white, fontSize: 16.5),
                  ),
                  SizedBox(height: 16),
                  Textfield(
                    controller: emailController,
                    hintText: "Email",
                    label: "Email",
                    labelColor: Colors.white,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 9),
                  Textfield(
                    controller: passwordController,
                    hintText: "Password",
                    label: "Password",
                    labelColor: Colors.white,
                    isPassword: true,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (val) => setState(() => rememberMe = val!),
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Button(
                    text: "Login",
                    color: Colors.white,
                    txtColor: Colors.black,
                    onPressed: login,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
