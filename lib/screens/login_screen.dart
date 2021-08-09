import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';
import 'package:delivery_app/screens/register_screen.dart';
import 'package:delivery_app/services/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:delivery_app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  Icon icon;
  bool _visible = false;
  var _emailTextController = TextEditingController();
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 250,
                              width: 250,
                              child: Image.asset(
                                'images/logo.png',
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                'VZY Cart- Delivery Boy App',
                                style: TextStyle(
                                    fontFamily: 'Anton',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Email';
                          }
                          final bool _isValid = EmailValidator.validate(
                              _emailTextController.text);
                          if (!_isValid) {
                            return 'Invalid Email Format';
                          }
                          setState(() {
                            email = value;
                          });
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                          ),
                          focusColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter Password';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          setState(() {
                            password = value;
                          });
                          return null;
                        },
                        obscureText: _visible == false ? true : false,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: _visible
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _visible = !_visible;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(),
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                            ),
                            focusColor: Theme.of(context).primaryColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      //forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, ResetPassword.id);
                              },
                              child: Text(
                                'Forgot Password ? ',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            // ignore: deprecated_member_use
                            child: FlatButton(
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  EasyLoading.show(status: 'Please wait...');
                                  _services.validateUser(email).then((value) {
                                    if (value.exists) {
                                      if (value['password'] == password) {
                                        _authData
                                            .loginBoys(email, password)
                                            .then((credential) {
                                          if (credential != null) {
                                            EasyLoading.showSuccess(
                                                    'Logged In Successfully')
                                                .then((value) {
                                              Navigator.pushReplacementNamed(
                                                  context, HomeScreen.id);
                                            });
                                          } else {
                                            EasyLoading.showInfo(
                                                    'Need to complete Registration')
                                                .then((value) {
                                              _authData.getEmail(email);
                                              Navigator.pushNamed(
                                                  context, RegisterScreen.id);
                                            });
                                            /*ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(_authData.error)));*/
                                          }
                                        });
                                      } else {
                                        EasyLoading.showError(
                                            'Invalid password');
                                      }
                                    } else {
                                      EasyLoading.showError(
                                          '$email does not registered as our Delivery Boy');
                                    }
                                  });
                                }
                              },
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
        ),
      ),
    );
  }
}

//next video will do delivery boy register and loggin
