import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressed;
  const AuthButton({
    super.key,
    required this.labelText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0D47A1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          labelText,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}