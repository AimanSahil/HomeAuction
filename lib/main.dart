import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
/// ADD THESE IMPORTS
import 'screens/home_screen.dart';
import 'screens/seller_dashboard.dart';
import 'screens/profile_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Auction App",

      themeMode: ThemeMode.dark,

      /// ADD ROUTES HERE
      routes: {

  '/auth': (context) =>
      const AuthScreen(),

  '/home': (context) =>
      const HomeScreen(
        isSeller: true,
      ),

  '/dashboard': (context) =>
      SellerDashboard(),

  '/profile': (context) =>
      const ProfileScreen(
        isSeller: true,
      ),
},
      theme: ThemeData(

        useMaterial3: true,

        brightness: Brightness.dark,

        scaffoldBackgroundColor:
            const Color(0xFF020617),

        primaryColor:
            const Color(0xFF6C97FF),

        colorScheme: const ColorScheme.dark(

          primary: Color(0xFF6C97FF),

          secondary: Color(0xFF6C97FF),

          surface: Color(0xFF121A3A),
        ),

        appBarTheme: const AppBarTheme(

          backgroundColor:
              Color(0xFF020617),

          elevation: 0,

          centerTitle: true,

          titleTextStyle: TextStyle(

            color: Colors.white,

            fontSize: 22,

            fontWeight: FontWeight.bold,
          ),

          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),

        textTheme: const TextTheme(

          bodyLarge: TextStyle(
            color: Colors.white,
          ),

          bodyMedium: TextStyle(
            color: Colors.white70,
          ),

          titleLarge: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(

          filled: true,

          fillColor:
              const Color(0xFF121A3A),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          hintStyle: const TextStyle(
            color: Colors.white38,
          ),

          labelStyle: const TextStyle(
            color: Colors.white54,
          ),

          border: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(22),

            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(22),

            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(22),

            borderSide: const BorderSide(
              color: Color(0xFF6C97FF),
              width: 1.4,
            ),
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(

          style: ElevatedButton.styleFrom(

            backgroundColor:
                const Color(0xFF6C97FF),

            foregroundColor:
                Colors.white,

            elevation: 0,

            shape: RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(24),
            ),

            minimumSize:
                const Size(double.infinity, 58),
          ),
        ),
      ),

     home: const WelcomeScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {

  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(

      stream:
          FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {

        /// LOADING
        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Scaffold(

            backgroundColor:
                Color(0xFF020617),

            body: Center(

              child: CircularProgressIndicator(
                color: Color(0xFF6C97FF),
              ),
            ),
          );
        }

        /// NOT LOGGED IN
        if (!snapshot.hasData ||
            snapshot.data == null) {

          return const AuthScreen();
        }

        /// LOGGED IN
        return const MainScreen();
      },
    );
  }
}