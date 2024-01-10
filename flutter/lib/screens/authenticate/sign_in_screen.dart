import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/constants/auth_text_input.dart';
import '../../models/constants/loading_widget.dart';
import '../../services/node_services/user_service.dart';
import '../frame.dart';

class SignInScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<bool> signInCallback;
  const SignInScreen({Key? key, required this.signInCallback, required this.formKey}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? _email, _password;
  String? _error;

  bool loadingAuth = false;

  void signIn() async  {
    var res = await UserService().attemptLogIn(_email!, _password!);
    if (res.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var json = jsonDecode(res.body);
      prefs.setBool('signedIn', true);
      prefs.setString('id', json['user_id'].toString());
      Navigator.push(context, MaterialPageRoute(builder:(context) => Frame(id: json['user_id'])));
    } else if(res.statusCode == 204) {
      setState(() {
        loadingAuth = false;
        _error = 'invalid e-mail or password';
      });
    }
    else {
      setState(() {
        loadingAuth = false;
        _error = 'Error logging in';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return loadingAuth

        ? LoadingWidget()

        : GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.black,),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                textField('_email', 'Email', false),
                textField('_password', 'Password', true),

                Visibility(visible: _error != null,child: const SizedBox(height: 20,)),
                Visibility(
                  visible: _error != null,
                  child: Text(_error ?? '', style: const TextStyle(color: Colors.red),),
                ),
                const SizedBox(height: 20,),
                Ink(
                  height: 40,
                  width: 80,
                  child: InkWell(
                      child: const SizedBox(
                        height: 40,
                        width: 80,
                        child: Center(
                          child: Text(
                            'Sign in',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          loadingAuth = true;
                        });
                        signIn();
                      }
                  ),
                ),

                TextButton(
                    onPressed: () {
                      widget.signInCallback(false);
                    },
                    child: const Text(
                      'Click here to sign up',
                      style: TextStyle(color: Colors.blue),
                    )
                ),
                const SizedBox(height: 50,),
              ],),
          ),
        );
  }

  Padding textField(String? val, String hintText, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 15),
      child: TextFormField(
        obscureText: obscureText,
        decoration: textInputDecoration(hintText),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            if (val == '_email') _email = value.trim();
            if (val == '_password') _password = value.trim();
          });
        },
      ),
    );
  }

}