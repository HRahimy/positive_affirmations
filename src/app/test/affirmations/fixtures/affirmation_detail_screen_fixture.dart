import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/affirmations/blocs/affirmations/affirmations_bloc.dart';
import 'package:app/affirmations/widgets/affirmation_detail_screen.dart';
import 'package:repository/src/models/affirmation.dart';

class AffirmationDetailScreenFixture extends StatelessWidget {
  AffirmationDetailScreenFixture({
    required this.affirmation,
    required this.affirmationsBloc,
    this.navigatorObserver,
  });

  final Affirmation affirmation;
  final AffirmationsBloc affirmationsBloc;
  final NavigatorObserver? navigatorObserver;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AffirmationsBloc>.value(value: affirmationsBloc),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          final args = AffirmationDetailScreenArguments(
            affirmation,
            affirmationsBloc,
          );

          return MaterialPageRoute(
            builder: (context) {
              return AffirmationDetailScreen();
            },
            settings: RouteSettings(
              name: AffirmationDetailScreen.routeName,
              arguments: args,
            ),
          );
        },
        initialRoute: AffirmationDetailScreen.routeName,
        navigatorObservers: [if (navigatorObserver != null) navigatorObserver!],
      ),
    );
  }
}
