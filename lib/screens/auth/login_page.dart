import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formkey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Focus.Me',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          onChanged: (v) => email = v,
                          validator: (v) =>
                              v!.contains('@') ? null : 'E-mail inválido'),
                      const SizedBox(height: 8),
                      TextFormField(
                          decoration: const InputDecoration(labelText: 'Senha'),
                          obscureText: true,
                          onChanged: (v) => password = v,
                          validator: (v) =>
                              v!.length >= 6 ? null : 'Mínimo 6 caracteres'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              final messenger = ScaffoldMessenger.of(context);
                              final error = await auth.signIn(email, password);
                              if (!mounted) return;
                              setState(() {
                                loading = false;
                              });
                              if (error != null) {
                                messenger.showSnackBar(
                                    SnackBar(content: Text(error)));
                              }
                            }
                          },
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text('Entrar')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const RegisterPage()));
                          },
                          child: const Text('Criar uma conta'))
                    ])))));
  }
}
