import 'package:enstabhouse/constants.dart';
import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:enstabhouse/screens/home_feed_screen.dart';

class RegisterScreen extends StatefulWidget  {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State <RegisterScreen>with SingleTickerProviderStateMixin {
  bool _isAgreed =false ;
  late AnimationController _controller ;
  late Animation<double> _animation  ;
  @override
  void dispose() {
    _controller.dispose() ;
    super.dispose();
  }
  void _handleTap(){
    setState(() {
      _isAgreed = !_isAgreed;
      if(_isAgreed){
        _controller.forward() ;
      }else{
        _controller.reverse() ;
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _controller =AnimationController(vsync:this ,
        duration: Duration(milliseconds: 500)
    ) ;
    _animation = Tween<double>(begin: 0 , end: 1).animate(
      CurvedAnimation(
          parent : _controller , curve : Curves.easeInOutCirc
      ),
    );
  }
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
                  const SizedBox(height: 30.0,
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
                  const SizedBox(height: 30.0,
                  ) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Full Name" ,
                      prefixIcon: const Icon(Icons.person_2) ,
                      hintText: "Enter your full name"
                    ) ,
                  ) ,
                  const SizedBox(height: 30.0,
                  ) ,
                  TextField(
                    decoration:kTextFilledDecoration.copyWith(
                      labelText: "Email" ,
                      prefixIcon: Icon(Icons.email) ,
                      hintText: "student@enstab.ucar.tn",
                    ),
                  ) ,
                  const SizedBox(height: 30.0,) ,
                  TextField(
                    obscureText: true,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Password" ,
                      hintText: "Enter your password " ,
                      prefixIcon: const Icon(Icons.password_outlined) ,
                      suffixIcon: const Icon(Icons.visibility_off ,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0,) ,
                  TextField(
                    obscureText: true,
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Password Confirmation" ,
                      hintText: "Confirm your password " ,
                      prefixIcon: const Icon(Icons.password_outlined) ,
                      suffixIcon: const Icon(Icons.visibility_off ,
                        color: Colors.grey,
                      ),
                    ),
                  ) ,
                  const SizedBox(height: 30.0,) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Phone Number " ,
                      hintText: "+216 xx xxx xxx" ,
                      prefixIcon: Icon(Icons.phone) ,
                    ),
                  ) ,
                  const SizedBox(height: 30.0,) ,
                  TextField(
                    decoration: kTextFilledDecoration.copyWith(
                      labelText: "Major" ,
                      hintText: "Enter your classe(manaarsh chnya )" ,
                    ),
                  ) ,
                  const SizedBox(height: 20.0,) ,
                  GestureDetector(
                    onTap: _handleTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MSHCheckbox(value: _isAgreed,
                            size: 25,
                            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                              checkedColor: Color(0xFF9E0815),
                              uncheckedColor: Colors.grey,
                            ),
                            style: MSHCheckboxStyle.stroke,
                            onChanged: (bool selected ){
                          setState(() {
                            _isAgreed = selected;
                          });
                            }
                        ),
                        const SizedBox(width: 10,) ,
                        const Text("I agree to the Terms of Service and Privacy Policy",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ) ,
                  const SizedBox(height: 30.0,) ,
                  SizedBox(
                    width : double.infinity,
                    child: ElevatedButton(
                      onPressed : (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>HomeFeedScreen()
                        ) ,
                        ) ;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9E0815) ,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0) ,
                        ),
                      ),
                      child: Text("Register" ,
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0
                      ) ,
                      ),
                  ),
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
