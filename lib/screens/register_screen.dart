import 'package:enstabhouse/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  bool _isAgreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _controller;
  final TextEditingController emailController = TextEditingController() ;
  final TextEditingController passwordController = TextEditingController() ;
  final TextEditingController confirmPasswordController = TextEditingController() ;
  final TextEditingController numberController = TextEditingController() ;
  final TextEditingController majorController =TextEditingController() ;
  final TextEditingController fullNameController = TextEditingController() ;
  final _auth = FirebaseAuth.instance ;


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isAgreed = !_isAgreed;
      if (_isAgreed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Pre-fill the phone number prefix
    numberController.text = '+216';
    numberController.selection = TextSelection.fromPosition(
      TextPosition(offset: numberController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50.0,
                    backgroundColor: kPrimaryColor,
                    child: Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Join ENSTAB community",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.0,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: fullNameController,
                    autofocus: true,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Full Name",
                      prefixIcon: const Icon(Icons.person_2),
                      hintText: "Enter your full name",
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      hintText: "student@enstab.ucar.tn",
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Password",
                      hintText: "Enter your password",
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Password Confirmation",
                      hintText: "Confirm your password",
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: numberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      // Keep '+216' prefix and allow only digits after it
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        const prefix = '+216';
                        // Prevent removing the prefix
                        if (!newValue.text.startsWith(prefix)) {
                          return oldValue;
                        }
                        // Only allow digits after the prefix
                        final afterPrefix = newValue.text.substring(prefix.length);
                        if (afterPrefix.isNotEmpty &&
                            !RegExp(r'^\d+$').hasMatch(afterPrefix)) {
                          return oldValue;
                        }
                        // Cap at exactly 8 digits after the prefix
                        if (afterPrefix.length > 8) {
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ],
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Phone Number",
                      hintText: "+216 xx xxx xxx",
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                   controller: majorController,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Major",
                      hintText: "Enter your class",
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: _handleTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MSHCheckbox(
                          value: _isAgreed,
                          size: 25,
                          colorConfig:
                              MSHColorConfig.fromCheckedUncheckedDisabled(
                            checkedColor: kPrimaryColor,
                            uncheckedColor: Colors.grey,
                          ),
                          style: MSHCheckboxStyle.stroke,
                          onChanged: (bool selected) {
                            setState(() {
                              _isAgreed = selected;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: const Text(
                            "I agree to the Terms of Service and Privacy Policy",
                            softWrap: true,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async  {
                        if(
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty ||
                            fullNameController.text.isEmpty ||
                            numberController.text.isEmpty ||
                            numberController.text == '+216' ||
                            majorController.text.isEmpty
                        ){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please fill all fields")
                            )
                          );
                          return ;
                        }
                        // Validate exactly 8 digits after +216
                        final digits = numberController.text.substring('+216'.length);
                        if (digits.length != 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Phone number must be exactly 8 digits")),
                          );
                          return;
                        }
                        if (!emailController.text.trim().endsWith('@enstab.ucar.tn')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Email must be in the form: example@enstab.ucar.tn")),
                          );
                          return;
                        }
                        if (passwordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match")),
                          );
                          return;
                        }
                        if (!_isAgreed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("You must agree to terms")),
                          );
                          return;
                        }

                        //_____UserCreation _____

                        try {
                          final newUser = await _auth
                              .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                          if(newUser != null){
                            Navigator.pushNamed(context, '/home');
                          }
                        }on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message ?? "Registration failed")),
                          );
                        }


                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
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
