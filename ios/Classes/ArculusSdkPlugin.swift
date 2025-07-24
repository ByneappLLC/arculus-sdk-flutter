import Flutter
import UIKit

public class ArculusSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Plugin registration - no method channel needed for FFI implementation
    let instance = ArculusSdkPlugin()
    // The CSDK library will be loaded automatically when FFI calls are made
    print("ArculusSdkPlugin: CSDK XCFramework loaded and ready for FFI access")
  }
} 