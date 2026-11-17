import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;
  bool loading = false;

  static const Color primaryBlue = Color(0xFF2455C3);
  static const Color darkBlue = Color(0xFF163B85);

  @override
  void dispose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) return;

    if (currentPassword.text.isEmpty ||
        newPassword.text.length < 6 ||
        confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all password fields.'),
        ),
      );
      return;
    }

    if (newPassword.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match.'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword.text);

      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Password update failed.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // LOGOUT 
  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Log Out?',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Are you sure you want to log out of your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkBlue,
                          minimumSize: const Size(0, 48),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to log out. Please try again.'),
            ),
          );
        }
      }
    }
  }

  Widget passwordField(
    String label,
    TextEditingController controller,
    bool hidden,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: hidden,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: primaryBlue,
          ),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown User';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  primaryBlue,
                  darkBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: Text(
                    email.isNotEmpty
                        ? email[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'MY ACCOUNT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 27),

          const Text(
            'Account Information',
            style: TextStyle(
              color: darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 13),

          Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: primaryBlue,
              ),
              title: const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(email),
            ),
          ),

          const SizedBox(height: 27),

          const Text(
            'Change Password',
            style: TextStyle(
              color: darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 13),

          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  passwordField(
                    'Current Password',
                    currentPassword,
                    hideCurrent,
                    () => setState(
                      () => hideCurrent = !hideCurrent,
                    ),
                  ),
                  passwordField(
                    'New Password',
                    newPassword,
                    hideNew,
                    () => setState(
                      () => hideNew = !hideNew,
                    ),
                  ),
                  passwordField(
                    'Confirm New Password',
                    confirmPassword,
                    hideConfirm,
                    () => setState(
                      () => hideConfirm = !hideConfirm,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: loading ? null : changePassword,
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: Text(
                        loading ? 'Updating...' : 'UPDATE PASSWORD',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          OutlinedButton.icon(
            onPressed: confirmLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('LOG OUT'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'STUDENT INFORMATION SYSTEM',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
