import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final bool autoFocus;
  final bool enabled;
  final InputBorder border;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final String labelText;
  final String? Function(String?)? validation;
  InputField(this.controller, this.labelText, this.inputType,
      {Key? key,
        this.autoFocus = false,
        this.hintText = "",
        this.enabled = true,
        this.validation,
        this.inputFormatters,
        this.border = const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: .5,
            ))})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autofocus: autoFocus,
      inputFormatters: inputFormatters ?? [],
      validator: validation,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(height: .4, fontWeight: FontWeight.w400),
        border: border,
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: .5,
            )),
      ),
    );
  }
}
