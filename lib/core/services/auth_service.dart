import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/app_user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  // MARK: - Sign In

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // MARK: - Sign Up

  Future<void> signUp(String email, String password, String displayName) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);

    final user = AppUser.empty(cred.user!.uid, email, displayName: displayName);
    await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
  }

  // MARK: - Social Sign In

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // Sur Flutter Web, signInWithPopup ouvre une popup OAuth Google native.
      // GoogleSignIn().signIn() ne fonctionne pas sur web.
      final provider = GoogleAuthProvider();
      final userCred = await _auth.signInWithPopup(provider);
      await _ensureUserProfile(userCred.user!);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      await _ensureUserProfile(userCred.user!);
    }
  }

  Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    final userCred = await _auth.signInWithCredential(oauthCredential);
    if (appleCredential.givenName != null) {
      await userCred.user?.updateDisplayName(
          '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim());
    }
    await _ensureUserProfile(userCred.user!);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // MARK: - Password Reset

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // MARK: - Sign Out

  Future<void> signOut() async => _auth.signOut();

  // MARK: - User Profile

  Future<AppUser?> fetchUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(uid, doc.data()!);
      }
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        final user = AppUser.empty(uid, fbUser.email ?? '',
            displayName: fbUser.displayName ?? '');
        await _db.collection('users').doc(uid).set(user.toMap());
        return user;
      }
    } catch (_) {}
    return null;
  }

  Future<void> updatePreferences(String uid, Map<String, dynamic> prefs) async {
    await _db.collection('users').doc(uid).update({'preferences': prefs});
  }

  // MARK: - Helpers

  Future<void> _ensureUserProfile(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final appUser = AppUser.empty(user.uid, user.email ?? '',
          displayName: user.displayName ?? '');
      await _db.collection('users').doc(user.uid).set(appUser.toMap());
    }
  }

  // MARK: - Error messages

  static String errorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email': return 'Adresse email invalide.';
        case 'wrong-password': return 'Mot de passe incorrect.';
        case 'user-not-found': return 'Aucun compte avec cet email.';
        case 'email-already-in-use': return 'Un compte existe déjà avec cet email.';
        case 'weak-password': return 'Mot de passe trop faible (6 caractères min).';
        case 'network-request-failed': return 'Erreur réseau. Vérifiez votre connexion.';
        case 'sign_in_canceled': return 'Connexion annulée.';
        case 'popup_closed_by_user': return 'Connexion annulée.';
      }
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
