import 'package:app/affirmations/blocs/affirmation_form/affirmation_form_bloc.dart';
import 'package:app/affirmations/blocs/affirmations/affirmations_bloc.dart';
import 'package:app/affirmations/models/subtitle_field.dart';
import 'package:app/affirmations/models/title_field.dart';
import 'package:app/consts.dart';
import 'package:app/positive_affirmations_keys.dart';
import 'package:app/positive_affirmations_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:repository/repository.dart';

class AffirmationFormScreenArguments {
  AffirmationFormScreenArguments({
    required this.affirmationsBloc,
    this.affirmationFormBloc,
    this.toUpdateAffirmation,
  });

  final AffirmationsBloc affirmationsBloc;
  final AffirmationFormBloc? affirmationFormBloc;
  final Affirmation? toUpdateAffirmation;
}

class AffirmationFormScreen extends StatelessWidget {
  static const String routeName = '/affirmationFormScreen';

  const AffirmationFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final args = ModalRoute.of(context)!.settings.arguments
        as AffirmationFormScreenArguments;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AffirmationsBloc>.value(value: args.affirmationsBloc),
        if (args.affirmationFormBloc != null)
          BlocProvider<AffirmationFormBloc>.value(
              value: args.affirmationFormBloc!)
        else
          BlocProvider<AffirmationFormBloc>(
              create: (_) => AffirmationFormBloc(
                    affirmationsBloc: args.affirmationsBloc,
                    toUpdateAffirmation: args.toUpdateAffirmation,
                  ))
      ],
      child: Scaffold(
        key: PositiveAffirmationsKeys.affirmationForm,
        appBar: AppBar(
          key: args.toUpdateAffirmation != null
              ? PositiveAffirmationsKeys.editAffirmationFormAppbarTitle
              : PositiveAffirmationsKeys.newAffirmationFormAppbarTitle,
          title: args.toUpdateAffirmation != null
              ? const Text('Edit Affirmation')
              : const Text('New Affirmation'),
          leading: IconButton(
            key: PositiveAffirmationsKeys.affirmationFormBackButton,
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          ),
        ),
        body: _AffirmationForm(args.toUpdateAffirmation),
      ),
    );
  }
}

class _AffirmationForm extends StatelessWidget {
  _AffirmationForm(this.toUpdateAffirmation);

  final GlobalKey<FormState> _affirmationFormKey = GlobalKey<FormState>();

  final Affirmation? toUpdateAffirmation;

  final FocusNode _titleFocusNode = FocusNode();

  Widget _buildTitleLabel() {
    return const Text(
      'Tell me something awesome about you',
      key: PositiveAffirmationsKeys.affirmationFormTitleFieldLabel,
      style: TextStyle(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSubtitleLabel() {
    return const Text(
      'I\'d love it if you told me more about that',
      key: PositiveAffirmationsKeys.affirmationFormSubtitleFieldLabel,
      style: TextStyle(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _titleFocusNode.requestFocus();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Form(
        key: _affirmationFormKey,
        child: Align(
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildTitleLabel(),
              const Padding(padding: EdgeInsets.only(top: 15)),
              _TitleField(
                initialText: toUpdateAffirmation?.title,
                focusNode: _titleFocusNode,
              ),
              const Padding(padding: EdgeInsets.only(top: 30)),
              _buildSubtitleLabel(),
              const Padding(padding: EdgeInsets.only(top: 15)),
              _SubtitleField(toUpdateAffirmation?.subtitle),
              const Padding(padding: EdgeInsets.only(top: 30)),
              _SaveButton(),
              if (toUpdateAffirmation != null) ...[
                const Padding(padding: EdgeInsets.only(top: 30)),
                _ActivateDeactivateButton(
                  toUpdateAffirmation!.id,
                  toUpdateAffirmation!.active,
                ),
                const Padding(padding: EdgeInsets.only(top: 30)),
                _DeleteButton(toUpdateAffirmation!.id),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleField extends StatefulWidget {
  const _TitleField({required this.focusNode, this.initialText});

  final String? initialText;
  final FocusNode focusNode;

  @override
  __TitleFieldState createState() => __TitleFieldState(focusNode, initialText);
}

class __TitleFieldState extends State<_TitleField> {
  __TitleFieldState(this.focusNode, this.initialText);

  final FocusNode focusNode;

  String? initialText;
  TextEditingController? _textController;

  @override
  initState() {
    _textController = TextEditingController(text: initialText);
    super.initState();
  }

  String _generateErrorText(TitleFieldValidationError error) {
    switch (error) {
      case TitleFieldValidationError.empty:
        return PositiveAffirmationsConsts.titleFieldEmptyError;
      case TitleFieldValidationError.invalid:
        return PositiveAffirmationsConsts.titleFieldInvalidError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AffirmationFormBloc, AffirmationFormState>(
      builder: (context, state) {
        return TextField(
          key: PositiveAffirmationsKeys.affirmationFormTitleField,
          controller: _textController,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          onChanged: (title) {
            BlocProvider.of<AffirmationFormBloc>(context)
                .add(TitleUpdated(title));
          },
          decoration: InputDecoration(
            labelText: 'Title',
            errorText: state.title.invalid
                ? _generateErrorText(state.title.error!)
                : null,
          ),
        );
      },
    );
  }
}

class _SubtitleField extends StatefulWidget {
  const _SubtitleField(this.initialText);

  final String? initialText;

  @override
  __SubtitleFieldState createState() => __SubtitleFieldState(initialText);
}

class __SubtitleFieldState extends State<_SubtitleField> {
  __SubtitleFieldState(this.initialText);

  String? initialText;
  TextEditingController? _textController;

  @override
  initState() {
    _textController = TextEditingController(text: initialText);
    super.initState();
  }

  String _generateErrorText(SubtitleFieldValidationError error) {
    switch (error) {
      case SubtitleFieldValidationError.invalid:
        return PositiveAffirmationsConsts.subtitleFieldInvalidError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AffirmationFormBloc, AffirmationFormState>(
      builder: (context, state) {
        return TextField(
          key: PositiveAffirmationsKeys.affirmationFormSubtitleField,
          controller: _textController,
          textInputAction: TextInputAction.done,
          onChanged: (subtitle) {
            BlocProvider.of<AffirmationFormBloc>(context)
                .add(SubtitleUpdated(subtitle));
          },
          onEditingComplete: state.status == FormzStatus.invalid ||
                  state.status == FormzStatus.pure
              ? null
              : () {
                  BlocProvider.of<AffirmationFormBloc>(context)
                      .add(AffirmationSubmitted());
                  Navigator.of(context).pop();
                },
          decoration: InputDecoration(
            labelText: 'Description',
            errorText: state.subtitle.invalid
                ? _generateErrorText(state.subtitle.error!)
                : null,
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AffirmationFormBloc, AffirmationFormState>(
      builder: (context, state) {
        return ElevatedButton(
          key: PositiveAffirmationsKeys.affirmationFormSaveButton,
          onPressed: state.status == FormzStatus.invalid ||
                  state.status == FormzStatus.pure
              ? null
              : () {
                  BlocProvider.of<AffirmationFormBloc>(context)
                      .add(AffirmationSubmitted());
                  Navigator.of(context).pop();
                },
          child: const Text('SAVE'),
        );
      },
    );
  }
}

class _ActivateDeactivateButton extends StatelessWidget {
  const _ActivateDeactivateButton(
    this.id,
    this.active, {
    Key? key,
  }) : super(key: key);

  final String id;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: PositiveAffirmationsKeys.affirmationFormDeactivateDeactivateButton(
          id),
      onPressed: () {
        context.read<AffirmationsBloc>().add(AffirmationActivationToggled(id));
        Navigator.pop(context);
      },
      style: OutlinedButton.styleFrom(
        primary: active ? Colors.red : PositiveAffirmationsTheme.highlightColor,
      ),
      child: Text(
        active ? 'DEACTIVATE' : 'ACTIVATE',
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: PositiveAffirmationsKeys.affirmationFormDeleteButton(id),
      onPressed: () {
        context.read<AffirmationsBloc>().add(AffirmationDeleted(id: id));
        Navigator.pop(context);
      },
      style: OutlinedButton.styleFrom(primary: Colors.red),
      child: const Text(
        'DELETE',
      ),
    );
  }
}
