import 'package:flutter/material.dart';

class LoginTextfield extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction inputAction;
  final String? Function(String?)? validator;
  final bool isObscure;
  final bool hasSuffix;
  final VoidCallback? onSuffixPressed;

  const LoginTextfield({
    super.key,
    required this.labelText,
    required this.controller,
    required this.keyboardType,
    required this.inputAction,
    this.validator,
    this.isObscure = false,
    this.hasSuffix = false,
    this.onSuffixPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: inputAction,
      obscureText: isObscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: const Color(0xFFE3F2FD), // biru soft
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // default tanpa border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF0D47A1), 
            width: 2,
          ),
        ),
        suffixIcon: hasSuffix
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onSuffixPressed,
              )
            : null,
      ),
    );
  }
}
