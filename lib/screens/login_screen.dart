import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(
            _emailController.text,
            _passwordController.text,
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.teal.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hotel,
                            size: 72,
                            color: Colors.teal.shade700,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hotel Lux',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistema de gestión hotelera',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              labelText: 'Correo electrónico',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Ingresa tu correo electrónico';
                              }
                              if (!email.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelText: 'Contraseña',
                              suffixIcon: IconButton(
                                tooltip: _hidePassword
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                                onPressed: () {
                                  setState(
                                      () => _hidePassword = !_hidePassword);
                                },
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            obscureText: _hidePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) =>
                                _isLoading ? null : _login(),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Ingresa tu contraseña'
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _login,
                              icon: _isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(
                                _isLoading
                                    ? 'Iniciando sesión…'
                                    : 'Iniciar sesión',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
