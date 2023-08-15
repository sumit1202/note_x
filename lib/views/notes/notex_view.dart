import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_x/constants/routes.dart';
import 'package:note_x/enums/menu_action.dart';
import 'package:note_x/services/auth/auth_service.dart';
import 'package:note_x/services/auth/bloc/auth_bloc.dart';
import 'package:note_x/services/auth/bloc/auth_event.dart';
import 'package:note_x/services/cloud/firebase_cloud_storage.dart';
import 'package:note_x/utils/dialogs/logout_dialog.dart';
import 'package:note_x/views/notes/notex_grid_view.dart';
//import 'dart:developer' as dartlog show log;

class NotexView extends StatefulWidget {
  const NotexView({super.key});

  @override
  State<NotexView> createState() => _NotexViewState();
}

class _NotexViewState extends State<NotexView> {
  // late final NotesService _notesService;
  late final FirebaseCloudStorage _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // _notesService = NotesService();
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note X',
        ),
        //centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
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
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  }

                  break;
                default:
              }
            },
          )
        ],
      ),
      // body: NewWidget(notesService: _notesService, userEmail: userEmail),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data!;
                return NotexGridView(
                  notes: allNotes,
                  onDeleteNote: (note) async => await _notesService.deleteNote(
                    documentId: note.documentId,
                  ),
                  onTapNote: (note) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
            default:
              return const Center(child: CircularProgressIndicator.adaptive());
          }
        },
      ),
    );
  }
}

// class NewWidget extends StatelessWidget {
//   const NewWidget({
//     super.key,
//     required  notesService,
//     required this.userEmail,
//   }) : _notesService = notesService;

//   final var _notesService;
//   final String userEmail;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _notesService.getOrCreateUser(email: userEmail),
//       builder: ((context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             return StreamBuilder(
//               stream: _notesService.allNotes,
//               builder: (context, snapshot) {
//                 switch (snapshot.connectionState) {
//                   case ConnectionState.waiting:
//                   case ConnectionState.active:
//                     if (snapshot.hasData) {
//                       final allNotes = snapshot.data!;
//                       return NotexGridView(
//                         notes: allNotes,
//                         onDeleteNote: (note) async {
//                           await _notesService.deleteNote(id: note.id);
//                         },
//                         onTapNote: (note) {
//                           Navigator.of(context).pushNamed(
//                             createOrUpdateNoteRoute,
//                             arguments: note,
//                           );
//                         },
//                       );
//                     } else {
//                       return const Center(
//                           child: CircularProgressIndicator.adaptive());
//                     }
//                   default:
//                     return const Center(
//                         child: CircularProgressIndicator.adaptive());
//                 }
//               },
//             );
//           default:
//             return const Center(child: CircularProgressIndicator.adaptive());
//         }
//       }),
//     );
//   }
// }
