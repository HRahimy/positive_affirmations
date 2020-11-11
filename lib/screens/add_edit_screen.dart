import 'package:flutter/material.dart';
import 'package:positive_affirmations/models/affirmation.dart';
import 'package:positive_affirmations/positive_affirmation_keys.dart';

typedef OnSaveCallback = Function(String message, String remindOn);

class AddEditScreen extends StatefulWidget {
  final bool isEditing;
  final OnSaveCallback onSave;
  final Affirmation affirmation;

  AddEditScreen({
    Key key,
    @required this.onSave,
    @required this.isEditing,
    this.affirmation,
  }) : super(key: key ?? PositiveAffirmationsKeys.addAffirmationScreen);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.isEditing;

  String _message;
  String _remindOn;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Affirmation' : 'New Affirmation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: isEditing ? widget.affirmation.message : '',
                key: PositiveAffirmationsKeys.messageField,
                autofocus: !isEditing,
                style: textTheme.headline5,
                onSaved: (value) => _message = value,
              ),
              TextFormField(
                initialValue: isEditing ? widget.affirmation.remindOn : '',
                key: PositiveAffirmationsKeys.remindOnField,
                style: textTheme.headline5,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: isEditing
            ? PositiveAffirmationsKeys.saveAffirmationFab
            : PositiveAffirmationsKeys.saveNewAffirmation,
        tooltip: isEditing ? 'Save Changes' : 'Add Affirmation',
        child: Icon(isEditing ? Icons.check : Icons.add),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            widget.onSave(_message, _remindOn);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
