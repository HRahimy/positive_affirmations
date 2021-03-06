import 'package:flutter/material.dart';
import 'package:positive_affirmations/common/common_keys.dart';
import 'package:positive_affirmations/common/models/form_fields/nullable_person_name_field.dart';
import 'package:positive_affirmations/common/widgets/common_form_padding.dart';

class CommonNullablePersonNameField extends StatefulWidget {
  const CommonNullablePersonNameField({
    Key? key = CommonKeys.commonNullablePersonNameFormField,
    required this.name,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);
  final NullablePersonNameField name;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  @override
  State<StatefulWidget> createState() => _CommonNullablePersonNameFieldState();
}

class _CommonNullablePersonNameFieldState
    extends State<CommonNullablePersonNameField> {
  late FocusNode _focusNode;
  late bool _canShowError;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_focusListener);
    _canShowError = !_focusNode.hasFocus;
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
    if (widget.name.error != null &&
        !widget.name.pure &&
        widget.name.value != null &&
        _canShowError) {
      if (widget.name.value!.isNotEmpty) {
        switch (widget.name.error) {
          case NullablePersonNameFieldValidationError.invalid:
            return 'Name cannot contain any of the following characters: * . ( ) / \\ [ ] { } \$ = - & ^ % # @ ! ~ \' "';
          default:
            return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CommonFormPadding(
      child: TextFormField(
        focusNode: _focusNode,
        initialValue: widget.name.value,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          isDense: true,
          fillColor: Colors.white,
          filled: true,
          labelText: 'Nick name',
          errorText: _errorText,
        ),
      ),
    );
  }
}
