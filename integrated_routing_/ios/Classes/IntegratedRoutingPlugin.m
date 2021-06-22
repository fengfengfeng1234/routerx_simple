#import "IntegratedRoutingPlugin.h"
#if __has_include(<integrated_routing/integrated_routing-Swift.h>)
#import <integrated_routing/integrated_routing-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "integrated_routing-Swift.h"
#endif

@implementation IntegratedRoutingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIntegratedRoutingPlugin registerWithRegistrar:registrar];
}
@end
