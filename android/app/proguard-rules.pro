# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson specific classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.example.flirt.** { *; }

# Shared Preferences
-keep class androidx.preference.** { *; }

# Package Info Plus
-keep class io.flutter.plugins.packageinfo.** { *; }

# Local Notifications
-keep class com.dexterous.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Timezone
-keep class timezone.** { *; }
