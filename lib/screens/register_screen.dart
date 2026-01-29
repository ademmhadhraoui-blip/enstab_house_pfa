import 'package:enstabhouse/constants.dart';
import 'package:flutter/material.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('ENSTABHOUSE'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric( vertical: 20.0),
          child: Column(
            children : <Widget> [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Create account ' ,
                style: kTextProperties,
              ),
            ),
              SizedBox(
                height: 20.0,
              ) ,
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Create an account so you can explore ENSTAB' ,
                  style: kTextProperties.copyWith(
                    fontSize: 15.0,
                  ),
                ),
              ),
              const SizedBox(height: 50.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value){},
                  decoration: kTextFieldDecoration,
                  style : TextStyle(color: Colors.black),

                ),
              ),
              const SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value){},
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password' ,
                  ),
                  style : TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value){},
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'confirm your password' ,
                  ),
                  style : TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 30.0),
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
                        onPressed: () {},
                        style: kButtonLoginPageProperties.copyWith(

                        ) ,
                            child :const Text('Register') ,
                    )
                ),
            ),

                ],
          ),
        ),
      ),
    );
  }
}
