import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final GoogleSignIn _googleSignIn =
      GoogleSignIn.instance;

  static Future<void> initialize() async {
    if (!kIsWeb) {
      await _googleSignIn.initialize();
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    late UserCredential result;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({
        'prompt': 'select_account',
      });

      result = await _auth.signInWithPopup(provider);
    } else {
      final googleUser =
          await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google ID token is missing.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      result = await _auth.signInWithCredential(
        credential,
      );
    }

    final user = result.user;

    if (user != null) {
      final userRef = _db.collection('users').doc(user.uid);
      final existing = await userRef.get();

      final Map<String, dynamic> data = {
        'uid': user.uid,
        'name': user.displayName ?? '',
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!existing.exists) {
        data['createdAt'] =
            FieldValue.serverTimestamp();
      }

      await userRef.set(
        data,
        SetOptions(merge: true),
      );
    }

    return result;
  }

  Future<void> signOut() async {
    await _auth.signOut();

    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
