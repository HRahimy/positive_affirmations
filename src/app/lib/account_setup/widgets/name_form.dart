import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:app/account_setup/blocs/sign_up/sign_up_bloc.dart';
import 'package:app/account_setup/widgets/nick_name_form_screen.dart';
import 'package:app/consts.dart';
import 'package:app/models/models.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/positive_affirmations_theme.dart';

class NameForm extends StatelessWidget {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildLabel() => RichText(
        key: PositiveAffirmationsKeys.nameFieldLabel,
        text: TextSpan(
          style: PositiveAffirmationsTheme.theme.textTheme.headline1?.copyWith(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: 'Hi. My name\'s Buddy\n',
              style: TextStyle(color: Colors.grey),
            ),
            const TextSpan(text: 'What\'s your name?'),
          ],
        ),
      );

  Widget _buildSubmitButton() => BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return ElevatedButton(
            key: PositiveAffirmationsKeys.nameSubmitButton,
            onPressed: state.nameStatus.isValidated
                ? () {
                    context.read<SignUpBloc>().add(NameSubmitted());
                    final bloc = BlocProvider.of<SignUpBloc>(context);
                    Navigator.pushNamed(
                      context,
                      NickNameFormScreen.routeName,
                      arguments: NickNameFormScreenArguments(bloc),
                    );
                  }
                : null,
            child: Text('NEXT'),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35),
      child: Form(
        key: _formKey,
        child: Align(
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLabel(),
              const Padding(padding: EdgeInsets.only(top: 10)),
              _NameField(),
              const Padding(padding: EdgeInsets.only(top: 10)),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  String _generateErrorText(NameFieldValidationError error) {
    switch (error) {
      case NameFieldValidationError.empty:
        return PositiveAffirmationsConsts.nameFieldEmptyError;
      case NameFieldValidationError.invalid:
        return PositiveAffirmationsConsts.nameFieldInvalidError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return TextField(
          key: PositiveAffirmationsKeys.nameField,
          onChanged: (name) =>
              context.read<SignUpBloc>().add(NameUpdated(name)),
          decoration: InputDecoration(
            labelText: 'Name',
            errorText: state.name.invalid
                ? _generateErrorText(state.name.error!)
                : null,
          ),
        );
      },
    );
  }
}