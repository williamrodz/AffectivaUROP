//
//  NSImage+Extensions.h
//  AffdexMe
//
//  Created by Boisy Pitre on 3/18/16.
//  Copyright (c) 2017 Affectiva Inc.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Extensions)

+ (NSImage *)imageFromText:(NSString *)text size:(CGFloat)size;
+ (NSImage *)imageFromView:(NSView *)view;

@end
