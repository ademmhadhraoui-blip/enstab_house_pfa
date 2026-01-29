import 'package:enstabhouse/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ENSTABHOUSE !!!')),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50.0),
              const  Text('LOGIN HERE',
                  style: kTextProperties),
              const SizedBox(height: 20.0),
              const Text(
                "Welcome back, you've\nbeen missed",
                textAlign: TextAlign.center,
                style: kTextLoginProperties,
              ),

              const SizedBox(height: 50.0),

              // Champ Email
              TextField(
                onChanged: (value) {},
                decoration: kEmailDecoration,
              ),

              const SizedBox(height: 20.0),

              // Champ Mot de passe
              TextField(
                obscureText: true,
                onChanged: (value) {},
                decoration: kPasswordDecoration,
              ),

              const SizedBox(height: 20),

              // Mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: const Text('forget your password ?', style: kTextForgotProperties),
              ),
              const SizedBox(height: 50,) ,
              // register button
               SizedBox(
                 height: 55  ,
                 width: double.infinity ,
                 child: Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(15),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.blueAccent.withOpacity(0.4),
                         blurRadius: 20,
                         spreadRadius: 2,
                         offset: Offset.zero,
                       ),
                     ],
                   ),
                   child: ElevatedButton(
                     onPressed: () {
                       Navigator.push(context , MaterialPageRoute(
                         builder: (context)=> RegisterScreen() ,
                       ) ,
                       ) ;
                     },
                     style: kButtonLoginPageProperties.copyWith(
                       padding: MaterialStateProperty.all(EdgeInsets.zero),
                     ),
                     child: const  Text('Register'),
                 ),
                 ),
               ),
              const SizedBox(height: 50,) ,
              //create new account boutton
              SizedBox(
                height: 55  ,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2.0,
                ),
                  child: const Text('Create new account'),
                ),
              )
            ] ,
          ),
        ),
      ),
    );
  }
}