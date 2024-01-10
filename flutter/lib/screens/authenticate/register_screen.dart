import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/constants/auth_text_input.dart';
import '../../models/constants/loading_widget.dart';
import '../../services/node_services/user_service.dart';
import '../frame.dart';


class RegisterScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<bool> signInCallback;
  const RegisterScreen({Key? key, required this.formKey, required this.signInCallback}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late GlobalKey<FormState> formKey;

  String? _displayName, _username, _email, _password, _firstName, _lastName, _verifyPassword;
  DateTime? _birthday;
  String? _error, _birthdayError;

  bool loadingAuth = false;

  void registerUser() async {
    var res = await UserService().attemptSignUp(
        email: _email!,
        password: _password!,
        firstName: _firstName!,
        lastName: _lastName!,
        displayName: _displayName!,
        username: _username!,
        birthday: _birthday!
    );
    if(res.statusCode == 200) {
      var json = jsonDecode(res.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('signedIn', true);
      prefs.setString('id', json['id'].toString());
      Navigator.push(context, MaterialPageRoute(builder:(context) => Frame(id: json['id'])));
    } else if(res.statusCode == 203) {
      print(jsonDecode(res.body)['error']);
      setState(() {
        loadingAuth = false;
        if(jsonDecode(res.body)['error'] == 'email') {
          _error = 'Email already exists';
        }
        if (jsonDecode(res.body)['error'] == 'username') {
          _error = 'Username already exists';
        }
      });
    } else {
      loadingAuth = false;
      _error = 'Error signing up';
    }
  }



  @override
  void initState() {
    formKey = widget.formKey;
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return loadingAuth
        ? LoadingWidget()
        :GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Sign Up'), backgroundColor: Colors.black,),
      body: Center(
          child: Form(
            key: formKey,
            child: ListView(
              cacheExtent: 10000,
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 50,),

                textField('_firstName', 'First Name', false, _firstName),
                textField('_lastName', 'Last Name', false, _lastName),
                datePicker(),
                Visibility(
                  visible: _birthdayError != null,
                  child: Center(child: Column(
                    children: [
                      Text(_birthdayError ?? '', style: const TextStyle(color: Colors.red),),
                      SizedBox(height: 25,)
                    ],
                  )),
                ),
                textField('_username', 'Username', false, _username),
                textField('_displayName', 'Display Name', false, _displayName),
                textField('_email', 'Email', false, _email),
                textField('_password', 'Password', true, _password),
                textField('_verifyPassword', 'Confirm Password', true, _verifyPassword),

                Visibility(
                  visible: _error != null,
                  child: Center(child: Text(_error ?? '', style: const TextStyle(color: Colors.red),)),
                ),
                const SizedBox(height: 20,),

                signUpButton(),

                TextButton(
                    onPressed: () {
                      widget.signInCallback(true);
                    },
                    child: const Text(
                      'Already have an account? click here sign In',
                      style: TextStyle(color: Colors.blue),
                    )
                ),
                const SizedBox(height: 50,)
              ],),
          ),
      ),
    ),
        );
  }



  Widget datePicker() {
    DateTime today = DateTime.now();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: today,
          firstDate: DateTime(1900),
          lastDate: DateTime(today.year, today.month, today.day));
      if (picked != null && picked != _birthday) {
        setState(() {
          _birthday = picked;
        });
      }
    }
    return SizedBox(
      height: 100,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text('Date of Birth: ', style: TextStyle(color: Colors.white, fontSize: 25),),
            SizedBox(
              height: 50,
              width: 120,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[700]!),
                  side: _birthdayError != null ? MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.red)) : null
                ),
                onPressed: () => _selectDate(context),
                child: Text(_birthday == null ? 'Select date' : '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField(String? val, String hintText, bool obscureText, String? initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0, vertical: 15),
      child: TextFormField(
        maxLength: val == '_email' ? null : 30,
        style: const TextStyle(color: Colors.white),
        initialValue: initialValue,
        obscureText: obscureText,
        decoration: textInputDecoration(hintText),
        validator: (value) {
          if(value == null || value.isEmpty || value.trim() == '') {
            return 'field must be filled';
          }
          if(val == '_firstName') {
            if(value.trim().length > 30) {
              return 'maximum of 30 characters';
            }
            if(value.trim().length < 2) {
              return 'must have more then 2 characters';
            }
          }
          if(val == '_lastName') {
            if(value.trim().length > 30) {
              return 'maximum of 30 characters';
            }
            if(value.trim().length < 2) {
              return 'must have at least 2 characters';
            }
          }
          if(val == '_username') {
            if(value.trim().length > 30) {
              return 'maximum of 30 characters';
            }
            if(value.trim().length < 4) {
              return 'must have at least 4 characters';
            }
          }
          if(val == '_displayName') {
            if(value.trim().length > 30) {
              return 'maximum of 30 characters';
            }
            if(value.trim().length < 4) {
              return 'must have at least 4 characters';
            }
          }
          if(val == '_email') {
            bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value.trim());
            if(!emailValid) {
              return 'invalid email';
            }
          }
          if(val == '_password') {
            if(value.trim().length < 6) {
              return 'must have at least 6 characters';
            }
            if(value.trim().length > 30) {
              return 'maximum of 30 characters';
            }
            final validCharacters = RegExp(r'^[a-zA-Z0-9_\-=@,$()/?]+$');
            if(validCharacters.hasMatch(value.trim()) == false) {
              return 'must be numbers, letters or "_-=@,\$()/?"';
            }
          }
          if(val == '_verifyPassword') {
            if(value.trim() != _password) {
              return 'passwords do not match';
            }
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            if(val == '_firstName') _firstName = value.trim();
            if(val == '_lastName') _lastName = value.trim();
            if(val == '_displayName') _displayName = value.trim();
            if(val == '_username') _username = value.trim();
            if(val == '_email') _email = value.trim();
            if(val == '_password') _password = value.trim();
            if(val == '_verifyPassword') _verifyPassword = value.trim();
          });
        },
      ),
    );
  }



  Center signUpButton() {
    return Center(
      child: SizedBox(
        height: 40,
        width: 80,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            child: const Center(
                child: Text('Sign up', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700),)
            ),
            onTap: () {
              if(_birthday == null) {
                setState(() {
                  _birthdayError = 'enter birthdate';
                });
              } else {
                setState(() {
                  _birthdayError = null;
                });
              }

              if (formKey.currentState!.validate()) {
                if (_birthday != null) {
                  setState(() {
                    loadingAuth = true;
                  });
                  registerUser();
                }
              }
            },
          ),
        ),

      ),
    );
  }
}
