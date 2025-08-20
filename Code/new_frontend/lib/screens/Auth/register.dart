// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:new_frontend/services/authServices.dart';
import 'package:new_frontend/widgets/button.dart';
import 'package:new_frontend/widgets/txtfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreeTerms = false;

  void register() async {
    final response = await AuthService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
    );
    if (response['token'] != null) {
      Navigator.pushReplacementNamed(context, '/login');
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Textfield(
                    controller: nameController,
                    hintText: "Name",
                    label: "Name",
                    labelColor: Colors.white,
                  ),
                  const SizedBox(height: 9),
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
                  const SizedBox(height: 9),
                  Textfield(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    label: "Confirm Password",
                    labelColor: Colors.white,
                    isPassword: true,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: agreeTerms,
                        onChanged: (val) => setState(() => agreeTerms = val!),
                      ),
                      Text(
                        "I agree to terms and conditions",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Button(
                    text: "Register",
                    color: Colors.white,
                    txtColor: Colors.black,
                    onPressed: register,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          "Log In",
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
