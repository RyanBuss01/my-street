import 'package:flutter/material.dart';
import '../../screens/authenticate/widgets/logo_loading_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../frame.dart';
import 'authenticate.dart';


class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  Future<String> isUserSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('id') ?? '';
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: isUserSignedIn(),
        builder: (context, snap) {
          if(snap.connectionState == ConnectionState.done) {
            if (snap.data == '' || snap.data == null || snap.data == 'null') {
              return Authenticate();
            }
            else {
              return Frame(id: int.parse(snap.data.toString()));
            }
          }
          else {
            return logoLoadingWidget();
          }
        }
      // return const Authenticate();
    );
  }
}
