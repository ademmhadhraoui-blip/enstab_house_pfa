import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar:   AppBar(
            title: const Text('ENSTABHOUSE'),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min ,
            children:<Widget> [
            Align(alignment: Alignment.center,) ,
            Padding(padding: const EdgeInsets.all(40.0) ,
            ),
            const Text(
              'WELCOME',
              style: kTextProperties,
            ),
            const Text(
              'TO ENSTAB HOUSE',
              style: kTextProperties ,
              ),
            const SizedBox(
                height: 100.0
            ) ,
             Image.asset(
              'images/logo.png',
               height: 220, width: 220,
            ) ,
            const SizedBox(height: 50.0,) ,
            const Text('DISCOVER ENSTAB HERE' ,
            style: kTextProperties,
            ) ,
          const SizedBox(height: 50.0,) ,
          Row(
           mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // login button
              SizedBox(
                width: 150 , height: 70 ,
                child: Container(decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15) ,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4) ,
                      blurRadius: 20,
                      spreadRadius: 2 ,
                    ),
                  ]
                ),
                  child:
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context , MaterialPageRoute(
                        builder: (context) => LoginScreen() ,
                      ) ,
                      )  ;
                    },
                    style: kWelcomePageButtonStyle ,
                    child: Text('LOGIN'),
                  ),
                ),
              ) ,
                const SizedBox(width: 20),
              // register button
              SizedBox(
                width: 150 , height: 70,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context , MaterialPageRoute(
                        builder: (context) => RegisterScreen() ,
                      ) ,
                      )  ;
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2.0,
                     ),
                    child: const Text('REGISTER'),
                   ),
              ),
            ],
          )
          ],
          ),
        );

  }
}
