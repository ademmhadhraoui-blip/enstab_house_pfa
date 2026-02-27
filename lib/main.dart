import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/screens/login_screen.dart';
import 'package:enstabhouse/screens/home_feed_screen.dart';
import 'package:enstabhouse/screens/register_screen.dart';
import 'package:enstabhouse/screens/club_main_page/club_main_page.dart';
import 'package:enstabhouse/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ENSTAB House',

      // 🎨 Thème global — plus besoin de répéter les couleurs partout
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      //  Routes nommées — navigation propre
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeFeedScreen(),
        '/register': (context) => const RegisterScreen(),
        '/club': (context) => const ClubMainPage(),
      },
    );
  }
}