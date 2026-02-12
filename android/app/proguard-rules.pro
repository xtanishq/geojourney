# Keep FFmpegKit classes
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.mobileffmpeg.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-dontwarn com.arthenica.ffmpegkit.**
-dontwarn com.antonkarpenko.ffmpegkit.**

# Keep JNI references used by FFmpegKit
-keep class com.arthenica.ffmpegkit.** {
    native <methods>;
}

-keep class io.flutter.plugins.camera.** { *; }
-keep class io.flutter.plugin.camera.** { *; }


# Keep Flutter Plugin classes
-keep class com.arthenica.ffmpegkit.flutter.** { *; }
