import 'package:flutter/material.dart';
import 'package:note_x/services/auth/auth_service.dart';
import 'package:note_x/services/cloud/cloud_note.dart';
import 'package:note_x/services/cloud/firebase_cloud_storage.dart';
import 'package:note_x/utils/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  // DatabaseNote? _note;
  CloudNote? _note;
  // late final NotesService _notesService;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    // final email = currentUser.email;
    final userId = currentUser.id;
    // final owner = await _notesService.getUser(email: email);
    // final newNote = await _notesService.createNote(owner: owner);
    final newNote = await _notesService.ceateNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      // _notesService.deleteNote(id: note.id);
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    // if (text.isNotEmpty && note != null) {
    //   await _notesService.updateNote(note: note, text: text);
    // }
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    // await _notesService.updateNote(note: note, text: text);
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    // _notesService = NotesService();
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing here...',
                  border: InputBorder.none,
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator.adaptive());
          }
        },
      ),
    );
  }
}
