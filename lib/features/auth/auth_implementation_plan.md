### The prompt
User: The problem:
We have a shell "ui only" mvp built out. We need to build in functionality. The focus for today is building out the auth functionality: sign up and sign in via firebase, we will have email+password and google auth. 
Agricola currently doesn't have a way to create, authenticate and manage users auth accounts and state.
Review context and create a plan of how to implement auth on the agricola app. from the data layer, domain to statemanagement and hooking up to our widgets and pages.

Notes:
1. Auth types: email+password, google
2. Auth flows: sign up with email+passowrd, sign in with email and password, sign up with google, sign in with google, delete auth account, sign out.
3. Rather than output the plan in the chat, create a markdown (auth_impl_plan.md)*or other name* for easy sharing and editing since a living plan can and will probably change.

For the architecture of the app we will handle authentication (here) on the flutter app/client, while most of out logic will be handle by our dart backend... to be implemented. Our flutter app will send an auth token when sending requests to our backend. we obtain the token from firebase user. 

Create a detailed plan with actual code structure:
1. function signatures, type defs
2. exact flow of functions and data
3. which files to modify
4. which functions to create
5. how components interact
6. provide rationale for architectural decisions



# Firebase Authentication Implementation Plan
**Project:** Agricola - Farm Management App  
**Date:** January 14, 2026  
**Version:** 1.0

---
## Table of Contents
1. [Overview](#overview)
2. [Architecture Decisions](#architecture-decisions)
3. [Dependencies](#dependencies)
4. [Data Layer](#data-layer)
5. [Domain Layer](#domain-layer)
6. [State Management Layer](#state-management-layer)
7. [Presentation Layer](#presentation-layer)
8. [Router Integration](#router-integration)
9. [Implementation Steps](#implementation-steps)
10. [Testing Strategy](#testing-strategy)

---

## Overview

### Current State
- ✅ UI screens for sign up/sign in exist
- ✅ Firebase Core configured (Android only)
- ✅ Riverpod state management in place
- ✅ GoRouter navigation configured
- ❌ No Firebase Auth implementation
- ❌ No auth state management
- ❌ No route protection
- ❌ Simulated auth with `Future.delayed`

### Target State
- Firebase Authentication with email/password and Google Sign-In
- Persistent auth state across app restarts
- Protected routes (home, profile-setup require auth)
- User model linked to profile data
- Auth token management for backend API calls
- Proper error handling and user feedback

### Authentication Flows
1. **Sign Up with Email/Password** → Profile Setup → Home
2. **Sign In with Email/Password** → Check Profile → Home or Profile Setup
3. **Sign Up with Google** → Profile Setup → Home
4. **Sign In with Google** → Check Profile → Home or Profile Setup
5. **Sign Out** → Welcome Screen
6. **Delete Account** → Remove user data → Welcome Screen

---

## Architecture Decisions

### 1. **Clean Architecture with Repository Pattern**
**Rationale:** Separates Firebase implementation from business logic, making it easier to:
- Test authentication logic
- Switch auth providers if needed
- Mock auth for testing
- Centralize auth operations

**Structure:**
```
lib/features/auth/
├── data/
│   ├── repositories/
│   │   └── auth_repository_impl.dart
│   └── datasources/
│       └── firebase_auth_datasource.dart
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart
│   ├── models/
│   │   └── user_model.dart
│   └── failures/
│       └── auth_failure.dart
├── providers/
│   ├── auth_provider.dart
│   ├── auth_state_provider.dart
│   └── current_user_provider.dart
└── screens/ (existing)
```

### 2. **Riverpod for State Management**
**Rationale:** Already used in the app; provides:
- Compile-time safety
- Auto-dispose
- Easy testing
- Provider composition

**Auth Providers Structure:**
- `firebaseAuthProvider` - Singleton for FirebaseAuth instance
- `authRepositoryProvider` - Repository interface
- `authStateProvider` - Stream of auth state changes
- `currentUserProvider` - Current user data (null when signed out)
- `authControllerProvider` - Business logic operations

### 3. **Token Management for Backend**
**Rationale:** Backend will handle business logic, Flutter handles auth
- Firebase User provides `getIdToken()` method
- Token refreshed automatically by Firebase
- Include token in HTTP headers: `Authorization: Bearer <token>`
- Backend verifies token with Firebase Admin SDK

### 4. **Profile Completion Check**
**Rationale:** User can authenticate but may not have completed profile setup
- Store `isProfileComplete` flag in Firestore
- Router checks this flag after auth
- Redirect to profile-setup if incomplete

---

## Dependencies

### Add to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing
  flutter_riverpod: ^2.6.1
  firebase_core: ^4.3.0
  go_router: ^14.6.0
  shared_preferences: ^2.3.3
  
  # NEW - Authentication
  firebase_auth: ^5.3.3
  google_sign_in: ^6.2.2
  
  # NEW - Cloud Storage for User Data
  cloud_firestore: ^5.5.3
  
  # NEW - Error Handling
  fpdart: ^1.1.0  # Functional programming for Either<Failure, Success>
```

### Platform-Specific Configuration

#### Android (build.gradle.kts)
```kotlin
defaultConfig {
    applicationId "com.agricola.app"
    minSdk = 23  // Google Sign-In requires min SDK 23
    targetSdk = 34
}
```

---

## Data Layer

### 1. User Model
**File:** `lib/features/auth/domain/models/user_model.dart`

```dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  
  // Agricola-specific fields
  final UserType userType;
  final MerchantType? merchantType;
  final bool isProfileComplete;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.emailVerified,
    required this.createdAt,
    this.lastSignInAt,
    required this.userType,
    this.merchantType,
    this.isProfileComplete = false,
  });

  /// Create from Firebase User
  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    required UserType userType,
    MerchantType? merchantType,
    bool isProfileComplete = false,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime,
      userType: userType,
      merchantType: merchantType,
      isProfileComplete: isProfileComplete,
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> doc, String uid) {
    return UserModel(
      uid: uid,
      email: doc['email'] as String,
      displayName: doc['displayName'] as String?,
      photoUrl: doc['photoUrl'] as String?,
      phoneNumber: doc['phoneNumber'] as String?,
      emailVerified: doc['emailVerified'] as bool? ?? false,
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      lastSignInAt: doc['lastSignInAt'] != null
          ? (doc['lastSignInAt'] as Timestamp).toDate()
          : null,
      userType: UserType.values.firstWhere(
        (e) => e.name == doc['userType'],
        orElse: () => UserType.farmer,
      ),
      merchantType: doc['merchantType'] != null
          ? MerchantType.values.firstWhere(
              (e) => e.name == doc['merchantType'],
              orElse: () => MerchantType.agriShop,
            )
          : null,
      isProfileComplete: doc['isProfileComplete'] as bool? ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignInAt': lastSignInAt != null ? Timestamp.fromDate(lastSignInAt!) : null,
      'userType': userType.name,
      'merchantType': merchantType?.name,
      'isProfileComplete': isProfileComplete,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    UserType? userType,
    MerchantType? merchantType,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      userType: userType ?? this.userType,
      merchantType: merchantType ?? this.merchantType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        emailVerified,
        createdAt,
        lastSignInAt,
        userType,
        merchantType,
        isProfileComplete,
      ];
}

// Import existing enums from profile_setup_provider.dart
enum UserType { farmer, merchant }
enum MerchantType { agriShop, supermarketVendor }
```

**Rationale:**
- Combines Firebase auth data with Agricola-specific fields
- Immutable with Equatable for easy comparison
- Pure data model with no Firebase dependencies
- Includes profile completion flag for routing logic

---

### 2. Auth Failure Model
**File:** `lib/features/auth/domain/failures/auth_failure.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure {
  final String message;
  final AuthFailureType type;

  const AuthFailure({
    required this.message,
    required this.type,
  });

  factory AuthFailure.fromFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'No user found with this email',
          type: AuthFailureType.userNotFound,
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password',
          type: AuthFailureType.wrongPassword,
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'An account with this email already exists',
          type: AuthFailureType.emailAlreadyInUse,
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'Invalid email address',
          type: AuthFailureType.invalidEmail,
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'Password should be at least 6 characters',
          type: AuthFailureType.weakPassword,
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'This sign-in method is not enabled',
          type: AuthFailureType.operationNotAllowed,
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been disabled',
          type: AuthFailureType.userDisabled,
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later',
          type: AuthFailureType.tooManyRequests,
        );
      case 'network-request-failed':
        return const AuthFailure(
          message: 'Network error. Check your connection',
          type: AuthFailureType.networkError,
        );
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          message: 'Account exists with different sign-in method',
          type: AuthFailureType.accountExistsWithDifferentCredential,
        );
      default:
        return AuthFailure(
          message: e.message ?? 'An unexpected error occurred',
          type: AuthFailureType.unknown,
        );
    }
  }

  factory AuthFailure.fromException(Object e) {
    if (e is FirebaseAuthException) {
      return AuthFailure.fromFirebaseException(e);
    }
    return AuthFailure(
      message: e.toString(),
      type: AuthFailureType.unknown,
    );
  }
}

enum AuthFailureType {
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  operationNotAllowed,
  userDisabled,
  tooManyRequests,
  networkError,
  accountExistsWithDifferentCredential,
  unknown,
}
```

**Rationale:**
- Converts Firebase exceptions to user-friendly messages
- Type-safe error handling
- Bilingual support can be added by mapping to translation keys

---

### 3. Auth Repository Interface
**File:** `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:agricola/features/auth/domain/models/user_model.dart';
import 'package:agricola/features/auth/domain/failures/auth_failure.dart';

/// Abstract repository defining auth operations
/// Using Either<Failure, Success> pattern for error handling
abstract class AuthRepository {
  /// Stream of current auth state
  Stream<UserModel?> get authStateChanges;

  /// Get current user (null if signed out)
  UserModel? get currentUser;

  /// Sign up with email and password
  Future<Either<AuthFailure, UserModel>> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserType userType,
    MerchantType? merchantType,
  });

  /// Sign in with email and password
  Future<Either<AuthFailure, UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<Either<AuthFailure, UserModel>> signInWithGoogle({
    required UserType userType,
    MerchantType? merchantType,
  });

  /// Sign out
  Future<Either<AuthFailure, void>> signOut();

  /// Delete user account
  Future<Either<AuthFailure, void>> deleteAccount();

  /// Send password reset email
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email);

  /// Update user profile completion status
  Future<Either<AuthFailure, void>> updateProfileCompletionStatus(bool isComplete);

  /// Refresh user data from Firestore
  Future<Either<AuthFailure, UserModel>> refreshUserData();
}
```

**Rationale:**
- Interface allows for easy mocking in tests
- Either type provides explicit error handling
- Covers all required auth flows
- Includes profile completion flag management

---

### 4. Firebase Auth Datasource
**File:** `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agricola/features/auth/domain/models/user_model.dart';

class FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Stream of Firebase auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

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
    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in aborted by user');
    }

    // Obtain auth details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create credential
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
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

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Create or update user document in Firestore
  Future<void> createUserDocument({
    required String uid,
    required UserModel user,
  }) async {
    await _firestore.collection('users').doc(uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Get user document from Firestore
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
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
}
```

**Rationale:**
- Encapsulates all Firebase operations
- Dependency injection for testing
- Combines Firebase Auth + Firestore operations
- Handles both email/password and Google sign-in

---

### 5. Auth Repository Implementation
**File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:agricola/features/auth/domain/repositories/auth_repository.dart';
import 'package:agricola/features/auth/domain/models/user_model.dart';
import 'package:agricola/features/auth/domain/failures/auth_failure.dart';
import 'package:agricola/features/auth/data/datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Stream<UserModel?> get authStateChanges {
    return _datasource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserModelFromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _datasource.currentFirebaseUser;
    if (firebaseUser == null) return null;
    
    // Note: This is sync, so we return a basic user model
    // The stream will provide the full user data asynchronously
    return UserModel.fromFirebaseUser(
      firebaseUser,
      userType: UserType.farmer, // Placeholder, will be updated by stream
      isProfileComplete: false,
    );
  }

  @override
  Future<Either<AuthFailure, UserModel>> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    try {
      // Create auth account
      final userCredential = await _datasource.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Create user model
      final user = UserModel.fromFirebaseUser(
        firebaseUser,
        userType: userType,
        merchantType: merchantType,
        isProfileComplete: false,
      );

      // Save to Firestore
      await _datasource.createUserDocument(
        uid: firebaseUser.uid,
        user: user,
      );

      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(AuthFailure.fromFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in
      final userCredential = await _datasource.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // Get user data from Firestore
      final user = await _getUserModelFromFirebaseUser(firebaseUser);

      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(AuthFailure.fromFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signInWithGoogle({
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    try {
      // Sign in with Google
      final userCredential = await _datasource.signInWithGoogle();
      final firebaseUser = userCredential.user!;

      // Check if user document exists
      final userDoc = await _datasource.getUserDocument(firebaseUser.uid);

      UserModel user;

      if (userDoc.exists) {
        // Existing user - get from Firestore
        user = UserModel.fromFirestore(
          userDoc.data() as Map<String, dynamic>,
          firebaseUser.uid,
        );
      } else {
        // New user - create document
        user = UserModel.fromFirebaseUser(
          firebaseUser,
          userType: userType,
          merchantType: merchantType,
          isProfileComplete: false,
        );

        await _datasource.createUserDocument(
          uid: firebaseUser.uid,
          user: user,
        );
      }

      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(AuthFailure.fromFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return right(null);
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> deleteAccount() async {
    try {
      await _datasource.deleteAccount();
      return right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(AuthFailure.fromFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _datasource.sendPasswordResetEmail(email);
      return right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(AuthFailure.fromFirebaseException(e));
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> updateProfileCompletionStatus(
    bool isComplete,
  ) async {
    try {
      final user = _datasource.currentFirebaseUser;
      if (user == null) {
        return left(const AuthFailure(
          message: 'No user signed in',
          type: AuthFailureType.userNotFound,
        ));
      }

      await _datasource.updateProfileCompletionStatus(
        uid: user.uid,
        isComplete: isComplete,
      );

      return right(null);
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> refreshUserData() async {
    try {
      final firebaseUser = _datasource.currentFirebaseUser;
      if (firebaseUser == null) {
        return left(const AuthFailure(
          message: 'No user signed in',
          type: AuthFailureType.userNotFound,
        ));
      }

      final user = await _getUserModelFromFirebaseUser(firebaseUser);
      return right(user);
    } catch (e) {
      return left(AuthFailure.fromException(e));
    }
  }

  /// Helper: Convert Firebase User to UserModel with Firestore data
  Future<UserModel> _getUserModelFromFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    final userDoc = await _datasource.getUserDocument(firebaseUser.uid);

    if (userDoc.exists) {
      return UserModel.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        firebaseUser.uid,
      );
    }

    // Fallback if no Firestore document (shouldn't happen normally)
    return UserModel.fromFirebaseUser(
      firebaseUser,
      userType: UserType.farmer,
      isProfileComplete: false,
    );
  }
}
```

**Rationale:**
- Implements repository interface
- Wraps all Firebase operations in Either for error handling
- Combines Firebase Auth data with Firestore user data
- Handles new vs existing users for social sign-in

---

## State Management Layer

### 1. Auth Providers
**File:** `lib/features/auth/providers/auth_provider.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agricola/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:agricola/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agricola/features/auth/domain/repositories/auth_repository.dart';
import 'package:agricola/features/auth/domain/models/user_model.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Datasource
final authDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

// Auth state stream
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current user (synchronous access)
final currentUserProvider = Provider<UserModel?>((ref) {
  // Watch the async auth state
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});
```

**Rationale:**
- Dependency injection with Provider
- Single source of truth for auth state
- Automatic rebuild when auth state changes
- Easy to mock for testing

---

### 2. Auth Token Provider
**File:** `lib/features/auth/providers/auth_token_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';

/// Provides current Firebase auth token for backend API calls
/// Automatically refreshes when expired
final authTokenProvider = FutureProvider.autoDispose<String?>((ref) async {
  // Watch auth state to rebuild when user changes
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  // Get fresh token from Firebase (auto-refreshes if expired)
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firebaseUser = firebaseAuth.currentUser;
  
  if (firebaseUser == null) return null;
  
  return await firebaseUser.getIdToken();
});

/// Helper extension for easy token access in services
extension ApiAuthExtension on Ref {
  /// Get auth token for API calls
  Future<String?> getAuthToken() => read(authTokenProvider.future);
}
```

**Usage in API Services:**

```dart
// Example: Making authenticated API calls
class CropApiService {
  final Ref _ref;
  final Dio _dio;
  
  CropApiService(this._ref, this._dio);
  
  Future<void> saveCrop(CropModel crop) async {
    // Get current auth token
    final token = await _ref.getAuthToken();
    
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    await _dio.post(
      '/api/crops',
      data: crop.toJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
  
  Future<List<CropModel>> fetchUserCrops() async {
    final token = await _ref.getAuthToken();
    
    final response = await _dio.get(
      '/api/crops',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    
    return (response.data as List)
        .map((json) => CropModel.fromJson(json))
        .toList();
  }
}
```

**Alternative: HTTP Interceptor (For all requests):**

```dart
// lib/core/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agricola/features/auth/providers/auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  
  AuthInterceptor(this._ref);
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token
    final token = await _ref.getAuthToken();
    
    // Add to headers if available
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      // Token expired - provider will auto-refresh on next call
      // Or trigger re-authentication
    }
    
    handler.next(err);
  }
}
```

**Rationale:**
- ✅ Separates token management from user model (clean architecture)
- ✅ No Firebase dependencies in domain layer
- ✅ Token automatically refreshed by Firebase when expired
- ✅ Auto-dispose prevents memory leaks
- ✅ Rebuilds when user changes (sign in/out)
- ✅ Easy to mock for testing
- ✅ Can be used in HTTP interceptors for automatic auth header injection
- ✅ Centralized token access point

---

### 3. Auth Controller
**File:** `lib/features/auth/providers/auth_controller.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:agricola/features/auth/domain/repositories/auth_repository.dart';
import 'package:agricola/features/auth/domain/models/user_model.dart';
import 'package:agricola/features/auth/domain/failures/auth_failure.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  /// Sign up with email and password
  Future<Either<AuthFailure, UserModel>> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signUpWithEmailPassword(
      email: email,
      password: password,
      userType: userType,
      merchantType: merchantType,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  /// Sign in with email and password
  Future<Either<AuthFailure, UserModel>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithEmailPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  /// Sign in with Google
  Future<Either<AuthFailure, UserModel>> signInWithGoogle({
    required UserType userType,
    MerchantType? merchantType,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.signInWithGoogle(
      userType: userType,
      merchantType: merchantType,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    final result = await _repository.signOut();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        debugPrint('Sign out error: ${failure.message}');
      },
      (_) => state = const AsyncValue.data(null),
    );
  }

  /// Delete account
  Future<Either<AuthFailure, void>> deleteAccount() async {
    state = const AsyncValue.loading();

    final result = await _repository.deleteAccount();

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  /// Send password reset email
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();

    final result = await _repository.sendPasswordResetEmail(email);

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );

    return result;
  }

  /// Mark profile as complete
  Future<void> markProfileAsComplete() async {
    await _repository.updateProfileCompletionStatus(true);
  }

  /// Refresh user data
  Future<Either<AuthFailure, UserModel>> refreshUserData() async {
    return await _repository.refreshUserData();
  }
}
```

**Rationale:**
- Separates business logic from UI
- Provides loading/error states
- Returns Either for explicit error handling
- Easy to test controller in isolation

---

## Presentation Layer

### 1. Update Sign Up Screen
**File:** sign_up_screen.dart

**Modifications:**

```dart
// Add at top
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/domain/failures/auth_failure.dart';

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Add error state
  String? _errorMessage;

  // Replace existing _onSignUp method
  Future<void> _onSignUp() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(authControllerProvider.notifier);
      
      // Determine user type from widget.userType
      UserType userType = UserType.farmer;
      MerchantType? merchantType;
      
      if (widget.userType == 'agriShop') {
        userType = UserType.merchant;
        merchantType = MerchantType.agriShop;
      } else if (widget.userType == 'supermarketVendor') {
        userType = UserType.merchant;
        merchantType = MerchantType.supermarketVendor;
      }
      
      final result = await controller.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: userType,
        merchantType: merchantType,
      );
      
      result.fold(
        (failure) {
          // Show error
          setState(() {
            _errorMessage = failure.message;
          });
        },
        (user) {
          // Navigate to profile setup
          if (mounted) {
            context.go('/profile-setup?type=${widget.userType ?? "farmer"}');
          }
        },
      );
    }
  }
  
  // Add Google Sign Up method
  Future<void> _onGoogleSignUp() async {
    final controller = ref.read(authControllerProvider.notifier);
    
    UserType userType = UserType.farmer;
    MerchantType? merchantType;
    
    if (widget.userType == 'agriShop') {
      userType = UserType.merchant;
      merchantType = MerchantType.agriShop;
    } else if (widget.userType == 'supermarketVendor') {
      userType = UserType.merchant;
      merchantType = MerchantType.supermarketVendor;
    }
    
    final result = await controller.signInWithGoogle(
      userType: userType,
      merchantType: merchantType,
    );
    
    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
      (user) {
        if (mounted) {
          if (user.isProfileComplete) {
            context.go('/home');
          } else {
            context.go('/profile-setup?type=${widget.userType ?? "farmer"}');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      // ... existing scaffold setup
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ... existing title and subtitle
                
                // Show error message if exists
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // ... existing email and password fields
                
                const SizedBox(height: 24),
                
                // Sign Up button with loading state
                PrimaryButton(
                  text: t('sign_up', currentLang),
                  onTap: authState.isLoading ? null : _onSignUp,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        t('or', currentLang),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Google Sign Up button
                OutlineButton(
                  text: t('sign_up_with_google', currentLang),
                  onTap: authState.isLoading ? null : _onGoogleSignUp,
                  icon: Icons.g_mobiledata, // or use Google logo asset
                ),
                
                // ... existing footer
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 2. Update Sign In Screen
**File:** sign_in_screen.dart

**Similar modifications as Sign Up:**

```dart
// Add imports
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _onSignIn() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(authControllerProvider.notifier);
      
      final result = await controller.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
          });
        },
        (user) {
          if (mounted) {
            if (user.isProfileComplete) {
              context.go('/home');
            } else {
              // Determine profile setup type
              String type = 'farmer';
              if (user.userType == UserType.merchant) {
                type = user.merchantType == MerchantType.agriShop 
                    ? 'agriShop' 
                    : 'supermarketVendor';
              }
              context.go('/profile-setup?type=$type');
            }
          }
        },
      );
    }
  }

  Future<void> _onGoogleSignIn() async {
    final controller = ref.read(authControllerProvider.notifier);
    
    // For Google sign-in, we need to check if user exists
    // If new user, show user type selection dialog first
    final result = await controller.signInWithGoogle(
      userType: UserType.farmer, // Default, will be updated if new user
    );
    
    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
      (user) {
        if (mounted) {
          if (user.isProfileComplete) {
            context.go('/home');
          } else {
            String type = 'farmer';
            if (user.userType == UserType.merchant) {
              type = user.merchantType == MerchantType.agriShop 
                  ? 'agriShop' 
                  : 'supermarketVendor';
            }
            context.go('/profile-setup?type=$type');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final authState = ref.watch(authControllerProvider);
    
    // Similar structure to Sign Up screen with loading states
    // Add error message display, Google Sign-In button, etc.
  }
}
```

---

### 3. Add Loading Button States
**File:** app_buttons.dart

**Modify PrimaryButton to support loading state:**

```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;  // NEW

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,  // NEW
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,  // Disable when loading
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: onTap == null || isLoading  // Dim when disabled
              ? AppColors.green.withOpacity(0.5) 
              : AppColors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading  // NEW: Show spinner when loading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
```

---

### 4. Update Profile Setup Screen
**File:** profile_setup_screen.dart

**Add profile completion callback:**

```dart
import 'package:agricola/features/auth/providers/auth_controller.dart';

// In the "Finish" button handler
if (state.currentStep == state.totalSteps - 1) {
  // Mark profile as complete
  await ref.read(authControllerProvider.notifier).markProfileAsComplete();
  
  if (mounted) {
    context.go('/home');
  }
} else {
  notifier.nextStep();
}
```

---

### 5. Add Sign Out in Profile Screens
**Files:** 
- farmer_profile_screen.dart
- merchant_profile_screen.dart

**Update logout dialog:**

```dart
void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  final currentLang = ref.watch(languageProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t('logout', currentLang)),
      content: Text(t('are_you_sure_logout', currentLang)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t('cancel', currentLang)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            
            // Sign out
            await ref.read(authControllerProvider.notifier).signOut();
            
            // Navigate to welcome screen
            if (context.mounted) {
              context.go('/');
            }
          },
          child: Text(
            t('logout', currentLang),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
```

---

## Router Integration

### Update GoRouter with Auth Guards
**File:** main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: AgricolaApp()));
}

class AgricolaApp extends ConsumerWidget {
  const AgricolaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Agricola',
      theme: AppTheme.lightTheme,
      routerConfig: _createRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Get auth state
        final authState = ref.read(authStateProvider);
        
        return authState.when(
          data: (user) {
            final isSignedIn = user != null;
            final isProfileComplete = user?.isProfileComplete ?? false;
            
            final isOnAuthPage = state.matchedLocation == '/' ||
                state.matchedLocation == '/onboarding' ||
                state.matchedLocation == '/register' ||
                state.matchedLocation.startsWith('/sign-up') ||
                state.matchedLocation.startsWith('/sign-in');
            
            final isOnProfileSetup = state.matchedLocation.startsWith('/profile-setup');
            final isOnHome = state.matchedLocation == '/home';
            
            // If not signed in and trying to access protected route
            if (!isSignedIn && !isOnAuthPage) {
              return '/';
            }
            
            // If signed in but profile incomplete, redirect to profile setup
            if (isSignedIn && !isProfileComplete && !isOnProfileSetup && !isOnAuthPage) {
              String type = 'farmer';
              if (user.userType == UserType.merchant) {
                type = user.merchantType == MerchantType.agriShop 
                    ? 'agriShop' 
                    : 'supermarketVendor';
              }
              return '/profile-setup?type=$type';
            }
            
            // If signed in with complete profile and on auth page
            if (isSignedIn && isProfileComplete && isOnAuthPage) {
              return '/home';
            }
            
            // No redirect needed
            return null;
          },
          loading: () => null, // Don't redirect while loading
          error: (_, __) => '/', // Redirect to welcome on error
        );
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegistrationScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) =>
              SignUpScreen(userType: state.uri.queryParameters['type']),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/profile-setup',
          builder: (context, state) => ProfileSetupScreen(
            initialUserType: state.uri.queryParameters['type'],
          ),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      ],
    );
  }
}
```

**Rationale:**
- Redirect unauthenticated users to welcome screen
- Redirect authenticated users with incomplete profiles to profile setup
- Redirect authenticated users with complete profiles away from auth screens
- Handle loading states gracefully

---

## Implementation Steps

### Phase 1: Setup & Dependencies (Day 1)

**Step 1.1: Add Dependencies**
```bash
flutter pub add firebase_auth google_sign_in cloud_firestore fpdart
flutter pub get
```

**Step 1.2: Initialize Firebase in main.dart**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: AgricolaApp()));
}
```

**Step 1.3: Setup Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Other collections will be added later for crops, inventory, etc.
  }
}
```

---

### Phase 2: Data Layer (Day 1-2)

**Step 2.1: Create Models**
1. Create `lib/features/auth/domain/models/user_model.dart`
2. Create `lib/features/auth/domain/failures/auth_failure.dart`

**Step 2.2: Create Repository Interface**
1. Create `lib/features/auth/domain/repositories/auth_repository.dart`

**Step 2.3: Create Datasource**
1. Create `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

**Step 2.4: Implement Repository**
1. Create `lib/features/auth/data/repositories/auth_repository_impl.dart`

**Testing:**
```dart
// Test datasource operations manually
final datasource = FirebaseAuthDatasource();
await datasource.signUpWithEmailPassword(
  email: 'test@example.com',
  password: 'password123',
);
```

---

### Phase 3: State Management (Day 2)

**Step 3.1: Create Providers**
1. Create `lib/features/auth/providers/auth_provider.dart`
2. Create `lib/features/auth/providers/auth_controller.dart`

**Step 3.2: Test Providers**
```dart
// In a test widget
final authState = ref.watch(authStateProvider);
authState.when(
  data: (user) => Text('User: ${user?.email}'),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

---

### Phase 4: Presentation Layer (Day 3)

**Step 4.1: Update Sign Up Screen**
1. Add auth controller integration
2. Add error handling
3. Add Google Sign-In button
4. Add loading states

**Step 4.2: Update Sign In Screen**
1. Similar changes to Sign Up

**Step 4.3: Update Profile Setup**
1. Add profile completion callback

**Step 4.4: Update Profile Screens**
1. Add sign out functionality
2. Test sign out flow

---

### Phase 5: Router & Guards (Day 3-4)

**Step 5.1: Update main.dart**
1. Initialize Firebase
2. Add auth redirect logic
3. Test route protection

**Step 5.2: Test All Flows**
1. Sign up → Profile setup → Home
2. Sign in → Home (if profile complete)
3. Sign in → Profile setup (if incomplete)
4. Sign out → Welcome
5. Direct URL access (should redirect)

---

### Phase 6: Error Handling & Polish (Day 4)

**Step 6.1: Add Error Messages**
1. Update language provider with auth error keys
2. Test all error scenarios

**Step 6.2: Add Loading States**
1. Update buttons with spinners
2. Add skeleton screens if needed

**Step 6.3: Password Reset**
1. Add "Forgot Password" link
2. Create password reset screen
3. Implement reset flow

---

### Phase 7: Testing (Day 5)

**Step 7.1: Manual Testing**
- [ ] Sign up with email/password
- [ ] Sign in with email/password
- [ ] Sign up with Google
- [ ] Sign in with Google (existing account)
- [ ] Sign out
- [ ] Protected route access (should redirect)
- [ ] Profile completion flow
- [ ] Error scenarios (wrong password, network error, etc.)

**Step 7.2: Add Unit Tests**
```dart
// Example test
test('signUpWithEmailPassword should return user on success', () async {
  final result = await repository.signUpWithEmailPassword(
    email: 'test@example.com',
    password: 'password123',
    userType: UserType.farmer,
  );
  
  expect(result.isRight(), true);
});
```

---

## Testing Strategy

### Unit Tests

**Repository Tests (`auth_repository_test.dart`):**
```dart
void main() {
  late MockFirebaseAuthDatasource mockDatasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockFirebaseAuthDatasource();
    repository = AuthRepositoryImpl(mockDatasource);
  });

  group('signUpWithEmailPassword', () {
    test('should return UserModel on success', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      when(mockDatasource.signUpWithEmailPassword(
        email: any,
        password: any,
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await repository.signUpWithEmailPassword(
        email: 'test@test.com',
        password: 'password123',
        userType: UserType.farmer,
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('should return AuthFailure on Firebase error', () async {
      // Arrange
      when(mockDatasource.signUpWithEmailPassword(
        email: any,
        password: any,
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act
      final result = await repository.signUpWithEmailPassword(
        email: 'test@test.com',
        password: 'password123',
        userType: UserType.farmer,
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### Widget Tests

**Sign Up Screen Test:**
```dart
void main() {
  testWidgets('shows error message on sign up failure', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => MockAuthController()),
        ],
        child: const MaterialApp(home: SignUpScreen()),
      ),
    );

    // Enter email and password
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    
    // Tap sign up
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify error message appears
    expect(find.text('Email already in use'), findsOneWidget);
  });
}
```

### Integration Tests

**Auth Flow Test:**
```dart
void main() {
  testWidgets('complete sign up flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AgricolaApp()));

    // Navigate to sign up
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');

    // Submit
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Should navigate to profile setup
    expect(find.text('Profile Setup'), findsOneWidget);
  });
}
```

---

## Additional Considerations

### 1. Email Verification
Add optional email verification step:

```dart
Future<void> sendEmailVerification() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && !user.emailVerified) {
    await user.sendEmailVerification();
  }
}
```

### 2. Token Refresh for Backend
When making API calls to your Dart backend:

```dart
class ApiService {
  Future<Response> makeAuthenticatedRequest(String endpoint) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    
    return await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
```

### 3. Offline Persistence
Firebase Auth persists auth state automatically. For Firestore data:

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 4. Multi-language Error Messages
Update `language_provider.dart`:

```dart
// Add to translation maps
'auth_error_user_not_found': {
  'en': 'No user found with this email',
  'st': 'Ga go na modirisi ka email eno',
},
'auth_error_wrong_password': {
  'en': 'Incorrect password',
  'st': 'Password e sa siamang',
},
// ... more error messages
```

Use in screens:

```dart
setState(() {
  _errorMessage = t('auth_error_${failure.type.name}', currentLang);
});
```

---

## Summary

This plan provides:

1. **Clean Architecture**: Separation of concerns with data/domain/presentation layers
2. **Type-Safe Error Handling**: Using Either<Failure, Success> pattern
3. **Reactive State Management**: Riverpod providers for auth state
4. **Route Protection**: GoRouter redirects based on auth state
5. **Backend Integration**: Token management for API calls
6. **Profile Completion**: Firestore flag to track setup progress
7. **Social Auth**: Google Sign-In alongside email/password
8. **Testing**: Unit, widget, and integration tests

### File Checklist

**New Files
