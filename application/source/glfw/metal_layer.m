#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

CAMetalLayer* setupMetalLayer(void* window) {
    NSWindow* ns_window = (__bridge NSWindow*)window;

    CAMetalLayer* metal_layer = [CAMetalLayer layer];

    [ns_window.contentView setWantsLayer: YES];
    [ns_window.contentView setLayer: metal_layer];

    return metal_layer;
}
