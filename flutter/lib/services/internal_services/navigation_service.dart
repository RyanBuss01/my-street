import 'package:flutter/material.dart';

class NavigationService {

  static pushNoAnimation(context, StatefulWidget route) {
    Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => route,
            transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));
  }

  static Future<dynamic> push (context, StatefulWidget route) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) => route));
  }

  static Future<dynamic> pushReplacement (context, Widget route) {
    return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => route), (Route<dynamic> route) => false);
  }

  static Future<dynamic> fadeUpRoute(context, StatefulWidget route) {
    return Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => route,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, anim1, anim2, widget) {
              return FadeTransition(
                opacity: anim1,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(anim1),
                  child: widget,
                ),
              ) ;
            }
        )
    );
  }

  static Future<dynamic> pushLeft (context, StatefulWidget route) {
    return Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => route,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, anim1, anim2, widget) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(anim1),
                child: widget,
              );
            }
        )
    );
  }

  static pushLeftReplacement (context, StatefulWidget route) {
    Navigator.of(context).pushReplacement(
        PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => route,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, anim1, anim2, widget) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(anim1),
                child: widget,
              );
            }
        )
    );
  }

  static pushUp (context, StatefulWidget route) {
    Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => route,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, anim1, anim2, widget) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(anim1),
                child: widget,
              );
            }
        )
    );
  }

}