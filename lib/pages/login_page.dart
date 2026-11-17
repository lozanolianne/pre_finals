import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;
  bool googleLoading = false;

  static const Color primaryBlue = Color(0xFF2455C3);
  static const Color darkBlue = Color(0xFF163B85);
  static const Color fieldColor = Color(0xFFF3F5FA);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkBlue,
      ),
    );
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      showMessage(message);
    } catch (e) {
      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> loginWithGoogle() async {
    setState(() => googleLoading = true);

    try {
      await AuthService().signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Google sign-in failed.');
    } catch (e) {
      showMessage('Google sign-in was cancelled or failed.');
    } finally {
      if (mounted) {
        setState(() => googleLoading = false);
      }
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryBlue, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEAF0FC),
              Color(0xFFF7F9FE),
              Color(0xFFE5ECFA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 28,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, darkBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Sign in to continue to your account',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: darkBlue.withOpacity(0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 9),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: inputDecoration(
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 9),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: inputDecoration(
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => login(),
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed:
                                  googleLoading ? null : loginWithGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF303846),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: googleLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: const [
                                        _GoogleLogo(),
                                        SizedBox(width: 10),
                                        Text(
                                          'Sign in with Google',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Center(
                            child: Text(
                              'Secure student information management',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
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
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1,
      ),
    );
  }
}
