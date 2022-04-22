import 'package:flutter/material.dart';
import 'package:positive_affirmations/common/common_keys.dart';
import 'package:positive_affirmations/common/models/form_fields/email_field.dart';
import 'package:positive_affirmations/common/widgets/common_form_padding.dart';

class CommonEmailFormField extends StatefulWidget {
  const CommonEmailFormField({
    Key? key = CommonKeys.commonEmailFormField,
    required this.email,
    this.onChanged,
  }) : super(key: key);

  final EmailField email;
  final Function(String)? onChanged;

  @override
  State<StatefulWidget> createState() => _CommonEmailFormFieldState();
}

class _CommonEmailFormFieldState extends State<CommonEmailFormField> {
  late FocusNode _focusNode;
  bool _canShowError = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(_focusListener);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    super.dispose();
  }

  void _focusListener() {
    setState(() {
      _canShowError = !_focusNode.hasFocus;
    });
  }

  String? get _errorText {
    if (widget.email.error != null &&
        !widget.email.pure &&
        widget.email.value.isNotEmpty &&
        _canShowError) {
      switch (widget.email.error) {
        case EmailFieldValidationError.invalid:
          return 'Invalid email.';
        default:
          return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CommonFormPadding(
      child: TextFormField(
        focusNode: _focusNode,
        initialValue: widget.email.value,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          labelText: 'Email *',
          errorText: _errorText,
        ),
      ),
    );
  }
}
