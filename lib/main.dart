import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:delivery_app/screens/splash_screen.dart';
import 'package:delivery_app/screens/login_screen.dart';

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VZY Cart- Delivery Boy App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      builder: EasyLoading.init(),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ResetPassword.id: (context) => ResetPassword(),
        RegisterScreen.id: (context) => RegisterScreen(),
      },
    );
  }
}
