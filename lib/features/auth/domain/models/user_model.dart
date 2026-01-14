import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends Equatable {
  final String uid;
  final String email;
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

  @override
  List<Object?> get props => [
    uid,
    email,
    phoneNumber,
    emailVerified,
    createdAt,
    lastSignInAt,
    userType,
    merchantType,
    isProfileComplete,
  ];

  UserModel copyWith({
    String? uid,
    String? email,
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
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      userType: userType ?? this.userType,
      merchantType: merchantType ?? this.merchantType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  /// Get auth token for backend API calls
  Future<String?> getIdToken() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
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
}
