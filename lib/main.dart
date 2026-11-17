import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'services/auth_service.dart';

const Color primaryBlue = Color(0xFF2455C3);
const Color darkBlue = Color(0xFF163B85);
const Color lightBlue = Color(0xFFEAF1FF);
const Color backgroundColor = Color(0xFFF5F7FC);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthService.initialize();

  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Information System',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: darkBlue,
          surface: Colors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: darkBlue,
          elevation: 0,
          centerTitle: false,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7FC),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: primaryBlue,
              width: 1.5,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Unable to connect to Firebase. Please try again.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // LOGGED IN
        if (snapshot.hasData) {
          return const DashboardPage();
        }

        // LOGGED IN
        return const LoginPage();
      },
    );
  }
}
