
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PageTransitionType { none, slideLeft, slideRight, slideTop, slideBottom, fade }

class PixEventHandler {
  static void pushPage({
    required BuildContext context,
    required Widget route,
    bool isCupertino = false,
    PageTransitionType transition = PageTransitionType.none,
    int duration = 300,
  }) {
    if (transition != PageTransitionType.none) {
      Navigator.push(
        context,
        createPageRoute(route, transition: transition, duration: Duration(milliseconds: duration)),
      );
    } else {
      Navigator.push(
        context,
        isCupertino ? CupertinoPageRoute(builder: (context) => route) : MaterialPageRoute(builder: (context) => route),
      );
    }
  }

  static void pop({required BuildContext context}) {
    Navigator.pop(context);
  }

  static void showBottomSheetPage({required BuildContext context, required Widget route, double? maxHeight}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return route;
      },
      isScrollControlled: true,
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight) : null,
    );
  }

  static void showDialogPage(
      {required BuildContext context, required Widget route, bool barrierDismissible = true, Color? barrierColor}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return route;
      },
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
    );
  }
}

Route<T> createPageRoute<T>(
  Widget page, {
  PageTransitionType transition = PageTransitionType.slideRight,
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.ease,
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transition) {
        case PageTransitionType.none:
        case PageTransitionType.fade:
          return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: curve), child: child);

        case PageTransitionType.slideLeft:
        case PageTransitionType.slideRight:
        case PageTransitionType.slideTop:
        case PageTransitionType.slideBottom:
          Offset begin;
          switch (transition) {
            case PageTransitionType.slideLeft:
              begin = const Offset(-1.0, 0.0);
              break;
            case PageTransitionType.slideRight:
              begin = const Offset(1.0, 0.0);
              break;
            case PageTransitionType.slideTop:
              begin = const Offset(0.0, -1.0);
              break;
            case PageTransitionType.slideBottom:
              begin = const Offset(0.0, 1.0);
              break;
            default:
              begin = Offset.zero;
          }

          final tween = Tween<Offset>(begin: begin, end: Offset.zero).chain(CurveTween(curve: curve));

          return SlideTransition(position: animation.drive(tween), child: child);
      }
    },
  );
}

