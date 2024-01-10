import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/authenticate/wrapper.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
        title: 'My_street',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Wrapper(),
      // routes: {
      //     '/map' : (context) => MapScreen(currentPosition: currentPosition,)
      // },
    );
  }
}
