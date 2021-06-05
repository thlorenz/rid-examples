#import "Plugin.h"
#if __has_include(<plugin/plugin-Swift.h>)
#import <plugin/plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "plugin-Swift.h"
#endif

@implementation Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPlugin registerWithRegistrar:registrar];
}
@end
