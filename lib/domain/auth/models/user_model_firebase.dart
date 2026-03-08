import 'package:agricola_core/agricola_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Create a UserModel from a Firebase Auth User
UserModel userModelFromFirebaseUser(
  firebase_auth.User firebaseUser, {
  required UserType userType,
  MerchantType? merchantType,
  bool isProfileComplete = false,
  bool hasSkippedProfileSetup = false,
}) {
  return UserModel(
    uid: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    phoneNumber: firebaseUser.phoneNumber,
    emailVerified: firebaseUser.emailVerified,
    createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    lastSignInAt: firebaseUser.metadata.lastSignInTime,
    userType: userType,
    merchantType: merchantType,
    isProfileComplete: isProfileComplete,
    hasSkippedProfileSetup: hasSkippedProfileSetup,
    isAnonymous: firebaseUser.isAnonymous,
  );
}

/// Create a UserModel from a Firestore document
UserModel userModelFromFirestore(Map<String, dynamic> doc, String uid) {
  return UserModel(
    uid: uid,
    email: doc['email'] as String,
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
    hasSkippedProfileSetup: doc['hasSkippedProfileSetup'] as bool? ?? false,
    isAnonymous: doc['isAnonymous'] as bool? ?? false,
  );
}

/// Convert a UserModel to a Firestore document
Map<String, dynamic> userModelToFirestore(UserModel user) {
  return {
    'email': user.email,
    'phoneNumber': user.phoneNumber,
    'emailVerified': user.emailVerified,
    'createdAt': Timestamp.fromDate(user.createdAt),
    'lastSignInAt': user.lastSignInAt != null
        ? Timestamp.fromDate(user.lastSignInAt!)
        : null,
    'userType': user.userType.name,
    'merchantType': user.merchantType?.name,
    'isProfileComplete': user.isProfileComplete,
    'hasSkippedProfileSetup': user.hasSkippedProfileSetup,
    'isAnonymous': user.isAnonymous,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
