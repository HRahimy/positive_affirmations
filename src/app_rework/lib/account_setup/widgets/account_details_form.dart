import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:positive_affirmations/account_setup/bloc/sign_up/sign_up_cubit.dart';

class AccountDetailsForm extends StatelessWidget {
  const AccountDetailsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Form(),
    );
  }
}

class _Form extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Form(
            key: _formKey,
            child: Align(
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                children: const [
                  _Label(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  // _EmailField(),
                  // const Padding(padding: EdgeInsets.only(top: 10)),
                  // _PasswordField(),
                  // const Padding(padding: EdgeInsets.only(top: 10)),
                  // _ConfirmPasswordField(),
                  // const Padding(padding: EdgeInsets.only(top: 10)),
                  // if (state.submissionStatus == FormzStatus.submissionFailure)
                  //   Text(
                  //     state.submissionError,
                  //     style: const TextStyle(color: Colors.red),
                  //   ),
                  // const _SubmitButton(),
                  // const Padding(padding: EdgeInsets.only(top: 10)),
                  // const _BackButton(),
                  // const AlreadyHaveAccountPanel(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'And finally\n',
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          TextSpan(
            text:
                'To give you access to all features, I\'d need your email address and for you to set a strong password to your public account.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
