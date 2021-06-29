import 'package:flutter/material.dart';
import 'package:mobile_app/account_setup/widgets/app_summary_screen.dart';
import 'package:mobile_app/account_setup/widgets/name_form_screen.dart';
import 'package:mobile_app/account_setup/widgets/nick_name_form_screen.dart';
import 'package:mobile_app/affirmations/widgets/affirmations_home_screen.dart';

class PositiveAffirmationsRoutes {
  Map<String, Widget Function(BuildContext context)> routes(
      BuildContext context) {
    return {
      // '/': (context) => NameFormScreen(),
      NameFormScreen.routeName: (context) => NameFormScreen(),
      NickNameFormScreen.routeName: (context) => NickNameFormScreen(),
      AppSummaryScreen.routeName: (context) => AppSummaryScreen(),
      AffirmationsHomeScreen.routeName: (context) => AffirmationsHomeScreen(),
    };
  }
// Map<String, Widget Function(BuildContext)> get  routes = () {
//   return {};
// }
// final Map<String, Widget Function(BuildContext)> routes =
//     (BuildContext context) {
//   return {
//     NickNameFormScreen.routeName
//         : (context) => NickNameFormScreen(),
//   };
// }
}
