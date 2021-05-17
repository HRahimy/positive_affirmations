import 'package:flutter/material.dart';

typedef OnObservation = void Function(Route<dynamic> route, Route<dynamic> previousRoute);

class PositiveAffirmationsNavigatorObserver extends NavigatorObserver {
  OnObservation? onPushed;
  OnObservation? onPopped;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onPushed != null) {
      onPushed!(route, previousRoute!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (onPopped != null) {
      onPopped!(route, previousRoute!);
    }
  }

  attachPushRouteObserver(String expectedRouteName, Function pushCallback) {
    onPushed = (route, previousRoute) {
      final isExpectedRoutePushed = route.settings.name == expectedRouteName;
      // trigger callback if expected route is pushed
      print('newRoute: ${route.toString()},\n previousRoute: ${previousRoute.toString()}');
      if(isExpectedRoutePushed) { pushCallback(); }
    };
  }

  attachPopRouteObserver(String expectedRouteName, Function popCallback) {
    onPopped = (route, previousRoute) {
      final isExpectedRoutePushed = route.settings.name == expectedRouteName;
      // trigger callback if expected route is popped
      if(isExpectedRoutePushed) { popCallback(); }
    };
  }
}
