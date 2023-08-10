import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_x/constants/routes.dart';
import 'package:note_x/utils/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return RegisterWidget(
      email: _email,
      password: _password,
    );
  }
}

//--------------------------------------------------------------------

class RegisterWidget extends StatelessWidget {
  const RegisterWidget({
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
          'Note X',
        ),
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
              TextButton(
                onPressed: () async {
                  try {
                    final email = _email.text;
                    final password = _password.text;

                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, password: password);

                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();

                    Navigator.of(context).pushNamed(verifyEmailRoute);
                    
                  } on FirebaseAuthException catch (e) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text("Oops! : ${e.code} : ${e.message}"),
                    //   ),
                    // );
                    await showErrorDialog(context, 'Oops! ${e.code}.');
                  } catch (e) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text("Oops! : $e"),
                    //   ),
                    // );
                    await showErrorDialog(context, 'Oops! $e.');
                  }
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text(
                  'Already registered? Login here!',
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
