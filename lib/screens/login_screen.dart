import 'package:enstabhouse/constants.dart';
import 'package:flutter/material.dart';
import 'package:enstabhouse/screens/register_screen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Stack(
         children: [
           Positioned.fill(
             child: Container(
               decoration: BoxDecoration(
                 image: DecorationImage(
                   image: AssetImage("images/logo.png"
                   ),
                   fit: BoxFit.cover ,
                 ),
               ),
             ),
           ),

           Center(
             child: SingleChildScrollView(
               padding: const  EdgeInsets.all(20),
               child: Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(20.0) ,
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black12,
                       blurRadius: 20.0,
                       offset: Offset(0 ,10),
                     ),
                   ],
                 ),
                 child: Column(
                   children: [
                     CircleAvatar(
                       radius: 30 ,
                       backgroundColor: Color(0xFF9E0815),
                       child: const Icon(
                         Icons.school,
                         color: Colors.white ,
                         size: 30,
                       ),
                     ),
                     const SizedBox(height: 20.0,) ,
                     const Text(
                       'Welcome back' ,
                       style: TextStyle(
                         color: Colors.black,
                         fontSize: 24.0,
                         fontWeight: FontWeight.bold,
                       ),
                     ) ,
                     const SizedBox(height: 6.0,) ,
                      Text(
                       "sign in to continue" ,
                       style: TextStyle(
                         color: Colors.grey.shade600,
                         fontSize: 15.0,
                       ),
                     ),
                     const SizedBox(height :20.0) ,
                     TextField(
                       decoration:kTextFilledDecoration,
                     ),
                     const SizedBox(height: 16.0,) ,
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                            prefixIcon: const Icon(
                              Icons.password_outlined ,
                              color: Colors.grey,
                            ),
                            suffixIcon: const Icon(Icons.visibility_off ,
                              color: Colors.grey,
                            ),
                            hintText: "Enter your password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          )
                        ),
                      ),
                     const SizedBox(height: 12.0),
                     Row(
                       children: [
                         Checkbox(
                           value: false, onChanged: (v){},
                         ),
                         const Text("Remember me ?",
                         style: TextStyle(
                           color: Colors.grey,
                         ),
                         ),
                         const Spacer() ,
                         TextButton(
                           child: Text("Forget Password ?",
                           style: TextStyle(
                             color: Color(0xFF9E0815),
                           ),),
                           onPressed: (){
                             //mot de passe oublié !
                           },
                         ),
                       ],
                     ),
                     const SizedBox(height: 12,) ,
                     SizedBox(
                       width: double.infinity,
                       height: 50.0,
                       child: ElevatedButton(
                         onPressed: (){},
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Color(0xFF9E0815) ,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12.0) ,
                           )
                         ),
                         child: Text("Sign In" ,
                         style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0
                         ),
                         ),
                       ),
                     ),
                     SizedBox(height: 20.0,),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Text("Don't have an account ?" ,
                         style: TextStyle(color: Colors.grey
                         ),
                         ),
                         GestureDetector(
                           onTap:(){
                             Navigator.push(context , MaterialPageRoute(
                               builder: (context)=> RegisterScreen() ,
                             ),
                             );
                           } ,
                           child: Text("Register Now" ,
                           style: TextStyle(
                               color: Color(0xFF9E0815
                           )
                           ),
                           ),
                         )
                       ],
                     )
                   ],
                 ),
               ),
             ),
           )
         ],
      )
    );
  }
}
