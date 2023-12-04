#import "UpdateCheckerPlugin.h"
#if __has_include(<update_checker/update_checker-Swift.h>)
#import <update_checker/update_checker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "update_checker-Swift.h"
#endif

@implementation UpdateCheckerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUpdateCheckerPlugin registerWithRegistrar:registrar];
}
@end
