import 'package:flutter/material.dart';
import 'package:note_x/utils/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: "You cannot share empty note!",
    optionsBuilder: () => {'Ok': null},
  );
}
