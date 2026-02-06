import 'package:enstabhouse/constants.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Color(0xFF9E0815),
                    child:  Icon(
                      Icons.school ,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                  const SizedBox(height: 20.0,
                  ),
                  const Text("Create Account" ,
                    style: TextStyle(
                      color : Colors.black,
                      fontSize: 20.0 ,
                      fontWeight: FontWeight.bold ,
                    ),
                  ),
                  const Text("Join ENSTAB community " ,
                  style: TextStyle(
                    color: Colors.black ,
                    fontSize: 10.0,
                  ),
                  ) ,
                  const SizedBox(height: 20.0,
                  ) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Full Name" ,
                      prefixIcon: const Icon(Icons.person_2) ,
                      hintText: "Enter your full name"
                    ) ,
                  ) ,
                  const SizedBox(height: 20.0,
                  ) ,
                  TextField(
                    decoration:kTextFilledDecoration.copyWith(
                      labelText: "Email" ,
                      prefixIcon: Icon(Icons.email) ,
                      hintText: "student@enstab.ucar.tn",
                    ),
                  ) ,
                  const SizedBox(height: 20.0,) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Password" ,
                      hintText: "Enter your password " ,
                      prefixIcon: Icon(Icons.password_outlined)
                    ),
                  ),
                  const SizedBox(height: 20.0,) ,
                  const SizedBox(height: 20.0,
                  ) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Phone Number " ,
                      hintText: "+216 xx xxx xxx" ,
                      prefixIcon: Icon(Icons.phone) ,
                    ),
                  ) ,
                  const SizedBox(height: 20.0,) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Major" ,
                      hintText: "Enter your classe(manaarsh chnya )" ,

                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
