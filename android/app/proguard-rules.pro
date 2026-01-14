# Firebase Auth ProGuard Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.credentials.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.auth.internal.** { *; }

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.protobuf.** { *; }

# Prevent obfuscation of model classes
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
}

# Keep Firebase Configuration
-keep class com.google.firebase.remoteconfig.** { *; }
-keep class com.google.android.gms.measurement.** { *; }

# Flutter Firebase
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugin.common.** { *; }