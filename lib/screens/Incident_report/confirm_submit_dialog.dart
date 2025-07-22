import 'package:flutter/material.dart';
import '../../shared/widgets/custom_button.dart';

class ConfirmSubmitDialog extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  const ConfirmSubmitDialog({super.key, required this.onSubmit, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Report'),
      content: const Text('Are you sure you want to submit this report? Once submitted, you will not be able to make any further changes.'),
      actions: [
        CustomButton(
          text: 'Cancel',
          type: ButtonType.secondary,
          onPressed: onCancel,
        ),
        CustomButton(
          text: 'Submit',
          onPressed: onSubmit,
        ),
      ],
    );
  }
} 