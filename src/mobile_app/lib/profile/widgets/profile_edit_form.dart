import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

class ProfileEditFormArgs {
  const ProfileEditFormArgs({
    required this.userInitial,
  });

  final User userInitial;
}

class ProfileEditForm extends StatelessWidget {
  static const String routeName = '/profileEditForm';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final args =
        ModalRoute.of(context)!.settings.arguments as ProfileEditFormArgs;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Center(
        child: Text('Profile edit form'),
      ),
    );
  }
}
