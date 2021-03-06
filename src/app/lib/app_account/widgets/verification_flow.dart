import 'package:app/affirmations/widgets/affirmations_home_screen.dart';
import 'package:app/profile/blocs/profile/profile_bloc.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationFlow extends StatelessWidget {
  const VerificationFlow({Key? key}) : super(key: key);
  static const String routeName = '/verificationFlow';

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<ProfileState>(
      state: context.select((ProfileBloc bloc) => bloc.state),
      onGeneratePages: (state, pages) {
        return [
          const MaterialPage(child: AffirmationsHomeScreen())
          // if (!state.user.emailVerified)
          //   const MaterialPage(child: UnverifiedAccountScreen())
          // else
          //   const MaterialPage(child: AffirmationsHomeScreen())
        ];
      },
    );
  }
}
