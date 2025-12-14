import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomePage(); // sudah dari file home_page.dart
        }
        return const LoginPage();
      },
    );
  }
}

// =========================
// LOGIN PAGE & REGISTER PAGE tetap disini
// =========================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Login gagal");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6DC8F3), Color(0xff73A1F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black26,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 60, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: email,
                    decoration: _inputStyle("Email"),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: password,
                    decoration: _inputStyle("Password"),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text("Belum punya akun? Register di sini"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Register gagal");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff73A1F9), Color(0xff6DC8F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black26,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add,
                      size: 60, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    "Daftar Akun Baru",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: email,
                    decoration: _inputStyle("Email"),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: password,
                    decoration: _inputStyle("Password"),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputStyle(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}