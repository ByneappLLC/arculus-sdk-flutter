import Flutter
import UIKit

public class ArculusSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Plugin registration - ensure CSDK library symbols are available
    let instance = ArculusSdkPlugin()
    
    // Force load the CSDK library to ensure symbols are available for FFI
    // This helps with symbol resolution when using DynamicLibrary.process()
    print("ArculusSdkPlugin: Initializing CSDK library...")
    
    // Check if we can access a CSDK symbol to verify the library is loaded
    if let _ = dlsym(dlopen(nil, RTLD_LAZY), "WalletInit") {
      print("ArculusSdkPlugin: CSDK symbols found in process")
    } else {
      print("ArculusSdkPlugin: Warning - CSDK symbols not found in process")
      print("ArculusSdkPlugin: This may cause FFI symbol lookup failures")
    }
    
    print("ArculusSdkPlugin: CSDK XCFramework registration complete")
  }
} 