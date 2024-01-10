import 'package:flutter/material.dart';
import '../../screens/authenticate/register_screen.dart';
import '../../screens/authenticate/sign_in_screen.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final formKey = GlobalKey<FormState>();
  bool signInScreen = true;
  bool loadingAuth = false;


  void signInCallback(bool signIn) {
    setState(() {
      signInScreen = signIn;
    });
  }


  @override
  Widget build(BuildContext context) {
    return signInScreen

    /// Sign In Screen

        ? SignInScreen(formKey: formKey, signInCallback: signInCallback, )

    /// Sign Up Screen

        : RegisterScreen(formKey: formKey, signInCallback: signInCallback);
  }
}