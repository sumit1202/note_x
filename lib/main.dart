import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_x/constants/routes.dart';
import 'package:note_x/services/auth/bloc/auth_bloc.dart';
import 'package:note_x/services/auth/bloc/auth_event.dart';
import 'package:note_x/services/auth/bloc/auth_state.dart';
import 'package:note_x/services/auth/firebase_auth_provider.dart';
import 'package:note_x/views/login_view.dart';
import 'package:note_x/views/notes/create_update_note_view.dart';
import 'package:note_x/views/notes/notex_view.dart';
import 'package:note_x/views/register_view.dart';
import 'package:note_x/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note X',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(),
        appBarTheme: const AppBarTheme(
          color: Colors.deepPurple,
          iconTheme: IconThemeData(color: Colors.white),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        loginRoute: (context) => const LoginView(),
        notexRoute: (context) => const NotexView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotexView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
