import 'package:flutter/material.dart';
import 'package:note_x/utils/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'We have sent you a password reset email. Please check your email.',
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}
