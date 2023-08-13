import 'package:flutter/material.dart';
import 'package:note_x/utils/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this note?',
    optionsBuilder: () {
      return {
        'Cancel': false,
        'Yes': true,
      };
    },
  ).then((value) => value ?? false);
}
