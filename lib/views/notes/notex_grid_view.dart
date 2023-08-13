import 'package:flutter/material.dart';
import 'package:note_x/services/crud/notes_service.dart';
import 'package:note_x/utils/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotexGridView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;
  const NotexGridView(
      {super.key, required this.notes, required this.onDeleteNote});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 1,
              child: GestureDetector(
                onLongPress: () async {
                  final bool shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteNote(note);
                  }
                },
                child: GridTile(
                  // footer: IconButton(
                  //   onPressed: () async {
                  //     final bool shouldDelete = await showDeleteDialog(context);
                  //     if (shouldDelete) {
                  //       onDeleteNote(note);
                  //     }
                  //   },
                  //   icon: const Icon(
                  //     Icons.close,
                  //     //color: Colors.red,
                  //   ),
                  // ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      note.text,
                      maxLines: 8,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
