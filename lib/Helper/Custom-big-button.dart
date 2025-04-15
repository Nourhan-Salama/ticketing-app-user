import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String buttonText;

  const SubmitButton({
    Key? key,
    required this.isEnabled,
    required this.onPressed,
    required this.buttonText,  bool ?isLoading,  
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null, // Disable if not enabled
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? Color(0xFF0E004F) // **Color from Figma (Dark Purple)**
              : Color(0xFFB4A7F5).withOpacity(0.5), // **Disabled Color (Blur Effect)**
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

