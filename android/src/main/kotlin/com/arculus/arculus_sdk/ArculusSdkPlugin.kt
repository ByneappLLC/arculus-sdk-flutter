package com.arculus.arculus_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** ArculusSdkPlugin - Simplified for FFI usage */
class ArculusSdkPlugin: FlutterPlugin {

  companion object {
    init {
      // Initialize the CSDK library for FFI usage
      // This ensures the library is loaded when the plugin is first accessed
      CSDKLibrary.LIBRARY
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Plugin attached - library is loaded via static initializer
    // No method channel needed for FFI implementation
    
    // Verify library is loaded successfully
    try {
      val libraryName = CSDKLibrary.LIBRARY_NAME
      android.util.Log.d("ArculusSdkPlugin", "CSDK library loaded successfully: $libraryName")
    } catch (e: Exception) {
      android.util.Log.e("ArculusSdkPlugin", "Failed to load CSDK library", e)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    // Clean up if needed
  }
} 