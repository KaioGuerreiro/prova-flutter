import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await _authService.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro: $e';

        // Mensagens de erro mais amigáveis
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('configuration-not-found')) {
          errorMessage = 'Configuração pendente!\n\n'
              'A autenticação por E-mail/Senha precisa ser habilitada no Firebase Console.\n\n'
              'Veja o arquivo HABILITAR_EMAIL_AUTH.md para instruções.';
        } else if (errorString.contains('invalid-email')) {
          errorMessage = 'E-mail inválido. Verifique o formato.';
        } else if (errorString.contains('user-disabled')) {
          errorMessage = 'Esta conta foi desabilitada.';
        } else if (errorString.contains('user-not-found')) {
          errorMessage = 'Usuário não encontrado. Cadastre-se primeiro.';
        } else if (errorString.contains('wrong-password')) {
          errorMessage = 'Senha incorreta. Tente novamente.';
        } else if (errorString.contains('email-already-in-use')) {
          errorMessage = 'Este e-mail já está em uso. Faça login.';
        } else if (errorString.contains('weak-password')) {
          errorMessage = 'Senha muito fraca. Use no mínimo 6 caracteres.';
        } else if (errorString.contains('too-many-requests')) {
          errorMessage =
              'Muitas tentativas. Aguarde um momento e tente novamente.';
        } else if (errorString.contains('network-request-failed')) {
          errorMessage = 'Erro de conexão. Verifique sua internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: errorString.contains('configuration-not-found')
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_gas_station,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Controle de Abastecimento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a senha';
                          }
                          if (value.length < 6) {
                            return 'Senha deve ter no mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailAuth,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_isLogin ? 'Entrar' : 'Cadastrar'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(
                          _isLogin
                              ? 'Não tem conta? Cadastre-se'
                              : 'Já tem conta? Entre',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
