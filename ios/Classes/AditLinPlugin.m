#import "AditLinPlugin.h"
#if __has_include(<adit_lin_plugin/adit_lin_plugin-Swift.h>)
#import <adit_lin_plugin/adit_lin_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "adit_lin_plugin-Swift.h"
#endif

@implementation AditLinPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSLog(@"Channel called");
  [SwiftAditLinPlugin registerWithRegistrar:registrar];
}
@end
