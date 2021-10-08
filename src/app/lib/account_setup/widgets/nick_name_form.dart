import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:app/account_setup/blocs/sign_up/sign_up_bloc.dart';
import 'package:app/account_setup/widgets/app_summary_screen.dart';
import 'package:app/consts.dart';
import 'package:app/models/models.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/positive_affirmations_theme.dart';

class NickNameForm extends StatelessWidget {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              _Label(),
              const Padding(padding: EdgeInsets.only(top: 10)),
              _NickNameField(),
              const Padding(padding: EdgeInsets.only(top: 10)),
              _SubmitButton(),
              const Padding(padding: EdgeInsets.only(top: 10)),
              _ChangeNameButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return RichText(
          key: PositiveAffirmationsKeys.nickNameFieldLabel,
          text: TextSpan(
            style:
                PositiveAffirmationsTheme.theme.textTheme.headline1?.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: 'Nice to meet you ',
              ),
              TextSpan(
                text: '${state.name.value}\n',
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  decorationColor: PositiveAffirmationsTheme.highlightColor,
                  decorationThickness: 2,
                ),
              ),
              const TextSpan(text: 'One more question.\n'),
              const TextSpan(
                text: 'What would you like me to call you? 😉',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NickNameField extends StatelessWidget {
  String _generateErrorText(NickNameFieldValidationError error) {
    switch (error) {
      case NickNameFieldValidationError.invalid:
        return PositiveAffirmationsConsts.nickNameFieldInvalidError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return TextField(
          key: PositiveAffirmationsKeys.nickNameField,
          onChanged: (nickName) =>
              context.read<SignUpBloc>().add(NickNameUpdated(nickName)),
          decoration: InputDecoration(
            labelText: 'Nickname',
            errorText: state.nickName.invalid
                ? _generateErrorText(state.nickName.error!)
                : null,
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        return ElevatedButton(
          key: PositiveAffirmationsKeys.nickNameSubmitButton,
          onPressed:
              state.nickNameStatus.isValidated || state.nickNameStatus.isPure
                  ? () {
                      context.read<SignUpBloc>().add(NickNameSubmitted());
                      final bloc = BlocProvider.of<SignUpBloc>(context);
                      Navigator.pushNamed(
                        context,
                        AppSummaryScreen.routeName,
                        arguments: AppSummaryScreenArguments(bloc),
                      );
                    }
                  : null,
          child: Text('NEXT'),
        );
      },
    );
  }
}

class _ChangeNameButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: PositiveAffirmationsKeys.changeNameButton,
      onPressed: () => Navigator.of(context).pop(),
      child: Text('BACK'),
    );
  }
}