# Add project specific ProGuard rules here.
# For the Arculus CSDK library and JNA integration

# Keep JNA classes
-keep class com.sun.jna.* { *; }
-keepclassmembers class * extends com.sun.jna.* { public *; }

# Keep CSDK library wrapper classes
-keep class com.arculus.arculus_sdk.CSDKLibrary { *; }

# Disable warnings for JNA
-dontwarn java.awt.Component
-dontwarn java.awt.GraphicsEnvironment
-dontwarn java.awt.HeadlessException
-dontwarn java.awt.Window

# Keep source file and line numbers for debugging
-keepattributes SourceFile,LineNumberTable 