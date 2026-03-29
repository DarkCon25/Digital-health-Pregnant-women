import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmail(); // تحميل الإيميل المخزن عند فتح التطبيق
  }

  // تحميل الإيميل من SharedPreferences
  void _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      emailController.text = savedEmail;
    }
  }

  // تسجيل الدخول وحفظ الإيميل
  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // بعد النجاح نحفظ الإيميل محليًا
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);

      print("تم تسجيل الدخول بنجاح!");
    } catch (e) {
      print("خطأ في تسجيل الدخول: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          SizedBox.expand(
            child: Image.asset(
              'assets/images/photo_2026-03-29_20-43-57.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // النموذج
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الحقل للإيميل يظهر مخزن مسبقًا ويمكن تغييره
                  const SizedBox(height: 60),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 60),
                  TextField(
                    controller: passwordController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 90),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
