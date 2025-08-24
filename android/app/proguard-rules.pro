# ProGuard rules for Sudan Goods (Flutter + Firebase)
# Keep Flutter embedding and plugin classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep Firebase / Play Services classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Kotlin metadata and coroutines
-keep class kotlin.Metadata { *; }
-dontwarn kotlinx.coroutines.**

# If using Glide or similar image libraries (often pulled by plugins)
-dontwarn com.bumptech.glide.**

# If using OkHttp/Okio via plugins
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep ServiceLoader usage (plugins discovery)
-keep class java.util.ServiceLoader { *; }
-keepnames class * implements java.util.ServiceLoader$Provider

# Keep generated JSON adapters if using reflection (most json_serializable codegen does not need this)
# -keep class **JsonAdapter { *; }

# Optimize with default rules included via getDefaultProguardFile in build.gradle.kts
