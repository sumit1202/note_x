import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'dart:developer' as dartlog show log;

enum MenuAction { logout }

class NotexView extends StatefulWidget {
  const NotexView({super.key});

  @override
  State<NotexView> createState() => _NotexViewState();
}

class _NotexViewState extends State<NotexView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note X',
        ),
        actions: [
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
              //log(value.toString());
              //print('$value');
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => false);
                  }

                  break;
                default:
              }
            },
          )
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
