# Keep Isar
-keep class dev.isar.** { *; }
-keep class io.isar.** { *; }

# Keep JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Generative AI
-keep class com.google.ai.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep model classes (Isar)
-keep class * extends dev.isar.IsarObject { *; }

# Ignore missing Play Core classes (not using deferred components)
-dontwarn com.google.android.play.core.**

# Ignore missing ML Kit language-specific classes
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
