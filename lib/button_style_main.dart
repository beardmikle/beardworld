import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const StyledButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown[300]?.withOpacity(0.5), // Transparent background (e.g., earth)
        border: Border.all(
          color: Colors.green, // Border color (e.g., grass)
          width: 4.0, // Border thickness
        ),
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Makes the button background transparent
          shadowColor: Colors.transparent, // Removes shadows
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Text color
            // backgroundColor: Colors.black26, // Semi-transparent text background
          ),
        ),
      ),
    );
  }
}
