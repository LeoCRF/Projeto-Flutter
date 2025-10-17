import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onChanged: (v) => email = v,
                validator: (v) => v!.contains('@') ? null : 'E-mail inválido',
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) => v!.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final error = await auth.signUp(email, password);
                    if (!mounted) return;
                    setState(() => loading = false);
                    if (error != null) {
                      messenger.showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      navigator.pop();
                    }
                  }
                },
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
