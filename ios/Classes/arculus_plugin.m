#import "arculus_plugin.h"

@implementation ArculusPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"arculus_plugin" binaryMessenger:[registrar messenger]];
  ArculusPlugin* instance = [[ArculusPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"walletInit" isEqualToString:call.method]) {
    AppletObj *wallet = WalletInit();
    result(@((uintptr_t)wallet)); // Send pointer as int
  } 
  else if ([@"walletFree" isEqualToString:call.method]) {
    uintptr_t ptr = [call.arguments[@"walletPtr"] unsignedLongValue];
    int status = WalletFree((AppletObj *)ptr);
    result(@(status));
  } 
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
