import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _saveLogin = false;

  bool _canCheckBiometrics = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access this feature',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (_saveLogin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }
    } catch (e) {
      print(e);
    }
    return isAuthenticated;
  }

  Future<void> _login() async{
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print(credential.user);

      if (_saveLogin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', credential.user?.email ?? '');
        await prefs.setBool('isLoggedIn', true);
      }

      Navigator.of(context).pushNamed('/places-list');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Email não encontrado')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Senha incorreta')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erro desconhecido')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  } 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(children: [
            Text('Login'),
              TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                onPressed: () {
                  _login();
                },
                child: const Text('Login'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              }, 
              child: Text("Criar conta")
            ),
            CheckboxListTile(
              title: Text("Salvar login"),
              value: _saveLogin, 
              onChanged: (value) {
                setState(() {
                  _saveLogin = value!;
                });
              }
            ),
            SizedBox(height: 40),
            IconButton.filled(
              onPressed: () {
                authenticateWithBiometrics();
              }, 
              icon: Icon(Icons.fingerprint)
            )
          ],)

        ),
      ),
    );
  }
}