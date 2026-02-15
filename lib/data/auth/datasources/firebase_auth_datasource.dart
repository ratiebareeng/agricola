import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of Firebase auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Create or update user document in Firestore
  Future<void> createUserDocument({
    required String uid,
    required UserModel user,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');

    // Delete user document from Firestore
    await _firestore.collection('users').doc(user.uid).delete();

    // Delete auth account
    await user.delete();
  }

  /// Get user document from Firestore
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Sign in anonymously
  Future<firebase_auth.UserCredential> signInAnonymously() async {
    return await _firebaseAuth.signInAnonymously();
  }

  /// Sign in with email and password
  Future<firebase_auth.UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return await _signInWithGoogleWeb();
    } else {
      return await _signInWithGoogleMobile();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  /// Sign up with email and password
  Future<firebase_auth.UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Update profile completion status
  Future<void> updateProfileCompletionStatus({
    required String uid,
    required bool isComplete,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'isProfileComplete': isComplete,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark profile setup as skipped
  Future<void> markProfileSetupAsSkipped({
    required String uid,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'hasSkippedProfileSetup': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<firebase_auth.UserCredential> _signInWithGoogleMobile() async {
    List<String> scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid',
    ];
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
      scopeHint: scopes,
    );

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final googleAuthorization = await googleUser.authorizationClient
        .authorizationForScopes(scopes);

    if (googleAuthorization == null) {
      // Deal with the case where this scope is not approved (I don't even know if it's possible as it's a basic OAuth2.0 scope for google).
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuthorization!.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<firebase_auth.UserCredential> _signInWithGoogleWeb() async {
    firebase_auth.GoogleAuthProvider googleProvider =
        firebase_auth.GoogleAuthProvider();
    googleProvider.addScope('email');
    googleProvider.addScope('profile');

    return await _firebaseAuth.signInWithPopup(googleProvider);
  }
}
