# ─── Économe ProGuard / R8 Rules ───────────────────────────────────────
# Flutter app — 100% offline, no networking in release

# Flutter default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.econome.app.** { *; }

# Keep generated code (Riverpod, Drift, JsonSerializable, etc.)
-keep class **.g.** { *; }
-keep class **.freezed.** { *; }

# Keep annotations used by Riverpod
-keep class com.google.auto.value.** { *; }

# Keep Kotlin metadata for reflection-based libraries
-keepattributes *Annotation*, InnerClasses
-keepattributes Signature
-keepattributes EnclosingMethod
-keepattributes Exceptions

# Drift / SQLite
-keep class org.sqlite.** { *; }
-keep class sqlite.** { *; }

# Flutter local notifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep enum classes used in API
-keepclassmembers enum * { *; }

# Keep model classes used by Drift
-keep class com.econome.app.data.** { *; }
-keep class com.econome.app.database.** { *; }

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Dontwarn warnings that are unavoidable
-dontwarn com.google.auto.value.AutoValue
-dontwarn javax.annotation.Nullable

# Play Core (referenced by Flutter PlayStoreDeferredComponentManager but not always included)
-dontwarn com.google.android.play.core.**
