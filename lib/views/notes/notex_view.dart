import 'package:flutter/material.dart';
import 'package:note_x/constants/routes.dart';
import 'package:note_x/enums/menu_action.dart';
import 'package:note_x/services/auth/auth_service.dart';
import 'package:note_x/services/crud/notes_service.dart';
import 'package:note_x/utils/dialogs/logout_dialog.dart';
import 'package:note_x/views/notes/notex_grid_view.dart';
//import 'dart:developer' as dartlog show log;

class NotexView extends StatefulWidget {
  const NotexView({super.key});

  @override
  State<NotexView> createState() => _NotexViewState();
}

class _NotexViewState extends State<NotexView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note X',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }

                  break;
                default:
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data!;
                        return NotexGridView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                    default:
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                  }
                },
              );
            default:
              return const Center(child: CircularProgressIndicator.adaptive());
          }
        }),
      ),
    );
  }
}
