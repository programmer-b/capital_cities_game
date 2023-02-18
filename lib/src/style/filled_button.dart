import 'package:flutter/material.dart';

class FilledButton extends StatelessWidget {
  const FilledButton({super.key, this.onPressed, required this.child});

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(130, 40)),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      child: child,
    );
  }
}
