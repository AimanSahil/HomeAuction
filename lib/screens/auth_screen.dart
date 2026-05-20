import 'main_screen.dart';
import 'seller_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLogin = true;
  bool isPasswordVisible = false;
  String role = "Bidder";
  String errorMessage = "";
  bool showError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }
Future<void> checkLogin() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final role = doc.data()?['role'];

    if (role == "Seller") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SellerDashboard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const MainScreen()),
);
    }
  }
}
void handleAuth() async {
  setState(() {
    errorMessage = "";
    showError = false;
  });

  try {

    /// LOGIN
    if (isLogin) {

      await _auth.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

    } else {

      /// REGISTER
      await _auth.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        role,
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userRole = doc.data()?['role'];

    if (!mounted) return;

    /// REMOVE ALL OLD SCREENS
    if (userRole == "Seller") {

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const SellerDashboard(),
        ),
        (route) => false,
      );

    } else {

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
        (route) => false,
      );
    }

  } on FirebaseAuthException catch (e) {

    String message = "Something went wrong";

    if (e.code == 'wrong-password' ||
        e.code == 'user-not-found' ||
        e.code == 'invalid-credential') {

      message = "Email or password is incorrect";

    } else if (e.code == 'invalid-email') {

      message = "Invalid email format";

    } else if (e.code == 'email-already-in-use') {

      message = "An account with that email already exists";

    } else if (e.code == 'too-many-requests') {

      message = "Too many attempts. Try again later";
    }

    if (!mounted) return;

    setState(() {
      errorMessage = message;
      showError = true;
    });

    Future.delayed(
      const Duration(seconds: 3),
      () {

        if (mounted) {

          setState(() {
            showError = false;
            errorMessage = "";
          });
        }
      },
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      backgroundColor: const Color(0xFF0B1220),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1220),
              Color(0xFF0F1B2E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            // 👇 BONUS: prevents UI jump when keyboard opens
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),

              child: IntrinsicHeight(
                child: Column(
                  children: [

                    // LOGO SECTION
Column(
  children: [

    Center(
  child: Stack(
    alignment: Alignment.center,
    children: [

      // OUTER GLOW BOX
      Container(
        height: 220,
        width: 220,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(70),

          gradient: RadialGradient(
            colors: [
              const Color(0xFF4F7DFF).withOpacity(0.35),
              const Color(0xFF1E3A8A).withOpacity(0.18),
              Colors.transparent,
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B8DEF).withOpacity(0.25),
              blurRadius: 50,
              spreadRadius: 8,
            ),
          ],
        ),
      ),

      // INNER LOGO BOX
      Container(
        height: 165,
        width: 165,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),

          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF172554),
              Color(0xFF0F172A),
            ],
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(42),

          child: Padding(
  padding: const EdgeInsets.all(12),

  child: Transform.scale(
    scale: 2.2,

    child: Image.asset(
      "assets/animations/icon.png",
      fit: BoxFit.contain,
    ),
  ),
),
        ),
      ),
    ],
  ),
),

    const SizedBox(height: 10),

   const Text(
  "HomeAuction",
  style: TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  ),
),

    const SizedBox(height: 10),

    RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: "Bid smart. ",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: "Win big.",
            style: TextStyle(
              color: Color(0xFFFFC857),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 35),
  ],
),
                    const SizedBox(height: 25),

                    // TOGGLE
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B253B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = true),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isLogin
                                      ? const Color(0xFF5B8DEF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: isLogin
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = false),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: !isLogin
                                      ? const Color(0xFF5B8DEF)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      color: isLogin
                                          ? Colors.white70
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ROLE
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => role = "Bidder"),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: role == "Bidder"
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF1B253B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: role == "Bidder"
                                      ? const Color(0xFF5B8DEF)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.trending_up,
                                      color: Colors.white),
                                  SizedBox(height: 5),
                                  Text("Bidder",
                                      style:
                                          TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => role = "Seller"),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: role == "Seller"
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF1B253B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: role == "Seller"
                                      ? const Color(0xFF5B8DEF)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.home, color: Colors.white),
                                  SizedBox(height: 5),
                                  Text("Seller",
                                      style:
                                          TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (!isLogin)
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(
    color: showError ? Colors.redAccent : Colors.transparent,
    width: 2,
  ),
),
focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(
    color: showError ? Colors.redAccent : const Color(0xFF5B8DEF),
    width: 2,
  ),
),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.white54),
                          hintText: "Full Name",
                          hintStyle:
                              const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF1F2937),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(
    color: showError ? Colors.redAccent : Colors.transparent,
    width: 2,
  ),
),
focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(
    color: showError ? Colors.redAccent : const Color(0xFF5B8DEF),
    width: 2,
  ),
),
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.white54),
                        hintText: "Email Address",
                        hintStyle:
                            const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1B253B),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(
    color: showError ? Colors.redAccent : Colors.transparent,
    width: 2,
  ),
),
focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(
    color: showError ? Colors.redAccent : const Color(0xFF5B8DEF),
    width: 2,
  ),
),
                        prefixIcon:
                            const Icon(Icons.lock, color: Colors.white54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white38,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible =
                                  !isPasswordVisible;
                            });
                          },
                        ),
                        hintText: "Password",
                        hintStyle:
                            const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1B253B),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                   AnimatedSlide(
  offset: showError ? const Offset(0, 0) : const Offset(0, -0.5),
  duration: const Duration(milliseconds: 400),
  child: AnimatedOpacity(
    opacity: showError ? 1 : 0,
    duration: const Duration(milliseconds: 300),
    child: errorMessage.isNotEmpty
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox(),
  ),
),
TweenAnimationBuilder<double>(
  tween: Tween<double>(
    begin: 0,
    end: showError ? 8 : 0,
  ),
  duration: const Duration(milliseconds: 400),
  builder: (context, value, child) {
    return Transform.translate(
      offset: Offset(showError ? (value - 6.0) : 0.0, 0.0),
      child: child ?? const SizedBox(),
    );
  },
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: handleAuth,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B8DEF),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        isLogin ? "Sign In" : "Create Account",
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ),
  ),
),

                    const SizedBox(height: 20),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style:
                              const TextStyle(color: Colors.white54),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            isLogin ? "Register" : "Sign In",
                            style: const TextStyle(
                              color: Color(0xFF5B8DEF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30), 
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}