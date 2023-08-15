import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_x/constants/routes.dart';
import 'package:note_x/services/auth/auth_exceptions.dart';
import 'package:note_x/services/auth/bloc/auth_bloc.dart';
import 'package:note_x/services/auth/bloc/auth_event.dart';
import 'package:note_x/services/auth/bloc/auth_state.dart';
import 'package:note_x/utils/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginWidget(email: _email, password: _password);
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({
    super.key,
    required TextEditingController email,
    required TextEditingController password,
  })  : _email = email,
        _password = password;

  final TextEditingController _email;
  final TextEditingController _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
        ),
        //centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/dash.png',
                width: 70,
                height: 70,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is AuthStateLoggedOut) {
                    if (state.exception is UserNotFoundAuthException) {
                      await showErrorDialog(context, 'User not found');
                    } else if (state.exception is WrongPasswordAuthException) {
                      await showErrorDialog(context, 'Wrong credentials');
                    } else if (state.exception is GenericAuthException) {
                      await showErrorDialog(context, 'Authentication error');
                    }
                  }
                },
                child: TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;

                    context.read<AuthBloc>().add(
                          AuthEventLogin(email, password),
                        );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Not yet registered? Register here!',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
