import 'package:flutter/material.dart';
import 'package:pin_lock/pin_lock.dart';

/// Represents a visual representation of a single digit of the pin code
/// [InputFieldState] tells the UI wchich state it should draw
/// Optionally, you can modify what the input widgets look like based on their position,
/// e.g., if you want a prefix or a suffix in your pin widget, you'd add it to
/// the `0-th` or `(n-1)-th` input field
class PinInputField extends StatelessWidget {
  final InputFieldState state;
  final int index;
  const PinInputField({
    Key? key,
    required this.state,
    required this.index,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final borderColor = state == InputFieldState.error
        ? Theme.of(context).errorColor
        : Theme.of(context).primaryColor;
    double borderWidth = 1;
    if (state == InputFieldState.focused ||
        state == InputFieldState.filledAndFocused) {
      borderWidth = 4;
    }
    return Container(
      height: 40,
      width: 46,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: state == InputFieldState.filled ||
              state == InputFieldState.filledAndFocused
          ? Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
            )
          : Container(),
    );
  }
}
